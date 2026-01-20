/**
 * Social Media Deep Link Utilities
 * 
 * Generates deep links and web fallback URLs for social media platforms.
 * 
 * Requirements: 9.1, 9.2, 9.3
 */

export interface SocialMediaLinks {
  deepLink: string;
  webUrl: string;
}

/**
 * Generates TikTok deep link and web fallback URL
 * @param username - TikTok username
 * @returns Deep link and web URL
 * 
 * Requirements: 9.1
 * Deep link format: tiktok://user?username={username}
 * Web fallback: https://tiktok.com/@{username}
 */
export function getTikTokLinks(username: string): SocialMediaLinks {
  return {
    deepLink: `tiktok://user?username=${username}`,
    webUrl: `https://tiktok.com/@${username}`,
  };
}

/**
 * Generates Instagram deep link and web fallback URL
 * @param username - Instagram username
 * @returns Deep link and web URL
 * 
 * Requirements: 9.2
 * Deep link format: instagram://user?username={username}
 * Web fallback: https://instagram.com/{username}
 */
export function getInstagramLinks(username: string): SocialMediaLinks {
  return {
    deepLink: `instagram://user?username=${username}`,
    webUrl: `https://instagram.com/${username}`,
  };
}

/**
 * Generates Snapchat deep link and web fallback URL
 * @param username - Snapchat username
 * @returns Deep link and web URL
 * 
 * Requirements: 9.3
 * Deep link format: snapchat://add/{username}
 * Web fallback: https://snapchat.com/add/{username}
 */
export function getSnapchatLinks(username: string): SocialMediaLinks {
  return {
    deepLink: `snapchat://add/${username}`,
    webUrl: `https://snapchat.com/add/${username}`,
  };
}

/**
 * Validates that a deep link follows the correct format for a given platform
 * @param platform - Social media platform (tiktok, instagram, snapchat)
 * @param deepLink - The deep link to validate
 * @param username - The expected username
 * @returns true if the deep link is valid
 */
export function isValidDeepLink(
  platform: 'tiktok' | 'instagram' | 'snapchat',
  deepLink: string,
  username: string
): boolean {
  switch (platform) {
    case 'tiktok':
      return deepLink === `tiktok://user?username=${username}`;
    case 'instagram':
      return deepLink === `instagram://user?username=${username}`;
    case 'snapchat':
      return deepLink === `snapchat://add/${username}`;
    default:
      return false;
  }
}

/**
 * Validates that a web URL follows the correct format for a given platform
 * @param platform - Social media platform (tiktok, instagram, snapchat)
 * @param webUrl - The web URL to validate
 * @param username - The expected username
 * @returns true if the web URL is valid
 */
export function isValidWebUrl(
  platform: 'tiktok' | 'instagram' | 'snapchat',
  webUrl: string,
  username: string
): boolean {
  switch (platform) {
    case 'tiktok':
      return webUrl === `https://tiktok.com/@${username}`;
    case 'instagram':
      return webUrl === `https://instagram.com/${username}`;
    case 'snapchat':
      return webUrl === `https://snapchat.com/add/${username}`;
    default:
      return false;
  }
}
