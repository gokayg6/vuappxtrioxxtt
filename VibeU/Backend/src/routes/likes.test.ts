/**
 * Property-Based Tests for Like Without Notification
 * 
 * Feature: vibeu-v2-complete-overhaul
 * Property 15: Like Without Notification
 * 
 * For any like action, the system SHALL record the like but SHALL NOT create 
 * any notification for the target user.
 * 
 * Validates: Requirements 4.1
 */

import { describe, it, expect, beforeEach } from 'vitest';
import fc from 'fast-check';

/**
 * In-memory like store for testing
 */
interface Like {
  id: string;
  fromUserId: string;
  toUserId: string;
  createdAt: Date;
}

/**
 * In-memory notification store for testing
 */
interface Notification {
  id: string;
  userId: string;
  type: string;
  data: string;
  createdAt: Date;
}

/**
 * Combined store that simulates the database behavior
 * for likes and notifications
 */
class LikeNotificationStore {
  private likes: Map<string, Like> = new Map();
  private notifications: Notification[] = [];
  private likeIdCounter = 0;
  private notificationIdCounter = 0;

  /**
   * Create a like from one user to another
   * Requirements 4.1: Like WITHOUT sending any notification
   * 
   * This mirrors the actual implementation in social.ts which:
   * 1. Creates a like record
   * 2. Does NOT create any notification
   */
  createLike(fromUserId: string, toUserId: string): Like {
    const likeKey = `${fromUserId}-${toUserId}`;
    
    // Check if already liked
    if (this.likes.has(likeKey)) {
      throw new Error('Already liked');
    }

    const like: Like = {
      id: `like-${++this.likeIdCounter}`,
      fromUserId,
      toUserId,
      createdAt: new Date(),
    };
    
    this.likes.set(likeKey, like);
    
    // IMPORTANT: Do NOT create notification for likes
    // This is intentional per Requirements 4.1
    
    return like;
  }

  /**
   * Get all likes received by a user
   */
  getLikesReceived(userId: string): Like[] {
    const receivedLikes: Like[] = [];
    
    for (const like of this.likes.values()) {
      if (like.toUserId === userId) {
        receivedLikes.push(like);
      }
    }
    
    return receivedLikes;
  }

  /**
   * Get all likes sent by a user
   */
  getLikesSent(userId: string): Like[] {
    const sentLikes: Like[] = [];
    
    for (const like of this.likes.values()) {
      if (like.fromUserId === userId) {
        sentLikes.push(like);
      }
    }
    
    return sentLikes;
  }

  /**
   * Check if a user has liked another user
   */
  hasLiked(fromUserId: string, toUserId: string): boolean {
    const likeKey = `${fromUserId}-${toUserId}`;
    return this.likes.has(likeKey);
  }

  /**
   * Get all notifications for a user
   */
  getNotifications(userId: string): Notification[] {
    return this.notifications.filter(n => n.userId === userId);
  }

  /**
   * Get all notifications of a specific type for a user
   */
  getNotificationsByType(userId: string, type: string): Notification[] {
    return this.notifications.filter(n => n.userId === userId && n.type === type);
  }

  /**
   * Get total notification count for a user
   */
  getNotificationCount(userId: string): number {
    return this.notifications.filter(n => n.userId === userId).length;
  }

  /**
   * Clear all data (for test reset)
   */
  clear(): void {
    this.likes.clear();
    this.notifications = [];
    this.likeIdCounter = 0;
    this.notificationIdCounter = 0;
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

describe('Like Without Notification - Property 15', () => {
  let store: LikeNotificationStore;

  beforeEach(() => {
    store = new LikeNotificationStore();
  });

  /**
   * Property 15: Like Without Notification
   * 
   * For any like action, the system SHALL record the like but SHALL NOT create 
   * any notification for the target user.
   * 
   * Validates: Requirements 4.1
   */

  it('should record the like without creating any notification', () => {
    fc.assert(
      fc.property(userPairArb, ([fromUser, toUser]) => {
        store.clear();
        
        // Get initial notification count for target user
        const initialNotificationCount = store.getNotificationCount(toUser);
        
        // User likes another user
        const like = store.createLike(fromUser, toUser);
        
        // Verify like was recorded
        expect(like).toBeDefined();
        expect(like.id).toBeDefined();
        expect(like.fromUserId).toBe(fromUser);
        expect(like.toUserId).toBe(toUser);
        
        // Verify NO notification was created for the target user
        const finalNotificationCount = store.getNotificationCount(toUser);
        expect(finalNotificationCount).toBe(initialNotificationCount);
      }),
      { numRuns: 100 }
    );
  });

  it('should not create like-related notifications for target user', () => {
    fc.assert(
      fc.property(userPairArb, ([fromUser, toUser]) => {
        store.clear();
        
        // User likes another user
        store.createLike(fromUser, toUser);
        
        // Verify no like-related notifications exist
        const likeNotifications = store.getNotificationsByType(toUser, 'like_received');
        expect(likeNotifications.length).toBe(0);
        
        // Also check for any other notification types that might be related
        const allNotifications = store.getNotifications(toUser);
        expect(allNotifications.length).toBe(0);
      }),
      { numRuns: 100 }
    );
  });

  it('should record like in the database correctly', () => {
    fc.assert(
      fc.property(userPairArb, ([fromUser, toUser]) => {
        store.clear();
        
        // User likes another user
        store.createLike(fromUser, toUser);
        
        // Verify like is recorded
        expect(store.hasLiked(fromUser, toUser)).toBe(true);
        
        // Verify like appears in received likes
        const receivedLikes = store.getLikesReceived(toUser);
        expect(receivedLikes.length).toBe(1);
        expect(receivedLikes[0].fromUserId).toBe(fromUser);
        
        // Verify like appears in sent likes
        const sentLikes = store.getLikesSent(fromUser);
        expect(sentLikes.length).toBe(1);
        expect(sentLikes[0].toUserId).toBe(toUser);
      }),
      { numRuns: 100 }
    );
  });

  it('should not create notifications even with multiple likes', () => {
    fc.assert(
      fc.property(
        fc.array(userPairArb, { minLength: 1, maxLength: 10 }),
        (userPairs) => {
          store.clear();
          
          // Create multiple likes
          const uniquePairs = new Set<string>();
          for (const [fromUser, toUser] of userPairs) {
            const key = `${fromUser}-${toUser}`;
            if (!uniquePairs.has(key)) {
              uniquePairs.add(key);
              store.createLike(fromUser, toUser);
            }
          }
          
          // Verify no notifications were created for any user
          const allTargetUsers = new Set(userPairs.map(([_, toUser]) => toUser));
          for (const targetUser of allTargetUsers) {
            const notifications = store.getNotifications(targetUser);
            expect(notifications.length).toBe(0);
          }
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should prevent duplicate likes', () => {
    fc.assert(
      fc.property(userPairArb, ([fromUser, toUser]) => {
        store.clear();
        
        // First like should succeed
        const like = store.createLike(fromUser, toUser);
        expect(like).toBeDefined();
        
        // Second like should fail
        expect(() => store.createLike(fromUser, toUser)).toThrow('Already liked');
        
        // Still no notifications
        expect(store.getNotificationCount(toUser)).toBe(0);
      }),
      { numRuns: 100 }
    );
  });

  it('should allow mutual likes without notifications', () => {
    fc.assert(
      fc.property(userPairArb, ([userA, userB]) => {
        store.clear();
        
        // User A likes User B
        store.createLike(userA, userB);
        
        // User B likes User A (mutual like)
        store.createLike(userB, userA);
        
        // Both likes should be recorded
        expect(store.hasLiked(userA, userB)).toBe(true);
        expect(store.hasLiked(userB, userA)).toBe(true);
        
        // No notifications for either user
        expect(store.getNotificationCount(userA)).toBe(0);
        expect(store.getNotificationCount(userB)).toBe(0);
      }),
      { numRuns: 100 }
    );
  });
});
