import { prisma } from '../lib/prisma';

interface ScoreWeights {
  age: number;
  interest: number;
  location: number;
  activity: number;
  profileQuality: number;
}

const WEIGHTS: Record<'local' | 'global', ScoreWeights> = {
  local: {
    age: 1.0,
    interest: 0.5,
    location: 0.7,
    activity: 0.2,
    profileQuality: 0.3,
  },
  global: {
    age: 1.0,
    interest: 0.8,
    location: 0.1,
    activity: 0.4,
    profileQuality: 0.3,
  },
};

/**
 * Calculate discovery score for a user
 */
export async function calculateDiscoverScore(
  currentUserId: string,
  currentUserAge: number,
  currentUserCity: string,
  currentUserInterestIds: string[],
  targetUser: {
    id: string;
    age: number;
    city: string;
    country: string;
    lastActiveAt: Date;
    photos: { id: string }[];
    tags: { id: string }[];
    interests: { interestId: string }[];
    bio: string | null;
    isVerified: boolean;
  },
  mode: 'local' | 'global'
): Promise<number> {
  const weights = WEIGHTS[mode];
  
  // 1. Age Score
  const ageDiff = Math.abs(currentUserAge - targetUser.age);
  let ageScore: number;
  if (ageDiff === 0) ageScore = 100;
  else if (ageDiff <= 2) ageScore = 90;
  else if (ageDiff <= 5) ageScore = 70;
  else if (ageDiff <= 10) ageScore = 50;
  else ageScore = 30;
  
  // 2. Interest Score
  const targetInterestIds = targetUser.interests.map(i => i.interestId);
  const commonInterests = currentUserInterestIds.filter(id => 
    targetInterestIds.includes(id)
  );
  const interestScore = currentUserInterestIds.length > 0
    ? (commonInterests.length / currentUserInterestIds.length) * 100
    : 50;
  
  // 3. Location Score
  let locationScore: number;
  if (mode === 'local') {
    if (currentUserCity === targetUser.city) {
      locationScore = 100;
    } else {
      locationScore = 60; // Same country, different city
    }
  } else {
    locationScore = 50; // Global mode - location doesn't matter much
  }
  
  // 4. Activity Score
  const hoursSinceActive = 
    (Date.now() - targetUser.lastActiveAt.getTime()) / (1000 * 60 * 60);
  let activityScore: number;
  if (hoursSinceActive < 1) activityScore = 100;
  else if (hoursSinceActive < 6) activityScore = 90;
  else if (hoursSinceActive < 24) activityScore = 70;
  else if (hoursSinceActive < 72) activityScore = 50;
  else if (hoursSinceActive < 168) activityScore = 30;
  else activityScore = 10;
  
  // 5. Profile Quality Score
  let qualityScore = 0;
  
  // Photos (max 30)
  qualityScore += Math.min(targetUser.photos.length * 10, 30);
  
  // Bio (20)
  if (targetUser.bio && targetUser.bio.length > 20) {
    qualityScore += 20;
  }
  
  // Tags (max 15)
  qualityScore += Math.min(targetUser.tags.length * 5, 15);
  
  // Interests (max 15)
  qualityScore += Math.min(targetUser.interests.length * 3, 15);
  
  // Verified (20)
  if (targetUser.isVerified) {
    qualityScore += 20;
  }
  
  const profileQualityScore = Math.min(qualityScore, 100);
  
  // 6. Boost Score
  const activeBoost = await prisma.boost.findFirst({
    where: {
      userId: targetUser.id,
      isActive: true,
      expiresAt: { gt: new Date() },
    },
  });
  const boostScore = activeBoost ? activeBoost.multiplier * 50 : 0;
  
  // Calculate final score
  const finalScore = 
    ageScore * weights.age +
    interestScore * weights.interest +
    locationScore * weights.location +
    activityScore * weights.activity +
    profileQualityScore * weights.profileQuality +
    boostScore;
  
  // Add randomization factor (0.95 - 1.05)
  const randomFactor = 0.95 + Math.random() * 0.1;
  
  return Math.round(finalScore * randomFactor * 100) / 100;
}

/**
 * Get common interests between two users
 */
export function getCommonInterests(
  user1InterestIds: string[],
  user2InterestIds: string[]
): string[] {
  return user1InterestIds.filter(id => user2InterestIds.includes(id));
}
