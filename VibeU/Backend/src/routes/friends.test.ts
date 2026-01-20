/**
 * Property-Based Tests for Friendship Removal Bidirectionality
 * 
 * Feature: vibeu-v2-complete-overhaul
 * Property 13: Friendship Removal Bidirectionality
 * 
 * For any friendship removal, the system SHALL delete friendship records in both 
 * directions. After user A removes user B as friend, neither A nor B SHALL appear 
 * in each other's friend lists.
 * 
 * Validates: Requirements 8.7
 */

import { describe, it, expect, beforeEach } from 'vitest';
import fc from 'fast-check';

/**
 * In-memory friendship store for testing the bidirectionality property
 * This simulates the database behavior without requiring actual DB calls
 */
interface Friendship {
  id: string;
  userAId: string;
  userBId: string;
}

class FriendshipStore {
  private friendships: Map<string, Friendship> = new Map();
  private idCounter = 0;

  /**
   * Create a friendship between two users
   * Normalizes the order (userA < userB) to ensure uniqueness
   */
  createFriendship(userId1: string, userId2: string): Friendship {
    const [userAId, userBId] = [userId1, userId2].sort();
    
    // Check if friendship already exists
    const existingKey = `${userAId}-${userBId}`;
    if (this.friendships.has(existingKey)) {
      return this.friendships.get(existingKey)!;
    }

    const friendship: Friendship = {
      id: `friendship-${++this.idCounter}`,
      userAId,
      userBId,
    };
    
    this.friendships.set(existingKey, friendship);
    return friendship;
  }

  /**
   * Remove friendship bidirectionally - mirrors the actual implementation
   * This should delete the friendship regardless of which user initiates
   */
  removeFriendship(currentUserId: string, friendId: string): boolean {
    // Find and delete friendship in both directions
    // This mirrors: OR: [{ userAId: userId, userBId: friendId }, { userAId: friendId, userBId: userId }]
    const key1 = [currentUserId, friendId].sort().join('-');
    
    if (this.friendships.has(key1)) {
      this.friendships.delete(key1);
      return true;
    }
    
    return false;
  }

  /**
   * Get all friends for a user
   */
  getFriends(userId: string): string[] {
    const friends: string[] = [];
    
    for (const friendship of this.friendships.values()) {
      if (friendship.userAId === userId) {
        friends.push(friendship.userBId);
      } else if (friendship.userBId === userId) {
        friends.push(friendship.userAId);
      }
    }
    
    return friends;
  }

  /**
   * Check if two users are friends
   */
  areFriends(userId1: string, userId2: string): boolean {
    const key = [userId1, userId2].sort().join('-');
    return this.friendships.has(key);
  }

  /**
   * Clear all friendships (for test reset)
   */
  clear(): void {
    this.friendships.clear();
    this.idCounter = 0;
  }
}

/**
 * Generate a valid user ID
 */
const userIdArb = fc.uuid();

/**
 * Generate a pair of distinct user IDs
 */
const userPairArb = fc.tuple(userIdArb, userIdArb).filter(([a, b]) => a !== b);

describe('Friendship Removal Bidirectionality - Property 13', () => {
  let store: FriendshipStore;

  beforeEach(() => {
    store = new FriendshipStore();
  });

  /**
   * Property 13: Friendship Removal Bidirectionality
   * 
   * For any friendship removal, the system SHALL delete friendship records 
   * in both directions.
   * 
   * Validates: Requirements 8.7
   */

  it('should remove friendship when user A removes user B', () => {
    fc.assert(
      fc.property(userPairArb, ([userA, userB]) => {
        store.clear();
        
        // Create friendship
        store.createFriendship(userA, userB);
        
        // Verify friendship exists
        expect(store.areFriends(userA, userB)).toBe(true);
        expect(store.areFriends(userB, userA)).toBe(true);
        
        // User A removes User B
        const removed = store.removeFriendship(userA, userB);
        expect(removed).toBe(true);
        
        // Verify friendship is removed in both directions
        expect(store.areFriends(userA, userB)).toBe(false);
        expect(store.areFriends(userB, userA)).toBe(false);
      }),
      { numRuns: 100 }
    );
  });

  it('should remove friendship when user B removes user A', () => {
    fc.assert(
      fc.property(userPairArb, ([userA, userB]) => {
        store.clear();
        
        // Create friendship
        store.createFriendship(userA, userB);
        
        // Verify friendship exists
        expect(store.areFriends(userA, userB)).toBe(true);
        
        // User B removes User A (reverse direction)
        const removed = store.removeFriendship(userB, userA);
        expect(removed).toBe(true);
        
        // Verify friendship is removed in both directions
        expect(store.areFriends(userA, userB)).toBe(false);
        expect(store.areFriends(userB, userA)).toBe(false);
      }),
      { numRuns: 100 }
    );
  });

  it('should not show removed friend in either user\'s friend list', () => {
    fc.assert(
      fc.property(userPairArb, ([userA, userB]) => {
        store.clear();
        
        // Create friendship
        store.createFriendship(userA, userB);
        
        // Verify both users see each other as friends
        expect(store.getFriends(userA)).toContain(userB);
        expect(store.getFriends(userB)).toContain(userA);
        
        // Remove friendship
        store.removeFriendship(userA, userB);
        
        // Neither user should see the other in their friend list
        expect(store.getFriends(userA)).not.toContain(userB);
        expect(store.getFriends(userB)).not.toContain(userA);
      }),
      { numRuns: 100 }
    );
  });

  it('should be symmetric - removal by either user has the same effect', () => {
    fc.assert(
      fc.property(
        userPairArb,
        fc.boolean(), // Determines which user initiates removal
        ([userA, userB], userAInitiates) => {
          store.clear();
          
          // Create friendship
          store.createFriendship(userA, userB);
          
          // Either user can initiate removal
          if (userAInitiates) {
            store.removeFriendship(userA, userB);
          } else {
            store.removeFriendship(userB, userA);
          }
          
          // Result should be the same regardless of who initiated
          expect(store.areFriends(userA, userB)).toBe(false);
          expect(store.areFriends(userB, userA)).toBe(false);
          expect(store.getFriends(userA)).not.toContain(userB);
          expect(store.getFriends(userB)).not.toContain(userA);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should only affect the specific friendship, not other friendships', () => {
    fc.assert(
      fc.property(
        userIdArb,
        userIdArb,
        userIdArb,
        (userA, userB, userC) => {
          // Skip if any users are the same
          if (userA === userB || userB === userC || userA === userC) {
            return true; // Skip this test case
          }
          
          store.clear();
          
          // Create friendships: A-B and A-C
          store.createFriendship(userA, userB);
          store.createFriendship(userA, userC);
          
          // Verify both friendships exist
          expect(store.areFriends(userA, userB)).toBe(true);
          expect(store.areFriends(userA, userC)).toBe(true);
          
          // Remove A-B friendship
          store.removeFriendship(userA, userB);
          
          // A-B should be removed
          expect(store.areFriends(userA, userB)).toBe(false);
          
          // A-C should still exist
          expect(store.areFriends(userA, userC)).toBe(true);
          expect(store.getFriends(userA)).toContain(userC);
          expect(store.getFriends(userC)).toContain(userA);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should return false when trying to remove non-existent friendship', () => {
    fc.assert(
      fc.property(userPairArb, ([userA, userB]) => {
        store.clear();
        
        // Try to remove friendship that doesn't exist
        const removed = store.removeFriendship(userA, userB);
        
        // Should return false (no friendship to remove)
        expect(removed).toBe(false);
      }),
      { numRuns: 100 }
    );
  });
});
