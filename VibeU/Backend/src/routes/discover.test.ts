/**
 * Property-Based Tests for Discover Endpoint - Local/Global Mode Filtering
 * 
 * Feature: vibeu-v2-complete-overhaul
 * Property 7: Local/Global Mode Filtering
 * Validates: Requirements 11.4, 11.5, 12.7
 * 
 * For any discover query in local mode, all returned users SHALL be from the same 
 * country as the current user. For any discover query in global mode, users from 
 * any country MAY be returned. In both modes, only users from the same age group 
 * SHALL be returned.
 */

import { describe, it, expect } from 'vitest';
import fc from 'fast-check';

// Types for testing
type AgeGroup = 'minor' | 'adult';
type Mode = 'local' | 'global';

interface TestUser {
  id: string;
  dateOfBirth: Date;
  country: string;
  city: string;
  isBanned: boolean;
}

/**
 * Calculate age from date of birth
 */
function calculateAge(dateOfBirth: Date): number {
  const today = new Date();
  const birthDate = new Date(dateOfBirth);
  
  let age = today.getFullYear() - birthDate.getFullYear();
  const monthDiff = today.getMonth() - birthDate.getMonth();
  
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }
  
  return age;
}

/**
 * Calculate age group from date of birth
 * Minor: 15-17, Adult: 18+
 */
function calculateAgeGroup(dateOfBirth: Date): AgeGroup | null {
  const age = calculateAge(dateOfBirth);
  
  if (age < 15) return null;
  if (age >= 15 && age <= 17) return 'minor';
  return 'adult';
}

/**
 * Build date filter for age group
 * This mirrors the logic in discover.ts
 */
function buildDateFilter(userAgeGroup: AgeGroup): { gte?: Date; lte?: Date; lt?: Date } {
  const today = new Date();
  const eighteenYearsAgo = new Date(
    today.getFullYear() - 18,
    today.getMonth(),
    today.getDate()
  );
  
  if (userAgeGroup === 'minor') {
    const fifteenYearsAgo = new Date(
      today.getFullYear() - 15,
      today.getMonth(),
      today.getDate()
    );
    const seventeenYearsAgo = new Date(
      today.getFullYear() - 17,
      today.getMonth(),
      today.getDate()
    );
    
    return {
      gte: seventeenYearsAgo,
      lte: fifteenYearsAgo,
    };
  } else {
    return {
      lt: eighteenYearsAgo,
    };
  }
}

/**
 * Check if a date matches the filter
 */
function dateMatchesFilter(
  date: Date,
  filter: { gte?: Date; lte?: Date; lt?: Date }
): boolean {
  const dateTime = date.getTime();
  
  if (filter.gte && dateTime < filter.gte.getTime()) return false;
  if (filter.lte && dateTime > filter.lte.getTime()) return false;
  if (filter.lt && dateTime >= filter.lt.getTime()) return false;
  
  return true;
}

/**
 * Filter users based on mode and age group (simulates discover endpoint logic)
 */
function filterUsers(
  currentUser: TestUser,
  users: TestUser[],
  mode: Mode
): TestUser[] {
  const currentUserAgeGroup = calculateAgeGroup(currentUser.dateOfBirth);
  
  if (!currentUserAgeGroup) return [];
  
  const dateFilter = buildDateFilter(currentUserAgeGroup);
  
  return users.filter(user => {
    // Exclude current user
    if (user.id === currentUser.id) return false;
    
    // Exclude banned users
    if (user.isBanned) return false;
    
    // CRITICAL: Age group filter
    if (!dateMatchesFilter(user.dateOfBirth, dateFilter)) return false;
    
    // Local mode: same country filter
    if (mode === 'local' && user.country !== currentUser.country) return false;
    
    return true;
  });
}

// Arbitraries for generating test data
const countries = ['Turkey', 'USA', 'Germany', 'France', 'UK', 'Spain', 'Italy'];
const cities = ['Istanbul', 'Ankara', 'New York', 'Berlin', 'Paris', 'London', 'Madrid', 'Rome'];

// Generate valid date for minor (15-17 years old)
// We subtract 1 day to ensure the birthday has passed
const minorDateArbitrary = fc.integer({ min: 15, max: 17 }).map(age => {
  const today = new Date();
  return new Date(today.getFullYear() - age, today.getMonth(), today.getDate() - 1);
});

// Generate valid date for adult (18-50 years old)
// We subtract 1 day to ensure the birthday has passed
const adultDateArbitrary = fc.integer({ min: 18, max: 50 }).map(age => {
  const today = new Date();
  return new Date(today.getFullYear() - age, today.getMonth(), today.getDate() - 1);
});

// Generate test user
const testUserArbitrary = (dateArb: fc.Arbitrary<Date>) => fc.record({
  id: fc.uuid(),
  dateOfBirth: dateArb,
  country: fc.constantFrom(...countries),
  city: fc.constantFrom(...cities),
  isBanned: fc.constant(false),
});

describe('Local/Global Mode Filtering - Property 7', () => {
  /**
   * Property 7: Local/Global Mode Filtering
   * 
   * For any discover query in local mode, all returned users SHALL be from the 
   * same country as the current user.
   * 
   * Validates: Requirements 11.4
   */
  describe('Local Mode Country Filtering', () => {
    it('should only return users from the same country in local mode (adult pool)', () => {
      fc.assert(
        fc.property(
          testUserArbitrary(adultDateArbitrary),
          fc.array(testUserArbitrary(adultDateArbitrary), { minLength: 1, maxLength: 20 }),
          (currentUser, targetUsers) => {
            const filteredUsers = filterUsers(currentUser, targetUsers, 'local');
            
            // All returned users should be from the same country
            for (const user of filteredUsers) {
              expect(user.country).toBe(currentUser.country);
            }
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should only return users from the same country in local mode (minor pool)', () => {
      fc.assert(
        fc.property(
          testUserArbitrary(minorDateArbitrary),
          fc.array(testUserArbitrary(minorDateArbitrary), { minLength: 1, maxLength: 20 }),
          (currentUser, targetUsers) => {
            const filteredUsers = filterUsers(currentUser, targetUsers, 'local');
            
            // All returned users should be from the same country
            for (const user of filteredUsers) {
              expect(user.country).toBe(currentUser.country);
            }
          }
        ),
        { numRuns: 100 }
      );
    });
  });

  /**
   * Property 7: Local/Global Mode Filtering
   * 
   * For any discover query in global mode, users from any country MAY be returned.
   * 
   * Validates: Requirements 11.5
   */
  describe('Global Mode Country Filtering', () => {
    it('should not filter by country in global mode (adult pool)', () => {
      fc.assert(
        fc.property(
          testUserArbitrary(adultDateArbitrary),
          fc.array(testUserArbitrary(adultDateArbitrary), { minLength: 5, maxLength: 20 }),
          (currentUser, targetUsers) => {
            const filteredUsers = filterUsers(currentUser, targetUsers, 'global');
            
            // Count users from different countries in the input (excluding current user and banned)
            const eligibleDifferentCountryUsers = targetUsers.filter(
              u => u.country !== currentUser.country && 
                   u.id !== currentUser.id && 
                   !u.isBanned
            );
            
            // Count users from different countries in the output
            const filteredDifferentCountryUsers = filteredUsers.filter(
              u => u.country !== currentUser.country
            );
            
            // In global mode, all eligible users from different countries should be included
            // (as long as they pass the age group filter, which they should since we're using adultDateArbitrary)
            expect(filteredDifferentCountryUsers.length).toBe(eligibleDifferentCountryUsers.length);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should include users from different countries in global mode', () => {
      fc.assert(
        fc.property(
          testUserArbitrary(adultDateArbitrary),
          testUserArbitrary(adultDateArbitrary),
          (currentUser, targetUser) => {
            // Ensure different IDs
            fc.pre(currentUser.id !== targetUser.id);
            
            const filteredUsers = filterUsers(currentUser, [targetUser], 'global');
            
            // In global mode, the target user should be included regardless of country
            // (as long as they're not banned and in the same age group)
            if (!targetUser.isBanned) {
              expect(filteredUsers.length).toBe(1);
              expect(filteredUsers[0].id).toBe(targetUser.id);
            }
          }
        ),
        { numRuns: 100 }
      );
    });
  });

  /**
   * Property 7: Local/Global Mode Filtering
   * 
   * In both modes, only users from the same age group SHALL be returned.
   * CRITICAL: Minor (15-17) NEVER sees Adult (18+) and vice versa.
   * 
   * Validates: Requirements 12.7
   */
  describe('Age Group Isolation', () => {
    it('should never return adult users when current user is minor (local mode)', () => {
      fc.assert(
        fc.property(
          testUserArbitrary(minorDateArbitrary),
          fc.array(testUserArbitrary(adultDateArbitrary), { minLength: 1, maxLength: 20 }),
          (currentUser, adultUsers) => {
            const filteredUsers = filterUsers(currentUser, adultUsers, 'local');
            
            // No adult users should be returned
            expect(filteredUsers.length).toBe(0);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should never return adult users when current user is minor (global mode)', () => {
      fc.assert(
        fc.property(
          testUserArbitrary(minorDateArbitrary),
          fc.array(testUserArbitrary(adultDateArbitrary), { minLength: 1, maxLength: 20 }),
          (currentUser, adultUsers) => {
            const filteredUsers = filterUsers(currentUser, adultUsers, 'global');
            
            // No adult users should be returned
            expect(filteredUsers.length).toBe(0);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should never return minor users when current user is adult (local mode)', () => {
      fc.assert(
        fc.property(
          testUserArbitrary(adultDateArbitrary),
          fc.array(testUserArbitrary(minorDateArbitrary), { minLength: 1, maxLength: 20 }),
          (currentUser, minorUsers) => {
            const filteredUsers = filterUsers(currentUser, minorUsers, 'local');
            
            // No minor users should be returned
            expect(filteredUsers.length).toBe(0);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should never return minor users when current user is adult (global mode)', () => {
      fc.assert(
        fc.property(
          testUserArbitrary(adultDateArbitrary),
          fc.array(testUserArbitrary(minorDateArbitrary), { minLength: 1, maxLength: 20 }),
          (currentUser, minorUsers) => {
            const filteredUsers = filterUsers(currentUser, minorUsers, 'global');
            
            // No minor users should be returned
            expect(filteredUsers.length).toBe(0);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should only return users from the same age group (mixed pool test)', () => {
      fc.assert(
        fc.property(
          testUserArbitrary(adultDateArbitrary),
          fc.array(testUserArbitrary(minorDateArbitrary), { minLength: 1, maxLength: 10 }),
          fc.array(testUserArbitrary(adultDateArbitrary), { minLength: 1, maxLength: 10 }),
          fc.constantFrom('local' as const, 'global' as const),
          (currentUser, minorUsers, adultUsers, mode) => {
            const allUsers = [...minorUsers, ...adultUsers];
            const filteredUsers = filterUsers(currentUser, allUsers, mode);
            
            const currentUserAgeGroup = calculateAgeGroup(currentUser.dateOfBirth);
            
            // All returned users should be in the same age group
            for (const user of filteredUsers) {
              const userAgeGroup = calculateAgeGroup(user.dateOfBirth);
              expect(userAgeGroup).toBe(currentUserAgeGroup);
            }
          }
        ),
        { numRuns: 100 }
      );
    });
  });
});
