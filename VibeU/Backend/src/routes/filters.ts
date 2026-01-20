import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// GET /api/filters - Get user discover filters
router.get('/', async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.id || req.query.userId as string;
    
    if (!userId) {
      return res.status(400).json({ error: 'User ID required' });
    }
    
    let filters = await prisma.discoverFilters.findUnique({
      where: { userId }
    });
    
    // Create default filters if not exists
    if (!filters) {
      filters = await prisma.discoverFilters.create({
        data: { userId }
      });
    }
    
    res.json({ filters });
  } catch (error) {
    console.error('Error fetching filters:', error);
    res.status(500).json({ error: 'Failed to fetch filters' });
  }
});

// PUT /api/filters - Update discover filters
router.put('/', async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.id || req.body.userId;
    const {
      minAge,
      maxAge,
      maxDistance,
      showMen,
      showWomen,
      showNonBinary,
      onlyActive,
      onlyVerified,
      onlyWithPhotos,
      onlyWithBio,
      hideAlreadySeen
    } = req.body;
    
    if (!userId) {
      return res.status(400).json({ error: 'User ID required' });
    }
    
    const filters = await prisma.discoverFilters.upsert({
      where: { userId },
      update: {
        minAge: minAge ?? undefined,
        maxAge: maxAge ?? undefined,
        maxDistance: maxDistance ?? undefined,
        showMen: showMen ?? undefined,
        showWomen: showWomen ?? undefined,
        showNonBinary: showNonBinary ?? undefined,
        onlyActive: onlyActive ?? undefined,
        onlyVerified: onlyVerified ?? undefined,
        onlyWithPhotos: onlyWithPhotos ?? undefined,
        onlyWithBio: onlyWithBio ?? undefined,
        hideAlreadySeen: hideAlreadySeen ?? undefined
      },
      create: {
        userId,
        minAge: minAge ?? 18,
        maxAge: maxAge ?? 50,
        maxDistance: maxDistance ?? 100,
        showMen: showMen ?? true,
        showWomen: showWomen ?? true,
        showNonBinary: showNonBinary ?? true,
        onlyActive: onlyActive ?? false,
        onlyVerified: onlyVerified ?? false,
        onlyWithPhotos: onlyWithPhotos ?? true,
        onlyWithBio: onlyWithBio ?? false,
        hideAlreadySeen: hideAlreadySeen ?? false
      }
    });
    
    // Log the filter change
    await prisma.appLog.create({
      data: {
        level: 'INFO',
        category: 'Filters',
        message: 'Discover filters updated',
        metadata: JSON.stringify({
          minAge, maxAge, maxDistance,
          showMen, showWomen, showNonBinary,
          onlyActive, onlyVerified, onlyWithPhotos
        }),
        userId
      }
    });
    
    res.json({ success: true, filters });
  } catch (error) {
    console.error('Error updating filters:', error);
    res.status(500).json({ error: 'Failed to update filters' });
  }
});

// PUT /api/filters/age - Update age range only
router.put('/age', async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.id || req.body.userId;
    const { minAge, maxAge } = req.body;
    
    if (!userId) {
      return res.status(400).json({ error: 'User ID required' });
    }
    
    // Validate age range
    const min = Math.max(18, minAge || 18);
    const max = Math.min(100, maxAge || 50);
    
    if (min > max) {
      return res.status(400).json({ error: 'Invalid age range' });
    }
    
    const filters = await prisma.discoverFilters.upsert({
      where: { userId },
      update: { minAge: min, maxAge: max },
      create: { userId, minAge: min, maxAge: max }
    });
    
    // Log
    await prisma.appLog.create({
      data: {
        level: 'INFO',
        category: 'Filters',
        message: `Age range updated: ${min}-${max}`,
        userId
      }
    });
    
    res.json({ success: true, minAge: filters.minAge, maxAge: filters.maxAge });
  } catch (error) {
    console.error('Error updating age filter:', error);
    res.status(500).json({ error: 'Failed to update age filter' });
  }
});

// PUT /api/filters/distance - Update distance only
router.put('/distance', async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.id || req.body.userId;
    const { maxDistance } = req.body;
    
    if (!userId) {
      return res.status(400).json({ error: 'User ID required' });
    }
    
    const distance = Math.max(1, Math.min(500, maxDistance || 100));
    
    const filters = await prisma.discoverFilters.upsert({
      where: { userId },
      update: { maxDistance: distance },
      create: { userId, maxDistance: distance }
    });
    
    // Log
    await prisma.appLog.create({
      data: {
        level: 'INFO',
        category: 'Filters',
        message: `Distance updated: ${distance}km`,
        userId
      }
    });
    
    res.json({ success: true, maxDistance: filters.maxDistance });
  } catch (error) {
    console.error('Error updating distance filter:', error);
    res.status(500).json({ error: 'Failed to update distance filter' });
  }
});

// PUT /api/filters/gender - Update gender preferences
router.put('/gender', async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.id || req.body.userId;
    const { showMen, showWomen, showNonBinary } = req.body;
    
    if (!userId) {
      return res.status(400).json({ error: 'User ID required' });
    }
    
    // At least one must be true
    if (!showMen && !showWomen && !showNonBinary) {
      return res.status(400).json({ error: 'At least one gender must be selected' });
    }
    
    const filters = await prisma.discoverFilters.upsert({
      where: { userId },
      update: {
        showMen: showMen ?? undefined,
        showWomen: showWomen ?? undefined,
        showNonBinary: showNonBinary ?? undefined
      },
      create: {
        userId,
        showMen: showMen ?? true,
        showWomen: showWomen ?? true,
        showNonBinary: showNonBinary ?? true
      }
    });
    
    // Log
    await prisma.appLog.create({
      data: {
        level: 'INFO',
        category: 'Filters',
        message: 'Gender preferences updated',
        metadata: JSON.stringify({ showMen, showWomen, showNonBinary }),
        userId
      }
    });
    
    res.json({ success: true, filters });
  } catch (error) {
    console.error('Error updating gender filter:', error);
    res.status(500).json({ error: 'Failed to update gender filter' });
  }
});

// DELETE /api/filters - Reset filters to default
router.delete('/', async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.id || req.query.userId as string;
    
    if (!userId) {
      return res.status(400).json({ error: 'User ID required' });
    }
    
    // Delete existing and create new with defaults
    await prisma.discoverFilters.deleteMany({
      where: { userId }
    });
    
    const filters = await prisma.discoverFilters.create({
      data: { userId }
    });
    
    // Log
    await prisma.appLog.create({
      data: {
        level: 'INFO',
        category: 'Filters',
        message: 'Filters reset to default',
        userId
      }
    });
    
    res.json({ success: true, filters });
  } catch (error) {
    console.error('Error resetting filters:', error);
    res.status(500).json({ error: 'Failed to reset filters' });
  }
});

export const filtersRouter = router;
