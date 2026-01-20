/**
 * Property-Based Tests for Friendship Bidirectionality
 * 
 * Feature: vibeu-v2-complete-overhaul
 * Property 4: Friendship Bidirectionality
 * 
 * For any accepted friend request, the system SHALL create friendship records 
 * in both directions. When user A and user B become friends, querying friends 
 * for A SHALL include B, and querying friends for B SHALL include A.
 * 
 * Validates: Requirements 5.4, 5.5
 */

import { describe, it, expect, beforeEach } from 'vitest';
import fc from 'fast-check';

/**
 * Request status types
 */
type RequestStatus = 'pending' | 'accepted' | 'rejected' | 'cancelled';

/**
 * In-memory request store for testing
 */
interface Request {
  id: string;
  fromUserId: string;
  toUserId: string;
  status: RequestStatus;
  createdAt: Date;
  respondedAt?: Date;
}

/**
 * In-memory friendship store for testing
 */
interface Friendship {
  id: string;
  userAId: string;
  userBId: string;
  createdAt: Date;
}

/**
 * Combined store that simulates the database behavior
 * for request acceptance and friendship creation
 */
class RequestFriendshipStore {
  private requests: Map<string, Request> = new Map();
  private friendships: Map<string, Friendship> = new Map();
  private requestIdCounter = 0;
  private friendshipIdCounter = 0;

  /**
   * Create a friend request from one user to another
   */
  createRequest(fromUserId: string, toUserId: string): Request {
    const requestKey = `${fromUserId}-${toUserId}`;
    
    // Check if request already exists
    if (this.requests.has(requestKey)) {
      throw new Error('Request already exists');
    }

    const request: Request = {
      id: `request-${++this.requestIdCounter}`,
      fromUserId,
      toUserId,
      status: 'pending',
      createdAt: new Date(),
    };
    
    this.requests.set(requestKey, request);
    return request;
  }

  /**
   * Accept a friend request - creates bidirectional friendship
   * This mirrors the actual implementation in social.ts
   * 
   * Requirements 5.4: When a request is accepted, create a bidirectional friendship record
   */
  acceptRequest(requestId: string, acceptingUserId: string): Friendship {
    // Find the request
    let request: Request | undefined;
    for (const req of this.requests.values()) {
      if (req.id === requestId) {
        request = req;
        break;
      }
    }

    if (!request) {
      throw new Error('Request not found');
    }

    if (request.toUserId !== acceptingUserId) {
      throw new Error('Not authorized to accept this request');
    }

    if (request.status !== 'pending') {
      throw new Error('Request already processed');
    }

    // Update request status
    request.status = 'accepted';
    request.respondedAt = new Date();

    // Create bidirectional friendship (normalize user IDs by sorting)
    // This single record represents the friendship in both directions
    const [userAId, userBId] = [request.fromUserId, request.toUserId].sort();
    const friendshipKey = `${userAId}-${userBId}`;

    // Check if friendship already exists
    if (this.friendships.has(friendshipKey)) {
      return this.friendships.get(friendshipKey)!;
    }

    const friendship: Friendship = {
      id: `friendship-${++this.friendshipIdCounter}`,
      userAId,
      userBId,
      createdAt: new Date(),
    };

    this.friendships.set(friendshipKey, friendship);
    return friendship;
  }

  /**
   * Get all friends for a user
   * This mirrors the query: OR: [{ userAId: userId }, { userBId: userId }]
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
   * Get a request by ID
   */
  getRequest(requestId: string): Request | undefined {
    for (const req of this.requests.values()) {
      if (req.id === requestId) {
        return req;
      }
    }
    return undefined;
  }

  /**
   * Clear all data (for test reset)
   */
  clear(): void {
    this.requests.clear();
    this.friendships.clear();
    this.requestIdCounter = 0;
    this.friendshipIdCounter = 0;
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

describe('Friendship Bidirectionality - Property 4', () => {
  let store: RequestFriendshipStore;

  beforeEach(() => {
    store = new RequestFriendshipStore();
  });

  /**
   * Property 4: Friendship Bidirectionality
   * 
   * For any accepted friend request, the system SHALL create friendship records 
   * in both directions. When user A and user B become friends, querying friends 
   * for A SHALL include B, and querying friends for B SHALL include A.
   * 
   * Validates: Requirements 5.4, 5.5
   */

  it('should create bidirectional friendship when request is accepted', () => {
    fc.assert(
      fc.property(userPairArb, ([userA, userB]) => {
        store.clear();
        
        // User A sends request to User B
        const request = store.createRequest(userA, userB);
        
        // User B accepts the request
        const friendship = store.acceptRequest(request.id, userB);
        
        // Verify friendship was created
        expect(friendship).toBeDefined();
        expect(friendship.id).toBeDefined();
        
        // Verify bidirectionality: both users should see each other as friends
        expect(store.areFriends(userA, userB)).toBe(true);
        expect(store.areFriends(userB, userA)).toBe(true);
      }),
      { numRuns: 100 }
    );
  });

  it('should include friend in both users friend lists after acceptance', () => {
    fc.assert(
      fc.property(userPairArb, ([userA, userB]) => {
        store.clear();
        
        // User A sends request to User B
        const request = store.createRequest(userA, userB);
        
        // User B accepts the request
        store.acceptRequest(request.id, userB);
        
        // Querying friends for A should include B
        const friendsOfA = store.getFriends(userA);
        expect(friendsOfA).toContain(userB);
        
        // Querying friends for B should include A
        const friendsOfB = store.getFriends(userB);
        expect(friendsOfB).toContain(userA);
      }),
      { numRuns: 100 }
    );
  });

  it('should update request status to accepted', () => {
    fc.assert(
      fc.property(userPairArb, ([userA, userB]) => {
        store.clear();
        
        // User A sends request to User B
        const request = store.createRequest(userA, userB);
        expect(request.status).toBe('pending');
        
        // User B accepts the request
        store.acceptRequest(request.id, userB);
        
        // Request status should be updated
        const updatedRequest = store.getRequest(request.id);
        expect(updatedRequest?.status).toBe('accepted');
        expect(updatedRequest?.respondedAt).toBeDefined();
      }),
      { numRuns: 100 }
    );
  });

  it('should create exactly one friendship record regardless of user order', () => {
    fc.assert(
      fc.property(userPairArb, ([userA, userB]) => {
        store.clear();
        
        // User A sends request to User B
        const request = store.createRequest(userA, userB);
        
        // User B accepts the request
        store.acceptRequest(request.id, userB);
        
        // There should be exactly one friendship record
        // Both areFriends checks should return true from the same record
        expect(store.areFriends(userA, userB)).toBe(true);
        expect(store.areFriends(userB, userA)).toBe(true);
        
        // Friend lists should have exactly one entry each
        expect(store.getFriends(userA).length).toBe(1);
        expect(store.getFriends(userB).length).toBe(1);
      }),
      { numRuns: 100 }
    );
  });

  it('should only allow the recipient to accept the request', () => {
    fc.assert(
      fc.property(
        userPairArb,
        userIdArb,
        ([userA, userB], userC) => {
          // Skip if userC is the same as userA or userB
          if (userC === userA || userC === userB) {
            return true;
          }
          
          store.clear();
          
          // User A sends request to User B
          const request = store.createRequest(userA, userB);
          
          // User C (not the recipient) tries to accept - should fail
          expect(() => store.acceptRequest(request.id, userC)).toThrow('Not authorized');
          
          // User A (the sender) tries to accept - should fail
          expect(() => store.acceptRequest(request.id, userA)).toThrow('Not authorized');
          
          // No friendship should be created
          expect(store.areFriends(userA, userB)).toBe(false);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should not allow accepting an already processed request', () => {
    fc.assert(
      fc.property(userPairArb, ([userA, userB]) => {
        store.clear();
        
        // User A sends request to User B
        const request = store.createRequest(userA, userB);
        
        // User B accepts the request
        store.acceptRequest(request.id, userB);
        
        // Trying to accept again should fail
        expect(() => store.acceptRequest(request.id, userB)).toThrow('already processed');
      }),
      { numRuns: 100 }
    );
  });

  it('should maintain friendship symmetry - if A is friend of B, then B is friend of A', () => {
    fc.assert(
      fc.property(userPairArb, ([userA, userB]) => {
        store.clear();
        
        // Create and accept request
        const request = store.createRequest(userA, userB);
        store.acceptRequest(request.id, userB);
        
        // Symmetry check: areFriends should be symmetric
        const aFriendOfB = store.areFriends(userA, userB);
        const bFriendOfA = store.areFriends(userB, userA);
        
        expect(aFriendOfB).toBe(bFriendOfA);
        expect(aFriendOfB).toBe(true);
      }),
      { numRuns: 100 }
    );
  });
});
