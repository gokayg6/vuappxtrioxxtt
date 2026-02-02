import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

actor DiscoverService {
    static let shared = DiscoverService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Discover Feed
    
    /// Age Group enum for safety filtering
    enum AgeGroup: String {
        case minor = "minor"   // 15-17 years old
        case adult = "adult"   // 18+ years old
        
        static func from(age: Int) -> AgeGroup {
            return age >= 18 ? .adult : .minor
        }
    }
    
    func getDiscoverFeed(
        mode: DiscoverMode,
        cursor: String? = nil,
        limit: Int = 20,
        countryFilter: String? = nil, // nil = no filter, "Turkey" = my country only
        excludeCountry: String? = nil, // "Turkey" = exclude Turkey (for global mode)
        ageRange: ClosedRange<Int>? = nil,
        genderFilter: String? = nil,
        currentUserAge: Int = 18 // Current user's age for pool separation
    ) async throws -> DiscoverResponse {
        let currentUserAgeGroup = AgeGroup.from(age: currentUserAge)
        print("🔍 DiscoverService: Fetching users with countryFilter=\(countryFilter ?? "nil"), excludeCountry=\(excludeCountry ?? "nil"), limit=\(limit), ageGroup=\(currentUserAgeGroup.rawValue)")
        
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
        print("📊 DiscoverService: Fetched \(snapshot.documents.count) documents from Firestore")
        
        let currentUid = Auth.auth().currentUser?.uid
        let currentEmail = Auth.auth().currentUser?.email
        print("🔐 Current User UID: \(currentUid ?? "nil"), Email: \(currentEmail ?? "nil")")
        
        var users: [DiscoverUser] = []
        
        for doc in snapshot.documents {
            let userId = doc.documentID
            let data = doc.data()
            let userEmail = data["email"] as? String ?? ""
            let displayName = data["display_name"] as? String ?? ""
            
            // Skip self - check both UID and email
            if let currentUid = currentUid, userId == currentUid {
                print("⛔️ Skipping self by UID: \(userId)")
                continue
            }
            
            if let currentEmail = currentEmail, !currentEmail.isEmpty, !userEmail.isEmpty, userEmail.lowercased() == currentEmail.lowercased() {
                print("⛔️ Skipping self by Email: \(userEmail)")
                continue
            }
            
            print("👤 Processing user: \(userId)")
            print("   Raw data keys: \(data.keys.joined(separator: ", "))")
            print("   displayName: '\(displayName)'")
            
            // Skip users without name
            if displayName.isEmpty {
                print("   ❌ Skipped: Empty displayName")
                continue
            }
            
            // GLOBAL MODE: Skip users from excluded country (Turkey)
            if let excluded = excludeCountry, !excluded.isEmpty {
                let userCountry = data["country"] as? String ?? ""
                if userCountry.lowercased() == excluded.lowercased() || 
                   userCountry.lowercased() == "türkiye" ||
                   userCountry.lowercased() == "turkey" {
                    print("   ⛔️ Skipped: User from excluded country '\(userCountry)'")
                    continue
                }
            }
            
            let age = data["age"] as? Int ?? 18
            
            // 🔒 CRITICAL SAFETY: Age Pool Separation
            // - Users under 15 are not allowed (minimum age)
            // - Minors (15-17) can ONLY see other minors
            // - Adults (18+) can ONLY see other adults
            if age < 15 {
                print("   ⛔️ Skipped: User under minimum age (15)")
                continue
            }
            
            let userAgeGroup = AgeGroup.from(age: age)
            if userAgeGroup != currentUserAgeGroup {
                print("   ⛔️ Skipped: User in different age pool (\(userAgeGroup.rawValue) vs \(currentUserAgeGroup.rawValue))")
                continue
            }
            
            let city = data["city"] as? String ?? ""
            let country = data["country"] as? String
            let countryFlag = getCountryFlag(for: country)
            let profilePhotoURL = data["profile_photo_url"] as? String ?? ""
            let photosData = data["photos"] as? [[String: Any]] ?? []
            let tags = data["tags"] as? [String] ?? []
            let activityScore = data["activity_score"] as? Int ?? Int.random(in: 30...80)
            
            print("   photos count: \(photosData.count), profile_photo_url: '\(profilePhotoURL)'")
            
            // Social Links Logic
            let socialLinks = data["social_links"] as? [String: Any]
            let tiktok = socialLinks?["tiktok"] as? [String: String]
            let instagram = socialLinks?["instagram"] as? [String: String]
            let snapchat = socialLinks?["snapchat"] as? [String: String]
            
            let tiktokUsername = tiktok?["username"]
            let instagramUsername = instagram?["username"]
            let snapchatUsername = snapchat?["username"]
            
            // Photos Mapping from Firebase Storage URLs
            var userPhotos: [UserPhoto] = []
            if !photosData.isEmpty {
                userPhotos = photosData.enumerated().compactMap { index, photoDict in
                    guard let url = photoDict["url"] as? String, !url.isEmpty else { return nil }
                    return UserPhoto(
                        id: photoDict["id"] as? String ?? UUID().uuidString,
                        url: url,
                        thumbnailURL: photoDict["thumbnailURL"] as? String,
                        orderIndex: photoDict["orderIndex"] as? Int ?? index,
                        isPrimary: photoDict["isPrimary"] as? Bool ?? (index == 0)
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
            
            print("   userPhotos count after mapping: \(userPhotos.count)")
            
            // Skip users without photos
            if userPhotos.isEmpty {
                print("   ❌ Skipped: No photos")
                continue
            }
            
            print("   ✅ User added: \(displayName)")
            
            // Calculate real distance if location data available
            let latitude = data["latitude"] as? Double
            let longitude = data["longitude"] as? Double
            var calculatedDistance: Double?
            
            if let lat = latitude, let lon = longitude {
                // Get distance from LocationManager
                calculatedDistance = await MainActor.run {
                    LocationManager.shared.calculateDistanceFromUser(
                        to: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    )
                }
            }
            
            // Use calculated distance or fallback to random
            let finalDistance = calculatedDistance ?? Double.random(in: 1...20)
            
            // Get bio
            let bio = data["bio"] as? String
            
            // Construct User
            let user = DiscoverUser(
                id: userId,
                displayName: displayName,
                age: age,
                city: city,
                country: country,
                countryFlag: countryFlag,
                distanceKm: finalDistance,
                profilePhotoURL: profilePhotoURL,
                photos: userPhotos,
                tags: tags,
                commonInterests: [],
                score: Double(activityScore),
                isBoosted: false,
                tiktokUsername: tiktokUsername,
                instagramUsername: instagramUsername,
                snapchatUsername: snapchatUsername,
                isFriend: false,
                bio: bio
            )
            users.append(user)
        }
        
        print("✅ DiscoverService: Mapped \(users.count) valid users")
        
        // Apply age filter in-memory (Firestore doesn't support range queries well with other filters)
        var filteredUsers = users
        if let range = ageRange {
            filteredUsers = users.filter { range.contains($0.age) }
        }
        
        // Sort by activity score (highest first) + shuffle a bit for variety
        filteredUsers.sort { $0.score > $1.score }
        
        // Limit to requested count
        let limitedUsers = Array(filteredUsers.prefix(limit))
        
        print("🎯 DiscoverService: Returning \(limitedUsers.count) users")
        
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
    
    // MARK: - Helper Functions
    
    /// Convert country name to flag emoji
    private func getCountryFlag(for country: String?) -> String? {
        guard let country = country?.lowercased() else { return nil }
        
        let flagMap: [String: String] = [
            "türkiye": "🇹🇷",
            "turkey": "🇹🇷",
            "almanya": "🇩🇪",
            "germany": "🇩🇪",
            "amerika": "🇺🇸",
            "abd": "🇺🇸",
            "usa": "🇺🇸",
            "united states": "🇺🇸",
            "ingiltere": "🇬🇧",
            "england": "🇬🇧",
            "united kingdom": "🇬🇧",
            "uk": "🇬🇧",
            "fransa": "🇫🇷",
            "france": "🇫🇷",
            "italya": "🇮🇹",
            "italy": "🇮🇹",
            "ispanya": "🇪🇸",
            "spain": "🇪🇸",
            "hollanda": "🇳🇱",
            "netherlands": "🇳🇱",
            "belçika": "🇧🇪",
            "belgium": "🇧🇪",
            "avusturya": "🇦🇹",
            "austria": "🇦🇹",
            "isviçre": "🇨🇭",
            "switzerland": "🇨🇭",
            "yunanistan": "🇬🇷",
            "greece": "🇬🇷",
            "rusya": "🇷🇺",
            "russia": "🇷🇺",
            "kanada": "🇨🇦",
            "canada": "🇨🇦",
            "avustralya": "🇦🇺",
            "australia": "🇦🇺",
            "japonya": "🇯🇵",
            "japan": "🇯🇵"
        ]
        
        return flagMap[country] ?? "🌍"
    }
}
