import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { prisma } from '../lib/prisma';
import { calculateAge, getAgeGroup } from '../utils/age';

export interface AuthUser {
  id: string;
  ageGroup: 'minor' | 'adult';
  isPremium: boolean;
}

declare global {
  namespace Express {
    interface Request {
      user?: AuthUser;
    }
  }
}

export const authMiddleware = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;

    // Development mode: Allow mock tokens or no auth
    if (process.env.NODE_ENV === 'development') {
      const token = authHeader?.split(' ')[1];
      console.log('🔑 Auth Middleware:', { authHeader, token });

      if (token?.startsWith('firebase_uid_')) {
        const userId = token.replace('firebase_uid_', '');
        const mockUser = await prisma.user.findUnique({
          where: { id: userId },
          select: { id: true, dateOfBirth: true, isPremium: true }
        });

        if (mockUser) {
          const age = calculateAge(mockUser.dateOfBirth);
          req.user = {
            id: mockUser.id,
            ageGroup: getAgeGroup(age),
            isPremium: mockUser.isPremium
          };
          return next();
        }
      }

      if (!authHeader || token === 'mock_access_token' || token === 'mock_token') {
        // Use first user from database as mock user
        const mockUser = await prisma.user.findFirst({
          select: {
            id: true,
            dateOfBirth: true,
            isPremium: true,
          },
        });

        if (mockUser) {
          const age = calculateAge(mockUser.dateOfBirth);
          const ageGroup = getAgeGroup(age);

          req.user = {
            id: mockUser.id,
            ageGroup,
            isPremium: mockUser.isPremium,
          };

          return next();
        }
      }
    }

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Unauthorized', code: 'UNAUTHORIZED' });
    }

    const token = authHeader.split(' ')[1];

    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as {
      userId: string;
      ageGroup: string;
    };

    // Fetch user and recalculate age group (CRITICAL)
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: {
        id: true,
        dateOfBirth: true,
        isPremium: true,
        isBanned: true,
      },
    });

    if (!user) {
      return res.status(401).json({ message: 'User not found', code: 'USER_NOT_FOUND' });
    }

    if (user.isBanned) {
      return res.status(403).json({ message: 'Account banned', code: 'ACCOUNT_BANNED' });
    }

    // CRITICAL: Recalculate age group on every request
    const age = calculateAge(user.dateOfBirth);
    const ageGroup = getAgeGroup(age);

    req.user = {
      id: user.id,
      ageGroup,
      isPremium: user.isPremium,
    };

    // Update last active
    await prisma.user.update({
      where: { id: user.id },
      data: { lastActiveAt: new Date() },
    });

    next();
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      return res.status(401).json({ message: 'Token expired', code: 'TOKEN_EXPIRED' });
    }
    if (error instanceof jwt.JsonWebTokenError) {
      return res.status(401).json({ message: 'Invalid token', code: 'INVALID_TOKEN' });
    }
    next(error);
  }
};

// Age group enforcement middleware
export const enforceAgeGroup = (targetUserIdField: string = 'targetUserId') => {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      const targetUserId = req.body[targetUserIdField] || req.params.userId;

      if (!targetUserId) {
        return next();
      }

      const targetUser = await prisma.user.findUnique({
        where: { id: targetUserId },
        select: { dateOfBirth: true },
      });

      if (!targetUser) {
        return res.status(404).json({ message: 'User not found', code: 'USER_NOT_FOUND' });
      }

      const targetAge = calculateAge(targetUser.dateOfBirth);
      const targetAgeGroup = getAgeGroup(targetAge);

      // CRITICAL: Age group mismatch check
      // Requirements 5.2, 5.3: Cross-pool requests must be rejected
      if (req.user!.ageGroup !== targetAgeGroup) {
        return res.status(403).json({
          error: 'age_group_mismatch',
          message: 'Yaş grubu sebebiyle işlem yapılamıyor.',
        });
      }

      next();
    } catch (error) {
      next(error);
    }
  };
};
