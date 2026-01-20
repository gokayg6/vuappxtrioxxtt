import { Router } from 'express';
import { prisma } from '../lib/prisma';
import { AppError } from '../middleware/errorHandler';
import { calculateAge } from '../utils/age';

export const friendsRouter = Router();

/**
 * Check if a user is online (active within last 24 hours)
 */
function isOnline(lastActiveAt: Date): boolean {
  const now = new Date();
  const hoursDiff = (now.getTime() - lastActiveAt.getTime()) / (1000 * 60 * 60);
  return hoursDiff < 24;
}

/**
 * Build social links object for a friend
 */
function buildSocialLinks(friend: {
  tiktokUsername: string | null;
  instagramUsername: string | null;
  snapchatUsername: string | null;
}) {
  const socialLinks: Record<string, {
    username: string;
    deeplink: string;
    web_url: string;
  }> = {};

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

  return Object.keys(socialLinks).length > 0 ? socialLinks : null;
}

/**
 * GET /friends
 * Returns all friends for the authenticated user
 * Includes social media info, age, city, and online status
 * Requirements: 8.4, 5.5
 */
friendsRouter.get('/', async (req, res, next) => {
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
            dateOfBirth: true,
            city: true,
            profilePhotoUrl: true,
            lastActiveAt: true,
            tiktokUsername: true,
            instagramUsername: true,
            snapchatUsername: true,
          },
        },
        userB: {
          select: {
            id: true,
            displayName: true,
            dateOfBirth: true,
            city: true,
            profilePhotoUrl: true,
            lastActiveAt: true,
            tiktokUsername: true,
            instagramUsername: true,
            snapchatUsername: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    const friends = friendships.map((f) => {
      const friend = f.userAId === userId ? f.userB : f.userA;
      const age = calculateAge(friend.dateOfBirth);

      return {
        id: friend.id,
        displayName: friend.displayName,
        age,
        city: friend.city,
        profilePhotoURL: friend.profilePhotoUrl,
        isOnline: isOnline(friend.lastActiveAt),
        lastActiveAt: friend.lastActiveAt.toISOString(),
        tiktokUsername: friend.tiktokUsername,
        instagramUsername: friend.instagramUsername,
        snapchatUsername: friend.snapchatUsername,
        socialLinks: buildSocialLinks(friend),
        friendshipId: f.id,
        friendshipCreatedAt: f.createdAt.toISOString(),
      };
    });

    res.json({ friends });
  } catch (error) {
    next(error);
  }
});

/**
 * DELETE /friends/:friendId
 * Removes a friendship bidirectionally
 * Requirements: 8.7
 */
friendsRouter.delete('/:friendId', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const { friendId } = req.params;

    // Find and delete friendship in both directions
    const deleted = await prisma.friendship.deleteMany({
      where: {
        OR: [
          { userAId: userId, userBId: friendId },
          { userAId: friendId, userBId: userId },
        ],
      },
    });

    if (deleted.count === 0) {
      throw new AppError('Friendship not found', 404, 'FRIENDSHIP_NOT_FOUND');
    }

    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});
