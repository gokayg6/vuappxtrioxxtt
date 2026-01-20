import { Router } from 'express';
import { prisma } from '../lib/prisma';
import { calculateAge, getAgeGroup } from '../utils/age';
import { calculateDiscoverScore, getCommonInterests } from '../utils/score';
import { AppError } from '../middleware/errorHandler';

export const discoverRouter = Router();

// Get discover feed
discoverRouter.get('/', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const userAgeGroup = req.user!.ageGroup;
    const mode = (req.query.mode as 'local' | 'global') || 'local';
    const cursor = req.query.cursor as string | undefined;
    const limit = Math.min(parseInt(req.query.limit as string) || 20, 50);
    
    // Get current user data
    const currentUser = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        interests: true,
      },
    });
    
    if (!currentUser) {
      throw new AppError('User not found', 404, 'USER_NOT_FOUND');
    }
    
    const currentUserAge = calculateAge(currentUser.dateOfBirth);
    const currentUserInterestIds = currentUser.interests.map(i => i.interestId);
    
    // Get liked and skipped user IDs
    const [likedUserIds, skippedUserIds] = await Promise.all([
      prisma.like.findMany({
        where: { fromUserId: userId },
        select: { toUserId: true },
      }).then(likes => likes.map(l => l.toUserId)),
      
      prisma.skippedUser.findMany({
        where: {
          userId,
          expiresAt: { gt: new Date() },
        },
        select: { skippedUserId: true },
      }).then(skips => skips.map(s => s.skippedUserId)),
    ]);
    
    const excludeUserIds = [userId, ...likedUserIds, ...skippedUserIds];
    
    // Build query
    const whereClause: any = {
      id: { notIn: excludeUserIds },
      isBanned: false,
    };
    
    // CRITICAL: Age group filter
    // We need to filter by calculated age group
    // Since age_group is computed, we filter by date range
    const today = new Date();
    const eighteenYearsAgo = new Date(
      today.getFullYear() - 18,
      today.getMonth(),
      today.getDate()
    );
    
    if (userAgeGroup === 'minor') {
      // Minor: 15-17 years old (Requirements: 12.1)
      // Born between 17 years ago and 15 years ago
      const fifteenYearsAgo = new Date(
        today.getFullYear() - 15,
        today.getMonth(),
        today.getDate()
      );
      const seventeenYearsAgo = new Date(
        today.getFullYear() - 17,
        today.getMonth(),
        today.getDate()
      );
      
      whereClause.dateOfBirth = {
        gte: seventeenYearsAgo,
        lte: fifteenYearsAgo,
      };
    } else {
      // Adult: 18+ years old
      // Born before 18 years ago
      whereClause.dateOfBirth = {
        lt: eighteenYearsAgo,
      };
    }
    
    // Local mode: same country
    if (mode === 'local') {
      whereClause.country = currentUser.country;
    }
    
    // Fetch users
    const users = await prisma.user.findMany({
      where: whereClause,
      include: {
        photos: { orderBy: { orderIndex: 'asc' } },
        tags: { orderBy: { orderIndex: 'asc' } },
        interests: true,
      },
      take: limit + 1, // +1 to check if there are more
      ...(cursor && {
        cursor: { id: cursor },
        skip: 1,
      }),
    });
    
    const hasMore = users.length > limit;
    const resultUsers = hasMore ? users.slice(0, -1) : users;
    
    // Calculate scores and format response
    const scoredUsers = await Promise.all(
      resultUsers.map(async (user) => {
        const age = calculateAge(user.dateOfBirth);
        const score = await calculateDiscoverScore(
          userId,
          currentUserAge,
          currentUser.city,
          currentUserInterestIds,
          {
            id: user.id,
            age,
            city: user.city,
            country: user.country,
            lastActiveAt: user.lastActiveAt,
            photos: user.photos,
            tags: user.tags,
            interests: user.interests,
            bio: user.bio,
            isVerified: user.isVerified,
          },
          mode
        );
        
        const userInterestIds = user.interests.map(i => i.interestId);
        const commonInterestIds = getCommonInterests(
          currentUserInterestIds,
          userInterestIds
        );
        
        // Get common interest names
        const commonInterests = await prisma.interest.findMany({
          where: { id: { in: commonInterestIds } },
          select: { nameEn: true },
        });
        
        // Check if boosted
        const activeBoost = await prisma.boost.findFirst({
          where: {
            userId: user.id,
            isActive: true,
            expiresAt: { gt: new Date() },
          },
        });
        
        return {
          id: user.id,
          display_name: user.displayName,
          age,
          city: user.city,
          country: mode === 'global' ? user.country : undefined,
          country_flag: mode === 'global' ? getCountryFlag(user.country) : undefined,
          distance_km: mode === 'local' ? calculateDistance(
            currentUser.latitude,
            currentUser.longitude,
            user.latitude,
            user.longitude
          ) : undefined,
          profile_photo_url: user.profilePhotoUrl,
          photos: user.photos.map(p => ({
            id: p.id,
            url: p.url,
            thumbnail_url: p.thumbnailUrl,
            order_index: p.orderIndex,
            is_primary: p.isPrimary,
          })),
          tags: user.tags.map(t => t.tagCode),
          common_interests: commonInterests.map(i => i.nameEn),
          score,
          is_boosted: !!activeBoost,
        };
      })
    );
    
    // Sort by score
    scoredUsers.sort((a, b) => b.score - a.score);
    
    res.json({
      users: scoredUsers,
      next_cursor: hasMore ? resultUsers[resultUsers.length - 1].id : null,
      has_more: hasMore,
    });
  } catch (error) {
    next(error);
  }
});

// Get trending users
discoverRouter.get('/trending', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const userAgeGroup = req.user!.ageGroup;
    const mode = (req.query.mode as 'local' | 'global') || 'local';
    
    const currentUser = await prisma.user.findUnique({
      where: { id: userId },
    });
    
    if (!currentUser) {
      throw new AppError('User not found', 404, 'USER_NOT_FOUND');
    }
    
    // Get users with most likes in last 24 hours
    const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
    
    const today = new Date();
    const eighteenYearsAgo = new Date(
      today.getFullYear() - 18,
      today.getMonth(),
      today.getDate()
    );
    
    // CRITICAL: Age group filter (Requirements: 12.7)
    // Minor: 15-17 years old, Adult: 18+ years old
    const dateFilter = userAgeGroup === 'minor'
      ? {
          gte: new Date(today.getFullYear() - 17, today.getMonth(), today.getDate()),
          lte: new Date(today.getFullYear() - 15, today.getMonth(), today.getDate()),
        }
      : { lt: eighteenYearsAgo };
    
    const trendingUsers = await prisma.user.findMany({
      where: {
        id: { not: userId },
        isBanned: false,
        dateOfBirth: dateFilter,
        ...(mode === 'local' && { country: currentUser.country }),
        receivedLikes: {
          some: {
            createdAt: { gte: oneDayAgo },
          },
        },
      },
      include: {
        photos: { orderBy: { orderIndex: 'asc' } },
        tags: { orderBy: { orderIndex: 'asc' } },
        _count: {
          select: {
            receivedLikes: {
              where: { createdAt: { gte: oneDayAgo } },
            },
          },
        },
      },
      orderBy: {
        receivedLikes: { _count: 'desc' },
      },
      take: 10,
    });
    
    const formattedUsers = trendingUsers.map(user => {
      const age = calculateAge(user.dateOfBirth);
      return {
        id: user.id,
        display_name: user.displayName,
        age,
        city: user.city,
        country: mode === 'global' ? user.country : undefined,
        country_flag: mode === 'global' ? getCountryFlag(user.country) : undefined,
        profile_photo_url: user.profilePhotoUrl,
        photos: user.photos.map(p => ({
          id: p.id,
          url: p.url,
          thumbnail_url: p.thumbnailUrl,
          order_index: p.orderIndex,
          is_primary: p.isPrimary,
        })),
        tags: user.tags.map(t => t.tagCode),
        common_interests: [],
        score: 0,
        is_boosted: false,
      };
    });
    
    res.json({ users: formattedUsers });
  } catch (error) {
    next(error);
  }
});

// Get spotlight users
discoverRouter.get('/spotlight', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const userAgeGroup = req.user!.ageGroup;
    const mode = (req.query.mode as 'local' | 'global') || 'local';
    
    const currentUser = await prisma.user.findUnique({
      where: { id: userId },
    });
    
    if (!currentUser) {
      throw new AppError('User not found', 404, 'USER_NOT_FOUND');
    }
    
    const today = new Date();
    const eighteenYearsAgo = new Date(
      today.getFullYear() - 18,
      today.getMonth(),
      today.getDate()
    );
    
    // CRITICAL: Age group filter (Requirements: 12.7)
    // Minor: 15-17 years old, Adult: 18+ years old
    const dateFilter = userAgeGroup === 'minor'
      ? {
          gte: new Date(today.getFullYear() - 17, today.getMonth(), today.getDate()),
          lte: new Date(today.getFullYear() - 15, today.getMonth(), today.getDate()),
        }
      : { lt: eighteenYearsAgo };
    
    // Get boosted users or high-quality profiles
    const spotlightUsers = await prisma.user.findMany({
      where: {
        id: { not: userId },
        isBanned: false,
        dateOfBirth: dateFilter,
        ...(mode === 'local' && { country: currentUser.country }),
        OR: [
          {
            boosts: {
              some: {
                isActive: true,
                expiresAt: { gt: new Date() },
              },
            },
          },
          {
            isVerified: true,
          },
          {
            photos: { some: {} },
          },
        ],
      },
      include: {
        photos: { orderBy: { orderIndex: 'asc' } },
        tags: { orderBy: { orderIndex: 'asc' } },
        boosts: {
          where: {
            isActive: true,
            expiresAt: { gt: new Date() },
          },
        },
      },
      orderBy: { lastActiveAt: 'desc' },
      take: 10,
    });
    
    const formattedUsers = spotlightUsers.map(user => {
      const age = calculateAge(user.dateOfBirth);
      return {
        id: user.id,
        display_name: user.displayName,
        age,
        city: user.city,
        country: mode === 'global' ? user.country : undefined,
        country_flag: mode === 'global' ? getCountryFlag(user.country) : undefined,
        profile_photo_url: user.profilePhotoUrl,
        photos: user.photos.map(p => ({
          id: p.id,
          url: p.url,
          thumbnail_url: p.thumbnailUrl,
          order_index: p.orderIndex,
          is_primary: p.isPrimary,
        })),
        tags: user.tags.map(t => t.tagCode),
        common_interests: [],
        score: 0,
        is_boosted: user.boosts.length > 0,
      };
    });
    
    res.json({ users: formattedUsers });
  } catch (error) {
    next(error);
  }
});

// Helper functions
function getCountryFlag(country: string): string {
  const flags: Record<string, string> = {
    'Turkey': '🇹🇷',
    'United States': '🇺🇸',
    'United Kingdom': '🇬🇧',
    'Germany': '🇩🇪',
    'France': '🇫🇷',
    'Spain': '🇪🇸',
    'Brazil': '🇧🇷',
    'Mexico': '🇲🇽',
    'Italy': '🇮🇹',
    'Canada': '🇨🇦',
  };
  return flags[country] || '🌍';
}

function calculateDistance(
  lat1: number | null,
  lon1: number | null,
  lat2: number | null,
  lon2: number | null
): number | undefined {
  if (!lat1 || !lon1 || !lat2 || !lon2) return undefined;
  
  const R = 6371; // Earth's radius in km
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return Math.round(R * c * 10) / 10;
}

function toRad(deg: number): number {
  return deg * (Math.PI / 180);
}
