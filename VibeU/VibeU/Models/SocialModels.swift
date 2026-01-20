import Foundation
import SwiftUI

// MARK: - Social Media Platform
enum SocialMediaPlatform: String, CaseIterable {
    case tiktok
    case instagram
    case snapchat
    
    var iconName: String {
        switch self {
        case .tiktok: return "music.note"
        case .instagram: return "camera"
        case .snapchat: return "message"
        }
    }
    
    var color: Color {
        switch self {
        case .tiktok: return Color(red: 0.0, green: 0.96, blue: 0.88)
        case .instagram: return Color(red: 0.88, green: 0.19, blue: 0.42)
        case .snapchat: return Color(red: 1.0, green: 0.98, blue: 0.0)
        }
    }
    
    func deepLink(username: String) -> URL? {
        switch self {
        case .tiktok:
            return URL(string: "tiktok://user/@\(username)")
        case .instagram:
            return URL(string: "instagram://user?username=\(username)")
        case .snapchat:
            return URL(string: "snapchat://add/\(username)")
        }
    }
    
    func webURL(username: String) -> URL? {
        switch self {
        case .tiktok:
            return URL(string: "https://tiktok.com/@\(username)")
        case .instagram:
            return URL(string: "https://instagram.com/\(username)")
        case .snapchat:
            return URL(string: "https://snapchat.com/add/\(username)")
        }
    }
}

enum RequestStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
    case cancelled = "cancelled"
}

// MARK: - Friend Model (matches backend /friends response)
struct Friend: Identifiable, Codable, Equatable {
    let id: String
    let displayName: String
    let age: Int
    let city: String
    let profilePhotoURL: String
    let isOnline: Bool
    let lastActiveAt: Date
    let tiktokUsername: String?
    let instagramUsername: String?
    let snapchatUsername: String?
    let socialLinks: SocialLinks?
    let friendshipId: String
    let friendshipCreatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, age, city
        case displayName = "displayName"
        case profilePhotoURL = "profilePhotoURL"
        case isOnline = "isOnline"
        case lastActiveAt = "lastActiveAt"
        case tiktokUsername = "tiktokUsername"
        case instagramUsername = "instagramUsername"
        case snapchatUsername = "snapchatUsername"
        case socialLinks = "socialLinks"
        case friendshipId = "friendshipId"
        case friendshipCreatedAt = "friendshipCreatedAt"
    }
    
    var hasTikTok: Bool { tiktokUsername != nil }
    var hasInstagram: Bool { instagramUsername != nil }
    var hasSnapchat: Bool { snapchatUsername != nil }
}

struct SocialRequest: Identifiable, Codable, Equatable {
    let id: String
    let fromUser: RequestUser?
    let toUser: RequestUser?
    let status: RequestStatus
    let createdAt: Date
    let respondedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, status
        case fromUser = "from_user"
        case toUser = "to_user"
        case createdAt = "created_at"
        case respondedAt = "responded_at"
    }
}

struct RequestUser: Codable, Equatable {
    let id: String
    let displayName: String
    let profilePhotoURL: String
    let age: Int
    let city: String
    
    enum CodingKeys: String, CodingKey {
        case id, age, city
        case displayName = "display_name"
        case profilePhotoURL = "profile_photo_url"
    }
}

struct Friendship: Identifiable, Codable, Equatable {
    let id: String
    let friend: FriendUser
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, friend
        case createdAt = "created_at"
    }
}

struct FriendUser: Codable, Equatable {
    let id: String
    let displayName: String
    let profilePhotoURL: String
    let socialLinks: SocialLinks?
    let lastActiveAt: Date
    
    var isOnline: Bool {
        Date().timeIntervalSince(lastActiveAt) < 300 // 5 dakika
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case profilePhotoURL = "profile_photo_url"
        case socialLinks = "social_links"
        case lastActiveAt = "last_active_at"
    }
}

struct Like: Identifiable, Codable {
    let id: String
    let user: RequestUser
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, user
        case createdAt = "created_at"
    }
}

struct Favorite: Identifiable, Codable {
    let id: String
    let user: DiscoverUser
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, user
        case createdAt = "created_at"
    }
}
