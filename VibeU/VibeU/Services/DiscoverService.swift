import Foundation
import FirebaseFirestore
import FirebaseAuth

actor DiscoverService {
    static let shared = DiscoverService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Discover Feed
    
    func getDiscoverFeed(
        mode: DiscoverMode,
        cursor: String? = nil,
        limit: Int = 20,
        countryFilter: String? = nil, // nil = global, "Turkey" = my country
        ageRange: ClosedRange<Int>? = nil,
        genderFilter: String? = nil
    ) async throws -> DiscoverResponse {
        // Build query with filters
        var query: Query = db.collection("users")
        
        // Apply country filter if specified
        if let country = countryFilter, !country.isEmpty {
            query = query.whereField("country", isEqualTo: country)
        }
        
        // Apply gender filter if specified
        if let gender = genderFilter, !gender.isEmpty, gender != "all" {
            query = query.whereField("gender", isEqualTo: gender)
        }
        
        // Limit results
        query = query.limit(to: limit * 2) // Fetch more for filtering
        
        let snapshot = try await query.getDocuments()
        let currentUid = Auth.auth().currentUser?.uid
        
        var users: [DiscoverUser] = []
        
        for doc in snapshot.documents {
            let userId = doc.documentID
            
            // Skip self
            if let currentUid = currentUid, userId == currentUid { continue }
            
            let data = doc.data()
            
            // Map Firestore Data to DiscoverUser
            let displayName = data["displayName"] as? String ?? "VibeU User"
            let age = data["age"] as? Int ?? 18
            let city = data["city"] as? String ?? ""
            let profilePhotoURL = data["profilePhotoURL"] as? String ?? ""
            let photosData = data["photos"] as? [String] ?? []
            let tags = data["tags"] as? [String] ?? []
            let activityScore = data["activity_score"] as? Int ?? Int.random(in: 30...80)
            // let bio = data["bio"] as? String ?? ""
            
            // Social Links Logic
            let socialLinks = data["socialLinks"] as? [String: Any]
            let tiktok = socialLinks?["tiktok"] as? [String: String]
            let instagram = socialLinks?["instagram"] as? [String: String]
            let snapchat = socialLinks?["snapchat"] as? [String: String]
            
            let tiktokUsername = tiktok?["username"]
            let instagramUsername = instagram?["username"]
            let snapchatUsername = snapchat?["username"]
            
            // Photos Mapping
            var userPhotos: [UserPhoto] = []
            if !photosData.isEmpty {
                 userPhotos = photosData.enumerated().map { index, url in
                     UserPhoto(
                         id: UUID().uuidString,
                         url: url,
                         thumbnailURL: nil,
                         orderIndex: index,
                         isPrimary: index == 0
                     )
                 }
            } else if !profilePhotoURL.isEmpty {
                 userPhotos = [
                     UserPhoto(
                         id: UUID().uuidString,
                         url: profilePhotoURL,
                         thumbnailURL: nil,
                         orderIndex: 0,
                         isPrimary: true
                     )
                 ]
            }
            
            // Construct User
            let user = DiscoverUser(
                id: userId,
                displayName: displayName,
                age: age,
                city: city,
                country: nil,
                countryFlag: nil,
                distanceKm: Double.random(in: 1...20), // Placeholder
                profilePhotoURL: profilePhotoURL,
                photos: userPhotos,
                tags: tags,
                commonInterests: [],
                score: Double(activityScore),
                isBoosted: false,
                tiktokUsername: tiktokUsername,
                instagramUsername: instagramUsername,
                snapchatUsername: snapchatUsername,
                isFriend: false
            )
            users.append(user)
        }
        
        // Apply age filter in-memory (Firestore doesn't support range queries well with other filters)
        var filteredUsers = users
        if let range = ageRange {
            filteredUsers = users.filter { range.contains($0.age) }
        }
        
        // Sort by activity score (highest first) + shuffle a bit for variety
        filteredUsers.sort { $0.score > $1.score }
        
        // Limit to requested count
        let limitedUsers = Array(filteredUsers.prefix(limit))
        
        return DiscoverResponse(
            users: limitedUsers,
            nextCursor: nil,
            hasMore: filteredUsers.count > limit
        )
    }
    
    // MARK: - Trending (Reuse Feed)
    func getTrending(mode: DiscoverMode) async throws -> TrendingResponse {
        let response = try await getDiscoverFeed(mode: mode, limit: 10)
        return TrendingResponse(users: response.users)
    }
    
    // MARK: - Spotlight (Reuse Feed)
    func getSpotlight(mode: DiscoverMode) async throws -> SpotlightResponse {
        let response = try await getDiscoverFeed(mode: mode, limit: 5)
        return SpotlightResponse(users: response.users)
    }
    
    // MARK: - Interactions (Placeholders or Firestore)
    
    struct LikeResponse: Codable {
        var success: Bool
        var remainingLikes: Int?
        
        init(success: Bool = true, remainingLikes: Int? = 10) {
            self.success = success
            self.remainingLikes = remainingLikes
        }
    }
    
    func like(userId: String) async throws -> LikeResponse {
        // Implement "likes" collection write if needed
        return LikeResponse()
    }
    
    func skip(userId: String) async throws {
        // No-op
    }
    
    func favorite(userId: String) async throws {
        // No-op
    }
    
    func unfavorite(userId: String) async throws {
        // No-op
    }
    
    // MARK: - Missing Methods (Compatibility)
    func getFavorites() async throws -> [Favorite] {
        return []
    }
    
    func getReceivedLikes() async throws -> [Like] {
        return []
    }
}
