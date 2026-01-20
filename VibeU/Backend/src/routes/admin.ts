import { Router } from 'express';
import { prisma } from '../lib/prisma';
import { AppError } from '../middleware/errorHandler';

export const adminRouter = Router();

// Admin middleware
const adminMiddleware = async (req: any, res: any, next: any) => {
  // TODO: Implement proper admin check
  // For now, check if user has admin role
  const userId = req.user!.id;
  
  const user = await prisma.user.findUnique({
    where: { id: userId },
  });
  
  // Placeholder: In production, check admin role
  if (!user) {
    throw new AppError('Not authorized', 403, 'NOT_ADMIN');
  }
  
  next();
};

adminRouter.use(adminMiddleware);

// Get users
adminRouter.get('/users', async (req, res, next) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = Math.min(parseInt(req.query.limit as string) || 50, 100);
    const filter = req.query.filter as string;
    
    const where: any = {};
    
    if (filter === 'reported') {
      where.receivedReports = { some: {} };
    } else if (filter === 'banned') {
      where.isBanned = true;
    } else if (filter === 'premium') {
      where.isPremium = true;
    }
    
    const [users, total] = await Promise.all([
      prisma.user.findMany({
        where,
        select: {
          id: true,
          username: true,
          displayName: true,
          dateOfBirth: true,
          isPremium: true,
          isBanned: true,
          createdAt: true,
          _count: {
            select: { receivedReports: true },
          },
        },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.user.count({ where }),
    ]);
    
    res.json({
      users: users.map(u => ({
        id: u.id,
        username: u.username,
        display_name: u.displayName,
        is_premium: u.isPremium,
        is_banned: u.isBanned,
        report_count: u._count.receivedReports,
        created_at: u.createdAt.toISOString(),
      })),
      total,
      page,
    });
  } catch (error) {
    next(error);
  }
});

// Ban user
adminRouter.post('/users/:userId/ban', async (req, res, next) => {
  try {
    const { userId } = req.params;
    const { reason, duration_days } = req.body;
    
    await prisma.user.update({
      where: { id: userId },
      data: {
        isBanned: true,
        banReason: reason,
      },
    });
    
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

// Unban user
adminRouter.post('/users/:userId/unban', async (req, res, next) => {
  try {
    const { userId } = req.params;
    
    await prisma.user.update({
      where: { id: userId },
      data: {
        isBanned: false,
        banReason: null,
      },
    });
    
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

// Get reports
adminRouter.get('/reports', async (req, res, next) => {
  try {
    const status = req.query.status as string || 'pending';
    
    const reports = await prisma.report.findMany({
      where: { status: status as any },
      include: {
        reporter: {
          select: {
            id: true,
            username: true,
          },
        },
        reportedUser: {
          select: {
            id: true,
            username: true,
            profilePhotoUrl: true,
            photos: { take: 3 },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
    
    res.json({
      reports: reports.map(r => ({
        id: r.id,
        reporter: {
          id: r.reporter.id,
          username: r.reporter.username,
        },
        reported_user: {
          id: r.reportedUser.id,
          username: r.reportedUser.username,
          photos: r.reportedUser.photos.map(p => p.url),
        },
        reason: r.reason,
        description: r.description,
        created_at: r.createdAt.toISOString(),
      })),
    });
  } catch (error) {
    next(error);
  }
});

// Review report
adminRouter.post('/reports/:reportId/review', async (req, res, next) => {
  try {
    const { reportId } = req.params;
    const { action, notes } = req.body;
    const adminId = req.user!.id;
    
    const report = await prisma.report.findUnique({
      where: { id: reportId },
    });
    
    if (!report) {
      throw new AppError('Report not found', 404, 'REPORT_NOT_FOUND');
    }
    
    // Update report
    await prisma.report.update({
      where: { id: reportId },
      data: {
        status: action === 'dismiss' ? 'dismissed' : 'action_taken',
        adminNotes: notes,
        reviewedBy: adminId,
        reviewedAt: new Date(),
      },
    });
    
    // Take action if needed
    if (action === 'ban_user') {
      await prisma.user.update({
        where: { id: report.reportedUserId },
        data: {
          isBanned: true,
          banReason: `Banned due to report: ${report.reason}`,
        },
      });
    } else if (action === 'warn') {
      // TODO: Send warning notification
    }
    
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

// Get analytics
adminRouter.get('/analytics', async (req, res, next) => {
  try {
    const today = new Date();
    const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
    
    const [
      totalUsers,
      newUsersToday,
      activeUsersToday,
      likesToday,
      requestsToday,
      friendshipsToday,
      premiumUsers,
      boostsSoldToday,
    ] = await Promise.all([
      prisma.user.count({ where: { isBanned: false } }),
      prisma.user.count({
        where: { createdAt: { gte: startOfDay } },
      }),
      prisma.user.count({
        where: { lastActiveAt: { gte: startOfDay } },
      }),
      prisma.like.count({
        where: { createdAt: { gte: startOfDay } },
      }),
      prisma.request.count({
        where: { createdAt: { gte: startOfDay } },
      }),
      prisma.friendship.count({
        where: { createdAt: { gte: startOfDay } },
      }),
      prisma.user.count({
        where: { isPremium: true },
      }),
      prisma.purchase.count({
        where: {
          createdAt: { gte: startOfDay },
          purchaseType: 'consumable',
        },
      }),
    ]);
    
    // Calculate age group distribution
    const eighteenYearsAgo = new Date(
      today.getFullYear() - 18,
      today.getMonth(),
      today.getDate()
    );
    
    const [minorCount, adultCount] = await Promise.all([
      prisma.user.count({
        where: {
          isBanned: false,
          dateOfBirth: { gt: eighteenYearsAgo },
        },
      }),
      prisma.user.count({
        where: {
          isBanned: false,
          dateOfBirth: { lte: eighteenYearsAgo },
        },
      }),
    ]);
    
    res.json({
      users: {
        total: totalUsers,
        minor: minorCount,
        adult: adultCount,
        new_today: newUsersToday,
        active_today: activeUsersToday,
      },
      engagement: {
        likes_today: likesToday,
        requests_today: requestsToday,
        friendships_today: friendshipsToday,
      },
      premium: {
        active_subscribers: premiumUsers,
        boosts_sold_today: boostsSoldToday,
      },
    });
  } catch (error) {
    next(error);
  }
});
