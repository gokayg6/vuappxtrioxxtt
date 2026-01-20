/**
 * Badge Validation Utilities
 * 
 * Validates badge selection according to requirements:
 * - Maximum 5 badges per user
 * - Only predefined badges are allowed
 * 
 * Requirements: 2.3
 */

export const MAX_BADGES = 5;

// Predefined badge list
export const AVAILABLE_BADGES = [
  { emoji: '🔥', name: 'Enerjik' },
  { emoji: '🎮', name: 'Gamer' },
  { emoji: '🎧', name: 'Müzikçi' },
  { emoji: '📸', name: 'Estetik' },
  { emoji: '🤝', name: 'Sosyal' },
  { emoji: '😂', name: 'Komik' },
  { emoji: '💪', name: 'Sporcu' },
  { emoji: '📚', name: 'Kitap Kurdu' },
  { emoji: '🎬', name: 'Sinefil' },
  { emoji: '✈️', name: 'Gezgin' }
] as const;

export const VALID_BADGE_NAMES = AVAILABLE_BADGES.map(b => b.name);

/**
 * Validates if the badge count is within the limit
 * @param badges - Array of badge names
 * @returns true if badge count is 5 or less, false otherwise
 */
export function isValidBadgeCount(badges: string[]): boolean {
  if (!badges || !Array.isArray(badges)) {
    return true; // Empty/null is valid
  }
  return badges.length <= MAX_BADGES;
}

/**
 * Validates if a badge name is in the predefined list
 * @param badgeName - The badge name to validate
 * @returns true if badge is valid, false otherwise
 */
export function isValidBadgeName(badgeName: string): boolean {
  return VALID_BADGE_NAMES.includes(badgeName);
}

/**
 * Validates all badges in an array
 * @param badges - Array of badge names
 * @returns true if all badges are valid and count is within limit
 */
export function validateBadges(badges: string[]): {
  isValid: boolean;
  validBadges: string[];
  invalidBadges: string[];
  count: number;
  exceededBy: number;
} {
  if (!badges || !Array.isArray(badges)) {
    return {
      isValid: true,
      validBadges: [],
      invalidBadges: [],
      count: 0,
      exceededBy: 0
    };
  }

  const validBadges = badges.filter(b => isValidBadgeName(b));
  const invalidBadges = badges.filter(b => !isValidBadgeName(b));
  const count = badges.length;
  const exceededBy = Math.max(0, count - MAX_BADGES);
  
  const isValid = count <= MAX_BADGES && invalidBadges.length === 0;

  return {
    isValid,
    validBadges,
    invalidBadges,
    count,
    exceededBy
  };
}

/**
 * Checks if a new badge can be added
 * @param currentBadges - Current badge array
 * @param newBadge - Badge to add
 * @returns true if badge can be added, false otherwise
 */
export function canAddBadge(currentBadges: string[], newBadge: string): boolean {
  if (!currentBadges || !Array.isArray(currentBadges)) {
    return isValidBadgeName(newBadge);
  }
  
  // Check if already at max
  if (currentBadges.length >= MAX_BADGES) {
    return false;
  }
  
  // Check if badge is valid
  if (!isValidBadgeName(newBadge)) {
    return false;
  }
  
  // Check if already selected
  if (currentBadges.includes(newBadge)) {
    return false;
  }
  
  return true;
}

/**
 * Truncates badge array to maximum allowed
 * @param badges - Array of badge names
 * @returns Truncated array with max 5 badges
 */
export function truncateBadges(badges: string[]): string[] {
  if (!badges || !Array.isArray(badges)) {
    return [];
  }
  return badges.slice(0, MAX_BADGES);
}

/**
 * Gets remaining badge slots
 * @param badges - Current badge array
 * @returns Number of remaining slots (0 if at max)
 */
export function getRemainingBadgeSlots(badges: string[]): number {
  if (!badges || !Array.isArray(badges)) {
    return MAX_BADGES;
  }
  return Math.max(0, MAX_BADGES - badges.length);
}
