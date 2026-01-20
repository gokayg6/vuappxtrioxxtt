import Foundation

actor DiscoverService {
    static let shared = DiscoverService()
    
    private init() {}
    
    // MARK: - Discover Feed
    
    func getDiscoverFeed(
        mode: DiscoverMode,
        cursor: String? = nil,
        limit: Int = 20
    ) async throws -> DiscoverResponse {
        var endpoint = "/discover?mode=\(mode.rawValue)&limit=\(limit)"
        if let cursor = cursor {
            endpoint += "&cursor=\(cursor)"
        }
        
        return try await APIClient.shared.request(
            endpoint: endpoint,
            method: .get
        )
    }
    
    // MARK: - Trending
    
    func getTrending(mode: DiscoverMode) async throws -> TrendingResponse {
        return try await APIClient.shared.request(
            endpoint: "/discover/trending?mode=\(mode.rawValue)",
            method: .get
        )
    }
    
    // MARK: - Spotlight
    
    func getSpotlight(mode: DiscoverMode) async throws -> SpotlightResponse {
        return try await APIClient.shared.request(
            endpoint: "/discover/spotlight?mode=\(mode.rawValue)",
            method: .get
        )
    }
    
    // MARK: - Like
    
    struct LikeRequest: Codable {
        let targetUserId: String
        
        enum CodingKeys: String, CodingKey {
            case targetUserId = "target_user_id"
        }
    }
    
    struct LikeResponse: Codable {
        let success: Bool
        let remainingLikes: Int?
        
        enum CodingKeys: String, CodingKey {
            case success
            case remainingLikes = "remaining_likes"
        }
    }
    
    func like(userId: String) async throws -> LikeResponse {
        return try await APIClient.shared.request(
            endpoint: "/likes",
            method: .post,
            body: LikeRequest(targetUserId: userId)
        )
    }
    
    // MARK: - Skip
    
    struct SkipRequest: Codable {
        let userId: String
        
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
        }
    }
    
    func skip(userId: String) async throws {
        try await APIClient.shared.requestVoid(
            endpoint: "/skip",
            method: .post,
            body: SkipRequest(userId: userId)
        )
    }
    
    // MARK: - Favorite
    
    struct FavoriteRequest: Codable {
        let userId: String
        
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
        }
    }
    
    struct FavoriteResponse: Codable {
        let success: Bool
        let favoriteId: String
        
        enum CodingKeys: String, CodingKey {
            case success
            case favoriteId = "favorite_id"
        }
    }
    
    func addFavorite(userId: String) async throws -> FavoriteResponse {
        return try await APIClient.shared.request(
            endpoint: "/favorites",
            method: .post,
            body: FavoriteRequest(userId: userId)
        )
    }
    
    func removeFavorite(favoriteId: String) async throws {
        try await APIClient.shared.requestVoid(
            endpoint: "/favorites/\(favoriteId)",
            method: .delete
        )
    }
    
    func getFavorites() async throws -> [Favorite] {
        struct Response: Codable {
            let favorites: [Favorite]
        }
        let response: Response = try await APIClient.shared.request(
            endpoint: "/favorites",
            method: .get
        )
        return response.favorites
    }
    
    // MARK: - Received Likes (Premium)
    
    func getReceivedLikes() async throws -> [Like] {
        struct Response: Codable {
            let users: [Like]
            let totalCount: Int
            
            enum CodingKeys: String, CodingKey {
                case users
                case totalCount = "total_count"
            }
        }
        let response: Response = try await APIClient.shared.request(
            endpoint: "/likes/received",
            method: .get
        )
        return response.users
    }
}
