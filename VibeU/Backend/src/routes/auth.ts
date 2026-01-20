import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { z } from 'zod';

const router = Router();
const prisma = new PrismaClient();

const JWT_SECRET = process.env.JWT_SECRET || 'vibeu-super-secret-key-change-in-production';
const JWT_EXPIRES_IN = '30d';

// =====================================================
// VALIDATION SCHEMAS
// =====================================================

const registerSchema = z.object({
  // Basic Info
  email: z.string().email('Invalid email format'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  firstName: z.string().min(1, 'First name is required').max(50),
  lastName: z.string().min(1, 'Last name is required').max(50),

  // Personal Info
  dateOfBirth: z.string().refine((date) => {
    const birthDate = new Date(date);
    const age = Math.floor((Date.now() - birthDate.getTime()) / (365.25 * 24 * 60 * 60 * 1000));
    return age >= 18 && age <= 100;
  }, 'You must be at least 18 years old'),

  gender: z.enum(['male', 'female', 'non_binary', 'prefer_not_to_say']),

  // Location
  country: z.string().min(2, 'Country is required'),
  city: z.string().min(2, 'City is required'),
  latitude: z.number().optional(),
  longitude: z.number().optional(),

  // Profile
  bio: z.string().max(500).optional(),
  profilePhotoUrl: z.string().url().optional(),

  // Interests (array of interest codes)
  interests: z.array(z.string()).min(3, 'Select at least 3 interests').max(10),

  // Hobbies (custom tags)
  hobbies: z.array(z.string()).max(5).optional(),

  // Social Media (optional)
  instagramUsername: z.string().max(30).optional(),
  tiktokUsername: z.string().max(30).optional(),
  snapchatUsername: z.string().max(30).optional(),

  // OAuth IDs (if signing up with social)
  appleId: z.string().optional(),
  googleId: z.string().optional(),
});

const loginSchema = z.object({
  email: z.string().email('Invalid email format'),
  password: z.string().min(1, 'Password is required'),
});

const socialAuthSchema = z.object({
  provider: z.enum(['apple', 'google']),
  providerId: z.string(),
  email: z.string().email(),
  firstName: z.string().optional(),
  lastName: z.string().optional(),
  profilePhotoUrl: z.string().url().optional(),
});

// =====================================================
// HELPER FUNCTIONS
// =====================================================

function generateUsername(firstName: string, lastName: string): string {
  const base = `${firstName.toLowerCase()}${lastName.toLowerCase()}`.replace(/[^a-z0-9]/g, '');
  const random = Math.floor(Math.random() * 9999);
  return `${base}${random}`;
}

function generateToken(userId: string): string {
  return jwt.sign({ userId }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
}

async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, 10);
}

async function comparePassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}

// =====================================================
// ROUTES
// =====================================================

/**
 * POST /auth/register
 * Register a new user with complete profile information
 */
router.post('/register', async (req: Request, res: Response) => {
  try {
    const data = registerSchema.parse(req.body);

    // Check if email already exists
    const existingUser = await prisma.user.findUnique({
      where: { email: data.email },
    });

    if (existingUser) {
      return res.status(400).json({
        success: false,
        error: 'Email already registered',
      });
    }

    // Hash password
    const hashedPassword = await hashPassword(data.password);

    // Generate unique username
    let username = generateUsername(data.firstName, data.lastName);
    let usernameExists = await prisma.user.findUnique({ where: { username } });

    while (usernameExists) {
      username = generateUsername(data.firstName, data.lastName);
      usernameExists = await prisma.user.findUnique({ where: { username } });
    }

    // Calculate zodiac sign
    const birthDate = new Date(data.dateOfBirth);
    const zodiacSign = calculateZodiacSign(birthDate);

    // Create user
    const user = await prisma.user.create({
      data: {
        username,
        email: data.email,
        password: hashedPassword,
        displayName: `${data.firstName} ${data.lastName}`,
        dateOfBirth: birthDate,
        gender: data.gender,
        country: data.country,
        city: data.city,
        latitude: data.latitude,
        longitude: data.longitude,
        bio: data.bio || `Hey! I'm ${data.firstName}`,
        profilePhotoUrl: data.profilePhotoUrl || generateDefaultAvatar(data.gender),
        instagramUsername: data.instagramUsername,
        tiktokUsername: data.tiktokUsername,
        snapchatUsername: data.snapchatUsername,
        appleId: data.appleId,
        googleId: data.googleId,
      },
    });

    // Add interests
    if (data.interests && data.interests.length > 0) {
      const interestRecords = await prisma.interest.findMany({
        where: { code: { in: data.interests } },
      });

      await prisma.userInterest.createMany({
        data: interestRecords.map((interest) => ({
          userId: user.id,
          interestId: interest.id,
        })),
      });
    }

    // Add hobbies as tags
    if (data.hobbies && data.hobbies.length > 0) {
      await prisma.userTag.createMany({
        data: data.hobbies.map((hobby, index) => ({
          userId: user.id,
          tagCode: hobby.toLowerCase().replace(/\s+/g, '_'),
          orderIndex: index,
        })),
      });
    }

    // Create default settings
    await prisma.userSettings.create({
      data: {
        userId: user.id,
        theme: 'light',
        language: 'en',
      },
    });

    // Create default discover filters
    await prisma.discoverFilters.create({
      data: {
        userId: user.id,
      },
    });

    // Generate JWT token
    const token = generateToken(user.id);

    // Return user data (without password)
    const { password: _, ...userWithoutPassword } = user;

    res.status(201).json({
      success: true,
      data: {
        user: {
          ...userWithoutPassword,
          zodiacSign,
        },
        token,
      },
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        success: false,
        error: 'Validation error',
        details: error.errors,
      });
    }

    console.error('Registration error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to register user',
    });
  }
});

/**
 * POST /auth/login
 * Login with email and password
 */
router.post('/login', async (req: Request, res: Response) => {
  try {
    const data = loginSchema.parse(req.body);

    // Find user by email
    const user = await prisma.user.findUnique({
      where: { email: data.email },
      include: {
        interests: {
          include: {
            interest: true,
          },
        },
        tags: true,
      },
    });

    if (!user || !user.password) {
      return res.status(401).json({
        success: false,
        error: 'Invalid email or password',
      });
    }

    // Check if user is banned
    if (user.isBanned) {
      return res.status(403).json({
        success: false,
        error: 'Account has been banned',
        reason: user.banReason,
      });
    }

    // Verify password
    const isValidPassword = await comparePassword(data.password, user.password);

    if (!isValidPassword) {
      return res.status(401).json({
        success: false,
        error: 'Invalid email or password',
      });
    }

    // Update last active
    await prisma.user.update({
      where: { id: user.id },
      data: { lastActiveAt: new Date() },
    });

    // Generate token
    const token = generateToken(user.id);

    // Calculate zodiac sign
    const zodiacSign = calculateZodiacSign(user.dateOfBirth);

    // Return user data
    const { password: _, ...userWithoutPassword } = user;

    res.json({
      success: true,
      data: {
        user: {
          ...userWithoutPassword,
          zodiacSign,
        },
        token,
      },
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        success: false,
        error: 'Validation error',
        details: error.errors,
      });
    }

    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to login',
    });
  }
});

/**
 * POST /auth/social
 * Login or register with Apple/Google
 */
router.post('/social', async (req: Request, res: Response) => {
  try {
    const data = socialAuthSchema.parse(req.body);

    // Check if user exists with this provider ID
    const whereClause = data.provider === 'apple'
      ? { appleId: data.providerId }
      : { googleId: data.providerId };

    let user = await prisma.user.findFirst({
      where: whereClause,
      include: {
        interests: {
          include: {
            interest: true,
          },
        },
        tags: true,
      },
    });

    // If user doesn't exist, create a new one
    if (!user) {
      // Check if email is already used
      const emailUser = await prisma.user.findUnique({
        where: { email: data.email },
      });

      if (emailUser) {
        // Link the social account to existing user
        const updateData = data.provider === 'apple'
          ? { appleId: data.providerId }
          : { googleId: data.providerId };

        user = await prisma.user.update({
          where: { id: emailUser.id },
          data: updateData,
          include: {
            interests: {
              include: {
                interest: true,
              },
            },
            tags: true,
          },
        });
      } else {
        // Create new user - they'll need to complete profile
        const firstName = data.firstName || 'User';
        const lastName = data.lastName || '';
        const username = generateUsername(firstName, lastName);

        const createData: any = {
          username,
          email: data.email,
          displayName: `${firstName} ${lastName}`.trim(),
          dateOfBirth: new Date('2000-01-01'), // Placeholder
          gender: 'prefer_not_to_say',
          country: 'Unknown',
          city: 'Unknown',
          bio: `Hey! I'm ${firstName}`,
          profilePhotoUrl: data.profilePhotoUrl || generateDefaultAvatar('prefer_not_to_say'),
        };

        if (data.provider === 'apple') {
          createData.appleId = data.providerId;
        } else {
          createData.googleId = data.providerId;
        }

        user = await prisma.user.create({
          data: createData,
          include: {
            interests: {
              include: {
                interest: true,
              },
            },
            tags: true,
          },
        });

        // Create default settings
        await prisma.userSettings.create({
          data: {
            userId: user.id,
          },
        });

        // Create default filters
        await prisma.discoverFilters.create({
          data: {
            userId: user.id,
          },
        });
      }
    }

    // Check if banned
    if (user.isBanned) {
      return res.status(403).json({
        success: false,
        error: 'Account has been banned',
        reason: user.banReason,
      });
    }

    // Update last active
    await prisma.user.update({
      where: { id: user.id },
      data: { lastActiveAt: new Date() },
    });

    // Generate token
    const token = generateToken(user.id);

    // Calculate zodiac sign
    const zodiacSign = calculateZodiacSign(user.dateOfBirth);

    // Check if profile is complete
    const needsProfileCompletion =
      user.country === 'Unknown' ||
      user.dateOfBirth.getFullYear() === 2000;

    res.json({
      success: true,
      data: {
        user: {
          ...user,
          zodiacSign,
        },
        token,
        needsProfileCompletion,
      },
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        success: false,
        error: 'Validation error',
        details: error.errors,
      });
    }

    console.error('Social auth error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to authenticate',
    });
  }
});

/**
 * POST /auth/sync
 * Sync Firebase user to backend database
 * Called when iOS app needs the user to exist in backend (for friend requests etc)
 */
router.post('/sync', async (req: Request, res: Response) => {
  try {
    const { userId, displayName, email, profilePhotoUrl, dateOfBirth, gender, country, city } = req.body;

    if (!userId) {
      return res.status(400).json({ success: false, error: 'userId is required' });
    }

    // Check if user already exists
    let user = await prisma.user.findUnique({ where: { id: userId } });

    if (user) {
      // User exists, just return success
      console.log(`✅ User ${userId} already exists in backend`);
      return res.json({ success: true, exists: true, user });
    }

    // Create new user with Firebase UID
    const username = (displayName || 'user').toLowerCase().replace(/\s+/g, '_') + '_' + Math.floor(Math.random() * 9999);

    user = await prisma.user.create({
      data: {
        id: userId,  // Use Firebase UID as ID
        username,
        displayName: displayName || 'VibeU User',
        email: email || `${userId}@vibeu.firebase`,
        dateOfBirth: dateOfBirth ? new Date(dateOfBirth) : new Date('2000-01-01'),
        gender: gender || 'prefer_not_to_say',
        country: country || 'Turkey',
        city: city || 'Istanbul',
        bio: 'VibeU\'ya yeni katıldım!',
        profilePhotoUrl: profilePhotoUrl || `https://ui-avatars.com/api/?name=${encodeURIComponent(displayName || 'User')}&background=random`,
      },
    });

    // Create default settings
    await prisma.userSettings.create({ data: { userId: user.id } });
    await prisma.discoverFilters.create({ data: { userId: user.id } });

    console.log(`✅ Created new user ${userId} (${displayName}) in backend`);

    res.json({ success: true, exists: false, user });
  } catch (error) {
    console.error('Sync error:', error);
    res.status(500).json({ success: false, error: 'Failed to sync user' });
  }
});

/**
 * GET /auth/me
 * Get current user profile
 */
router.get('/me', async (req: Request, res: Response) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({
        success: false,
        error: 'No token provided',
      });
    }

    const decoded = jwt.verify(token, JWT_SECRET) as { userId: string };

    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      include: {
        interests: {
          include: {
            interest: true,
          },
        },
        tags: true,
        photos: {
          orderBy: { orderIndex: 'asc' },
        },
      },
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
      });
    }

    const zodiacSign = calculateZodiacSign(user.dateOfBirth);
    const { password: _, ...userWithoutPassword } = user;

    res.json({
      success: true,
      data: {
        ...userWithoutPassword,
        zodiacSign,
      },
    });
  } catch (error) {
    console.error('Get me error:', error);
    res.status(401).json({
      success: false,
      error: 'Invalid token',
    });
  }
});

// =====================================================
// UTILITY FUNCTIONS
// =====================================================

function calculateZodiacSign(date: Date): string {
  const month = date.getMonth() + 1;
  const day = date.getDate();

  if ((month === 3 && day >= 21) || (month === 4 && day <= 19)) return 'aries';
  if ((month === 4 && day >= 20) || (month === 5 && day <= 20)) return 'taurus';
  if ((month === 5 && day >= 21) || (month === 6 && day <= 20)) return 'gemini';
  if ((month === 6 && day >= 21) || (month === 7 && day <= 22)) return 'cancer';
  if ((month === 7 && day >= 23) || (month === 8 && day <= 22)) return 'leo';
  if ((month === 8 && day >= 23) || (month === 9 && day <= 22)) return 'virgo';
  if ((month === 9 && day >= 23) || (month === 10 && day <= 22)) return 'libra';
  if ((month === 10 && day >= 23) || (month === 11 && day <= 21)) return 'scorpio';
  if ((month === 11 && day >= 22) || (month === 12 && day <= 21)) return 'sagittarius';
  if ((month === 12 && day >= 22) || (month === 1 && day <= 19)) return 'capricorn';
  if ((month === 1 && day >= 20) || (month === 2 && day <= 18)) return 'aquarius';
  return 'pisces';
}

function generateDefaultAvatar(gender: string): string {
  const avatars = {
    male: 'https://api.dicebear.com/7.x/avataaars/svg?seed=male',
    female: 'https://api.dicebear.com/7.x/avataaars/svg?seed=female',
    non_binary: 'https://api.dicebear.com/7.x/avataaars/svg?seed=person',
    prefer_not_to_say: 'https://api.dicebear.com/7.x/avataaars/svg?seed=user',
  };

  return avatars[gender as keyof typeof avatars] || avatars.prefer_not_to_say;
}

export default router;
