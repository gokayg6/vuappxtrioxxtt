import { Router } from 'express';
import { prisma } from '../lib/prisma';
import { AppError } from '../middleware/errorHandler';

export const premiumRouter = Router();

// Get products
premiumRouter.get('/products', async (req, res, next) => {
  try {
    res.json({
      products: [
        {
          id: 'com.vibeu.premium.monthly',
          type: 'subscription',
          name: 'Premium Monthly',
          price: '$9.99',
          features: [
            'unlimited_likes',
            'see_who_liked',
            'unlimited_global',
            'neon_frame',
            'no_ads',
          ],
        },
        {
          id: 'com.vibeu.boost.30min',
          type: 'consumable',
          name: '30 Min Boost',
          price: '$2.99',
        },
        {
          id: 'com.vibeu.boost.1hour',
          type: 'consumable',
          name: '1 Hour Boost',
          price: '$4.99',
        },
        {
          id: 'com.vibeu.boost.6hour',
          type: 'consumable',
          name: '6 Hour Boost',
          price: '$9.99',
        },
      ],
    });
  } catch (error) {
    next(error);
  }
});

// Get premium status
premiumRouter.get('/status', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        isPremium: true,
        premiumExpiresAt: true,
      },
    });
    
    const activeBoosts = await prisma.boost.findMany({
      where: {
        userId,
        isActive: true,
        expiresAt: { gt: new Date() },
      },
    });
    
    // Get subscription info
    const subscription = user?.isPremium
      ? await prisma.purchase.findFirst({
          where: {
            userId,
            purchaseType: 'subscription',
            status: 'completed',
          },
          orderBy: { createdAt: 'desc' },
        })
      : null;
    
    res.json({
      is_premium: user?.isPremium || false,
      subscription: subscription
        ? {
            product_id: subscription.productId,
            expires_at: user?.premiumExpiresAt?.toISOString(),
            will_renew: true, // TODO: Check with App Store
          }
        : null,
      active_boosts: activeBoosts.map(b => ({
        type: b.boostType,
        expires_at: b.expiresAt.toISOString(),
        remaining_minutes: Math.max(
          0,
          Math.floor((b.expiresAt.getTime() - Date.now()) / 60000)
        ),
      })),
    });
  } catch (error) {
    next(error);
  }
});

// Verify purchase
premiumRouter.post('/verify-purchase', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const { product_id, transaction_id, receipt_data } = req.body;
    
    if (!product_id || !transaction_id) {
      throw new AppError('Missing required fields', 400, 'MISSING_FIELDS');
    }
    
    // Check if transaction already processed
    const existingPurchase = await prisma.purchase.findUnique({
      where: { transactionId: transaction_id },
    });
    
    if (existingPurchase) {
      throw new AppError('Transaction already processed', 400, 'DUPLICATE_TRANSACTION');
    }
    
    // TODO: Verify receipt with Apple
    // For now, trust the client
    
    const isSubscription = product_id.includes('premium');
    const isBoost = product_id.includes('boost');
    
    // Create purchase record
    await prisma.purchase.create({
      data: {
        userId,
        productId: product_id,
        transactionId: transaction_id,
        purchaseType: isSubscription ? 'subscription' : 'consumable',
        receiptData: receipt_data,
        expiresAt: isSubscription
          ? new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) // 30 days
          : null,
      },
    });
    
    // Update user premium status
    if (isSubscription) {
      await prisma.user.update({
        where: { id: userId },
        data: {
          isPremium: true,
          premiumExpiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
        },
      });
    }
    
    // Activate boost if purchased
    if (isBoost) {
      let durationMinutes = 30;
      let boostType: 'thirtyMin' | 'oneHour' | 'sixHour' = 'thirtyMin';
      
      if (product_id.includes('1hour')) {
        durationMinutes = 60;
        boostType = 'oneHour';
      } else if (product_id.includes('6hour')) {
        durationMinutes = 360;
        boostType = 'sixHour';
      }
      
      await prisma.boost.create({
        data: {
          userId,
          boostType,
          expiresAt: new Date(Date.now() + durationMinutes * 60 * 1000),
        },
      });
    }
    
    // Get updated status
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });
    
    const activeBoosts = await prisma.boost.findMany({
      where: {
        userId,
        isActive: true,
        expiresAt: { gt: new Date() },
      },
    });
    
    res.json({
      success: true,
      premium_status: {
        is_premium: user?.isPremium || false,
        subscription: isSubscription
          ? {
              product_id,
              expires_at: user?.premiumExpiresAt?.toISOString(),
              will_renew: true,
            }
          : null,
        active_boosts: activeBoosts.map(b => ({
          type: b.boostType,
          expires_at: b.expiresAt.toISOString(),
          remaining_minutes: Math.max(
            0,
            Math.floor((b.expiresAt.getTime() - Date.now()) / 60000)
          ),
        })),
      },
    });
  } catch (error) {
    next(error);
  }
});

// Activate boost (from inventory)
premiumRouter.post('/activate-boost', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const { boost_type } = req.body;
    
    // TODO: Check if user has boost in inventory
    // For now, just create the boost
    
    let durationMinutes = 30;
    let boostType: 'thirtyMin' | 'oneHour' | 'sixHour' = 'thirtyMin';
    
    if (boost_type === '1hour') {
      durationMinutes = 60;
      boostType = 'oneHour';
    } else if (boost_type === '6hour') {
      durationMinutes = 360;
      boostType = 'sixHour';
    }
    
    const boost = await prisma.boost.create({
      data: {
        userId,
        boostType,
        expiresAt: new Date(Date.now() + durationMinutes * 60 * 1000),
      },
    });
    
    res.json({
      success: true,
      boost: {
        type: boost.boostType,
        started_at: boost.startedAt.toISOString(),
        expires_at: boost.expiresAt.toISOString(),
        multiplier: boost.multiplier,
      },
    });
  } catch (error) {
    next(error);
  }
});

// Activate premium for testing (no payment required)
premiumRouter.post('/activate-test', async (req, res, next) => {
  try {
    const userId = req.user?.id || req.body.userId;
    const { plan, price, duration } = req.body;
    
    if (!userId) {
      throw new AppError('User ID required', 400, 'MISSING_USER_ID');
    }
    
    // Calculate expiration based on plan
    let expiresAt: Date;
    switch (duration) {
      case '1 Hafta':
        expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
        break;
      case '6 Ay':
        expiresAt = new Date(Date.now() + 180 * 24 * 60 * 60 * 1000);
        break;
      case '1 Ay':
      default:
        expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
    }
    
    // Update user premium status
    await prisma.user.update({
      where: { id: userId },
      data: {
        isPremium: true,
        premiumExpiresAt: expiresAt,
      },
    });
    
    // Create purchase record for tracking
    await prisma.purchase.create({
      data: {
        userId,
        productId: `com.vibeu.premium.test.${duration?.replace(' ', '_') || 'monthly'}`,
        transactionId: `test_${Date.now()}_${userId}`,
        purchaseType: 'subscription',
        amount: parseFloat(price?.replace('₺', '').replace(',', '.') || '0'),
        currency: 'TRY',
        status: 'completed',
        expiresAt,
      },
    });
    
    // Log the activation
    await prisma.appLog.create({
      data: {
        level: 'INFO',
        category: 'Premium',
        message: 'Premium activated (TEST MODE)',
        metadata: JSON.stringify({ plan, price, duration, expiresAt }),
        userId,
      },
    });
    
    res.json({
      success: true,
      message: 'Premium activated successfully',
      premium_status: {
        is_premium: true,
        expires_at: expiresAt.toISOString(),
        plan: duration || '1 Ay',
      },
    });
  } catch (error) {
    next(error);
  }
});

// Check premium status (public endpoint for testing)
premiumRouter.get('/check/:userId', async (req, res, next) => {
  try {
    const { userId } = req.params;
    
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        isPremium: true,
        premiumExpiresAt: true,
      },
    });
    
    if (!user) {
      return res.json({ is_premium: false });
    }
    
    // Check if premium has expired
    const isExpired = user.premiumExpiresAt && user.premiumExpiresAt < new Date();
    
    res.json({
      is_premium: user.isPremium && !isExpired,
      expires_at: user.premiumExpiresAt?.toISOString(),
      is_expired: isExpired,
    });
  } catch (error) {
    next(error);
  }
});

// Deactivate premium (for testing)
premiumRouter.post('/deactivate-test', async (req, res, next) => {
  try {
    const userId = req.user?.id || req.body.userId;
    
    if (!userId) {
      throw new AppError('User ID required', 400, 'MISSING_USER_ID');
    }
    
    await prisma.user.update({
      where: { id: userId },
      data: {
        isPremium: false,
        premiumExpiresAt: null,
      },
    });
    
    // Log
    await prisma.appLog.create({
      data: {
        level: 'INFO',
        category: 'Premium',
        message: 'Premium deactivated (TEST MODE)',
        userId,
      },
    });
    
    res.json({
      success: true,
      message: 'Premium deactivated',
    });
  } catch (error) {
    next(error);
  }
});

// Get rate limit status
premiumRouter.get('/rate-limits/status', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const isPremium = req.user!.isPremium;
    
    if (isPremium) {
      res.json({
        likes_remaining: -1, // Unlimited
        requests_remaining: 50,
        resets_at: null,
      });
      return;
    }
    
    const today = new Date();
    const windowStart = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const windowEnd = new Date(windowStart.getTime() + 24 * 60 * 60 * 1000);
    
    const [likeLimit, requestLimit] = await Promise.all([
      prisma.rateLimit.findFirst({
        where: { visitorId: userId, actionType: 'like', windowStart },
      }),
      prisma.rateLimit.findFirst({
        where: { visitorId: userId, actionType: 'request', windowStart },
      }),
    ]);
    
    res.json({
      likes_remaining: 100 - (likeLimit?.count || 0),
      requests_remaining: 10 - (requestLimit?.count || 0),
      resets_at: windowEnd.toISOString(),
    });
  } catch (error) {
    next(error);
  }
});
