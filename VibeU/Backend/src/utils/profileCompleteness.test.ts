/**
 * Property-Based Tests for Profile Completeness Check
 * 
 * Feature: vibeu-v2-complete-overhaul
 * Property 14: Profile Completeness Check
 * Validates: Requirements 1.1, 1.2, 1.3
 */

import { describe, it, expect } from 'vitest';
import fc from 'fast-check';
import {
  isProfileComplete,
  checkProfileCompleteness,
  isValidDisplayName,
  isValidDateOfBirth,
  isValidGender,
  isValidCountry,
  isValidCity,
  isValidProfilePhotoUrl,
  UserProfile
} from './profileCompleteness';

// Arbitrary for generating valid user profiles
const validProfileArb = fc.record({
  displayName: fc.string({ minLength: 1 }).filter(s => s.trim().length > 0),
  dateOfBirth: fc.date({ 
    min: new Date('1950-01-01'), 
    max: new Date(Date.now() - 15 * 365.25 * 24 * 60 * 60 * 1000) // At least 15 years ago
  }).filter(d => !isNaN(d.getTime())), // Ensure valid date
  gender: fc.constantFrom('male', 'female', 'other', 'prefer_not_to_say'),
  country: fc.string({ minLength: 1 }).filter(s => s.trim().length > 0),
  city: fc.string({ minLength: 1 }).filter(s => s.trim().length > 0),
  profilePhotoUrl: fc.webUrl()
});

// Arbitrary for generating profiles with potentially missing fields
const partialProfileArb = fc.record({
  displayName: fc.oneof(
    fc.string({ minLength: 1 }).filter(s => s.trim().length > 0),
    fc.constant(''),
    fc.constant('   ')
  ),
  dateOfBirth: fc.oneof(
    fc.date({ min: new Date('1950-01-01'), max: new Date(Date.now() - 15 * 365.25 * 24 * 60 * 60 * 1000) }),
    fc.date({ min: new Date(Date.now() - 14 * 365.25 * 24 * 60 * 60 * 1000), max: new Date() }) // Under 15
  ),
  gender: fc.oneof(
    fc.constantFrom('male', 'female', 'other', 'prefer_not_to_say'),
    fc.constant('invalid'),
    fc.constant('')
  ),
  country: fc.oneof(
    fc.string({ minLength: 1 }).filter(s => s.trim().length > 0),
    fc.constant(''),
    fc.constant('   ')
  ),
  city: fc.oneof(
    fc.string({ minLength: 1 }).filter(s => s.trim().length > 0),
    fc.constant(''),
    fc.constant('   ')
  ),
  profilePhotoUrl: fc.oneof(
    fc.webUrl(),
    fc.constant(''),
    fc.constant('not-a-url')
  )
});

describe('Profile Completeness Check - Property 14', () => {
  /**
   * Property 14: Profile Completeness Check
   * 
   * For any user attempting to access the main app, if their profile is missing 
   * any required field (displayName, dateOfBirth, gender, country, city, profilePhoto), 
   * the system SHALL redirect to onboarding flow.
   * 
   * Validates: Requirements 1.1, 1.2, 1.3
   */

  it('should return true for any valid complete profile', () => {
    fc.assert(
      fc.property(validProfileArb, (profile) => {
        const result = isProfileComplete(profile);
        expect(result).toBe(true);
      }),
      { numRuns: 100 }
    );
  });

  it('should return false when displayName is empty or whitespace-only', () => {
    fc.assert(
      fc.property(
        validProfileArb,
        fc.oneof(fc.constant(''), fc.constant('   '), fc.constant('\t\n')),
        (profile, emptyName) => {
          const incompleteProfile = { ...profile, displayName: emptyName };
          const result = checkProfileCompleteness(incompleteProfile);
          expect(result.isComplete).toBe(false);
          expect(result.missingFields).toContain('displayName');
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should return false when dateOfBirth indicates age under 15', () => {
    fc.assert(
      fc.property(
        validProfileArb,
        fc.date({ min: new Date(Date.now() - 14 * 365.25 * 24 * 60 * 60 * 1000), max: new Date() }),
        (profile, youngDate) => {
          const incompleteProfile = { ...profile, dateOfBirth: youngDate };
          const result = checkProfileCompleteness(incompleteProfile);
          expect(result.isComplete).toBe(false);
          expect(result.missingFields).toContain('dateOfBirth');
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should return false when gender is invalid', () => {
    fc.assert(
      fc.property(
        validProfileArb,
        fc.string().filter(s => !['male', 'female', 'other', 'prefer_not_to_say'].includes(s.toLowerCase())),
        (profile, invalidGender) => {
          const incompleteProfile = { ...profile, gender: invalidGender };
          const result = checkProfileCompleteness(incompleteProfile);
          expect(result.isComplete).toBe(false);
          expect(result.missingFields).toContain('gender');
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should return false when country is empty or whitespace-only', () => {
    fc.assert(
      fc.property(
        validProfileArb,
        fc.oneof(fc.constant(''), fc.constant('   '), fc.constant('\t\n')),
        (profile, emptyCountry) => {
          const incompleteProfile = { ...profile, country: emptyCountry };
          const result = checkProfileCompleteness(incompleteProfile);
          expect(result.isComplete).toBe(false);
          expect(result.missingFields).toContain('country');
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should return false when city is empty or whitespace-only', () => {
    fc.assert(
      fc.property(
        validProfileArb,
        fc.oneof(fc.constant(''), fc.constant('   '), fc.constant('\t\n')),
        (profile, emptyCity) => {
          const incompleteProfile = { ...profile, city: emptyCity };
          const result = checkProfileCompleteness(incompleteProfile);
          expect(result.isComplete).toBe(false);
          expect(result.missingFields).toContain('city');
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should return false when profilePhotoUrl is empty or invalid', () => {
    fc.assert(
      fc.property(
        validProfileArb,
        fc.oneof(fc.constant(''), fc.constant('not-a-valid-url'), fc.constant('   ')),
        (profile, invalidUrl) => {
          const incompleteProfile = { ...profile, profilePhotoUrl: invalidUrl };
          const result = checkProfileCompleteness(incompleteProfile);
          expect(result.isComplete).toBe(false);
          expect(result.missingFields).toContain('profilePhotoUrl');
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should correctly identify all missing fields in incomplete profiles', () => {
    fc.assert(
      fc.property(partialProfileArb, (profile) => {
        const result = checkProfileCompleteness(profile);
        
        // Verify each field check is consistent
        const expectedMissing: string[] = [];
        
        if (!isValidDisplayName(profile.displayName)) {
          expectedMissing.push('displayName');
        }
        if (!isValidDateOfBirth(profile.dateOfBirth)) {
          expectedMissing.push('dateOfBirth');
        }
        if (!isValidGender(profile.gender)) {
          expectedMissing.push('gender');
        }
        if (!isValidCountry(profile.country)) {
          expectedMissing.push('country');
        }
        if (!isValidCity(profile.city)) {
          expectedMissing.push('city');
        }
        if (!isValidProfilePhotoUrl(profile.profilePhotoUrl)) {
          expectedMissing.push('profilePhotoUrl');
        }
        
        expect(result.missingFields.sort()).toEqual(expectedMissing.sort());
        expect(result.isComplete).toBe(expectedMissing.length === 0);
      }),
      { numRuns: 100 }
    );
  });

  it('should be idempotent - checking the same profile multiple times yields same result', () => {
    fc.assert(
      fc.property(partialProfileArb, (profile) => {
        const result1 = checkProfileCompleteness(profile);
        const result2 = checkProfileCompleteness(profile);
        const result3 = checkProfileCompleteness(profile);
        
        expect(result1.isComplete).toBe(result2.isComplete);
        expect(result2.isComplete).toBe(result3.isComplete);
        expect(result1.missingFields.sort()).toEqual(result2.missingFields.sort());
        expect(result2.missingFields.sort()).toEqual(result3.missingFields.sort());
      }),
      { numRuns: 100 }
    );
  });
});
