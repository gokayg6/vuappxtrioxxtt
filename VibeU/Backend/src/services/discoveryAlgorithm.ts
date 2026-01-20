/**
 * Discovery Algorithm Service
 * 
 * Calculates discovery scores for user matching based on various factors.
 * Supports both Local and Global modes with different weight configurations.
 * 
 * Requirements: 10.1, 10.2, 10.3, 10.5, 10.6, 10.7, 10.8, 10.9
 */

import { calculateAge } from '../utils/ageUtils';

/**
 * Score weights configuration for discovery algorithm
 */
export interface ScoreWeights {
  age: number;
  location: number;
  interest: number;
  activity: number;
  profileQuality: number;
}

/**
 * Local mode weights - prioritizes location proximity
 * Requirements: 10.2
 */
export const LOCAL_WEIGHTS: ScoreWeights = {
  age: 100,
  location: 70,
  interest: 50,
  activity: 20,
  profileQuality: 30,
};

/**
 * Global mode weights - prioritizes interests over location
 * Requirements: 10.3
 */
export const GLOBAL_WEIGHTS: ScoreWeights = {
  age: 80,
  location: 0,
  interest: 80,
  activity: 40,
  profileQuality: 30,
};

/**
 * User data required for score calculation
 */
export interface DiscoveryUser {
  id: string;
  dateOfBirth: Date;
  country: string;
  city: string;
  tags: { tagCode: string }[];
  lastActiveAt: Date;
  photos: { id: string }[];
}

/**
 * Calculate hours difference between two dates
 */
export function getHoursDiff(date1: Date, date2: Date): number {
  const diffMs = Math.abs(date2.getTime() - date1.getTime());
  return diffMs / (1000 * 60 * 60);
}

/**
 * Calculate age score based on age proximity
 * Higher scores for users with closer ages
 * 
 * Formula: max(0, baseWeight - ageDifference * 10)
 * Requirements: 10.5
 * 
 * @param currentUserAge - Current user's age
 * @param targetUserAge - Target user's age
 * @param baseWeight - Base weight for age score
 * @returns Age score (0 to baseWeight)
 */
export function calculateAgeScore(
  currentUserAge: number,
  targetUserAge: number,
  baseWeight: number
): number {
  const ageDiff = Math.abs(currentUserAge - targetUserAge);
  return Math.max(0, baseWeight - ageDiff * 10);
}

/**
 * Calculate location score based on geographic proximity
 * - Same city: full points
 * - Same country: half points
 * - Different country: zero points
 * 
 * Requirements: 10.6
 * 
 * @param currentUserCity - Current user's city
 * @param currentUserCountry - Current user's country
 * @param targetUserCity - Target user's city
 * @param targetUserCountry - Target user's country
 * @param weight - Weight for location score
 * @returns Location score (0, weight/2, or weight)
 */
export function calculateLocationScore(
  currentUserCity: string,
  currentUserCountry: string,
  targetUserCity: string,
  targetUserCountry: string,
  weight: number
): number {
  if (currentUserCity === targetUserCity) {
    return weight;
  }
  if (currentUserCountry === targetUserCountry) {
    return weight * 0.5;
  }
  return 0;
}

/**
 * Calculate interest score based on common badges/emoji
 * 
 * Formula: (commonBadges / 5) * weight
 * Requirements: 10.7
 * 
 * @param currentUserTags - Current user's badge codes
 * @param targetUserTags - Target user's badge codes
 * @param weight - Weight for interest score
 * @returns Interest score (0 to weight)
 */
export function calculateInterestScore(
  currentUserTags: string[],
  targetUserTags: string[],
  weight: number
): number {
  const currentBadges = new Set(currentUserTags);
  const commonBadges = targetUserTags.filter(tag => currentBadges.has(tag)).length;
  return (commonBadges / 5) * weight;
}

/**
 * Calculate activity score based on last active time
 * - Active in last 24 hours: full points
 * - Otherwise: 30% of points
 * 
 * Requirements: 10.8
 * 
 * @param lastActiveAt - Target user's last active timestamp
 * @param weight - Weight for activity score
 * @returns Activity score (weight * 0.3 or weight)
 */
export function calculateActivityScore(
  lastActiveAt: Date,
  weight: number
): number {
  const hoursSinceActive = getHoursDiff(lastActiveAt, new Date());
  return hoursSinceActive < 24 ? weight : weight * 0.3;
}

/**
 * Calculate profile quality score based on photo count
 * 
 * Formula: (photoCount / 5) * weight
 * More photos = higher quality score
 * Requirements: 10.9
 * 
 * @param photoCount - Number of photos in profile
 * @param weight - Weight for profile quality score
 * @returns Profile quality score (0 to weight)
 */
export function calculateProfileQualityScore(
  photoCount: number,
  weight: number
): number {
  const normalizedCount = Math.min(photoCount, 5);
  return (normalizedCount / 5) * weight;
}

/**
 * Calculate total discovery score for a target user
 * 
 * The score is the sum of:
 * - Age score (yaş yakınlığı)
 * - Location score (konum yakınlığı)
 * - Interest score (ortak ilgi alanları/emoji eşleşmesi)
 * - Activity score (aktiflik durumu)
 * - Profile quality score (profil kalitesi - fotoğraf sayısı)
 * 
 * Requirements: 10.1, 10.2, 10.3, 10.5, 10.6, 10.7, 10.8, 10.9
 * 
 * @param currentUser - Current user data
 * @param targetUser - Target user data
 * @param mode - Discovery mode ('local' or 'global')
 * @returns Total discovery score
 */
export function calculateDiscoveryScore(
  currentUser: DiscoveryUser,
  targetUser: DiscoveryUser,
  mode: 'local' | 'global'
): number {
  const weights = mode === 'local' ? LOCAL_WEIGHTS : GLOBAL_WEIGHTS;
  
  // Calculate current user's age
  const currentUserAge = calculateAge(currentUser.dateOfBirth);
  const targetUserAge = calculateAge(targetUser.dateOfBirth);
  
  // Extract tag codes
  const currentUserTags = currentUser.tags.map(t => t.tagCode);
  const targetUserTags = targetUser.tags.map(t => t.tagCode);
  
  // Calculate individual scores
  const ageScore = calculateAgeScore(currentUserAge, targetUserAge, weights.age);
  
  const locationScore = calculateLocationScore(
    currentUser.city,
    currentUser.country,
    targetUser.city,
    targetUser.country,
    weights.location
  );
  
  const interestScore = calculateInterestScore(
    currentUserTags,
    targetUserTags,
    weights.interest
  );
  
  const activityScore = calculateActivityScore(
    targetUser.lastActiveAt,
    weights.activity
  );
  
  const profileQualityScore = calculateProfileQualityScore(
    targetUser.photos.length,
    weights.profileQuality
  );
  
  // Sum all scores
  return ageScore + locationScore + interestScore + activityScore + profileQualityScore;
}

/**
 * Rank users by discovery score in descending order
 * 
 * Requirements: 10.10
 * 
 * @param currentUser - Current user data
 * @param targetUsers - Array of target users to rank
 * @param mode - Discovery mode ('local' or 'global')
 * @returns Array of users with scores, sorted by score descending
 */
export function rankUsersByScore(
  currentUser: DiscoveryUser,
  targetUsers: DiscoveryUser[],
  mode: 'local' | 'global'
): Array<{ user: DiscoveryUser; score: number }> {
  const usersWithScores = targetUsers.map(targetUser => ({
    user: targetUser,
    score: calculateDiscoveryScore(currentUser, targetUser, mode),
  }));
  
  // Sort by score descending
  return usersWithScores.sort((a, b) => b.score - a.score);
}
