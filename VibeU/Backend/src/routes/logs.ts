import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// POST /api/logs - Create a new log entry
router.post('/', async (req: Request, res: Response) => {
  try {
    const { id, timestamp, level, category, message, metadata, userId } = req.body;
    
    // Store log in database
    const log = await prisma.appLog.create({
      data: {
        id: id || undefined,
        timestamp: timestamp ? new Date(timestamp) : new Date(),
        level: level || 'INFO',
        category: category || 'General',
        message: message || '',
        metadata: metadata ? JSON.stringify(metadata) : null,
        userId: userId || (req as any).userId || null
      }
    });
    
    // Also log to console for debugging
    console.log(`[${log.level}] [${log.category}] ${log.message}`, metadata || '');
    
    res.status(201).json({ success: true, logId: log.id });
  } catch (error) {
    console.error('Error creating log:', error);
    // Don't fail the request for logging errors
    res.status(200).json({ success: false, error: 'Log creation failed' });
  }
});

// GET /api/logs - Get logs (admin only)
router.get('/', async (req: Request, res: Response) => {
  try {
    const { level, category, userId, limit = '100', offset = '0' } = req.query;
    
    const where: any = {};
    if (level) where.level = level;
    if (category) where.category = category;
    if (userId) where.userId = userId;
    
    const logs = await prisma.appLog.findMany({
      where,
      orderBy: { timestamp: 'desc' },
      take: parseInt(limit as string),
      skip: parseInt(offset as string)
    });
    
    res.json({ logs });
  } catch (error) {
    console.error('Error fetching logs:', error);
    res.status(500).json({ error: 'Failed to fetch logs' });
  }
});

// GET /api/logs/stats - Get log statistics
router.get('/stats', async (req: Request, res: Response) => {
  try {
    const stats = await prisma.appLog.groupBy({
      by: ['level'],
      _count: { id: true }
    });
    
    const categoryStats = await prisma.appLog.groupBy({
      by: ['category'],
      _count: { id: true }
    });
    
    res.json({
      byLevel: stats.map(s => ({ level: s.level, count: s._count.id })),
      byCategory: categoryStats.map(s => ({ category: s.category, count: s._count.id }))
    });
  } catch (error) {
    console.error('Error fetching log stats:', error);
    res.status(500).json({ error: 'Failed to fetch log stats' });
  }
});

export const logsRouter = router;
