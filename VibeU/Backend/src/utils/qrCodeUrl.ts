/**
 * QR Code URL Generator and Parser
 * 
 * Generates and validates QR code URLs in the format: vibeu://profile/{userId}
 * 
 * Requirements: 7.1, 7.6
 */

export const QR_URL_SCHEME = 'vibeu';
export const QR_URL_PROFILE_PATH = 'profile';

/**
 * Generates a profile URL for QR code
 * Format: vibeu://profile/{userId}
 * 
 * @param userId - The user's unique identifier
 * @returns URL string in format vibeu://profile/{userId}
 * 
 * Requirements: 7.1
 */
export function generateProfileQRUrl(userId: string): string {
  if (!userId || userId.trim() === '') {
    throw new Error('userId cannot be empty');
  }
  return `${QR_URL_SCHEME}://${QR_URL_PROFILE_PATH}/${userId}`;
}

/**
 * Parses a profile URL to extract userId
 * 
 * @param urlString - The URL string to parse
 * @returns The userId if valid, null otherwise
 * 
 * Requirements: 7.6
 */
export function parseProfileQRUrl(urlString: string): string | null {
  if (!urlString || typeof urlString !== 'string') {
    return null;
  }

  try {
    // Parse the URL
    const url = new URL(urlString);
    
    // Validate scheme
    if (url.protocol !== `${QR_URL_SCHEME}:`) {
      return null;
    }
    
    // Validate host (path in custom URL schemes)
    if (url.host !== QR_URL_PROFILE_PATH) {
      return null;
    }
    
    // Extract userId from pathname
    const pathParts = url.pathname.split('/').filter(part => part !== '');
    
    if (pathParts.length !== 1) {
      return null;
    }
    
    const userId = pathParts[0];
    
    if (!userId || userId.trim() === '') {
      return null;
    }
    
    return userId;
  } catch {
    return null;
  }
}

/**
 * Validates if a URL string is a valid VibeU profile QR URL
 * 
 * @param urlString - The URL string to validate
 * @returns true if valid, false otherwise
 * 
 * Requirements: 7.1, 7.6
 */
export function isValidProfileQRUrl(urlString: string): boolean {
  return parseProfileQRUrl(urlString) !== null;
}

/**
 * Validates the format of a QR URL
 * Checks that it follows the pattern: vibeu://profile/{userId}
 * 
 * @param urlString - The URL string to validate
 * @param expectedUserId - Optional: the expected userId to match
 * @returns true if format is valid, false otherwise
 */
export function validateQRUrlFormat(urlString: string, expectedUserId?: string): boolean {
  const parsedUserId = parseProfileQRUrl(urlString);
  
  if (parsedUserId === null) {
    return false;
  }
  
  if (expectedUserId !== undefined) {
    return parsedUserId === expectedUserId;
  }
  
  return true;
}

/**
 * Round-trip validation: generate URL then parse it back
 * This ensures the URL format is consistent
 * 
 * @param userId - The user's unique identifier
 * @returns true if round-trip is successful, false otherwise
 */
export function validateRoundTrip(userId: string): boolean {
  try {
    const generatedUrl = generateProfileQRUrl(userId);
    const parsedUserId = parseProfileQRUrl(generatedUrl);
    return parsedUserId === userId;
  } catch {
    return false;
  }
}
