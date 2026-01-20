/**
 * Property-Based Tests for Age Calculation
 * 
 * Feature: vibeu-v2-complete-overhaul
 * Property 2: Age Calculation Correctness
 * Validates: Requirements 1.4, 1.5, 12.1, 12.2
 */

import { describe, it, expect } from 'vitest';
import fc from 'fast-check';
import { calculateAge, calculateAgeGroup } from './ageUtils';

describe('Age Calculation Correctness - Property 2', () => {
  /**
   * Property 2: Age Calculation Correctness
   * 
   * For any valid date of birth, the calculated age SHALL equal the number of 
   * complete years between the birth date and today, and the age group SHALL be 
   * "minor" if age is 15-17, "adult" if age is 18+, and null (registration rejected) 
   * if age is below 15.
   * 
   * Validates: Requirements 1.4, 1.5, 12.1, 12.2
   */
  
  it('should calculate age as non-negative for any valid date of birth', () => {
    fc.assert(
      fc.property(
        fc.date({ min: new Date('1950-01-01'), max: new Date() }),
        (dateOfBirth) => {
          const age = calculateAge(dateOfBirth);
          expect(age).toBeGreaterThanOrEqual(0);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should return null for age group when age is below 15', () => {
    fc.assert(
      fc.property(
        fc.date({ min: new Date('1950-01-01'), max: new Date() }),
        (dateOfBirth) => {
          const age = calculateAge(dateOfBirth);
          const ageGroup = calculateAgeGroup(dateOfBirth);
          
          if (age < 15) {
            expect(ageGroup).toBeNull();
          }
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should return minor for age group when age is 15-17', () => {
    fc.assert(
      fc.property(
        fc.date({ min: new Date('1950-01-01'), max: new Date() }),
        (dateOfBirth) => {
          const age = calculateAge(dateOfBirth);
          const ageGroup = calculateAgeGroup(dateOfBirth);
          
          if (age >= 15 && age <= 17) {
            expect(ageGroup).toBe('minor');
          }
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should return adult for age group when age is 18+', () => {
    fc.assert(
      fc.property(
        fc.date({ min: new Date('1950-01-01'), max: new Date() }),
        (dateOfBirth) => {
          const age = calculateAge(dateOfBirth);
          const ageGroup = calculateAgeGroup(dateOfBirth);
          
          if (age >= 18) {
            expect(ageGroup).toBe('adult');
          }
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should correctly map age to age group for all valid dates', () => {
    fc.assert(
      fc.property(
        fc.date({ min: new Date('1950-01-01'), max: new Date() }),
        (dateOfBirth) => {
          const age = calculateAge(dateOfBirth);
          const ageGroup = calculateAgeGroup(dateOfBirth);
          
          // Verify age group matches age
          if (age < 15) {
            expect(ageGroup).toBeNull();
          } else if (age <= 17) {
            expect(ageGroup).toBe('minor');
          } else {
            expect(ageGroup).toBe('adult');
          }
        }
      ),
      { numRuns: 100 }
    );
  });
});
