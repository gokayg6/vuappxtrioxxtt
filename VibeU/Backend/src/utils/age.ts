/**
 * Calculate age from date of birth
 * CRITICAL: This is used for age group enforcement
 */
export function calculateAge(dateOfBirth: Date): number {
  const today = new Date();
  const birthDate = new Date(dateOfBirth);
  
  let age = today.getFullYear() - birthDate.getFullYear();
  const monthDiff = today.getMonth() - birthDate.getMonth();
  
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }
  
  return age;
}

/**
 * Get age group from age
 * CRITICAL: This determines which pool the user belongs to
 * 
 * minor: 13-17 years old
 * adult: 18+ years old
 */
export function getAgeGroup(age: number): 'minor' | 'adult' {
  if (age < 13) {
    throw new Error('User must be at least 13 years old');
  }
  
  return age < 18 ? 'minor' : 'adult';
}

/**
 * Validate date of birth
 * Returns true if user is at least 13 years old
 */
export function isValidDateOfBirth(dateOfBirth: Date): boolean {
  const age = calculateAge(dateOfBirth);
  return age >= 13;
}

/**
 * Check if two users are in the same age group
 * CRITICAL: This is the core safety check
 */
export function isSameAgeGroup(
  user1DateOfBirth: Date,
  user2DateOfBirth: Date
): boolean {
  const age1 = calculateAge(user1DateOfBirth);
  const age2 = calculateAge(user2DateOfBirth);
  
  const ageGroup1 = getAgeGroup(age1);
  const ageGroup2 = getAgeGroup(age2);
  
  return ageGroup1 === ageGroup2;
}
