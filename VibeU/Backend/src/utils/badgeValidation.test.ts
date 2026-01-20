/**
 * Property-Based Tests for Badge Selection Limit
 * 
 * Feature: vibeu-v2-complete-overhaul
 * Property 11: Badge Selection Limit
 * Validates: Requirements 2.3
 * 
 * For any user, the number of selected emoji badges SHALL be at most 5.
 * Attempting to select a 6th badge SHALL be rejected.
 */

import { describe, it, expect } from 'vitest';
import fc from 'fast-check';
import {
  MAX_BADGES,
  VALID_BADGE_NAMES,
  isValidBadgeCount,
  isValidBadgeName,
  validateBadges,
  canAddBadge,
  truncateBadges,
  getRemainingBadgeSlots
} from './badgeValidation';

// Arbitrary for generating valid badge arrays
const validBadgeArb = fc.constantFrom(...VALID_BADGE_NAMES);
const validBadgeArrayArb = fc.array(validBadgeArb, { minLength: 0, maxLength: MAX_BADGES });
const oversizedBadgeArrayArb = fc.array(validBadgeArb, { minLength: MAX_BADGES + 1, maxLength: MAX_BADGES + 5 });

describe('Badge Selection Limit - Property 11', () => {
  /**
   * Property 11: Badge Selection Limit
   * 
   * For any user, the number of selected emoji badges SHALL be at most 5.
   * Attempting to select a 6th badge SHALL be rejected.
   * 
   * Validates: Requirements 2.3
   */

  it('should accept any badge array with 5 or fewer badges', () => {
    fc.assert(
      fc.property(validBadgeArrayArb, (badges) => {
        const result = isValidBadgeCount(badges);
        expect(result).toBe(true);
        expect(badges.length).toBeLessThanOrEqual(MAX_BADGES);
      }),
      { numRuns: 100 }
    );
  });

  it('should reject any badge array with more than 5 badges', () => {
    fc.assert(
      fc.property(oversizedBadgeArrayArb, (badges) => {
        const result = isValidBadgeCount(badges);
        expect(result).toBe(false);
        expect(badges.length).toBeGreaterThan(MAX_BADGES);
      }),
      { numRuns: 100 }
    );
  });

  it('should validate all predefined badge names as valid', () => {
    fc.assert(
      fc.property(validBadgeArb, (badge) => {
        const result = isValidBadgeName(badge);
        expect(result).toBe(true);
      }),
      { numRuns: 100 }
    );
  });

  it('should reject invalid badge names', () => {
    fc.assert(
      fc.property(
        fc.string().filter(s => !VALID_BADGE_NAMES.includes(s)),
        (invalidBadge) => {
          const result = isValidBadgeName(invalidBadge);
          expect(result).toBe(false);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should prevent adding a 6th badge when at max capacity', () => {
    fc.assert(
      fc.property(
        fc.shuffledSubarray(VALID_BADGE_NAMES, { minLength: MAX_BADGES, maxLength: MAX_BADGES }),
        validBadgeArb,
        (currentBadges, newBadge) => {
          const result = canAddBadge(currentBadges, newBadge);
          expect(result).toBe(false);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should allow adding a badge when under max capacity', () => {
    fc.assert(
      fc.property(
        fc.shuffledSubarray(VALID_BADGE_NAMES, { minLength: 0, maxLength: MAX_BADGES - 1 }),
        (currentBadges) => {
          // Find a badge not in current selection
          const availableBadge = VALID_BADGE_NAMES.find(b => !currentBadges.includes(b));
          if (availableBadge) {
            const result = canAddBadge(currentBadges, availableBadge);
            expect(result).toBe(true);
          }
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should truncate badge array to exactly 5 when exceeding limit', () => {
    fc.assert(
      fc.property(oversizedBadgeArrayArb, (badges) => {
        const truncated = truncateBadges(badges);
        expect(truncated.length).toBe(MAX_BADGES);
        expect(truncated).toEqual(badges.slice(0, MAX_BADGES));
      }),
      { numRuns: 100 }
    );
  });

  it('should not modify badge array that is within the limit', () => {
    fc.assert(
      fc.property(validBadgeArrayArb, (badges) => {
        const truncated = truncateBadges(badges);
        expect(truncated).toEqual(badges);
        expect(truncated.length).toBe(badges.length);
      }),
      { numRuns: 100 }
    );
  });

  it('should correctly calculate remaining badge slots', () => {
    fc.assert(
      fc.property(
        fc.array(validBadgeArb, { minLength: 0, maxLength: MAX_BADGES + 3 }),
        (badges) => {
          const remaining = getRemainingBadgeSlots(badges);
          const expected = Math.max(0, MAX_BADGES - badges.length);
          expect(remaining).toBe(expected);
          expect(remaining).toBeGreaterThanOrEqual(0);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should return consistent validation results for any badge array', () => {
    fc.assert(
      fc.property(
        fc.array(fc.oneof(validBadgeArb, fc.string()), { minLength: 0, maxLength: 10 }),
        (badges) => {
          const result = validateBadges(badges);
          
          // Count should match input length
          expect(result.count).toBe(badges.length);
          
          // Valid + invalid should equal total
          expect(result.validBadges.length + result.invalidBadges.length).toBe(badges.length);
          
          // exceededBy should be correct
          if (badges.length <= MAX_BADGES) {
            expect(result.exceededBy).toBe(0);
          } else {
            expect(result.exceededBy).toBe(badges.length - MAX_BADGES);
          }
          
          // isValid should be true only if count <= 5 AND no invalid badges
          const expectedValid = badges.length <= MAX_BADGES && result.invalidBadges.length === 0;
          expect(result.isValid).toBe(expectedValid);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should handle null and undefined badge arrays gracefully', () => {
    expect(isValidBadgeCount(null as any)).toBe(true);
    expect(isValidBadgeCount(undefined as any)).toBe(true);
    expect(truncateBadges(null as any)).toEqual([]);
    expect(truncateBadges(undefined as any)).toEqual([]);
    expect(getRemainingBadgeSlots(null as any)).toBe(MAX_BADGES);
    expect(getRemainingBadgeSlots(undefined as any)).toBe(MAX_BADGES);
  });

  it('should prevent adding duplicate badges', () => {
    fc.assert(
      fc.property(
        fc.shuffledSubarray(VALID_BADGE_NAMES, { minLength: 1, maxLength: MAX_BADGES - 1 }),
        (currentBadges) => {
          // Try to add a badge that's already selected
          const duplicateBadge = currentBadges[0];
          const result = canAddBadge(currentBadges, duplicateBadge);
          expect(result).toBe(false);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should be idempotent - truncating twice yields same result', () => {
    fc.assert(
      fc.property(
        fc.array(validBadgeArb, { minLength: 0, maxLength: 10 }),
        (badges) => {
          const truncated1 = truncateBadges(badges);
          const truncated2 = truncateBadges(truncated1);
          const truncated3 = truncateBadges(truncated2);
          
          expect(truncated1).toEqual(truncated2);
          expect(truncated2).toEqual(truncated3);
        }
      ),
      { numRuns: 100 }
    );
  });
});
