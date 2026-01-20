/**
 * Photo Count Validation Utilities
 * 
 * Feature: vibeu-v2-complete-overhaul
 * Property 3: Photo Count Constraints
 * Validates: Requirements 2.1, 3.1, 3.5
 * 
 * For any user profile, the photo count SHALL be at least 1 and at most 5.
 * Attempting to delete the last photo SHALL be rejected.
 * Attempting to add a 6th photo SHALL be rejected.
 */

// Photo count constraints
export const MIN_PHOTOS = 1;
export const MAX_PHOTOS = 5;

/**
 * Validates if the photo count is within the allowed range
 * @param count - Number of photos
 * @returns true if count is between MIN_PHOTOS and MAX_PHOTOS (inclusive)
 */
export function isValidPhotoCount(count: number): boolean {
  if (count === null || count === undefined || isNaN(count)) {
    return false;
  }
  return count >= MIN_PHOTOS && count <= MAX_PHOTOS;
}

/**
 * Checks if a photo can be added to the current collection
 * @param currentCount - Current number of photos
 * @returns true if adding a photo would not exceed MAX_PHOTOS
 */
export function canAddPhoto(currentCount: number): boolean {
  if (currentCount === null || currentCount === undefined || isNaN(currentCount)) {
    return true; // Can add if no photos exist
  }
  return currentCount < MAX_PHOTOS;
}

/**
 * Checks if a photo can be deleted from the current collection
 * Requirements: 3.5 - Prevent deletion if it's the only remaining photo
 * @param currentCount - Current number of photos
 * @returns true if deleting a photo would not go below MIN_PHOTOS
 */
export function canDeletePhoto(currentCount: number): boolean {
  if (currentCount === null || currentCount === undefined || isNaN(currentCount)) {
    return false; // Can't delete if no photos exist
  }
  return currentCount > MIN_PHOTOS;
}

/**
 * Calculates how many more photos can be added
 * @param currentCount - Current number of photos
 * @returns Number of photos that can still be added (0 if at max)
 */
export function getRemainingPhotoSlots(currentCount: number): number {
  if (currentCount === null || currentCount === undefined || isNaN(currentCount)) {
    return MAX_PHOTOS;
  }
  return Math.max(0, MAX_PHOTOS - currentCount);
}

/**
 * Calculates how many photos can be deleted
 * @param currentCount - Current number of photos
 * @returns Number of photos that can be deleted (0 if at min)
 */
export function getDeletablePhotoCount(currentCount: number): number {
  if (currentCount === null || currentCount === undefined || isNaN(currentCount)) {
    return 0;
  }
  return Math.max(0, currentCount - MIN_PHOTOS);
}

/**
 * Validates a photo array and returns validation result
 * @param photos - Array of photo objects or URLs
 * @returns Validation result with details
 */
export interface PhotoValidationResult {
  isValid: boolean;
  count: number;
  canAdd: boolean;
  canDelete: boolean;
  remainingSlots: number;
  deletableCount: number;
  error?: string;
}

export function validatePhotos(photos: unknown[] | null | undefined): PhotoValidationResult {
  const count = photos?.length ?? 0;
  
  const result: PhotoValidationResult = {
    isValid: isValidPhotoCount(count),
    count,
    canAdd: canAddPhoto(count),
    canDelete: canDeletePhoto(count),
    remainingSlots: getRemainingPhotoSlots(count),
    deletableCount: getDeletablePhotoCount(count),
  };
  
  if (count < MIN_PHOTOS) {
    result.error = `En az ${MIN_PHOTOS} fotoğraf gerekli`;
  } else if (count > MAX_PHOTOS) {
    result.error = `En fazla ${MAX_PHOTOS} fotoğraf eklenebilir`;
  }
  
  return result;
}

/**
 * Truncates a photo array to the maximum allowed count
 * @param photos - Array of photos
 * @returns Truncated array with at most MAX_PHOTOS items
 */
export function truncatePhotos<T>(photos: T[] | null | undefined): T[] {
  if (!photos || !Array.isArray(photos)) {
    return [];
  }
  return photos.slice(0, MAX_PHOTOS);
}

/**
 * Ensures a photo array has at least the minimum required photos
 * @param photos - Array of photos
 * @returns true if the array has at least MIN_PHOTOS items
 */
export function hasMinimumPhotos(photos: unknown[] | null | undefined): boolean {
  if (!photos || !Array.isArray(photos)) {
    return false;
  }
  return photos.length >= MIN_PHOTOS;
}

/**
 * Validates photo order indices
 * @param orderIndices - Array of order indices
 * @returns true if all indices are valid (0 to length-1, no duplicates)
 */
export function isValidPhotoOrder(orderIndices: number[]): boolean {
  if (!orderIndices || !Array.isArray(orderIndices)) {
    return false;
  }
  
  const count = orderIndices.length;
  if (count === 0) return true;
  
  // Check for valid range and no duplicates
  const seen = new Set<number>();
  for (const index of orderIndices) {
    if (index < 0 || index >= count || seen.has(index)) {
      return false;
    }
    seen.add(index);
  }
  
  return seen.size === count;
}
