/**
 * Property-Based Tests for QR Code URL Format
 * 
 * Feature: vibeu-v2-complete-overhaul
 * Property 9: QR Code URL Format
 * Validates: Requirements 7.1, 7.6
 * 
 * For any user, the generated QR code SHALL contain a URL in the format 
 * "vibeu://profile/{userId}" where userId is the user's unique identifier.
 */

import { describe, it, expect } from 'vitest';
import fc from 'fast-check';
import {
  generateProfileQRUrl,
  parseProfileQRUrl,
  isValidProfileQRUrl,
  validateQRUrlFormat,
  validateRoundTrip,
  QR_URL_SCHEME,
  QR_URL_PROFILE_PATH,
} from './qrCodeUrl';

// Arbitrary for valid user IDs (UUID format or alphanumeric)
const userIdArbitrary = fc.oneof(
  fc.uuid(),
  fc.stringMatching(/^[a-zA-Z0-9_-]{1,50}$/)
);

// Arbitrary for non-empty strings (valid user IDs)
const nonEmptyUserIdArbitrary = fc.string({ minLength: 1, maxLength: 50 })
  .filter(s => s.trim().length > 0 && !s.includes('/') && !s.includes('?') && !s.includes('#'));

describe('QR Code URL Format - Property 9', () => {
  /**
   * Property 9: QR Code URL Format
   * 
   * For any user, the generated QR code SHALL contain a URL in the format 
   * "vibeu://profile/{userId}" where userId is the user's unique identifier.
   * 
   * Validates: Requirements 7.1, 7.6
   */

  describe('URL Generation (Requirement 7.1)', () => {
    it('should generate URL in format vibeu://profile/{userId} for any valid userId', () => {
      fc.assert(
        fc.property(userIdArbitrary, (userId) => {
          const url = generateProfileQRUrl(userId);
          
          // URL must follow exact format: vibeu://profile/{userId}
          expect(url).toBe(`vibeu://profile/${userId}`);
        }),
        { numRuns: 100 }
      );
    });

    it('should always start with vibeu:// scheme', () => {
      fc.assert(
        fc.property(userIdArbitrary, (userId) => {
          const url = generateProfileQRUrl(userId);
          
          expect(url.startsWith(`${QR_URL_SCHEME}://`)).toBe(true);
        }),
        { numRuns: 100 }
      );
    });

    it('should always contain /profile/ path', () => {
      fc.assert(
        fc.property(userIdArbitrary, (userId) => {
          const url = generateProfileQRUrl(userId);
          
          expect(url).toContain(`://${QR_URL_PROFILE_PATH}/`);
        }),
        { numRuns: 100 }
      );
    });

    it('should preserve userId exactly in generated URL', () => {
      fc.assert(
        fc.property(userIdArbitrary, (userId) => {
          const url = generateProfileQRUrl(userId);
          
          // The URL should end with the exact userId
          expect(url.endsWith(`/${userId}`)).toBe(true);
        }),
        { numRuns: 100 }
      );
    });
  });

  describe('URL Parsing (Requirement 7.6)', () => {
    it('should correctly parse userId from valid QR URL', () => {
      fc.assert(
        fc.property(userIdArbitrary, (userId) => {
          const url = generateProfileQRUrl(userId);
          const parsedUserId = parseProfileQRUrl(url);
          
          expect(parsedUserId).toBe(userId);
        }),
        { numRuns: 100 }
      );
    });

    it('should return null for invalid scheme', () => {
      fc.assert(
        fc.property(
          userIdArbitrary,
          fc.constantFrom('http', 'https', 'ftp', 'invalid'),
          (userId, scheme) => {
            const invalidUrl = `${scheme}://profile/${userId}`;
            const parsedUserId = parseProfileQRUrl(invalidUrl);
            
            expect(parsedUserId).toBeNull();
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should return null for invalid path', () => {
      fc.assert(
        fc.property(
          userIdArbitrary,
          fc.constantFrom('user', 'users', 'account', 'invalid'),
          (userId, path) => {
            const invalidUrl = `vibeu://${path}/${userId}`;
            const parsedUserId = parseProfileQRUrl(invalidUrl);
            
            expect(parsedUserId).toBeNull();
          }
        ),
        { numRuns: 100 }
      );
    });
  });

  describe('Round-Trip Property', () => {
    it('should satisfy round-trip: parse(generate(userId)) === userId', () => {
      fc.assert(
        fc.property(userIdArbitrary, (userId) => {
          // Generate URL from userId
          const generatedUrl = generateProfileQRUrl(userId);
          
          // Parse the URL back to userId
          const parsedUserId = parseProfileQRUrl(generatedUrl);
          
          // Round-trip must preserve the original userId
          expect(parsedUserId).toBe(userId);
        }),
        { numRuns: 100 }
      );
    });

    it('should validate round-trip using helper function', () => {
      fc.assert(
        fc.property(userIdArbitrary, (userId) => {
          expect(validateRoundTrip(userId)).toBe(true);
        }),
        { numRuns: 100 }
      );
    });
  });

  describe('URL Validation', () => {
    it('should validate correctly formatted URLs as valid', () => {
      fc.assert(
        fc.property(userIdArbitrary, (userId) => {
          const url = generateProfileQRUrl(userId);
          
          expect(isValidProfileQRUrl(url)).toBe(true);
          expect(validateQRUrlFormat(url)).toBe(true);
          expect(validateQRUrlFormat(url, userId)).toBe(true);
        }),
        { numRuns: 100 }
      );
    });

    it('should reject URLs with wrong userId when expectedUserId is provided', () => {
      fc.assert(
        fc.property(
          userIdArbitrary,
          userIdArbitrary,
          (userId1, userId2) => {
            fc.pre(userId1 !== userId2); // Precondition: userIds must be different
            
            const url = generateProfileQRUrl(userId1);
            
            // Should fail validation when expecting different userId
            expect(validateQRUrlFormat(url, userId2)).toBe(false);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should reject malformed URLs', () => {
      const malformedUrls = [
        '',
        'not-a-url',
        'vibeu://',
        'vibeu://profile',
        'vibeu://profile/',
        'http://profile/123',
        'vibeu://user/123',
      ];

      for (const url of malformedUrls) {
        expect(isValidProfileQRUrl(url)).toBe(false);
      }
    });
  });

  describe('Edge Cases', () => {
    it('should handle UUID format userIds', () => {
      fc.assert(
        fc.property(fc.uuid(), (uuid) => {
          const url = generateProfileQRUrl(uuid);
          const parsed = parseProfileQRUrl(url);
          
          expect(parsed).toBe(uuid);
          expect(url).toBe(`vibeu://profile/${uuid}`);
        }),
        { numRuns: 100 }
      );
    });

    it('should handle alphanumeric userIds', () => {
      fc.assert(
        fc.property(
          fc.stringMatching(/^[a-zA-Z0-9]{1,20}$/),
          (userId) => {
            const url = generateProfileQRUrl(userId);
            const parsed = parseProfileQRUrl(url);
            
            expect(parsed).toBe(userId);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should throw error for empty userId', () => {
      expect(() => generateProfileQRUrl('')).toThrow();
      expect(() => generateProfileQRUrl('   ')).toThrow();
    });
  });

  describe('URL Format Consistency', () => {
    it('should generate URLs without spaces', () => {
      fc.assert(
        fc.property(userIdArbitrary, (userId) => {
          const url = generateProfileQRUrl(userId);
          
          expect(url).not.toContain(' ');
        }),
        { numRuns: 100 }
      );
    });

    it('should generate URLs with consistent structure', () => {
      fc.assert(
        fc.property(userIdArbitrary, (userId) => {
          const url = generateProfileQRUrl(userId);
          
          // URL should have exactly 3 parts when split by ://
          const [scheme, rest] = url.split('://');
          expect(scheme).toBe('vibeu');
          
          // Rest should have exactly 2 parts when split by /
          const parts = rest.split('/');
          expect(parts.length).toBe(2);
          expect(parts[0]).toBe('profile');
          expect(parts[1]).toBe(userId);
        }),
        { numRuns: 100 }
      );
    });
  });
});
