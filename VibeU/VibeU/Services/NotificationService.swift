import Foundation

actor NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func getNotifications(cursor: String? = nil, limit: Int = 20) async throws -> NotificationsResponse {
        var endpoint = "/notifications?limit=\(limit)"
        if let cursor = cursor {
            endpoint += "&cursor=\(cursor)"
        }
        
        return try await APIClient.shared.request(
            endpoint: endpoint,
            method: .get
        )
    }
    
    func markAsRead(notificationId: String) async throws {
        try await APIClient.shared.requestVoid(
            endpoint: "/notifications/\(notificationId)/read",
            method: .post
        )
    }
    
    func markAllAsRead() async throws {
        try await APIClient.shared.requestVoid(
            endpoint: "/notifications/read-all",
            method: .post
        )
    }
    
    func getUnreadCount() async throws -> Int {
        struct Response: Codable {
            let unreadCount: Int
            
            enum CodingKeys: String, CodingKey {
                case unreadCount = "unread_count"
            }
        }
        let response: Response = try await APIClient.shared.request(
            endpoint: "/notifications/unread-count",
            method: .get
        )
        return response.unreadCount
    }
}
