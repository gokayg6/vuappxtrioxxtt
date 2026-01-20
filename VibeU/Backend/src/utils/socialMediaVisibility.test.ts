/**
 * Property-Based Tests for Social Media Visibility Control
 * 
 * Feature: vibeu-v2-complete-overhaul
 * Property 5: Social Media Visibility Control
 * Validates: Requirements 2.5, 5.5, 9.4, 9.5
 * 
 * For any user, their social media usernames (TikTok, Instagram, Snapchat) 
 * SHALL only be visible to users who are their friends. 
 * Non-friends SHALL see locked indicators instead of actual usernames.
 */

import { describe, it, expect } from 'vitest';
import fc from 'fast-check';
import {
  getSocialMediaVisibility,
  isVisibilityCorrect,
  arePresenceIndicatorsCorrect,
  SocialMediaData,
} from './socialMediaVisibility';

// Arbitrary for valid social media usernames (can be null or valid string)
const usernameArbitrary = fc.option(
  fc.stringMatching(/^[a-zA-Z0-9_.]{1,30}$/),
  { nil: null }
);

// Arbitrary for social media data
const socialMediaDataArbitrary: fc.Arbitrary<SocialMediaData> = fc.record({
  tiktokUsername: usernameArbitrary,
  instagramUsername: usernameArbitrary,
  snapchatUsername: usernameArbitrary,
});

describe('Social Media Visibility Control - Property 5', () => {
  /**
   * Property 5: Social Media Visibility Control
   * 
   * For any user, their social media usernames (TikTok, Instagram, Snapchat) 
   * SHALL only be visible to users who are their friends. 
   * Non-friends SHALL see locked indicators instead of actual usernames.
   * 
   * Validates: Requirements 2.5, 5.5, 9.4, 9.5
   */

  describe('Non-Friend Visibility (Requirements 2.5, 9.4)', () => {
    it('should hide all social media usernames for non-friends', () => {
      fc.assert(
        fc.property(socialMediaDataArbitrary, (socialMedia) => {
          const visibility = getSocialMediaVisibility(socialMedia, false);
          
          // Non-friends should never see actual usernames
          expect(visibility.tiktokUsername).toBeNull();
          expect(visibility.instagramUsername).toBeNull();
          expect(visibility.snapchatUsername).toBeNull();
        }),
        { numRuns: 100 }
      );
    });

    it('should show locked indicator for non-friends', () => {
      fc.assert(
        fc.property(socialMediaDataArbitrary, (socialMedia) => {
          const visibility = getSocialMediaVisibility(socialMedia, false);
          
          // Non-friends should see locked state
          expect(visibility.isLocked).toBe(true);
        }),
        { numRuns: 100 }
      );
    });

    it('should still show presence indicators (hasTiktok, etc.) for non-friends', () => {
      fc.assert(
        fc.property(socialMediaDataArbitrary, (socialMedia) => {
          const visibility = getSocialMediaVisibility(socialMedia, false);
          
          // Presence indicators should match original data
          expect(visibility.hasTiktok).toBe(!!socialMedia.tiktokUsername);
          expect(visibility.hasInstagram).toBe(!!socialMedia.instagramUsername);
          expect(visibility.hasSnapchat).toBe(!!socialMedia.snapchatUsername);
        }),
        { numRuns: 100 }
      );
    });
  });

  describe('Friend Visibility (Requirements 5.5, 9.5)', () => {
    it('should show all social media usernames for friends', () => {
      fc.assert(
        fc.property(socialMediaDataArbitrary, (socialMedia) => {
          const visibility = getSocialMediaVisibility(socialMedia, true);
          
          // Friends should see actual usernames
          expect(visibility.tiktokUsername).toBe(socialMedia.tiktokUsername);
          expect(visibility.instagramUsername).toBe(socialMedia.instagramUsername);
          expect(visibility.snapchatUsername).toBe(socialMedia.snapchatUsername);
        }),
        { numRuns: 100 }
      );
    });

    it('should show unlocked indicator for friends', () => {
      fc.assert(
        fc.property(socialMediaDataArbitrary, (socialMedia) => {
          const visibility = getSocialMediaVisibility(socialMedia, true);
          
          // Friends should see unlocked state
          expect(visibility.isLocked).toBe(false);
        }),
        { numRuns: 100 }
      );
    });

    it('should show correct presence indicators for friends', () => {
      fc.assert(
        fc.property(socialMediaDataArbitrary, (socialMedia) => {
          const visibility = getSocialMediaVisibility(socialMedia, true);
          
          // Presence indicators should match original data
          expect(visibility.hasTiktok).toBe(!!socialMedia.tiktokUsername);
          expect(visibility.hasInstagram).toBe(!!socialMedia.instagramUsername);
          expect(visibility.hasSnapchat).toBe(!!socialMedia.snapchatUsername);
        }),
        { numRuns: 100 }
      );
    });
  });

  describe('Visibility Correctness Validation', () => {
    it('should correctly validate visibility rules for any friendship status', () => {
      fc.assert(
        fc.property(
          socialMediaDataArbitrary,
          fc.boolean(),
          (socialMedia, isFriend) => {
            const visibility = getSocialMediaVisibility(socialMedia, isFriend);
            
            // Visibility should always be correct according to rules
            expect(isVisibilityCorrect(visibility, isFriend)).toBe(true);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should always preserve presence indicators regardless of friendship', () => {
      fc.assert(
        fc.property(
          socialMediaDataArbitrary,
          fc.boolean(),
          (socialMedia, isFriend) => {
            const visibility = getSocialMediaVisibility(socialMedia, isFriend);
            
            // Presence indicators should always be correct
            expect(arePresenceIndicatorsCorrect(socialMedia, visibility)).toBe(true);
          }
        ),
        { numRuns: 100 }
      );
    });
  });

  describe('Consistency Properties', () => {
    it('should be deterministic - same input always produces same output', () => {
      fc.assert(
        fc.property(
          socialMediaDataArbitrary,
          fc.boolean(),
          (socialMedia, isFriend) => {
            const visibility1 = getSocialMediaVisibility(socialMedia, isFriend);
            const visibility2 = getSocialMediaVisibility(socialMedia, isFriend);
            
            // Same input should produce identical output
            expect(visibility1).toEqual(visibility2);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should have opposite locked states for friends vs non-friends', () => {
      fc.assert(
        fc.property(socialMediaDataArbitrary, (socialMedia) => {
          const friendVisibility = getSocialMediaVisibility(socialMedia, true);
          const nonFriendVisibility = getSocialMediaVisibility(socialMedia, false);
          
          // Locked states should be opposite
          expect(friendVisibility.isLocked).toBe(false);
          expect(nonFriendVisibility.isLocked).toBe(true);
          expect(friendVisibility.isLocked).not.toBe(nonFriendVisibility.isLocked);
        }),
        { numRuns: 100 }
      );
    });

    it('should have same presence indicators for friends and non-friends', () => {
      fc.assert(
        fc.property(socialMediaDataArbitrary, (socialMedia) => {
          const friendVisibility = getSocialMediaVisibility(socialMedia, true);
          const nonFriendVisibility = getSocialMediaVisibility(socialMedia, false);
          
          // Presence indicators should be identical
          expect(friendVisibility.hasTiktok).toBe(nonFriendVisibility.hasTiktok);
          expect(friendVisibility.hasInstagram).toBe(nonFriendVisibility.hasInstagram);
          expect(friendVisibility.hasSnapchat).toBe(nonFriendVisibility.hasSnapchat);
        }),
        { numRuns: 100 }
      );
    });
  });
});
