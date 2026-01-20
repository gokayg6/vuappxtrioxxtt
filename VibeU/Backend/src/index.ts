import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import authRouter from './routes/auth';
import { userRouter } from './routes/users';
import { discoverRouter } from './routes/discover';
import { socialRouter } from './routes/social';
import { friendsRouter } from './routes/friends';
import { premiumRouter } from './routes/premium';
import { notificationRouter } from './routes/notifications';
import { adminRouter } from './routes/admin';
import { doubleDateRouter } from './routes/doubledate';
import { logsRouter } from './routes/logs';
import { settingsRouter } from './routes/settings';
import { filtersRouter } from './routes/filters';
import profileRouter from './routes/profile';
import { errorHandler } from './middleware/errorHandler';
import { authMiddleware } from './middleware/auth';
import { rateLimiter } from './middleware/rateLimit';

dotenv.config();

const app = express();
const PORT = parseInt(process.env.PORT || '3000', 10);

// Enable trust proxy for tunnels
app.set('trust proxy', 1);

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(rateLimiter);

// Public routes
app.use('/api/auth', authRouter);

// Public interests endpoint (before auth middleware)
app.get('/api/profile/interests/all', async (req, res) => {
  const { PrismaClient } = await import('@prisma/client');
  const prisma = new PrismaClient();
  try {
    const interests = await prisma.interest.findMany({
      orderBy: [{ category: 'asc' }, { nameEn: 'asc' }]
    });
    const grouped = interests.reduce((acc: Record<string, typeof interests>, interest) => {
      if (!acc[interest.category]) acc[interest.category] = [];
      acc[interest.category].push(interest);
      return acc;
    }, {});
    res.json({ interests, grouped });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch interests' });
  }
});

// Profile routes without auth (for development)
app.use('/api/profile', profileRouter);

// Protected routes
app.use('/api/users', authMiddleware, userRouter);
app.use('/api/discover', authMiddleware, discoverRouter);
app.use('/api/likes', authMiddleware, socialRouter);
app.use('/api/requests', authMiddleware, socialRouter);
app.use('/api/friends', authMiddleware, friendsRouter);
app.use('/api/favorites', authMiddleware, socialRouter);
app.use('/api/skip', authMiddleware, socialRouter);
app.use('/api/reports', authMiddleware, socialRouter);
app.use('/api/premium', authMiddleware, premiumRouter);
app.use('/api/notifications', authMiddleware, notificationRouter);
app.use('/api/doubledate', authMiddleware, doubleDateRouter);
// app.use('/api/profile', authMiddleware, profileRouter); // Moved to public routes
app.use('/api/logs', logsRouter); // Logs can be sent without auth for error tracking
app.use('/api/settings', settingsRouter); // Settings without auth for development
app.use('/api/filters', filtersRouter); // Filters without auth for development

// Admin routes
app.use('/api/admin', authMiddleware, adminRouter);

// Error handler
app.use(errorHandler);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 VibeU Backend running on http://0.0.0.0:${PORT}`);
  console.log(`📱 Access from devices: http://192.168.140.129:${PORT}`);
});

export default app;
