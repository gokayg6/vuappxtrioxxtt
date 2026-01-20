import { Router } from 'express';
import { prisma } from '../lib/prisma';

export const notificationRouter = Router();

// Get notifications
notificationRouter.get('/', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const cursor = req.query.cursor as string | undefined;
    const limit = Math.min(parseInt(req.query.limit as string) || 20, 50);
    
    const notifications = await prisma.notification.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: limit + 1,
      ...(cursor && {
        cursor: { id: cursor },
        skip: 1,
      }),
    });
    
    const hasMore = notifications.length > limit;
    const resultNotifications = hasMore ? notifications.slice(0, -1) : notifications;
    
    const unreadCount = await prisma.notification.count({
      where: { userId, isRead: false },
    });
    
    res.json({
      notifications: resultNotifications.map(n => ({
        id: n.id,
        type: n.type,
        title_key: n.titleKey,
        body_key: n.bodyKey,
        data: n.data,
        is_read: n.isRead,
        created_at: n.createdAt.toISOString(),
      })),
      unread_count: unreadCount,
      next_cursor: hasMore ? resultNotifications[resultNotifications.length - 1].id : null,
    });
  } catch (error) {
    next(error);
  }
});

// Get unread count
notificationRouter.get('/unread-count', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    
    const unreadCount = await prisma.notification.count({
      where: { userId, isRead: false },
    });
    
    res.json({ unread_count: unreadCount });
  } catch (error) {
    next(error);
  }
});

// Mark as read
notificationRouter.post('/:id/read', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const notificationId = req.params.id;
    
    await prisma.notification.updateMany({
      where: {
        id: notificationId,
        userId,
      },
      data: { isRead: true },
    });
    
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

// Mark all as read
notificationRouter.post('/read-all', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    
    await prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true },
    });
    
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});
