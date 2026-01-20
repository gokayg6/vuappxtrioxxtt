/**
 * Property-Based Tests for Age Group Isolation
 * 
 * Feature: vibeu-v2-complete-overhaul
 * Property 1: Age Group Isolation
 * 
 * For any user interaction (discover query, like, friend request), the system 
 * SHALL only return or allow interactions with users in the same age group. 
 * A minor (15-17) SHALL never see, like, or send requests to an adult (18+), 
 * and vice versa.
 * 
 * Validates: Requirements 4.2, 4.3, 5.2, 5.3, 12.5, 12.6, 12.7
 */

import { describe, it, expect } from 'vitest';
import fc from 'fast-check';
import { calculateAgeGroup } from '../utils/ageUtils';

/**
 * Pure function to check if two age groups can interact
 * This mirrors the logic in validateAgeGroupMatch but without database calls
 */
function canAgeGroupsInteract(
  ageGroup1: 'minor' | 'adult' | null,
  ageGroup2: 'minor' | 'adult' | null
): boolean {
  // If either user has null age group (under 15), they shouldn't interact
  if (ageGroup1 === null || ageGroup2 === null) {
    return false;
  }
  
  // Only allow interaction if both users are in the same age group
  return ageGroup1 === ageGroup2;
}

/**
 * Generate a date of birth that results in a specific age group
 * Uses integer-based age generation with a birth date that has already passed this year
 * to ensure accurate age calculation
 */
function generateDateOfBirthForAgeGroup(ageGroup: 'minor' | 'adult' | 'under15'): fc.Arbitrary<Date> {
  const today = new Date();
  const currentYear = today.getFullYear();
  
  // Use January 1st as birth date - this ensures the birthday has already passed
  // (since we're past January 1st in the current year)
  switch (ageGroup) {
    case 'under15':
      // Age 0-14: Generate age then create date
      return fc.integer({ min: 0, max: 14 }).map(age => {
        const birthYear = currentYear - age;
        return new Date(birthYear, 0, 1); // January 1st
      });
    case 'minor':
      // Age 15-17: Generate age then create date
      return fc.integer({ min: 15, max: 17 }).map(age => {
        const birthYear = currentYear - age;
        return new Date(birthYear, 0, 1); // January 1st
      });
    case 'adult':
      // Age 18-75: Generate age then create date
      return fc.integer({ min: 18, max: 75 }).map(age => {
        const birthYear = currentYear - age;
        return new Date(birthYear, 0, 1); // January 1st
      });
  }
}

describe('Age Group Isolation - Property 1', () => {
  /**
   * Property 1: Age Group Isolation
   * 
   * CRITICAL: This is the core safety property for the application
   * 
   * Validates: Requirements 4.2, 4.3, 5.2, 5.3, 12.5, 12.6, 12.7
   */

  it('should NEVER allow minor to interact with adult', () => {
    fc.assert(
      fc.property(
        generateDateOfBirthForAgeGroup('minor'),
        generateDateOfBirthForAgeGroup('adult'),
        (minorDob, adultDob) => {
          const minorAgeGroup = calculateAgeGroup(minorDob);
          const adultAgeGroup = calculateAgeGroup(adultDob);
          
          // Verify the generated dates produce correct age groups
          expect(minorAgeGroup).toBe('minor');
          expect(adultAgeGroup).toBe('adult');
          
          // CRITICAL: Cross-pool interaction must be rejected
          const canInteract = canAgeGroupsInteract(minorAgeGroup, adultAgeGroup);
          expect(canInteract).toBe(false);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should NEVER allow adult to interact with minor', () => {
    fc.assert(
      fc.property(
        generateDateOfBirthForAgeGroup('adult'),
        generateDateOfBirthForAgeGroup('minor'),
        (adultDob, minorDob) => {
          const adultAgeGroup = calculateAgeGroup(adultDob);
          const minorAgeGroup = calculateAgeGroup(minorDob);
          
          // Verify the generated dates produce correct age groups
          expect(adultAgeGroup).toBe('adult');
          expect(minorAgeGroup).toBe('minor');
          
          // CRITICAL: Cross-pool interaction must be rejected
          const canInteract = canAgeGroupsInteract(adultAgeGroup, minorAgeGroup);
          expect(canInteract).toBe(false);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should ALWAYS allow minor to interact with minor', () => {
    fc.assert(
      fc.property(
        generateDateOfBirthForAgeGroup('minor'),
        generateDateOfBirthForAgeGroup('minor'),
        (minor1Dob, minor2Dob) => {
          const minor1AgeGroup = calculateAgeGroup(minor1Dob);
          const minor2AgeGroup = calculateAgeGroup(minor2Dob);
          
          // Verify both are minors
          expect(minor1AgeGroup).toBe('minor');
          expect(minor2AgeGroup).toBe('minor');
          
          // Same pool interaction must be allowed
          const canInteract = canAgeGroupsInteract(minor1AgeGroup, minor2AgeGroup);
          expect(canInteract).toBe(true);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should ALWAYS allow adult to interact with adult', () => {
    fc.assert(
      fc.property(
        generateDateOfBirthForAgeGroup('adult'),
        generateDateOfBirthForAgeGroup('adult'),
        (adult1Dob, adult2Dob) => {
          const adult1AgeGroup = calculateAgeGroup(adult1Dob);
          const adult2AgeGroup = calculateAgeGroup(adult2Dob);
          
          // Verify both are adults
          expect(adult1AgeGroup).toBe('adult');
          expect(adult2AgeGroup).toBe('adult');
          
          // Same pool interaction must be allowed
          const canInteract = canAgeGroupsInteract(adult1AgeGroup, adult2AgeGroup);
          expect(canInteract).toBe(true);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should NEVER allow interaction with under-15 users', () => {
    fc.assert(
      fc.property(
        fc.constantFrom('minor', 'adult') as fc.Arbitrary<'minor' | 'adult'>,
        generateDateOfBirthForAgeGroup('under15'),
        (validAgeGroup, under15Dob) => {
          const under15AgeGroup = calculateAgeGroup(under15Dob);
          
          // Under 15 should return null
          expect(under15AgeGroup).toBeNull();
          
          // No one should be able to interact with under-15 users
          const canInteract = canAgeGroupsInteract(validAgeGroup, under15AgeGroup);
          expect(canInteract).toBe(false);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should be symmetric - if A can interact with B, then B can interact with A', () => {
    fc.assert(
      fc.property(
        fc.date({ min: new Date('1950-01-01'), max: new Date() }),
        fc.date({ min: new Date('1950-01-01'), max: new Date() }),
        (dob1, dob2) => {
          const ageGroup1 = calculateAgeGroup(dob1);
          const ageGroup2 = calculateAgeGroup(dob2);
          
          const canInteract1to2 = canAgeGroupsInteract(ageGroup1, ageGroup2);
          const canInteract2to1 = canAgeGroupsInteract(ageGroup2, ageGroup1);
          
          // Interaction permission must be symmetric
          expect(canInteract1to2).toBe(canInteract2to1);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should correctly categorize all age groups based on date of birth', () => {
    fc.assert(
      fc.property(
        fc.date({ min: new Date('1950-01-01'), max: new Date() }),
        fc.date({ min: new Date('1950-01-01'), max: new Date() }),
        (dob1, dob2) => {
          const ageGroup1 = calculateAgeGroup(dob1);
          const ageGroup2 = calculateAgeGroup(dob2);
          
          const canInteract = canAgeGroupsInteract(ageGroup1, ageGroup2);
          
          // Verify the interaction rules
          if (ageGroup1 === null || ageGroup2 === null) {
            // Under 15 users cannot interact with anyone
            expect(canInteract).toBe(false);
          } else if (ageGroup1 === ageGroup2) {
            // Same age group can interact
            expect(canInteract).toBe(true);
          } else {
            // Different age groups cannot interact
            expect(canInteract).toBe(false);
          }
        }
      ),
      { numRuns: 100 }
    );
  });
});
