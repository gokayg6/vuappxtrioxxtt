/**
 * Property-Based Tests for Photo Count Constraints
 * 
 * Feature: vibeu-v2-complete-overhaul
 * Property 3: Photo Count Constraints
 * Validates: Requirements 2.1, 3.1, 3.5
 * 
 * For any user profile, the photo count SHALL be at least 1 and at most 5.
 * Attempting to delete the last photo SHALL be rejected.
 * Attempting to add a 6th photo SHALL be rejected.
 */

import { describe, it, expect } from 'vitest';
import fc from 'fast-check';
import {
  MIN_PHOTOS,
  MAX_PHOTOS,
  isValidPhotoCount,
  canAddPhoto,
  canDeletePhoto,
  getRemainingPhotoSlots,
  getDeletablePhotoCount,
  validatePhotos,
  truncatePhotos,
  hasMinimumPhotos,
  isValidPhotoOrder
} from './photoValidation';

// Arbitraries for generating test data
const validPhotoCountArb = fc.integer({ min: MIN_PHOTOS, max: MAX_PHOTOS });
const belowMinPhotoCountArb = fc.integer({ min: 0, max: MIN_PHOTOS - 1 });
const aboveMaxPhotoCountArb = fc.integer({ min: MAX_PHOTOS + 1, max: MAX_PHOTOS + 10 });
const anyPhotoCountArb = fc.integer({ min: 0, max: MAX_PHOTOS + 5 });

// Generate photo arrays of specific sizes
const photoArrayArb = (minLen: number, maxLen: number) => 
  fc.array(fc.string(), { minLength: minLen, maxLength: maxLen });

describe('Photo Count Constraints - Property 3', () => {
  /**
   * Property 3: Photo Count Constraints
   * 
   * For any user profile, the photo count SHALL be at least 1 and at most 5.
   * Attempting to delete the last photo SHALL be rejected.
   * Attempting to add a 6th photo SHALL be rejected.
   * 
   * Validates: Requirements 2.1, 3.1, 3.5
   */

  describe('isValidPhotoCount', () => {
    it('should accept any count between MIN_PHOTOS and MAX_PHOTOS (inclusive)', () => {
      fc.assert(
        fc.property(validPhotoCountArb, (count) => {
          const result = isValidPhotoCount(count);
          expect(result).toBe(true);
          expect(count).toBeGreaterThanOrEqual(MIN_PHOTOS);
          expect(count).toBeLessThanOrEqual(MAX_PHOTOS);
        }),
        { numRuns: 100 }
      );
    });

    it('should reject any count below MIN_PHOTOS', () => {
      fc.assert(
        fc.property(belowMinPhotoCountArb, (count) => {
          const result = isValidPhotoCount(count);
          expect(result).toBe(false);
          expect(count).toBeLessThan(MIN_PHOTOS);
        }),
        { numRuns: 100 }
      );
    });

    it('should reject any count above MAX_PHOTOS', () => {
      fc.assert(
        fc.property(aboveMaxPhotoCountArb, (count) => {
          const result = isValidPhotoCount(count);
          expect(result).toBe(false);
          expect(count).toBeGreaterThan(MAX_PHOTOS);
        }),
        { numRuns: 100 }
      );
    });
  });

  describe('canAddPhoto - Requirements 2.1, 3.1', () => {
    it('should allow adding photos when below MAX_PHOTOS', () => {
      fc.assert(
        fc.property(
          fc.integer({ min: 0, max: MAX_PHOTOS - 1 }),
          (currentCount) => {
            const result = canAddPhoto(currentCount);
            expect(result).toBe(true);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should reject adding a 6th photo when at MAX_PHOTOS', () => {
      fc.assert(
        fc.property(
          fc.integer({ min: MAX_PHOTOS, max: MAX_PHOTOS + 5 }),
          (currentCount) => {
            const result = canAddPhoto(currentCount);
            expect(result).toBe(false);
          }
        ),
        { numRuns: 100 }
      );
    });
  });

  describe('canDeletePhoto - Requirements 3.5', () => {
    it('should allow deleting photos when above MIN_PHOTOS', () => {
      fc.assert(
        fc.property(
          fc.integer({ min: MIN_PHOTOS + 1, max: MAX_PHOTOS + 5 }),
          (currentCount) => {
            const result = canDeletePhoto(currentCount);
            expect(result).toBe(true);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should reject deleting the last photo when at MIN_PHOTOS', () => {
      fc.assert(
        fc.property(
          fc.integer({ min: 0, max: MIN_PHOTOS }),
          (currentCount) => {
            const result = canDeletePhoto(currentCount);
            expect(result).toBe(false);
          }
        ),
        { numRuns: 100 }
      );
    });
  });

  describe('getRemainingPhotoSlots', () => {
    it('should correctly calculate remaining slots for any count', () => {
      fc.assert(
        fc.property(anyPhotoCountArb, (currentCount) => {
          const remaining = getRemainingPhotoSlots(currentCount);
          const expected = Math.max(0, MAX_PHOTOS - currentCount);
          expect(remaining).toBe(expected);
          expect(remaining).toBeGreaterThanOrEqual(0);
        }),
        { numRuns: 100 }
      );
    });

    it('should return MAX_PHOTOS when count is 0', () => {
      expect(getRemainingPhotoSlots(0)).toBe(MAX_PHOTOS);
    });

    it('should return 0 when at or above MAX_PHOTOS', () => {
      fc.assert(
        fc.property(
          fc.integer({ min: MAX_PHOTOS, max: MAX_PHOTOS + 10 }),
          (currentCount) => {
            const remaining = getRemainingPhotoSlots(currentCount);
            expect(remaining).toBe(0);
          }
        ),
        { numRuns: 100 }
      );
    });
  });

  describe('getDeletablePhotoCount', () => {
    it('should correctly calculate deletable count for any count', () => {
      fc.assert(
        fc.property(anyPhotoCountArb, (currentCount) => {
          const deletable = getDeletablePhotoCount(currentCount);
          const expected = Math.max(0, currentCount - MIN_PHOTOS);
          expect(deletable).toBe(expected);
          expect(deletable).toBeGreaterThanOrEqual(0);
        }),
        { numRuns: 100 }
      );
    });

    it('should return 0 when at or below MIN_PHOTOS', () => {
      fc.assert(
        fc.property(
          fc.integer({ min: 0, max: MIN_PHOTOS }),
          (currentCount) => {
            const deletable = getDeletablePhotoCount(currentCount);
            expect(deletable).toBe(0);
          }
        ),
        { numRuns: 100 }
      );
    });
  });

  describe('validatePhotos', () => {
    it('should return consistent validation results for valid photo arrays', () => {
      fc.assert(
        fc.property(
          photoArrayArb(MIN_PHOTOS, MAX_PHOTOS),
          (photos) => {
            const result = validatePhotos(photos);
            
            expect(result.isValid).toBe(true);
            expect(result.count).toBe(photos.length);
            expect(result.error).toBeUndefined();
            
            // Verify canAdd and canDelete are consistent
            expect(result.canAdd).toBe(photos.length < MAX_PHOTOS);
            expect(result.canDelete).toBe(photos.length > MIN_PHOTOS);
            
            // Verify remaining slots
            expect(result.remainingSlots).toBe(MAX_PHOTOS - photos.length);
            expect(result.deletableCount).toBe(photos.length - MIN_PHOTOS);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should return invalid for photo arrays below MIN_PHOTOS', () => {
      fc.assert(
        fc.property(
          photoArrayArb(0, MIN_PHOTOS - 1),
          (photos) => {
            const result = validatePhotos(photos);
            
            expect(result.isValid).toBe(false);
            expect(result.count).toBe(photos.length);
            expect(result.error).toBeDefined();
            expect(result.canDelete).toBe(false);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should return invalid for photo arrays above MAX_PHOTOS', () => {
      fc.assert(
        fc.property(
          photoArrayArb(MAX_PHOTOS + 1, MAX_PHOTOS + 5),
          (photos) => {
            const result = validatePhotos(photos);
            
            expect(result.isValid).toBe(false);
            expect(result.count).toBe(photos.length);
            expect(result.error).toBeDefined();
            expect(result.canAdd).toBe(false);
          }
        ),
        { numRuns: 100 }
      );
    });
  });

  describe('truncatePhotos', () => {
    it('should truncate arrays exceeding MAX_PHOTOS to exactly MAX_PHOTOS', () => {
      fc.assert(
        fc.property(
          photoArrayArb(MAX_PHOTOS + 1, MAX_PHOTOS + 10),
          (photos) => {
            const truncated = truncatePhotos(photos);
            expect(truncated.length).toBe(MAX_PHOTOS);
            expect(truncated).toEqual(photos.slice(0, MAX_PHOTOS));
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should not modify arrays within the limit', () => {
      fc.assert(
        fc.property(
          photoArrayArb(0, MAX_PHOTOS),
          (photos) => {
            const truncated = truncatePhotos(photos);
            expect(truncated).toEqual(photos);
            expect(truncated.length).toBe(photos.length);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should be idempotent - truncating twice yields same result', () => {
      fc.assert(
        fc.property(
          photoArrayArb(0, MAX_PHOTOS + 10),
          (photos) => {
            const truncated1 = truncatePhotos(photos);
            const truncated2 = truncatePhotos(truncated1);
            const truncated3 = truncatePhotos(truncated2);
            
            expect(truncated1).toEqual(truncated2);
            expect(truncated2).toEqual(truncated3);
          }
        ),
        { numRuns: 100 }
      );
    });
  });

  describe('hasMinimumPhotos', () => {
    it('should return true for arrays with at least MIN_PHOTOS', () => {
      fc.assert(
        fc.property(
          photoArrayArb(MIN_PHOTOS, MAX_PHOTOS + 5),
          (photos) => {
            const result = hasMinimumPhotos(photos);
            expect(result).toBe(true);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should return false for arrays below MIN_PHOTOS', () => {
      fc.assert(
        fc.property(
          photoArrayArb(0, MIN_PHOTOS - 1),
          (photos) => {
            const result = hasMinimumPhotos(photos);
            expect(result).toBe(false);
          }
        ),
        { numRuns: 100 }
      );
    });
  });

  describe('isValidPhotoOrder', () => {
    it('should accept valid sequential order indices', () => {
      fc.assert(
        fc.property(
          fc.integer({ min: 1, max: MAX_PHOTOS }),
          (count) => {
            const indices = Array.from({ length: count }, (_, i) => i);
            const result = isValidPhotoOrder(indices);
            expect(result).toBe(true);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should accept valid shuffled order indices', () => {
      fc.assert(
        fc.property(
          fc.integer({ min: 1, max: MAX_PHOTOS }),
          fc.integer({ min: 0, max: 1000 }), // seed for shuffle
          (count, seed) => {
            const indices = Array.from({ length: count }, (_, i) => i);
            // Simple shuffle using seed
            for (let i = indices.length - 1; i > 0; i--) {
              const j = (seed + i) % (i + 1);
              [indices[i], indices[j]] = [indices[j], indices[i]];
            }
            const result = isValidPhotoOrder(indices);
            expect(result).toBe(true);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should reject order indices with duplicates', () => {
      fc.assert(
        fc.property(
          fc.integer({ min: 2, max: MAX_PHOTOS }),
          (count) => {
            // Create indices with a duplicate
            const indices = Array.from({ length: count }, (_, i) => i);
            indices[count - 1] = indices[0]; // Create duplicate
            const result = isValidPhotoOrder(indices);
            expect(result).toBe(false);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should reject order indices with out-of-range values', () => {
      fc.assert(
        fc.property(
          fc.integer({ min: 1, max: MAX_PHOTOS }),
          (count) => {
            const indices = Array.from({ length: count }, (_, i) => i);
            indices[0] = count; // Out of range (should be 0 to count-1)
            const result = isValidPhotoOrder(indices);
            expect(result).toBe(false);
          }
        ),
        { numRuns: 100 }
      );
    });
  });

  describe('Edge cases', () => {
    it('should handle null and undefined gracefully', () => {
      expect(isValidPhotoCount(null as any)).toBe(false);
      expect(isValidPhotoCount(undefined as any)).toBe(false);
      expect(canAddPhoto(null as any)).toBe(true);
      expect(canAddPhoto(undefined as any)).toBe(true);
      expect(canDeletePhoto(null as any)).toBe(false);
      expect(canDeletePhoto(undefined as any)).toBe(false);
      expect(getRemainingPhotoSlots(null as any)).toBe(MAX_PHOTOS);
      expect(getRemainingPhotoSlots(undefined as any)).toBe(MAX_PHOTOS);
      expect(getDeletablePhotoCount(null as any)).toBe(0);
      expect(getDeletablePhotoCount(undefined as any)).toBe(0);
      expect(truncatePhotos(null)).toEqual([]);
      expect(truncatePhotos(undefined)).toEqual([]);
      expect(hasMinimumPhotos(null)).toBe(false);
      expect(hasMinimumPhotos(undefined)).toBe(false);
      expect(isValidPhotoOrder(null as any)).toBe(false);
      expect(isValidPhotoOrder(undefined as any)).toBe(false);
    });

    it('should handle empty arrays', () => {
      const result = validatePhotos([]);
      expect(result.isValid).toBe(false);
      expect(result.count).toBe(0);
      expect(result.canAdd).toBe(true);
      expect(result.canDelete).toBe(false);
      expect(result.remainingSlots).toBe(MAX_PHOTOS);
      expect(result.deletableCount).toBe(0);
    });
  });

  describe('Invariants', () => {
    it('should maintain invariant: remainingSlots + count <= MAX_PHOTOS for valid counts', () => {
      fc.assert(
        fc.property(validPhotoCountArb, (count) => {
          const remaining = getRemainingPhotoSlots(count);
          expect(remaining + count).toBe(MAX_PHOTOS);
        }),
        { numRuns: 100 }
      );
    });

    it('should maintain invariant: deletableCount + MIN_PHOTOS <= count for valid counts', () => {
      fc.assert(
        fc.property(validPhotoCountArb, (count) => {
          const deletable = getDeletablePhotoCount(count);
          expect(deletable + MIN_PHOTOS).toBe(count);
        }),
        { numRuns: 100 }
      );
    });

    it('should maintain invariant: canAdd implies remainingSlots > 0', () => {
      fc.assert(
        fc.property(anyPhotoCountArb, (count) => {
          const canAdd = canAddPhoto(count);
          const remaining = getRemainingPhotoSlots(count);
          
          if (canAdd) {
            expect(remaining).toBeGreaterThan(0);
          } else {
            expect(remaining).toBe(0);
          }
        }),
        { numRuns: 100 }
      );
    });

    it('should maintain invariant: canDelete implies deletableCount > 0', () => {
      fc.assert(
        fc.property(anyPhotoCountArb, (count) => {
          const canDelete = canDeletePhoto(count);
          const deletable = getDeletablePhotoCount(count);
          
          if (canDelete) {
            expect(deletable).toBeGreaterThan(0);
          } else {
            expect(deletable).toBe(0);
          }
        }),
        { numRuns: 100 }
      );
    });
  });
});
