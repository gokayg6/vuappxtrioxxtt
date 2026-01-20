/**
 * Property-Based Tests for Social Media Deep Link Format
 * 
 * Feature: vibeu-v2-complete-overhaul
 * Property 8: Social Media Deep Link Format
 * Validates: Requirements 9.1, 9.2, 9.3
 * 
 * For any social media username, the generated deep link SHALL follow the correct format:
 * - TikTok → "tiktok://user?username={username}"
 * - Instagram → "instagram://user?username={username}"
 * - Snapchat → "snapchat://add/{username}"
 */

import { describe, it, expect } from 'vitest';
import fc from 'fast-check';
import {
  getTikTokLinks,
  getInstagramLinks,
  getSnapchatLinks,
  isValidDeepLink,
  isValidWebUrl,
} from './socialMediaLinks';

// Arbitrary for valid social media usernames
// Social media usernames typically: alphanumeric, underscores, periods, 1-30 chars
const usernameArbitrary = fc.stringMatching(/^[a-zA-Z0-9_.]{1,30}$/);

describe('Social Media Deep Link Format - Property 8', () => {
  /**
   * Property 8: Social Media Deep Link Format
   * 
   * For any social media username, the generated deep link SHALL follow the correct format:
   * - TikTok → "tiktok://user?username={username}"
   * - Instagram → "instagram://user?username={username}"
   * - Snapchat → "snapchat://add/{username}"
   * 
   * Validates: Requirements 9.1, 9.2, 9.3
   */

  describe('TikTok Deep Links (Requirement 9.1)', () => {
    it('should generate correct TikTok deep link format for any valid username', () => {
      fc.assert(
        fc.property(usernameArbitrary, (username) => {
          const links = getTikTokLinks(username);
          
          // Deep link must follow format: tiktok://user?username={username}
          expect(links.deepLink).toBe(`tiktok://user?username=${username}`);
          expect(isValidDeepLink('tiktok', links.deepLink, username)).toBe(true);
        }),
        { numRuns: 100 }
      );
    });

    it('should generate correct TikTok web fallback URL for any valid username', () => {
      fc.assert(
        fc.property(usernameArbitrary, (username) => {
          const links = getTikTokLinks(username);
          
          // Web URL must follow format: https://tiktok.com/@{username}
          expect(links.webUrl).toBe(`https://tiktok.com/@${username}`);
          expect(isValidWebUrl('tiktok', links.webUrl, username)).toBe(true);
        }),
        { numRuns: 100 }
      );
    });

    it('should have deep link starting with tiktok:// scheme', () => {
      fc.assert(
        fc.property(usernameArbitrary, (username) => {
          const links = getTikTokLinks(username);
          expect(links.deepLink.startsWith('tiktok://')).toBe(true);
        }),
        { numRuns: 100 }
      );
    });
  });

  describe('Instagram Deep Links (Requirement 9.2)', () => {
    it('should generate correct Instagram deep link format for any valid username', () => {
      fc.assert(
        fc.property(usernameArbitrary, (username) => {
          const links = getInstagramLinks(username);
          
          // Deep link must follow format: instagram://user?username={username}
          expect(links.deepLink).toBe(`instagram://user?username=${username}`);
          expect(isValidDeepLink('instagram', links.deepLink, username)).toBe(true);
        }),
        { numRuns: 100 }
      );
    });

    it('should generate correct Instagram web fallback URL for any valid username', () => {
      fc.assert(
        fc.property(usernameArbitrary, (username) => {
          const links = getInstagramLinks(username);
          
          // Web URL must follow format: https://instagram.com/{username}
          expect(links.webUrl).toBe(`https://instagram.com/${username}`);
          expect(isValidWebUrl('instagram', links.webUrl, username)).toBe(true);
        }),
        { numRuns: 100 }
      );
    });

    it('should have deep link starting with instagram:// scheme', () => {
      fc.assert(
        fc.property(usernameArbitrary, (username) => {
          const links = getInstagramLinks(username);
          expect(links.deepLink.startsWith('instagram://')).toBe(true);
        }),
        { numRuns: 100 }
      );
    });
  });

  describe('Snapchat Deep Links (Requirement 9.3)', () => {
    it('should generate correct Snapchat deep link format for any valid username', () => {
      fc.assert(
        fc.property(usernameArbitrary, (username) => {
          const links = getSnapchatLinks(username);
          
          // Deep link must follow format: snapchat://add/{username}
          expect(links.deepLink).toBe(`snapchat://add/${username}`);
          expect(isValidDeepLink('snapchat', links.deepLink, username)).toBe(true);
        }),
        { numRuns: 100 }
      );
    });

    it('should generate correct Snapchat web fallback URL for any valid username', () => {
      fc.assert(
        fc.property(usernameArbitrary, (username) => {
          const links = getSnapchatLinks(username);
          
          // Web URL must follow format: https://snapchat.com/add/{username}
          expect(links.webUrl).toBe(`https://snapchat.com/add/${username}`);
          expect(isValidWebUrl('snapchat', links.webUrl, username)).toBe(true);
        }),
        { numRuns: 100 }
      );
    });

    it('should have deep link starting with snapchat:// scheme', () => {
      fc.assert(
        fc.property(usernameArbitrary, (username) => {
          const links = getSnapchatLinks(username);
          expect(links.deepLink.startsWith('snapchat://')).toBe(true);
        }),
        { numRuns: 100 }
      );
    });
  });

  describe('Cross-Platform Consistency', () => {
    it('should preserve username in all generated links for any platform', () => {
      fc.assert(
        fc.property(
          usernameArbitrary,
          fc.constantFrom('tiktok', 'instagram', 'snapchat') as fc.Arbitrary<'tiktok' | 'instagram' | 'snapchat'>,
          (username, platform) => {
            let links;
            switch (platform) {
              case 'tiktok':
                links = getTikTokLinks(username);
                break;
              case 'instagram':
                links = getInstagramLinks(username);
                break;
              case 'snapchat':
                links = getSnapchatLinks(username);
                break;
            }
            
            // Username must be present in both deep link and web URL
            expect(links.deepLink).toContain(username);
            expect(links.webUrl).toContain(username);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should generate valid URLs (no spaces or invalid characters in output)', () => {
      fc.assert(
        fc.property(usernameArbitrary, (username) => {
          const tiktok = getTikTokLinks(username);
          const instagram = getInstagramLinks(username);
          const snapchat = getSnapchatLinks(username);
          
          // Deep links should not contain spaces
          expect(tiktok.deepLink).not.toContain(' ');
          expect(instagram.deepLink).not.toContain(' ');
          expect(snapchat.deepLink).not.toContain(' ');
          
          // Web URLs should be valid HTTPS URLs
          expect(tiktok.webUrl.startsWith('https://')).toBe(true);
          expect(instagram.webUrl.startsWith('https://')).toBe(true);
          expect(snapchat.webUrl.startsWith('https://')).toBe(true);
        }),
        { numRuns: 100 }
      );
    });
  });
});
