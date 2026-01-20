import Foundation

enum NotificationType: String, Codable {
    case requestReceived = "request_received"
    case requestAccepted = "request_accepted"
    case newFriend = "new_friend"
    case boostExpired = "boost_expired"
    case premiumExpiring = "premium_expiring"
    case system = "system"
}

struct AppNotification: Identifiable, Codable {
    let id: String
    let type: NotificationType
    let titleKey: String
    let bodyKey: String
    var title: String
    var body: String
    let avatarURL: String?
    let data: NotificationData?
    var isRead: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, type, data, title, body
        case titleKey = "title_key"
        case bodyKey = "body_key"
        case avatarURL = "avatar_url"
        case isRead = "is_read"
        case createdAt = "created_at"
    }
    
    init(id: String, type: NotificationType, titleKey: String, bodyKey: String, title: String, body: String, avatarURL: String? = nil, data: NotificationData? = nil, isRead: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.type = type
        self.titleKey = titleKey
        self.bodyKey = bodyKey
        self.title = title
        self.body = body
        self.avatarURL = avatarURL
        self.data = data
        self.isRead = isRead
        self.createdAt = createdAt
    }
}

struct NotificationData: Codable {
    let requestId: String?
    let fromUserId: String?
    let friendshipId: String?
    
    enum CodingKeys: String, CodingKey {
        case requestId = "request_id"
        case fromUserId = "from_user_id"
        case friendshipId = "friendship_id"
    }
}

struct NotificationsResponse: Codable {
    let notifications: [AppNotification]
    let unreadCount: Int
    let nextCursor: String?
    
    enum CodingKeys: String, CodingKey {
        case notifications
        case unreadCount = "unread_count"
        case nextCursor = "next_cursor"
    }
}
