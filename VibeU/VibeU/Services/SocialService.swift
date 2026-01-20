import Foundation

actor SocialService {
    static let shared = SocialService()
    
    private init() {}
    
    // MARK: - Requests
    
    struct SendRequestBody: Codable {
        let targetUserId: String
        
        enum CodingKeys: String, CodingKey {
            case targetUserId = "target_user_id"
        }
    }
    
    struct SendRequestResponse: Codable {
        let success: Bool
        let requestId: String
        
        enum CodingKeys: String, CodingKey {
            case success
            case requestId = "request_id"
        }
    }
    
    func sendRequest(toUserId: String) async throws -> SendRequestResponse {
        return try await APIClient.shared.request(
            endpoint: "/requests",
            method: .post,
            body: SendRequestBody(targetUserId: toUserId)
        )
    }
    
    func getReceivedRequests() async throws -> [SocialRequest] {
        struct Response: Codable {
            let requests: [SocialRequest]
        }
        let response: Response = try await APIClient.shared.request(
            endpoint: "/requests/received",
            method: .get
        )
        return response.requests
    }
    
    func getSentRequests() async throws -> [SocialRequest] {
        struct Response: Codable {
            let requests: [SocialRequest]
        }
        let response: Response = try await APIClient.shared.request(
            endpoint: "/requests/sent",
            method: .get
        )
        return response.requests
    }
    
    struct AcceptResponse: Codable {
        let success: Bool
        let friendshipId: String
        let friend: FriendUser
        
        enum CodingKeys: String, CodingKey {
            case success
            case friendshipId = "friendship_id"
            case friend
        }
    }
    
    func acceptRequest(requestId: String) async throws -> AcceptResponse {
        return try await APIClient.shared.request(
            endpoint: "/requests/\(requestId)/accept",
            method: .post
        )
    }
    
    func rejectRequest(requestId: String) async throws {
        try await APIClient.shared.requestVoid(
            endpoint: "/requests/\(requestId)/reject",
            method: .post
        )
    }
    
    // MARK: - Friends
    
    func getFriends() async throws -> [Friendship] {
        struct Response: Codable {
            let friends: [Friendship]
        }
        let response: Response = try await APIClient.shared.request(
            endpoint: "/friends",
            method: .get
        )
        return response.friends
    }
    
    func removeFriend(friendshipId: String) async throws {
        try await APIClient.shared.requestVoid(
            endpoint: "/friends/\(friendshipId)",
            method: .delete
        )
    }
    
    func getSocialLinks(friendId: String) async throws -> SocialLinks {
        return try await APIClient.shared.request(
            endpoint: "/friends/\(friendId)/social-links",
            method: .get
        )
    }
    
    // MARK: - Report
    
    struct ReportRequest: Codable {
        let userId: String
        let reason: String
        let description: String?
        
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case reason
            case description
        }
    }
    
    func reportUser(userId: String, reason: String, description: String?) async throws {
        try await APIClient.shared.requestVoid(
            endpoint: "/reports",
            method: .post,
            body: ReportRequest(userId: userId, reason: reason, description: description)
        )
    }
}
