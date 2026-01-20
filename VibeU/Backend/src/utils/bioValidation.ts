/**
 * Bio Validation Utilities
 * 
 * Validates bio text according to requirements:
 * - Maximum 500 characters
 * - Accepts text up to 500 characters
 * - Rejects or truncates text exceeding 500 characters
 * 
 * Requirements: 2.2
 */

export const BIO_MAX_LENGTH = 500;

/**
 * Validates if a bio text is within the character limit
 * @param bio - The bio text to validate
 * @returns true if bio is valid (500 characters or less), false otherwise
 */
export function isValidBioLength(bio: string): boolean {
  if (bio === null || bio === undefined) {
    return true; // Empty bio is valid
  }
  return bio.length <= BIO_MAX_LENGTH;
}

/**
 * Truncates bio text to the maximum allowed length
 * @param bio - The bio text to truncate
 * @returns The truncated bio (max 500 characters)
 */
export function truncateBio(bio: string): string {
  if (bio === null || bio === undefined) {
    return '';
  }
  if (bio.length <= BIO_MAX_LENGTH) {
    return bio;
  }
  return bio.substring(0, BIO_MAX_LENGTH);
}

/**
 * Validates bio and returns validation result
 * @param bio - The bio text to validate
 * @returns Validation result with isValid flag and truncated text if needed
 */
export function validateBio(bio: string | null | undefined): {
  isValid: boolean;
  text: string;
  characterCount: number;
  exceededBy: number;
} {
  const text = bio ?? '';
  const characterCount = text.length;
  const isValid = characterCount <= BIO_MAX_LENGTH;
  const exceededBy = Math.max(0, characterCount - BIO_MAX_LENGTH);
  
  return {
    isValid,
    text: isValid ? text : truncateBio(text),
    characterCount,
    exceededBy
  };
}

/**
 * Gets remaining characters for a bio
 * @param bio - The current bio text
 * @returns Number of remaining characters (can be negative if exceeded)
 */
export function getRemainingCharacters(bio: string | null | undefined): number {
  const text = bio ?? '';
  return BIO_MAX_LENGTH - text.length;
}
