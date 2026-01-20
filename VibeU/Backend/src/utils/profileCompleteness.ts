/**
 * Profile Completeness Utility Functions
 * 
 * Feature: vibeu-v2-complete-overhaul
 * Property 14: Profile Completeness Check
 * Validates: Requirements 1.1, 1.2, 1.3
 * 
 * Zorunlu alanlar: displayName, dateOfBirth, gender, country, city, profilePhotoUrl
 */

import { calculateAge } from './ageUtils';

export interface UserProfile {
  displayName: string;
  dateOfBirth: Date;
  gender: string;
  country: string;
  city: string;
  profilePhotoUrl: string;
}

export interface ProfileCompletenessResult {
  isComplete: boolean;
  missingFields: string[];
}

/**
 * Checks if a display name is valid (non-empty after trimming)
 */
export function isValidDisplayName(displayName: string): boolean {
  return displayName.trim().length > 0;
}

/**
 * Checks if a date of birth is valid
 * - Must be in the past
 * - User must be at least 15 years old (per Requirements 1.4, 1.5)
 */
export function isValidDateOfBirth(dateOfBirth: Date): boolean {
  const now = new Date();
  
  // Date should be in the past
  if (dateOfBirth >= now) {
    return false;
  }
  
  // Calculate age and check if at least 15
  const age = calculateAge(dateOfBirth);
  return age >= 15;
}

/**
 * Checks if a gender value is valid
 * Valid values: male, female, other, prefer_not_to_say
 */
export function isValidGender(gender: string): boolean {
  const validGenders = ['male', 'female', 'other', 'prefer_not_to_say'];
  return validGenders.includes(gender.toLowerCase());
}

/**
 * Checks if a country is valid (non-empty after trimming)
 */
export function isValidCountry(country: string): boolean {
  return country.trim().length > 0;
}

/**
 * Checks if a city is valid (non-empty after trimming)
 */
export function isValidCity(city: string): boolean {
  return city.trim().length > 0;
}

/**
 * Checks if a profile photo URL is valid
 * - Must be non-empty after trimming
 * - Must be a valid URL format
 */
export function isValidProfilePhotoUrl(profilePhotoUrl: string): boolean {
  const trimmed = profilePhotoUrl.trim();
  if (trimmed.length === 0) {
    return false;
  }
  
  try {
    new URL(trimmed);
    return true;
  } catch {
    return false;
  }
}

/**
 * Checks if a user profile is complete
 * 
 * Property 14: Profile Completeness Check
 * For any user attempting to access the main app, if their profile is missing 
 * any required field (displayName, dateOfBirth, gender, country, city, profilePhoto), 
 * the system SHALL redirect to onboarding flow.
 * 
 * Validates: Requirements 1.1, 1.2, 1.3
 */
export function checkProfileCompleteness(profile: UserProfile): ProfileCompletenessResult {
  const missingFields: string[] = [];
  
  if (!isValidDisplayName(profile.displayName)) {
    missingFields.push('displayName');
  }
  
  if (!isValidDateOfBirth(profile.dateOfBirth)) {
    missingFields.push('dateOfBirth');
  }
  
  if (!isValidGender(profile.gender)) {
    missingFields.push('gender');
  }
  
  if (!isValidCountry(profile.country)) {
    missingFields.push('country');
  }
  
  if (!isValidCity(profile.city)) {
    missingFields.push('city');
  }
  
  if (!isValidProfilePhotoUrl(profile.profilePhotoUrl)) {
    missingFields.push('profilePhotoUrl');
  }
  
  return {
    isComplete: missingFields.length === 0,
    missingFields
  };
}

/**
 * Simple boolean check for profile completeness
 */
export function isProfileComplete(profile: UserProfile): boolean {
  return checkProfileCompleteness(profile).isComplete;
}
