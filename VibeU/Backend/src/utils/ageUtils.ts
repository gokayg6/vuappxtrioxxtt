/**
 * Age Calculation and Validation Utilities
 * 
 * CRITICAL: These functions enforce age-based pool separation
 * - 15 yaş altı → null (kayıt reddi)
 * - 15-17 → minor (Minor_Pool)
 * - 18+ → adult (Adult_Pool)
 * 
 * Requirements: 1.4, 1.5, 12.1, 12.2
 */

/**
 * Calculate age from date of birth
 * 
 * @param dateOfBirth - The user's date of birth
 * @returns The calculated age in complete years
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
 * Calculate age group from date of birth
 * 
 * CRITICAL: This determines which pool the user belongs to
 * - null: Under 15 (registration rejected)
 * - 'minor': 15-17 years old (Minor_Pool)
 * - 'adult': 18+ years old (Adult_Pool)
 * 
 * @param dateOfBirth - The user's date of birth
 * @returns 'minor' | 'adult' | null
 */
export function calculateAgeGroup(dateOfBirth: Date): 'minor' | 'adult' | null {
  const age = calculateAge(dateOfBirth);
  
  if (age < 15) {
    return null; // Registration rejected
  }
  
  if (age >= 15 && age <= 17) {
    return 'minor';
  }
  
  return 'adult';
}
