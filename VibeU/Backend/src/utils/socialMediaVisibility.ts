/**
 * Social Media Visibility Control Utilities
 * 
 * Controls visibility of social media usernames based on friendship status.
 * 
 * Property 5: Social Media Visibility Control
 * For any user, their social media usernames (TikTok, Instagram, Snapchat) 
 * SHALL only be visible to users who are their friends. 
 * Non-friends SHALL see locked indicators instead of actual usernames.
 * 
 * Validates: Requirements 2.5, 5.5, 9.4, 9.5
 */

export interface SocialMediaData {
  tiktokUsername: string | null;
  instagramUsername: string | null;
  snapchatUsername: string | null;
}

export interface VisibleSocialMedia {
  hasTiktok: boolean;
  hasInstagram: boolean;
  hasSnapchat: boolean;
  tiktokUsername: string | null;
  instagramUsername: string | null;
  snapchatUsername: string | null;
  isLocked: boolean;
}

/**
 * Determines what social media information should be visible based on friendship status
 * 
 * @param socialMedia - The user's social media data
 * @param isFriend - Whether the requesting user is a friend
 * @returns Visible social media information with appropriate visibility
 * 
 * Requirements: 2.5, 5.5, 9.4, 9.5
 */
export function getSocialMediaVisibility(
  socialMedia: SocialMediaData,
  isFriend: boolean
): VisibleSocialMedia {
  const hasTiktok = !!socialMedia.tiktokUsername;
  const hasInstagram = !!socialMedia.instagramUsername;
  const hasSnapchat = !!socialMedia.snapchatUsername;

  if (isFriend) {
    // Friends can see actual usernames (Requirements: 5.5, 9.5)
    return {
      hasTiktok,
      hasInstagram,
      hasSnapchat,
      tiktokUsername: socialMedia.tiktokUsername,
      instagramUsername: socialMedia.instagramUsername,
      snapchatUsername: socialMedia.snapchatUsername,
      isLocked: false,
    };
  } else {
    // Non-friends see locked indicators (Requirements: 2.5, 9.4)
    return {
      hasTiktok,
      hasInstagram,
      hasSnapchat,
      tiktokUsername: null,
      instagramUsername: null,
      snapchatUsername: null,
      isLocked: true,
    };
  }
}

/**
 * Checks if social media usernames are properly hidden for non-friends
 * 
 * @param visibility - The visibility result
 * @param isFriend - Whether the user is a friend
 * @returns true if visibility rules are correctly applied
 */
export function isVisibilityCorrect(
  visibility: VisibleSocialMedia,
  isFriend: boolean
): boolean {
  if (isFriend) {
    // Friends should see unlocked state
    return visibility.isLocked === false;
  } else {
    // Non-friends should see locked state with null usernames
    return (
      visibility.isLocked === true &&
      visibility.tiktokUsername === null &&
      visibility.instagramUsername === null &&
      visibility.snapchatUsername === null
    );
  }
}

/**
 * Checks if the presence indicators (hasTiktok, etc.) are always visible
 * regardless of friendship status
 * 
 * @param socialMedia - Original social media data
 * @param visibility - The visibility result
 * @returns true if presence indicators match original data
 */
export function arePresenceIndicatorsCorrect(
  socialMedia: SocialMediaData,
  visibility: VisibleSocialMedia
): boolean {
  return (
    visibility.hasTiktok === !!socialMedia.tiktokUsername &&
    visibility.hasInstagram === !!socialMedia.instagramUsername &&
    visibility.hasSnapchat === !!socialMedia.snapchatUsername
  );
}
