import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// GET /api/settings - Get user settings
router.get('/', async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.id || req.query.userId as string;
    
    if (!userId) {
      return res.status(400).json({ error: 'User ID required' });
    }
    
    let settings = await prisma.userSettings.findUnique({
      where: { userId }
    });
    
    // Create default settings if not exists
    if (!settings) {
      settings = await prisma.userSettings.create({
        data: { userId }
      });
    }
    
    res.json({ settings });
  } catch (error) {
    console.error('Error fetching settings:', error);
    res.status(500).json({ error: 'Failed to fetch settings' });
  }
});

// PUT /api/settings - Update user settings
router.put('/', async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.id || req.body.userId;
    const {
      theme,
      language,
      pushNotifications,
      matchNotifications,
      messageNotifications,
      likeNotifications,
      hideAge,
      hideDistance,
      hideOnlineStatus,
      readReceipts,
      locationEnabled
    } = req.body;
    
    if (!userId) {
      return res.status(400).json({ error: 'User ID required' });
    }
    
    const settings = await prisma.userSettings.upsert({
      where: { userId },
      update: {
        theme: theme ?? undefined,
        language: language ?? undefined,
        pushNotifications: pushNotifications ?? undefined,
        matchNotifications: matchNotifications ?? undefined,
        messageNotifications: messageNotifications ?? undefined,
        likeNotifications: likeNotifications ?? undefined,
        hideAge: hideAge ?? undefined,
        hideDistance: hideDistance ?? undefined,
        hideOnlineStatus: hideOnlineStatus ?? undefined,
        readReceipts: readReceipts ?? undefined,
        locationEnabled: locationEnabled ?? undefined
      },
      create: {
        userId,
        theme: theme ?? 'dark',
        language: language ?? 'tr',
        pushNotifications: pushNotifications ?? true,
        matchNotifications: matchNotifications ?? true,
        messageNotifications: messageNotifications ?? true,
        likeNotifications: likeNotifications ?? true,
        hideAge: hideAge ?? false,
        hideDistance: hideDistance ?? false,
        hideOnlineStatus: hideOnlineStatus ?? false,
        readReceipts: readReceipts ?? true,
        locationEnabled: locationEnabled ?? true
      }
    });
    
    // Log the settings change
    await prisma.appLog.create({
      data: {
        level: 'INFO',
        category: 'Settings',
        message: 'User settings updated',
        metadata: JSON.stringify({ userId, changes: req.body }),
        userId
      }
    });
    
    res.json({ success: true, settings });
  } catch (error) {
    console.error('Error updating settings:', error);
    res.status(500).json({ error: 'Failed to update settings' });
  }
});

// PUT /api/settings/theme - Update theme only
router.put('/theme', async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.id || req.body.userId;
    const { theme } = req.body;
    
    if (!userId || !theme) {
      return res.status(400).json({ error: 'User ID and theme required' });
    }
    
    const settings = await prisma.userSettings.upsert({
      where: { userId },
      update: { theme },
      create: { userId, theme }
    });
    
    res.json({ success: true, theme: settings.theme });
  } catch (error) {
    console.error('Error updating theme:', error);
    res.status(500).json({ error: 'Failed to update theme' });
  }
});

// PUT /api/settings/language - Update language only
router.put('/language', async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.id || req.body.userId;
    const { language } = req.body;
    
    if (!userId || !language) {
      return res.status(400).json({ error: 'User ID and language required' });
    }
    
    const settings = await prisma.userSettings.upsert({
      where: { userId },
      update: { language },
      create: { userId, language }
    });
    
    // Log language change
    await prisma.appLog.create({
      data: {
        level: 'INFO',
        category: 'Settings',
        message: `Language changed to ${language}`,
        userId
      }
    });
    
    res.json({ success: true, language: settings.language });
  } catch (error) {
    console.error('Error updating language:', error);
    res.status(500).json({ error: 'Failed to update language' });
  }
});

// PUT /api/settings/privacy - Update privacy settings
router.put('/privacy', async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.id || req.body.userId;
    const { hideAge, hideDistance, hideOnlineStatus, readReceipts } = req.body;
    
    if (!userId) {
      return res.status(400).json({ error: 'User ID required' });
    }
    
    const settings = await prisma.userSettings.upsert({
      where: { userId },
      update: {
        hideAge: hideAge ?? undefined,
        hideDistance: hideDistance ?? undefined,
        hideOnlineStatus: hideOnlineStatus ?? undefined,
        readReceipts: readReceipts ?? undefined
      },
      create: {
        userId,
        hideAge: hideAge ?? false,
        hideDistance: hideDistance ?? false,
        hideOnlineStatus: hideOnlineStatus ?? false,
        readReceipts: readReceipts ?? true
      }
    });
    
    // Log privacy change
    await prisma.appLog.create({
      data: {
        level: 'INFO',
        category: 'Settings',
        message: 'Privacy settings updated',
        metadata: JSON.stringify({ hideAge, hideDistance, hideOnlineStatus, readReceipts }),
        userId
      }
    });
    
    res.json({ success: true, settings });
  } catch (error) {
    console.error('Error updating privacy settings:', error);
    res.status(500).json({ error: 'Failed to update privacy settings' });
  }
});

export const settingsRouter = router;
