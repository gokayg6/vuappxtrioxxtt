import Foundation

// MARK: - FriendsService
// This service handles friend-related API calls
// Requirements: 8.4, 8.7
actor FriendsService {
    static let shared = FriendsService()
    
    private init() {}
    
    // MARK: - Response Types
    struct FriendsResponse: Codable {
        let friends: [Friend]
    }
    
    struct RemoveFriendResponse: Codable {
        let success: Bool
    }
    
    // MARK: - GET /friends
    // Returns all friends for the authenticated user
    // Requirement: 8.4
    func getFriends() async throws -> [Friend] {
        let response: FriendsResponse = try await APIClient.shared.request(
            endpoint: "/friends",
            method: .get
        )
        return response.friends
    }
    
    // MARK: - DELETE /friends/:friendId
    // Removes a friendship bidirectionally
    // Requirement: 8.7
    func removeFriend(friendId: String) async throws {
        try await APIClient.shared.requestVoid(
            endpoint: "/friends/\(friendId)",
            method: .delete
        )
    }
    
    // MARK: - POST /requests
    // Sends a friend request to another user
    // Requirement: 5.2
    func sendFriendRequest(userId: String) async throws {
        print("📨 [FriendsService] Sending request to userId: \(userId)")
        
        // First, sync the target user to backend (in case they don't exist)
        try await syncUserToBackend(userId: userId)
        
        let body = ["target_user_id": userId]
        // Note: requiresAuth false for dev since backend accepts mock tokens
        try await APIClient.shared.requestVoid(
            endpoint: "/requests",
            method: .post,
            body: body,
            requiresAuth: true
        )
        print("📨 [FriendsService] Request sent successfully!")
    }
    
    // Sync user to backend database
    private func syncUserToBackend(userId: String) async throws {
        // Fetch user info from Firebase/UserService
        if let user = try? await UserService.shared.getProfileById(userId) {
            let dateFormatter = ISO8601DateFormatter()
            
            struct SyncUserBody: Codable {
                let userId: String
                let displayName: String
                let email: String
                let profilePhotoUrl: String?
                let dateOfBirth: String
                let gender: String
                let country: String
                let city: String
            }
            
            let body = SyncUserBody(
                userId: user.id,
                displayName: user.displayName,
                email: user.username,
                profilePhotoUrl: user.profilePhotoURL,
                dateOfBirth: dateFormatter.string(from: user.dateOfBirth),
                gender: user.gender.rawValue,
                country: user.country,
                city: user.city
            )
            
            try? await APIClient.shared.requestVoid(
                endpoint: "/auth/sync",
                method: .post,
                body: body,
                requiresAuth: false
            )
            print("✅ [FriendsService] Target user synced to backend: \(userId)")
        } else {
            // If can't fetch from Firebase, create minimal sync
            struct MinimalSyncBody: Codable {
                let userId: String
                let displayName: String
            }
            
            let body = MinimalSyncBody(userId: userId, displayName: "VibeU User")
            
            try? await APIClient.shared.requestVoid(
                endpoint: "/auth/sync",
                method: .post,
                body: body,
                requiresAuth: false
            )
        }
    }
    
    // MARK: - Friend Request Models
    struct PendingRequest: Codable, Identifiable {
        let id: String
        let fromUser: RequestUser
        let status: String
        let createdAt: String
        
        enum CodingKeys: String, CodingKey {
            case id, status
            case fromUser = "from_user"
            case createdAt = "created_at"
        }
    }
    
    struct RequestUser: Codable {
        let id: String
        let displayName: String
        let profilePhotoUrl: String
        let city: String
        let dateOfBirth: String? // Optional since backend might not send it always
        
        enum CodingKeys: String, CodingKey {
            case id, city, dateOfBirth
            case displayName = "display_name"
            case profilePhotoUrl = "profile_photo_url"
        }
    }
    
    struct RequestsResponse: Codable {
        let requests: [PendingRequest]
    }
    
    // MARK: - GET /requests/received
    // Fetch pending friend requests
    func getPendingRequests() async throws -> [PendingRequest] {
        let response: RequestsResponse = try await APIClient.shared.request(
            endpoint: "/requests/received",
            method: .get
        )
        return response.requests
    }
    
    // MARK: - PUT /requests/:id/accept
    // Accept a friend request
    func acceptRequest(requestId: String) async throws {
        try await APIClient.shared.requestVoid(
            endpoint: "/requests/\(requestId)/accept",
            method: .put
        )
    }
    
    // MARK: - POST /requests/:id/reject
    // Reject a friend request
    func rejectRequest(requestId: String) async throws {
        try await APIClient.shared.requestVoid(
            endpoint: "/requests/\(requestId)/reject",
            method: .post
        )
    }
}
