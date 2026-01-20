/**
 * Age Group Validation Middleware
 * 
 * CRITICAL: This middleware enforces strict age-based pool separation
 * - Minor Pool (15-17): Can ONLY interact with other minors
 * - Adult Pool (18+): Can ONLY interact with other adults
 * 
 * Cross-pool interactions are ALWAYS rejected with HTTP 403
 * 
 * Requirements: 12.5, 12.6, 12.8
 */

import { Request, Response, NextFunction } from 'express';
import { prisma } from '../lib/prisma';
import { calculateAge, calculateAgeGroup } from '../utils/ageUtils';

/**
 * Validates that two users are in the same age group
 * 
 * CRITICAL: This is the core safety function for age-based separation
 * 
 * @param currentUserId - The ID of the current authenticated user
 * @param targetUserId - The ID of the user being interacted with
 * @returns Promise<boolean> - true if same age group, false otherwise
 */
export async function validateAgeGroupMatch(
  currentUserId: string,
  targetUserId: string
): Promise<boolean> {
  // Fetch both users' date of birth
  const [currentUser, targetUser] = await Promise.all([
    prisma.user.findUnique({
      where: { id: currentUserId },
      select: { dateOfBirth: true }
    }),
    prisma.user.findUnique({
      where: { id: targetUserId },
      select: { dateOfBirth: true }
    })
  ]);

  // If either user doesn't exist, return false
  if (!currentUser || !targetUser) {
    return false;
  }

  // Calculate age groups from date of birth (NEVER trust client-provided age)
  const currentAgeGroup = calculateAgeGroup(currentUser.dateOfBirth);
  const targetAgeGroup = calculateAgeGroup(targetUser.dateOfBirth);

  // If either user has null age group (under 15), they shouldn't be in the system
  if (currentAgeGroup === null || targetAgeGroup === null) {
    return false;
  }

  // CRITICAL: Only allow interaction if both users are in the same age group
  return currentAgeGroup === targetAgeGroup;
}

/**
 * Express middleware factory for age group validation
 * 
 * Creates a middleware that validates age group match before allowing
 * cross-user interactions (likes, requests, etc.)
 * 
 * @param targetUserIdField - The field name containing the target user ID
 *                           Can be in req.body, req.params, or req.query
 * @returns Express middleware function
 */
export function ageGroupMiddleware(targetUserIdField: string = 'targetUserId') {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      // Get current user from auth middleware
      const currentUserId = req.user?.id;
      
      if (!currentUserId) {
        return res.status(401).json({
          error: 'unauthorized',
          message: 'Oturum süresi doldu.'
        });
      }

      // Extract target user ID from request
      const targetUserId = 
        req.body[targetUserIdField] || 
        req.params[targetUserIdField] ||
        req.params.userId ||
        req.query[targetUserIdField];

      // If no target user ID, skip validation (might be a list endpoint)
      if (!targetUserId) {
        return next();
      }

      // Validate age group match
      const isMatch = await validateAgeGroupMatch(currentUserId, targetUserId as string);

      if (!isMatch) {
        // CRITICAL: Cross-pool action rejected
        return res.status(403).json({
          error: 'age_group_mismatch',
          message: 'Yaş grubu sebebiyle işlem yapılamıyor.'
        });
      }

      next();
    } catch (error) {
      next(error);
    }
  };
}

/**
 * Utility function to get age group for a user by ID
 * 
 * @param userId - The user's ID
 * @returns Promise<'minor' | 'adult' | null>
 */
export async function getAgeGroupForUser(userId: string): Promise<'minor' | 'adult' | null> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { dateOfBirth: true }
  });

  if (!user) {
    return null;
  }

  return calculateAgeGroup(user.dateOfBirth);
}

/**
 * Utility function to check if a user can interact with another user
 * based on age group rules
 * 
 * This is a convenience wrapper around validateAgeGroupMatch
 * 
 * @param currentUserId - The current user's ID
 * @param targetUserId - The target user's ID
 * @returns Promise<{ canInteract: boolean; reason?: string }>
 */
export async function canInteractWithUser(
  currentUserId: string,
  targetUserId: string
): Promise<{ canInteract: boolean; reason?: string }> {
  const isMatch = await validateAgeGroupMatch(currentUserId, targetUserId);

  if (!isMatch) {
    return {
      canInteract: false,
      reason: 'Yaş grubu sebebiyle işlem yapılamıyor.'
    };
  }

  return { canInteract: true };
}
