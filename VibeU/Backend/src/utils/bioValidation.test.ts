/**
 * Property-Based Tests for Bio Character Limit
 * 
 * Feature: vibeu-v2-complete-overhaul
 * Property 10: Bio Character Limit
 * Validates: Requirements 2.2
 * 
 * For any bio text, the system SHALL accept text up to 500 characters 
 * and reject or truncate text exceeding 500 characters.
 */

import { describe, it, expect } from 'vitest';
import fc from 'fast-check';
import {
  BIO_MAX_LENGTH,
  isValidBioLength,
  truncateBio,
  validateBio,
  getRemainingCharacters
} from './bioValidation';

describe('Bio Character Limit - Property 10', () => {
  /**
   * Property 10: Bio Character Limit
   * 
   * For any bio text, the system SHALL accept text up to 500 characters 
   * and reject or truncate text exceeding 500 characters.
   * 
   * Validates: Requirements 2.2
   */

  it('should accept any bio text with 500 characters or less', () => {
    fc.assert(
      fc.property(
        fc.string({ minLength: 0, maxLength: BIO_MAX_LENGTH }),
        (bio) => {
          const result = isValidBioLength(bio);
          expect(result).toBe(true);
          expect(bio.length).toBeLessThanOrEqual(BIO_MAX_LENGTH);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should reject any bio text exceeding 500 characters', () => {
    fc.assert(
      fc.property(
        fc.string({ minLength: BIO_MAX_LENGTH + 1, maxLength: BIO_MAX_LENGTH + 1000 }),
        (bio) => {
          const result = isValidBioLength(bio);
          expect(result).toBe(false);
          expect(bio.length).toBeGreaterThan(BIO_MAX_LENGTH);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should truncate bio to exactly 500 characters when exceeding limit', () => {
    fc.assert(
      fc.property(
        fc.string({ minLength: BIO_MAX_LENGTH + 1, maxLength: BIO_MAX_LENGTH + 1000 }),
        (bio) => {
          const truncated = truncateBio(bio);
          expect(truncated.length).toBe(BIO_MAX_LENGTH);
          expect(truncated).toBe(bio.substring(0, BIO_MAX_LENGTH));
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should not modify bio text that is within the limit', () => {
    fc.assert(
      fc.property(
        fc.string({ minLength: 0, maxLength: BIO_MAX_LENGTH }),
        (bio) => {
          const truncated = truncateBio(bio);
          expect(truncated).toBe(bio);
          expect(truncated.length).toBe(bio.length);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should correctly calculate remaining characters for any bio', () => {
    fc.assert(
      fc.property(
        fc.string({ minLength: 0, maxLength: BIO_MAX_LENGTH + 500 }),
        (bio) => {
          const remaining = getRemainingCharacters(bio);
          expect(remaining).toBe(BIO_MAX_LENGTH - bio.length);
          
          if (bio.length <= BIO_MAX_LENGTH) {
            expect(remaining).toBeGreaterThanOrEqual(0);
          } else {
            expect(remaining).toBeLessThan(0);
          }
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should return consistent validation results for any bio', () => {
    fc.assert(
      fc.property(
        fc.string({ minLength: 0, maxLength: BIO_MAX_LENGTH + 500 }),
        (bio) => {
          const result = validateBio(bio);
          
          // isValid should match length check
          expect(result.isValid).toBe(bio.length <= BIO_MAX_LENGTH);
          
          // characterCount should match actual length
          expect(result.characterCount).toBe(bio.length);
          
          // exceededBy should be correct
          if (bio.length <= BIO_MAX_LENGTH) {
            expect(result.exceededBy).toBe(0);
          } else {
            expect(result.exceededBy).toBe(bio.length - BIO_MAX_LENGTH);
          }
          
          // text should be truncated if exceeded
          if (bio.length <= BIO_MAX_LENGTH) {
            expect(result.text).toBe(bio);
          } else {
            expect(result.text.length).toBe(BIO_MAX_LENGTH);
          }
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should handle null and undefined bio gracefully', () => {
    expect(isValidBioLength(null as any)).toBe(true);
    expect(isValidBioLength(undefined as any)).toBe(true);
    expect(truncateBio(null as any)).toBe('');
    expect(truncateBio(undefined as any)).toBe('');
    expect(getRemainingCharacters(null)).toBe(BIO_MAX_LENGTH);
    expect(getRemainingCharacters(undefined)).toBe(BIO_MAX_LENGTH);
  });

  it('should handle special characters and unicode in bio', () => {
    fc.assert(
      fc.property(
        fc.string({ minLength: 0, maxLength: BIO_MAX_LENGTH }),
        (bio) => {
          const result = isValidBioLength(bio);
          expect(result).toBe(true);
          
          const truncated = truncateBio(bio);
          expect(truncated).toBe(bio);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should be idempotent - truncating twice yields same result', () => {
    fc.assert(
      fc.property(
        fc.string({ minLength: 0, maxLength: BIO_MAX_LENGTH + 500 }),
        (bio) => {
          const truncated1 = truncateBio(bio);
          const truncated2 = truncateBio(truncated1);
          const truncated3 = truncateBio(truncated2);
          
          expect(truncated1).toBe(truncated2);
          expect(truncated2).toBe(truncated3);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should preserve bio content prefix when truncating', () => {
    fc.assert(
      fc.property(
        fc.string({ minLength: BIO_MAX_LENGTH + 1, maxLength: BIO_MAX_LENGTH + 500 }),
        (bio) => {
          const truncated = truncateBio(bio);
          
          // The truncated text should be a prefix of the original
          expect(bio.startsWith(truncated)).toBe(true);
          
          // Every character in truncated should match original
          for (let i = 0; i < truncated.length; i++) {
            expect(truncated[i]).toBe(bio[i]);
          }
        }
      ),
      { numRuns: 100 }
    );
  });
});
