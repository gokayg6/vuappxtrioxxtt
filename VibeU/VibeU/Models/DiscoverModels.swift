import Foundation

enum DiscoverMode: String, Codable {
    case local = "local"
    case global = "global"
    case forYou = "forYou"
    case doubleDate = "doubleDate"
}

struct DiscoverUser: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let displayName: String
    let age: Int
    let city: String
    let country: String?
    let countryFlag: String?
    let distanceKm: Double?
    let profilePhotoURL: String
    let photos: [UserPhoto]
    let tags: [String]
    let commonInterests: [String]
    let score: Double
    let isBoosted: Bool
    let tiktokUsername: String?
    let instagramUsername: String?
    let snapchatUsername: String?
    let isFriend: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, age, city, country, tags, score, photos
        case displayName = "display_name"
        case countryFlag = "country_flag"
        case distanceKm = "distance_km"
        case profilePhotoURL = "profile_photo_url"
        case commonInterests = "common_interests"
        case isBoosted = "is_boosted"
        case tiktokUsername = "tiktok_username"
        case instagramUsername = "instagram_username"
        case snapchatUsername = "snapchat_username"
        case isFriend = "is_friend"
    }
    
    // Computed properties for social media availability
    var hasTikTok: Bool { tiktokUsername != nil && !tiktokUsername!.isEmpty }
    var hasInstagram: Bool { instagramUsername != nil && !instagramUsername!.isEmpty }
    var hasSnapchat: Bool { snapchatUsername != nil && !snapchatUsername!.isEmpty }
    var hasAnySocialMedia: Bool { hasTikTok || hasInstagram || hasSnapchat }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Convenience init with default values for tiktokUsername and isFriend
    init(
        id: String,
        displayName: String,
        age: Int,
        city: String,
        country: String?,
        countryFlag: String?,
        distanceKm: Double?,
        profilePhotoURL: String,
        photos: [UserPhoto],
        tags: [String],
        commonInterests: [String],
        score: Double,
        isBoosted: Bool,
        tiktokUsername: String? = nil,
        instagramUsername: String?,
        snapchatUsername: String?,
        isFriend: Bool? = false
    ) {
        self.id = id
        self.displayName = displayName
        self.age = age
        self.city = city
        self.country = country
        self.countryFlag = countryFlag
        self.distanceKm = distanceKm
        self.profilePhotoURL = profilePhotoURL
        self.photos = photos
        self.tags = tags
        self.commonInterests = commonInterests
        self.score = score
        self.isBoosted = isBoosted
        self.tiktokUsername = tiktokUsername
        self.instagramUsername = instagramUsername
        self.snapchatUsername = snapchatUsername
        self.isFriend = isFriend
    }
}

struct DiscoverResponse: Codable {
    let users: [DiscoverUser]
    let nextCursor: String?
    let hasMore: Bool
    
    enum CodingKeys: String, CodingKey {
        case users
        case nextCursor = "next_cursor"
        case hasMore = "has_more"
    }
}

struct TrendingResponse: Codable {
    let users: [DiscoverUser]
}

struct SpotlightResponse: Codable {
    let users: [DiscoverUser]
}

extension DiscoverUser {
    init(user: User) {
        self.id = user.id
        self.displayName = user.displayName
        self.age = user.age
        self.city = user.city
        self.country = user.country
        self.countryFlag = nil // Can be implemented if needed
        self.distanceKm = nil
        self.profilePhotoURL = user.profilePhotoURL
        self.photos = user.photos
        self.tags = user.tags
        self.commonInterests = [] // Can be computed contextually
        self.score = 0
        self.isBoosted = false
        self.tiktokUsername = user.socialLinks?.tiktok?.username
        self.instagramUsername = user.socialLinks?.instagram?.username
        self.snapchatUsername = user.socialLinks?.snapchat?.username
        self.isFriend = false
    }
}
    

