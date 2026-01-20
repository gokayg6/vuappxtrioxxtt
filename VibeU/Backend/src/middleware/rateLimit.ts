import rateLimit from 'express-rate-limit';
import { Request, Response, NextFunction } from 'express';
import { prisma } from '../lib/prisma';

// Global rate limiter
export const rateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests per window
  message: { message: 'Too many requests', code: 'RATE_LIMIT_EXCEEDED' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Action-specific rate limits
const ACTION_LIMITS = {
  like: { free: 100, premium: -1 }, // -1 = unlimited
  request: { free: 10, premium: 50 },
  report: { free: 5, premium: 10 },
};

export const actionRateLimiter = (actionType: keyof typeof ACTION_LIMITS) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      const userId = req.user!.id;
      const isPremium = req.user!.isPremium;
      const limits = ACTION_LIMITS[actionType];
      const limit = isPremium ? limits.premium : limits.free;
      
      // Unlimited for premium
      if (limit === -1) {
        return next();
      }
      
      const now = new Date();
      const windowStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      const windowEnd = new Date(windowStart.getTime() + 24 * 60 * 60 * 1000);
      
      // Get or create rate limit record
      let rateLimit = await prisma.rateLimit.findFirst({
        where: {
          visitorId: userId,
          actionType,
          windowStart,
        },
      });
      
      if (!rateLimit) {
        rateLimit = await prisma.rateLimit.create({
          data: {
            visitorId: userId,
            actionType,
            count: 0,
            windowStart,
            windowEnd,
          },
        });
      }
      
      if (rateLimit.count >= limit) {
        return res.status(429).json({
          message: 'Rate limit exceeded',
          code: 'RATE_LIMIT_EXCEEDED',
          resets_at: windowEnd.toISOString(),
          remaining: 0,
        });
      }
      
      // Increment count
      await prisma.rateLimit.update({
        where: { id: rateLimit.id },
        data: { count: { increment: 1 } },
      });
      
      // Add remaining to response
      res.setHeader('X-RateLimit-Remaining', limit - rateLimit.count - 1);
      res.setHeader('X-RateLimit-Reset', windowEnd.toISOString());
      
      next();
    } catch (error) {
      next(error);
    }
  };
};

// Cooldown checker
export const cooldownChecker = (actionType: string) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      const userId = req.user!.id;
      const targetUserId = req.body.targetUserId || req.body.target_user_id;
      
      if (!targetUserId) {
        return next();
      }
      
      const cooldown = await prisma.cooldown.findFirst({
        where: {
          userId,
          targetUserId,
          actionType,
          expiresAt: { gt: new Date() },
        },
      });
      
      if (cooldown) {
        return res.status(429).json({
          message: 'Cooldown active',
          code: 'COOLDOWN_ACTIVE',
          expires_at: cooldown.expiresAt.toISOString(),
        });
      }
      
      next();
    } catch (error) {
      next(error);
    }
  };
};
