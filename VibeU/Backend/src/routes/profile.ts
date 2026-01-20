import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// =====================================================
// INTERESTS ENDPOINTS (Must be before /:userId routes)
// =====================================================

// Get all available interests (PUBLIC)
router.get('/interests/all', async (req: Request, res: Response) => {
  try {
    const interests = await prisma.interest.findMany({
      orderBy: [{ category: 'asc' }, { nameEn: 'asc' }]
    });
    
    // Group by category
    const grouped = interests.reduce((acc, interest) => {
      if (!acc[interest.category]) {
        acc[interest.category] = [];
      }
      acc[interest.category].push(interest);
      return acc;
    }, {} as Record<string, typeof interests>);
    
    res.json({ interests, grouped });
  } catch (error) {
    console.error('Error fetching interests:', error);
    res.status(500).json({ error: 'Failed to fetch interests' });
  }
});

// =====================================================
// PROFILE ENDPOINTS
// =====================================================

// Get user profile with all data
router.get('/:userId', async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;
    
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        photos: { orderBy: { orderIndex: 'asc' } },
        interests: { include: { interest: true } },
        tags: { orderBy: { orderIndex: 'asc' } }
      }
    });
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    // Log profile view
    await prisma.appLog.create({
      data: {
        level: 'INFO',
        category: 'Profile',
        message: 'Profile viewed',
        userId,
        metadata: JSON.stringify({ viewedAt: new Date() })
      }
    });
    
    res.json(user);
  } catch (error) {
    console.error('Error fetching profile:', error);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
});

// Update user profile
router.put('/:userId', async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;
    const updateData = req.body;
    
    // Remove fields that shouldn't be updated directly
    delete updateData.id;
    delete updateData.createdAt;
    delete updateData.updatedAt;
    
    const user = await prisma.user.update({
      where: { id: userId },
      data: updateData
    });
    
    // Log profile update
    await prisma.appLog.create({
      data: {
        level: 'INFO',
        category: 'Profile',
        message: 'Profile updated',
        userId,
        metadata: JSON.stringify({ updatedFields: Object.keys(updateData) })
      }
    });
    
    res.json(user);
  } catch (error) {
    console.error('Error updating profile:', error);
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

// Get profile completion percentage
router.get('/:userId/completion', async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;
    
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        photos: true,
        interests: true
      }
    });
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    let completion = 0;
    const details: Record<string, boolean> = {};
    
    // Profile photo (20%)
    if (user.profilePhotoUrl) {
      completion += 20;
      details.profilePhoto = true;
    }
    
    // Display name (10%)
    if (user.displayName && user.displayName.length > 0) {
      completion += 10;
      details.displayName = true;
    }
    
    // Bio (15%)
    if (user.bio && user.bio.length >= 10) {
      completion += 15;
      details.bio = true;
    }
    
    // At least 3 photos (15%)
    if (user.photos.length >= 3) {
      completion += 15;
      details.photos = true;
    }
    
    // At least 5 interests (15%)
    if (user.interests.length >= 5) {
      completion += 15;
      details.interests = true;
    }
    
    // Social links (10%)
    if (user.instagramUsername || user.tiktokUsername || user.snapchatUsername) {
      completion += 10;
      details.socialLinks = true;
    }
    
    // Location (5%)
    if (user.city && user.country) {
      completion += 5;
      details.location = true;
    }
    
    // Age/DOB (10%)
    if (user.dateOfBirth) {
      completion += 10;
      details.dateOfBirth = true;
    }
    
    res.json({
      percentage: Math.min(completion, 100),
      isComplete: completion >= 100,
      details
    });
  } catch (error) {
    console.error('Error calculating completion:', error);
    res.status(500).json({ error: 'Failed to calculate completion' });
  }
});

// =====================================================
// PHOTOS ENDPOINTS
// =====================================================

// Get user photos
router.get('/:userId/photos', async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;
    
    const photos = await prisma.userPhoto.findMany({
      where: { userId },
      orderBy: { orderIndex: 'asc' }
    });
    
    res.json(photos);
  } catch (error) {
    console.error('Error fetching photos:', error);
    res.status(500).json({ error: 'Failed to fetch photos' });
  }
});

// Add photo
router.post('/:userId/photos', async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;
    const { url, thumbnailUrl } = req.body;
    
    // Get current max order index
    const maxOrder = await prisma.userPhoto.findFirst({
      where: { userId },
      orderBy: { orderIndex: 'desc' }
    });
    
    const newOrderIndex = (maxOrder?.orderIndex ?? -1) + 1;
    
    if (newOrderIndex >= 6) {
      return res.status(400).json({ error: 'Maximum 6 photos allowed' });
    }
    
    const photo = await prisma.userPhoto.create({
      data: {
        userId,
        url,
        thumbnailUrl,
        orderIndex: newOrderIndex,
        isPrimary: newOrderIndex === 0
      }
    });
    
    // Log photo upload
    await prisma.appLog.create({
      data: {
        level: 'INFO',
        category: 'Profile',
        message: 'Photo uploaded',
        userId,
        metadata: JSON.stringify({ photoId: photo.id, orderIndex: newOrderIndex })
      }
    });
    
    res.status(201).json(photo);
  } catch (error) {
    console.error('Error adding photo:', error);
    res.status(500).json({ error: 'Failed to add photo' });
  }
});

// Delete photo
router.delete('/:userId/photos/:photoId', async (req: Request, res: Response) => {
  try {
    const { userId, photoId } = req.params;
    
    await prisma.userPhoto.delete({
      where: { id: photoId, userId }
    });
    
    // Reorder remaining photos
    const remainingPhotos = await prisma.userPhoto.findMany({
      where: { userId },
      orderBy: { orderIndex: 'asc' }
    });
    
    for (let i = 0; i < remainingPhotos.length; i++) {
      await prisma.userPhoto.update({
        where: { id: remainingPhotos[i].id },
        data: { orderIndex: i, isPrimary: i === 0 }
      });
    }
    
    // Log photo deletion
    await prisma.appLog.create({
      data: {
        level: 'INFO',
        category: 'Profile',
        message: 'Photo deleted',
        userId,
        metadata: JSON.stringify({ photoId })
      }
    });
    
    res.json({ success: true });
  } catch (error) {
    console.error('Error deleting photo:', error);
    res.status(500).json({ error: 'Failed to delete photo' });
  }
});

// Reorder photos
router.put('/:userId/photos/reorder', async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;
    const { photoIds } = req.body; // Array of photo IDs in new order
    
    for (let i = 0; i < photoIds.length; i++) {
      await prisma.userPhoto.update({
        where: { id: photoIds[i], userId },
        data: { orderIndex: i, isPrimary: i === 0 }
      });
    }
    
    // Log reorder
    await prisma.appLog.create({
      data: {
        level: 'INFO',
        category: 'Profile',
        message: 'Photos reordered',
        userId,
        metadata: JSON.stringify({ newOrder: photoIds })
      }
    });
    
    res.json({ success: true });
  } catch (error) {
    console.error('Error reordering photos:', error);
    res.status(500).json({ error: 'Failed to reorder photos' });
  }
});

// =====================================================
// INTERESTS ENDPOINTS (User-specific)
// =====================================================

// Get user's interests
router.get('/:userId/interests', async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;
    
    const userInterests = await prisma.userInterest.findMany({
      where: { userId },
      include: { interest: true }
    });
    
    res.json(userInterests.map(ui => ui.interest));
  } catch (error) {
    console.error('Error fetching user interests:', error);
    res.status(500).json({ error: 'Failed to fetch user interests' });
  }
});

// Update user's interests
router.put('/:userId/interests', async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;
    const { interestIds } = req.body; // Array of interest IDs
    
    if (interestIds.length > 10) {
      return res.status(400).json({ error: 'Maximum 10 interests allowed' });
    }
    
    // Delete existing interests
    await prisma.userInterest.deleteMany({
      where: { userId }
    });
    
    // Add new interests
    await prisma.userInterest.createMany({
      data: interestIds.map((interestId: string) => ({
        userId,
        interestId
      }))
    });
    
    // Log interest update
    await prisma.appLog.create({
      data: {
        level: 'INFO',
        category: 'Profile',
        message: 'Interests updated',
        userId,
        metadata: JSON.stringify({ count: interestIds.length, interestIds })
      }
    });
    
    res.json({ success: true, count: interestIds.length });
  } catch (error) {
    console.error('Error updating interests:', error);
    res.status(500).json({ error: 'Failed to update interests' });
  }
});

// =====================================================
// SOCIAL LINKS ENDPOINTS
// =====================================================

// Get user's social links
router.get('/:userId/social', async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;
    
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        instagramUsername: true,
        tiktokUsername: true,
        snapchatUsername: true
      }
    });
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json({
      instagram: user.instagramUsername,
      tiktok: user.tiktokUsername,
      snapchat: user.snapchatUsername
    });
  } catch (error) {
    console.error('Error fetching social links:', error);
    res.status(500).json({ error: 'Failed to fetch social links' });
  }
});

// Update social links
router.put('/:userId/social', async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;
    const { instagram, tiktok, snapchat } = req.body;
    
    const user = await prisma.user.update({
      where: { id: userId },
      data: {
        instagramUsername: instagram || null,
        tiktokUsername: tiktok || null,
        snapchatUsername: snapchat || null
      }
    });
    
    // Log social update
    await prisma.appLog.create({
      data: {
        level: 'INFO',
        category: 'Profile',
        message: 'Social links updated',
        userId,
        metadata: JSON.stringify({ instagram: !!instagram, tiktok: !!tiktok, snapchat: !!snapchat })
      }
    });
    
    res.json({
      instagram: user.instagramUsername,
      tiktok: user.tiktokUsername,
      snapchat: user.snapchatUsername
    });
  } catch (error) {
    console.error('Error updating social links:', error);
    res.status(500).json({ error: 'Failed to update social links' });
  }
});

// =====================================================
// QR PROFILE ENDPOINTS
// =====================================================

// Get QR code data
router.get('/:userId/qr', async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;
    
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, username: true, displayName: true, profilePhotoUrl: true }
    });
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    // Generate QR code data (profile URL)
    const qrData = `vibeu://profile/${user.username}`;
    
    // Log QR generation
    await prisma.appLog.create({
      data: {
        level: 'INFO',
        category: 'Profile',
        message: 'QR code generated',
        userId,
        metadata: JSON.stringify({ qrData })
      }
    });
    
    res.json({
      qrData,
      profileUrl: `https://vibeu.app/u/${user.username}`,
      user: {
        id: user.id,
        username: user.username,
        displayName: user.displayName,
        profilePhotoUrl: user.profilePhotoUrl
      }
    });
  } catch (error) {
    console.error('Error generating QR:', error);
    res.status(500).json({ error: 'Failed to generate QR' });
  }
});

// Scan QR and get profile
router.get('/qr/scan/:username', async (req: Request, res: Response) => {
  try {
    const { username } = req.params;
    const { scannerId } = req.query;
    
    const user = await prisma.user.findUnique({
      where: { username },
      include: {
        photos: { orderBy: { orderIndex: 'asc' }, take: 3 },
        interests: { include: { interest: true }, take: 5 }
      }
    });
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    // Log QR scan
    await prisma.appLog.create({
      data: {
        level: 'INFO',
        category: 'Profile',
        message: 'QR code scanned',
        userId: scannerId as string || null,
        metadata: JSON.stringify({ scannedUsername: username, scannedUserId: user.id })
      }
    });
    
    res.json({
      id: user.id,
      username: user.username,
      displayName: user.displayName,
      profilePhotoUrl: user.profilePhotoUrl,
      bio: user.bio,
      city: user.city,
      photos: user.photos,
      interests: user.interests.map(ui => ui.interest)
    });
  } catch (error) {
    console.error('Error scanning QR:', error);
    res.status(500).json({ error: 'Failed to scan QR' });
  }
});

export default router;
