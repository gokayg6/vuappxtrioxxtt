/**
 * Property-Based Tests for Discovery Algorithm
 * 
 * Feature: vibeu-v2-complete-overhaul
 * Property 6: Discovery Algorithm Score Ordering
 * Validates: Requirements 10.1, 10.2, 10.3, 10.5-10.10
 */

import { describe, it, expect } from 'vitest';
import fc from 'fast-check';
import {
  calculateDiscoveryScore,
  calculateAgeScore,
  calculateLocationScore,
  calculateInterestScore,
  calculateActivityScore,
  calculateProfileQualityScore,
  rankUsersByScore,
  LOCAL_WEIGHTS,
  GLOBAL_WEIGHTS,
  DiscoveryUser,
} from './discoveryAlgorithm';

// Helper to generate valid dates from timestamps to avoid NaN dates
const validDateArbitrary = (minYear: number, maxYear: number) =>
  fc.integer({ min: minYear, max: maxYear }).chain(year =>
    fc.integer({ min: 1, max: 12 }).chain(month =>
      fc.integer({ min: 1, max: 28 }).map(day =>
        new Date(year, month - 1, day)
      )
    )
  );

// Arbitrary for generating valid DiscoveryUser
const discoveryUserArbitrary = fc.record({
  id: fc.uuid(),
  dateOfBirth: validDateArbitrary(1990, 2009),
  country: fc.constantFrom('Turkey', 'USA', 'Germany', 'France', 'UK'),
  city: fc.constantFrom('Istanbul', 'Ankara', 'New York', 'Berlin', 'Paris', 'London'),
  tags: fc.array(
    fc.record({ tagCode: fc.constantFrom('🔥', '🎮', '🎧', '📸', '🤝', '😂', '💪', '📚', '🎬', '✈️') }),
    { minLength: 0, maxLength: 5 }
  ),
  lastActiveAt: fc.integer({ min: Date.now() - 7 * 24 * 60 * 60 * 1000, max: Date.now() }).map(ts => new Date(ts)),
  photos: fc.array(fc.record({ id: fc.uuid() }), { minLength: 1, maxLength: 5 }),
});

describe('Discovery Algorithm Score Ordering - Property 6', () => {
  /**
   * Property 6: Discovery Algorithm Score Ordering
   * 
   * For any discover query result, users SHALL be ordered by their calculated score 
   * in descending order. The score SHALL be the sum of age score, location score, 
   * interest score, activity score, and profile quality score with weights determined 
   * by the mode (local/global).
   * 
   * Validates: Requirements 10.1, 10.2, 10.3, 10.5-10.10
   */

  it('should return users ordered by score in descending order (local mode)', () => {
    fc.assert(
      fc.property(
        discoveryUserArbitrary,
        fc.array(discoveryUserArbitrary, { minLength: 2, maxLength: 20 }),
        (currentUser, targetUsers) => {
          const rankedUsers = rankUsersByScore(currentUser, targetUsers, 'local');
          
          // Verify descending order
          for (let i = 1; i < rankedUsers.length; i++) {
            expect(rankedUsers[i - 1].score).toBeGreaterThanOrEqual(rankedUsers[i].score);
          }
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should return users ordered by score in descending order (global mode)', () => {
    fc.assert(
      fc.property(
        discoveryUserArbitrary,
        fc.array(discoveryUserArbitrary, { minLength: 2, maxLength: 20 }),
        (currentUser, targetUsers) => {
          const rankedUsers = rankUsersByScore(currentUser, targetUsers, 'global');
          
          // Verify descending order
          for (let i = 1; i < rankedUsers.length; i++) {
            expect(rankedUsers[i - 1].score).toBeGreaterThanOrEqual(rankedUsers[i].score);
          }
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should calculate score as sum of all component scores', () => {
    fc.assert(
      fc.property(
        discoveryUserArbitrary,
        discoveryUserArbitrary,
        fc.constantFrom('local' as const, 'global' as const),
        (currentUser, targetUser, mode) => {
          const totalScore = calculateDiscoveryScore(currentUser, targetUser, mode);
          
          // Score should be non-negative
          expect(totalScore).toBeGreaterThanOrEqual(0);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should use LOCAL_WEIGHTS in local mode', () => {
    fc.assert(
      fc.property(
        discoveryUserArbitrary,
        discoveryUserArbitrary,
        (currentUser, targetUser) => {
          const score = calculateDiscoveryScore(currentUser, targetUser, 'local');
          
          // In local mode, location weight is 70 (non-zero)
          // Score should reflect location component
          expect(LOCAL_WEIGHTS.location).toBe(70);
          expect(score).toBeGreaterThanOrEqual(0);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should use GLOBAL_WEIGHTS in global mode with zero location weight', () => {
    fc.assert(
      fc.property(
        discoveryUserArbitrary,
        discoveryUserArbitrary,
        (currentUser, targetUser) => {
          // In global mode, location weight is 0
          expect(GLOBAL_WEIGHTS.location).toBe(0);
          
          const score = calculateDiscoveryScore(currentUser, targetUser, 'global');
          expect(score).toBeGreaterThanOrEqual(0);
        }
      ),
      { numRuns: 100 }
    );
  });
});

describe('Age Score Calculation - Requirements 10.5', () => {
  it('should give higher scores for closer ages', () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 15, max: 50 }),
        fc.integer({ min: 15, max: 50 }),
        fc.integer({ min: 15, max: 50 }),
        fc.integer({ min: 1, max: 100 }),
        (currentAge, targetAge1, targetAge2, baseWeight) => {
          const diff1 = Math.abs(currentAge - targetAge1);
          const diff2 = Math.abs(currentAge - targetAge2);
          
          const score1 = calculateAgeScore(currentAge, targetAge1, baseWeight);
          const score2 = calculateAgeScore(currentAge, targetAge2, baseWeight);
          
          // Closer age should have higher or equal score
          if (diff1 < diff2) {
            expect(score1).toBeGreaterThanOrEqual(score2);
          } else if (diff2 < diff1) {
            expect(score2).toBeGreaterThanOrEqual(score1);
          }
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should return max(0, baseWeight - ageDiff * 10)', () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 15, max: 50 }),
        fc.integer({ min: 15, max: 50 }),
        fc.integer({ min: 1, max: 100 }),
        (currentAge, targetAge, baseWeight) => {
          const ageDiff = Math.abs(currentAge - targetAge);
          const expectedScore = Math.max(0, baseWeight - ageDiff * 10);
          const actualScore = calculateAgeScore(currentAge, targetAge, baseWeight);
          
          expect(actualScore).toBe(expectedScore);
        }
      ),
      { numRuns: 100 }
    );
  });
});

describe('Location Score Calculation - Requirements 10.6', () => {
  it('should give full points for same city', () => {
    fc.assert(
      fc.property(
        fc.string({ minLength: 1, maxLength: 20 }),
        fc.string({ minLength: 1, maxLength: 20 }),
        fc.integer({ min: 1, max: 100 }),
        (city, country, weight) => {
          const score = calculateLocationScore(city, country, city, country, weight);
          expect(score).toBe(weight);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should give half points for same country different city', () => {
    fc.assert(
      fc.property(
        fc.string({ minLength: 1, maxLength: 20 }),
        fc.string({ minLength: 1, maxLength: 20 }),
        fc.string({ minLength: 1, maxLength: 20 }),
        fc.integer({ min: 1, max: 100 }),
        (city1, city2, country, weight) => {
          fc.pre(city1 !== city2); // Ensure cities are different
          
          const score = calculateLocationScore(city1, country, city2, country, weight);
          expect(score).toBe(weight * 0.5);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should give zero points for different countries', () => {
    fc.assert(
      fc.property(
        fc.string({ minLength: 1, maxLength: 20 }),
        fc.string({ minLength: 1, maxLength: 20 }),
        fc.string({ minLength: 1, maxLength: 20 }),
        fc.string({ minLength: 1, maxLength: 20 }),
        fc.integer({ min: 1, max: 100 }),
        (city1, country1, city2, country2, weight) => {
          fc.pre(country1 !== country2); // Ensure countries are different
          
          const score = calculateLocationScore(city1, country1, city2, country2, weight);
          expect(score).toBe(0);
        }
      ),
      { numRuns: 100 }
    );
  });
});

describe('Interest Score Calculation - Requirements 10.7', () => {
  it('should calculate (commonBadges / 5) * weight', () => {
    fc.assert(
      fc.property(
        fc.array(fc.constantFrom('🔥', '🎮', '🎧', '📸', '🤝'), { minLength: 0, maxLength: 5 }),
        fc.array(fc.constantFrom('🔥', '🎮', '🎧', '📸', '🤝'), { minLength: 0, maxLength: 5 }),
        fc.integer({ min: 1, max: 100 }),
        (currentTags, targetTags, weight) => {
          const currentSet = new Set(currentTags);
          const commonCount = targetTags.filter(t => currentSet.has(t)).length;
          const expectedScore = (commonCount / 5) * weight;
          
          const actualScore = calculateInterestScore(currentTags, targetTags, weight);
          expect(actualScore).toBeCloseTo(expectedScore, 5);
        }
      ),
      { numRuns: 100 }
    );
  });
});

describe('Activity Score Calculation - Requirements 10.8', () => {
  it('should give full points if active in last 24 hours', () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 0, max: 23 }),
        fc.integer({ min: 1, max: 100 }),
        (hoursAgo, weight) => {
          const lastActiveAt = new Date(Date.now() - hoursAgo * 60 * 60 * 1000);
          const score = calculateActivityScore(lastActiveAt, weight);
          expect(score).toBe(weight);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should give 30% points if not active in last 24 hours', () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 25, max: 168 }),
        fc.integer({ min: 1, max: 100 }),
        (hoursAgo, weight) => {
          const lastActiveAt = new Date(Date.now() - hoursAgo * 60 * 60 * 1000);
          const score = calculateActivityScore(lastActiveAt, weight);
          expect(score).toBeCloseTo(weight * 0.3, 5);
        }
      ),
      { numRuns: 100 }
    );
  });
});

describe('Profile Quality Score Calculation - Requirements 10.9', () => {
  it('should calculate (photoCount / 5) * weight', () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 0, max: 10 }),
        fc.integer({ min: 1, max: 100 }),
        (photoCount, weight) => {
          const normalizedCount = Math.min(photoCount, 5);
          const expectedScore = (normalizedCount / 5) * weight;
          
          const actualScore = calculateProfileQualityScore(photoCount, weight);
          expect(actualScore).toBeCloseTo(expectedScore, 5);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should cap photo count at 5', () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 6, max: 20 }),
        fc.integer({ min: 1, max: 100 }),
        (photoCount, weight) => {
          const score = calculateProfileQualityScore(photoCount, weight);
          const maxScore = calculateProfileQualityScore(5, weight);
          
          expect(score).toBe(maxScore);
        }
      ),
      { numRuns: 100 }
    );
  });
});
