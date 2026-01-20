import Foundation

// MARK: - Chat Models

struct Conversation: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let participant: ChatParticipant
    let lastMessage: ChatMessage?
    let unreadCount: Int
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, participant
        case lastMessage = "last_message"
        case unreadCount = "unread_count"
        case updatedAt = "updated_at"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id
    }
}

struct ChatParticipant: Codable, Equatable {
    let id: String
    let displayName: String
    let profilePhotoURL: String
    let isOnline: Bool
    let lastActiveAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case profilePhotoURL = "profile_photo_url"
        case isOnline = "is_online"
        case lastActiveAt = "last_active_at"
    }
}

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: String
    let conversationId: String
    let senderId: String
    let content: String
    let messageType: MessageType
    let isRead: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case content
        case messageType = "message_type"
        case isRead = "is_read"
        case createdAt = "created_at"
    }
}

enum MessageType: String, Codable {
    case text = "text"
    case image = "image"
    case gif = "gif"
    case voice = "voice"
}

// MARK: - Liked User Model

struct LikedUser: Identifiable, Codable, Equatable {
    let id: String
    let user: DiscoverUser
    let likedAt: Date
    let isMatched: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, user
        case likedAt = "liked_at"
        case isMatched = "is_matched"
    }
}

// MARK: - Favorite User Model

struct FavoriteUser: Identifiable, Codable, Equatable {
    let id: String
    let user: DiscoverUser
    let addedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, user
        case addedAt = "added_at"
    }
}
