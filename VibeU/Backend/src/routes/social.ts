import { Router } from 'express';
import { prisma } from '../lib/prisma';
import { enforceAgeGroup } from '../middleware/auth';
import { actionRateLimiter, cooldownChecker } from '../middleware/rateLimit';
import { AppError } from '../middleware/errorHandler';

export const socialRouter = Router();

// Like a user
// Requirements 4.1: Like WITHOUT sending any notification to the target user
// Requirements 4.2, 4.3: Age group validation via enforceAgeGroup middleware
// Cross-pool likes are rejected with 403 "Yaş grubu sebebiyle işlem yapılamıyor."
// IMPORTANT: Do NOT create notifications for likes - this is intentional per requirements
socialRouter.post(
  '/likes',
  enforceAgeGroup('target_user_id'),
  actionRateLimiter('like'),
  async (req, res, next) => {
    try {
      const userId = req.user!.id;
      const { target_user_id } = req.body;

      if (!target_user_id) {
        throw new AppError('Target user ID required', 400, 'TARGET_REQUIRED');
      }

      // Check if already liked
      const existingLike = await prisma.like.findUnique({
        where: {
          fromUserId_toUserId: {
            fromUserId: userId,
            toUserId: target_user_id,
          },
        },
      });

      if (existingLike) {
        throw new AppError('Already liked', 400, 'ALREADY_LIKED');
      }

      // Create like
      await prisma.like.create({
        data: {
          fromUserId: userId,
          toUserId: target_user_id,
        },
      });

      // Get remaining likes for free users
      const isPremium = req.user!.isPremium;
      let remainingLikes: number | undefined;

      if (!isPremium) {
        const today = new Date();
        const windowStart = new Date(today.getFullYear(), today.getMonth(), today.getDate());

        const rateLimit = await prisma.rateLimit.findFirst({
          where: {
            visitorId: userId,
            actionType: 'like',
            windowStart,
          },
        });

        remainingLikes = 100 - (rateLimit?.count || 0);
      }

      res.json({
        success: true,
        remaining_likes: remainingLikes,
      });
    } catch (error) {
      next(error);
    }
  }
);

// Get received likes (Premium only)
socialRouter.get('/likes/received', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const isPremium = req.user!.isPremium;

    if (!isPremium) {
      throw new AppError('Premium required', 403, 'PREMIUM_REQUIRED');
    }

    const likes = await prisma.like.findMany({
      where: { toUserId: userId },
      include: {
        fromUser: {
          select: {
            id: true,
            displayName: true,
            profilePhotoUrl: true,
            city: true,
            dateOfBirth: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    res.json({
      users: likes.map(like => ({
        id: like.id,
        user: {
          id: like.fromUser.id,
          display_name: like.fromUser.displayName,
          profile_photo_url: like.fromUser.profilePhotoUrl,
          city: like.fromUser.city,
        },
        created_at: like.createdAt.toISOString(),
      })),
      total_count: likes.length,
    });
  } catch (error) {
    next(error);
  }
});

// Send request (Sosyal Medya İsteği)
// Requirements 5.2, 5.3: Age group validation before sending request
// Cross-pool requests are rejected with 403 "Yaş grubu sebebiyle işlem yapılamıyor."
socialRouter.post(
  '/',
  enforceAgeGroup('target_user_id'),
  actionRateLimiter('request'),
  cooldownChecker('request'),
  async (req, res, next) => {
    try {
      console.log('📨 FRIEND REQUEST RECEIVED:', req.body);
      const userId = req.user!.id;
      const { target_user_id } = req.body;
      console.log(`📨 From: ${userId} To: ${target_user_id}`);

      if (!target_user_id) {
        throw new AppError('Target user ID required', 400, 'TARGET_REQUIRED');
      }

      // Check existing request
      const existingRequest = await prisma.request.findUnique({
        where: {
          fromUserId_toUserId: {
            fromUserId: userId,
            toUserId: target_user_id,
          },
        },
      });

      if (existingRequest) {
        throw new AppError('Request already sent', 400, 'REQUEST_EXISTS');
      }

      // Create request
      const request = await prisma.request.create({
        data: {
          fromUserId: userId,
          toUserId: target_user_id,
        },
      });

      // Create notification
      await prisma.notification.create({
        data: {
          userId: target_user_id,
          type: 'request_received',
          titleKey: 'notification_request_title',
          bodyKey: 'notification_request_body',
          data: JSON.stringify({
            request_id: request.id,
            from_user_id: userId,
          }),
        },
      });

      res.json({
        success: true,
        request_id: request.id,
      });
    } catch (error) {
      next(error);
    }
  }
);

// Get received requests
socialRouter.get('/received', async (req, res, next) => {
  try {
    const userId = req.user!.id;

    const requests = await prisma.request.findMany({
      where: {
        toUserId: userId,
        status: 'pending',
      },
      include: {
        fromUser: {
          select: {
            id: true,
            displayName: true,
            profilePhotoUrl: true,
            city: true,
            dateOfBirth: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    res.json({
      requests: requests.map(req => ({
        id: req.id,
        from_user: {
          id: req.fromUser.id,
          display_name: req.fromUser.displayName,
          profile_photo_url: req.fromUser.profilePhotoUrl,
          city: req.fromUser.city,
        },
        status: req.status,
        created_at: req.createdAt.toISOString(),
      })),
    });
  } catch (error) {
    next(error);
  }
});

// Get sent requests
socialRouter.get('/sent', async (req, res, next) => {
  try {
    const userId = req.user!.id;

    const requests = await prisma.request.findMany({
      where: { fromUserId: userId },
      include: {
        toUser: {
          select: {
            id: true,
            displayName: true,
            profilePhotoUrl: true,
            city: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    res.json({
      requests: requests.map(req => ({
        id: req.id,
        to_user: {
          id: req.toUser.id,
          display_name: req.toUser.displayName,
          profile_photo_url: req.toUser.profilePhotoUrl,
        },
        status: req.status,
        created_at: req.createdAt.toISOString(),
      })),
    });
  } catch (error) {
    next(error);
  }
});

// Accept request - Creates bidirectional friendship
// Requirements 5.4: When a request is accepted, create a bidirectional friendship record
// The friendship is stored once with normalized user IDs (sorted) to ensure uniqueness
// Both users can query this friendship from either direction
socialRouter.put('/:id/accept', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const requestId = req.params.id;

    const request = await prisma.request.findUnique({
      where: { id: requestId },
      include: {
        fromUser: {
          select: {
            id: true,
            displayName: true,
            profilePhotoUrl: true,
            tiktokUsername: true,
            instagramUsername: true,
            snapchatUsername: true,
            lastActiveAt: true,
          },
        },
      },
    });

    if (!request) {
      throw new AppError('Request not found', 404, 'REQUEST_NOT_FOUND');
    }

    if (request.toUserId !== userId) {
      throw new AppError('Not authorized', 403, 'NOT_AUTHORIZED');
    }

    if (request.status !== 'pending') {
      throw new AppError('Request already processed', 400, 'REQUEST_PROCESSED');
    }

    // Update request
    await prisma.request.update({
      where: { id: requestId },
      data: {
        status: 'accepted',
        respondedAt: new Date(),
      },
    });

    // Create bidirectional friendship (ensure userA < userB for uniqueness)
    // This single record represents the friendship in both directions
    // Requirements 5.4: Bidirectional friendship creation
    const [userAId, userBId] = [request.fromUserId, request.toUserId].sort();

    const friendship = await prisma.friendship.create({
      data: {
        userAId,
        userBId,
      },
    });

    // Create notification for requester
    await prisma.notification.create({
      data: {
        userId: request.fromUserId,
        type: 'request_accepted',
        titleKey: 'notification_accepted_title',
        bodyKey: 'notification_accepted_body',
        data: JSON.stringify({
          friendship_id: friendship.id,
        }),
      },
    });

    // Build social links
    const socialLinks: any = {};
    if (request.fromUser.tiktokUsername) {
      socialLinks.tiktok = {
        username: request.fromUser.tiktokUsername,
        deeplink: `tiktok://user/@${request.fromUser.tiktokUsername}`,
        web_url: `https://tiktok.com/@${request.fromUser.tiktokUsername}`,
      };
    }
    if (request.fromUser.instagramUsername) {
      socialLinks.instagram = {
        username: request.fromUser.instagramUsername,
        deeplink: `instagram://user?username=${request.fromUser.instagramUsername}`,
        web_url: `https://instagram.com/${request.fromUser.instagramUsername}`,
      };
    }
    if (request.fromUser.snapchatUsername) {
      socialLinks.snapchat = {
        username: request.fromUser.snapchatUsername,
        deeplink: `snapchat://add/${request.fromUser.snapchatUsername}`,
        web_url: `https://snapchat.com/add/${request.fromUser.snapchatUsername}`,
      };
    }

    res.json({
      success: true,
      friendship_id: friendship.id,
      friend: {
        id: request.fromUser.id,
        display_name: request.fromUser.displayName,
        profile_photo_url: request.fromUser.profilePhotoUrl,
        social_links: Object.keys(socialLinks).length > 0 ? socialLinks : null,
        last_active_at: request.fromUser.lastActiveAt.toISOString(),
      },
    });
  } catch (error) {
    next(error);
  }
});

// Accept request also works via POST for compatibility
// (Duplicated from PUT handler above)

// Reject request
socialRouter.post('/:id/reject', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const requestId = req.params.id;

    const request = await prisma.request.findUnique({
      where: { id: requestId },
    });

    if (!request) {
      throw new AppError('Request not found', 404, 'REQUEST_NOT_FOUND');
    }

    if (request.toUserId !== userId) {
      throw new AppError('Not authorized', 403, 'NOT_AUTHORIZED');
    }

    // Update request
    await prisma.request.update({
      where: { id: requestId },
      data: {
        status: 'rejected',
        respondedAt: new Date(),
      },
    });

    // Create cooldown (7 days)
    await prisma.cooldown.create({
      data: {
        userId: request.fromUserId,
        targetUserId: userId,
        actionType: 'request',
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      },
    });

    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

// Get friends
socialRouter.get('/friends', async (req, res, next) => {
  try {
    const userId = req.user!.id;

    const friendships = await prisma.friendship.findMany({
      where: {
        OR: [
          { userAId: userId },
          { userBId: userId },
        ],
      },
      include: {
        userA: {
          select: {
            id: true,
            displayName: true,
            profilePhotoUrl: true,
            tiktokUsername: true,
            instagramUsername: true,
            snapchatUsername: true,
            lastActiveAt: true,
          },
        },
        userB: {
          select: {
            id: true,
            displayName: true,
            profilePhotoUrl: true,
            tiktokUsername: true,
            instagramUsername: true,
            snapchatUsername: true,
            lastActiveAt: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    const friends = friendships.map(f => {
      const friend = f.userAId === userId ? f.userB : f.userA;

      const socialLinks: any = {};
      if (friend.tiktokUsername) {
        socialLinks.tiktok = {
          username: friend.tiktokUsername,
          deeplink: `tiktok://user/@${friend.tiktokUsername}`,
          web_url: `https://tiktok.com/@${friend.tiktokUsername}`,
        };
      }
      if (friend.instagramUsername) {
        socialLinks.instagram = {
          username: friend.instagramUsername,
          deeplink: `instagram://user?username=${friend.instagramUsername}`,
          web_url: `https://instagram.com/${friend.instagramUsername}`,
        };
      }
      if (friend.snapchatUsername) {
        socialLinks.snapchat = {
          username: friend.snapchatUsername,
          deeplink: `snapchat://add/${friend.snapchatUsername}`,
          web_url: `https://snapchat.com/add/${friend.snapchatUsername}`,
        };
      }

      return {
        id: f.id,
        friend: {
          id: friend.id,
          display_name: friend.displayName,
          profile_photo_url: friend.profilePhotoUrl,
          social_links: Object.keys(socialLinks).length > 0 ? socialLinks : null,
          last_active_at: friend.lastActiveAt.toISOString(),
        },
        created_at: f.createdAt.toISOString(),
      };
    });

    res.json({ friends });
  } catch (error) {
    next(error);
  }
});

// Remove friend
socialRouter.delete('/friends/:id', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const friendshipId = req.params.id;

    const friendship = await prisma.friendship.findUnique({
      where: { id: friendshipId },
    });

    if (!friendship) {
      throw new AppError('Friendship not found', 404, 'FRIENDSHIP_NOT_FOUND');
    }

    if (friendship.userAId !== userId && friendship.userBId !== userId) {
      throw new AppError('Not authorized', 403, 'NOT_AUTHORIZED');
    }

    await prisma.friendship.delete({
      where: { id: friendshipId },
    });

    // Create cooldown for re-request (30 days)
    const otherUserId = friendship.userAId === userId ? friendship.userBId : friendship.userAId;

    await prisma.cooldown.create({
      data: {
        userId,
        targetUserId: otherUserId,
        actionType: 'request',
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      },
    });

    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

// Skip user
socialRouter.post('/skip', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const { user_id } = req.body;

    if (!user_id) {
      throw new AppError('User ID required', 400, 'USER_ID_REQUIRED');
    }

    await prisma.skippedUser.upsert({
      where: {
        userId_skippedUserId: {
          userId,
          skippedUserId: user_id,
        },
      },
      create: {
        userId,
        skippedUserId: user_id,
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
      },
      update: {
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
      },
    });

    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

// Favorites
socialRouter.post('/favorites', enforceAgeGroup('user_id'), async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const { user_id } = req.body;

    const favorite = await prisma.favorite.create({
      data: {
        userId,
        favoritedUserId: user_id,
      },
    });

    res.json({
      success: true,
      favorite_id: favorite.id,
    });
  } catch (error) {
    next(error);
  }
});

socialRouter.get('/favorites', async (req, res, next) => {
  try {
    const userId = req.user!.id;

    const favorites = await prisma.favorite.findMany({
      where: { userId },
      include: {
        favoritedUser: {
          include: {
            photos: { orderBy: { orderIndex: 'asc' } },
            tags: { orderBy: { orderIndex: 'asc' } },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    res.json({
      favorites: favorites.map(f => ({
        id: f.id,
        user: {
          id: f.favoritedUser.id,
          display_name: f.favoritedUser.displayName,
          profile_photo_url: f.favoritedUser.profilePhotoUrl,
          city: f.favoritedUser.city,
        },
        created_at: f.createdAt.toISOString(),
      })),
    });
  } catch (error) {
    next(error);
  }
});

socialRouter.delete('/favorites/:id', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const favoriteId = req.params.id;

    await prisma.favorite.deleteMany({
      where: {
        id: favoriteId,
        userId,
      },
    });

    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

// Report user
socialRouter.post('/reports', actionRateLimiter('report'), async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const { user_id, reason, description } = req.body;

    if (!user_id || !reason) {
      throw new AppError('User ID and reason required', 400, 'MISSING_FIELDS');
    }

    const report = await prisma.report.create({
      data: {
        reporterId: userId,
        reportedUserId: user_id,
        reason,
        description,
      },
    });

    res.json({
      success: true,
      report_id: report.id,
    });
  } catch (error) {
    next(error);
  }
});
