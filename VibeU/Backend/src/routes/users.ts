import { Router } from 'express';
import { prisma } from '../lib/prisma';
import { calculateAge, getAgeGroup } from '../utils/age';
import { AppError } from '../middleware/errorHandler';

export const userRouter = Router();

// Get current user
userRouter.get('/me', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        photos: { orderBy: { orderIndex: 'asc' } },
        tags: { orderBy: { orderIndex: 'asc' } },
        interests: { include: { interest: true } },
      },
    });
    
    if (!user) {
      throw new AppError('User not found', 404, 'USER_NOT_FOUND');
    }
    
    const age = calculateAge(user.dateOfBirth);
    const ageGroup = getAgeGroup(age);
    
    res.json(formatUser(user, age, ageGroup));
  } catch (error) {
    next(error);
  }
});

// Update profile
userRouter.put('/me', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const { display_name, bio, city } = req.body;
    
    const user = await prisma.user.update({
      where: { id: userId },
      data: {
        ...(display_name && { displayName: display_name }),
        ...(bio !== undefined && { bio }),
        ...(city && { city }),
      },
      include: {
        photos: { orderBy: { orderIndex: 'asc' } },
        tags: { orderBy: { orderIndex: 'asc' } },
        interests: { include: { interest: true } },
      },
    });
    
    const age = calculateAge(user.dateOfBirth);
    const ageGroup = getAgeGroup(age);
    
    res.json({
      success: true,
      user: formatUser(user, age, ageGroup),
    });
  } catch (error) {
    next(error);
  }
});

// Update tags
userRouter.put('/me/tags', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const { tags } = req.body;
    
    if (!Array.isArray(tags) || tags.length > 5) {
      throw new AppError('Invalid tags', 400, 'INVALID_TAGS');
    }
    
    // Delete existing tags
    await prisma.userTag.deleteMany({
      where: { userId },
    });
    
    // Create new tags
    await prisma.userTag.createMany({
      data: tags.map((tag: string, index: number) => ({
        userId,
        tagCode: tag,
        orderIndex: index,
      })),
    });
    
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

// Update interests
userRouter.put('/me/interests', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const { interest_ids } = req.body;
    
    if (!Array.isArray(interest_ids)) {
      throw new AppError('Invalid interests', 400, 'INVALID_INTERESTS');
    }
    
    // Delete existing interests
    await prisma.userInterest.deleteMany({
      where: { userId },
    });
    
    // Create new interests
    await prisma.userInterest.createMany({
      data: interest_ids.map((interestId: string) => ({
        userId,
        interestId,
      })),
    });
    
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

// Update social links
userRouter.put('/me/social-links', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const { tiktok_username, instagram_username, snapchat_username } = req.body;
    
    await prisma.user.update({
      where: { id: userId },
      data: {
        tiktokUsername: tiktok_username || null,
        instagramUsername: instagram_username || null,
        snapchatUsername: snapchat_username || null,
      },
    });
    
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

// Update location
userRouter.put('/me/location', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const { latitude, longitude } = req.body;
    
    await prisma.user.update({
      where: { id: userId },
      data: {
        latitude,
        longitude,
      },
    });
    
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

// Get QR code data
userRouter.get('/me/qr-code', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    
    res.json({
      qr_data: `vibeu://profile/${userId}`,
      qr_image_url: `https://cdn.vibeu.app/qr/${userId}.png`,
    });
  } catch (error) {
    next(error);
  }
});

// Get user profile by ID (for QR scan)
userRouter.get('/profile/:userId', async (req, res, next) => {
  try {
    const currentUserId = req.user!.id;
    const currentAgeGroup = req.user!.ageGroup;
    const targetUserId = req.params.userId;
    
    const targetUser = await prisma.user.findUnique({
      where: { id: targetUserId },
      include: {
        photos: { orderBy: { orderIndex: 'asc' } },
        tags: { orderBy: { orderIndex: 'asc' } },
        interests: { include: { interest: true } },
      },
    });
    
    if (!targetUser) {
      throw new AppError('User not found', 404, 'USER_NOT_FOUND');
    }
    
    // CRITICAL: Age group check
    const targetAge = calculateAge(targetUser.dateOfBirth);
    const targetAgeGroup = getAgeGroup(targetAge);
    
    if (currentAgeGroup !== targetAgeGroup) {
      throw new AppError('Age group mismatch', 403, 'AGE_GROUP_MISMATCH');
    }
    
    // Get current user interests for common interests
    const currentUser = await prisma.user.findUnique({
      where: { id: currentUserId },
      include: { interests: true },
    });
    
    const currentInterestIds = currentUser?.interests.map(i => i.interestId) || [];
    const targetInterestIds = targetUser.interests.map(i => i.interestId);
    const commonInterestIds = currentInterestIds.filter(id => targetInterestIds.includes(id));
    
    const commonInterests = await prisma.interest.findMany({
      where: { id: { in: commonInterestIds } },
      select: { nameEn: true },
    });
    
    res.json({
      id: targetUser.id,
      display_name: targetUser.displayName,
      age: targetAge,
      city: targetUser.city,
      profile_photo_url: targetUser.profilePhotoUrl,
      photos: targetUser.photos.map(p => ({
        id: p.id,
        url: p.url,
        thumbnail_url: p.thumbnailUrl,
        order_index: p.orderIndex,
        is_primary: p.isPrimary,
      })),
      tags: targetUser.tags.map(t => t.tagCode),
      common_interests: commonInterests.map(i => i.nameEn),
    });
  } catch (error) {
    next(error);
  }
});

// Get available interests
userRouter.get('/interests', async (req, res, next) => {
  try {
    const interests = await prisma.interest.findMany({
      orderBy: { category: 'asc' },
    });
    
    res.json({
      interests: interests.map(i => ({
        id: i.id,
        code: i.code,
        name: i.nameEn,
        emoji: i.emoji,
        category: i.category,
      })),
    });
  } catch (error) {
    next(error);
  }
});

// Delete account
userRouter.delete('/me', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const { confirmation } = req.body;
    
    if (confirmation !== 'DELETE') {
      throw new AppError('Confirmation required', 400, 'CONFIRMATION_REQUIRED');
    }
    
    // Soft delete - mark as banned with deletion reason
    await prisma.user.update({
      where: { id: userId },
      data: {
        isBanned: true,
        banReason: 'Account deleted by user',
      },
    });
    
    // TODO: Schedule permanent deletion after 30 days
    
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

// Helper function
function formatUser(user: any, age: number, ageGroup: string) {
  return {
    id: user.id,
    username: user.username,
    display_name: user.displayName,
    date_of_birth: user.dateOfBirth.toISOString(),
    age,
    age_group: ageGroup,
    gender: user.gender,
    country: user.country,
    city: user.city,
    bio: user.bio,
    profile_photo_url: user.profilePhotoUrl,
    photos: user.photos.map((p: any) => ({
      id: p.id,
      url: p.url,
      thumbnail_url: p.thumbnailUrl,
      order_index: p.orderIndex,
      is_primary: p.isPrimary,
    })),
    tags: user.tags.map((t: any) => t.tagCode),
    interests: user.interests.map((ui: any) => ({
      id: ui.interest.id,
      code: ui.interest.code,
      name: ui.interest.nameEn,
      emoji: ui.interest.emoji,
      category: ui.interest.category,
    })),
    is_premium: user.isPremium,
    premium_expires_at: user.premiumExpiresAt?.toISOString(),
    is_verified: user.isVerified,
    social_links: null,
    last_active_at: user.lastActiveAt.toISOString(),
    created_at: user.createdAt.toISOString(),
  };
}
