import Foundation
import os.log

// MARK: - Log Service
actor LogService {
    static let shared = LogService()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.vibeu.app", category: "VibeU")
    private var logs: [LogEntry] = []
    private let maxLogs = 1000
    
    private init() {}
    
    // MARK: - Log Levels
    enum LogLevel: String, Codable {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case critical = "CRITICAL"
    }
    
    // MARK: - Log Entry
    struct LogEntry: Codable, Identifiable {
        let id: String
        let timestamp: Date
        let level: LogLevel
        let category: String
        let message: String
        let metadata: [String: String]?
        let userId: String?
        
        init(level: LogLevel, category: String, message: String, metadata: [String: String]? = nil, userId: String? = nil) {
            self.id = UUID().uuidString
            self.timestamp = Date()
            self.level = level
            self.category = category
            self.message = message
            self.metadata = metadata
            self.userId = userId
        }
    }
    
    // MARK: - Logging Methods
    
    func debug(_ message: String, category: String = "General", metadata: [String: String]? = nil) {
        log(level: .debug, category: category, message: message, metadata: metadata)
    }
    
    func info(_ message: String, category: String = "General", metadata: [String: String]? = nil) {
        log(level: .info, category: category, message: message, metadata: metadata)
    }
    
    func warning(_ message: String, category: String = "General", metadata: [String: String]? = nil) {
        log(level: .warning, category: category, message: message, metadata: metadata)
    }
    
    func error(_ message: String, category: String = "General", metadata: [String: String]? = nil) {
        log(level: .error, category: category, message: message, metadata: metadata)
    }
    
    func critical(_ message: String, category: String = "General", metadata: [String: String]? = nil) {
        log(level: .critical, category: category, message: message, metadata: metadata)
    }
    
    private func log(level: LogLevel, category: String, message: String, metadata: [String: String]?) {
        let userId = UserDefaults.standard.string(forKey: "currentUserId")
        let entry = LogEntry(level: level, category: category, message: message, metadata: metadata, userId: userId)
        
        // Add to local logs
        logs.append(entry)
        if logs.count > maxLogs {
            logs.removeFirst(logs.count - maxLogs)
        }
        
        // System log
        let fullMessage = "[\(category)] \(message)"
        switch level {
        case .debug:
            logger.debug("\(fullMessage)")
        case .info:
            logger.info("\(fullMessage)")
        case .warning:
            logger.warning("\(fullMessage)")
        case .error:
            logger.error("\(fullMessage)")
        case .critical:
            logger.critical("\(fullMessage)")
        }
        
        // Send to backend asynchronously
        Task {
            await sendToBackend(entry)
        }
    }
    
    // MARK: - Backend Sync
    
    private func sendToBackend(_ entry: LogEntry) async {
        do {
            try await APIClient.shared.requestVoid(
                endpoint: "/logs",
                method: .post,
                body: entry
            )
        } catch {
            // Silently fail - don't log errors about logging
        }
    }
    
    // MARK: - Retrieve Logs
    
    func getLogs(level: LogLevel? = nil, category: String? = nil, limit: Int = 100) -> [LogEntry] {
        var filtered = logs
        
        if let level = level {
            filtered = filtered.filter { $0.level == level }
        }
        
        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }
        
        return Array(filtered.suffix(limit))
    }
    
    func clearLogs() {
        logs.removeAll()
    }
}

// MARK: - Log Categories
extension LogService {
    struct Categories {
        static let auth = "Auth"
        static let premium = "Premium"
        static let discover = "Discover"
        static let chat = "Chat"
        static let profile = "Profile"
        static let social = "Social"
        static let network = "Network"
        static let ui = "UI"
        static let purchase = "Purchase"
        static let notification = "Notification"
        static let location = "Location"
        static let filter = "Filter"
        static let story = "Story"
    }
}

// MARK: - Convenience Extensions
extension LogService {
    // Auth logs
    func logLogin(method: String, success: Bool, userId: String? = nil) {
        let message = success ? "User logged in via \(method)" : "Login failed via \(method)"
        let level: LogLevel = success ? .info : .warning
        log(level: level, category: Categories.auth, message: message, metadata: ["method": method, "userId": userId ?? "unknown"])
    }
    
    func logLogout(userId: String) {
        info("User logged out", category: Categories.auth, metadata: ["userId": userId])
    }
    
    // Premium logs
    func logPremiumPurchase(productId: String, success: Bool, error: String? = nil) {
        let message = success ? "Premium purchased: \(productId)" : "Premium purchase failed: \(productId)"
        let level: LogLevel = success ? .info : .error
        var metadata: [String: String] = ["productId": productId]
        if let error = error {
            metadata["error"] = error
        }
        log(level: level, category: Categories.premium, message: message, metadata: metadata)
    }
    
    func logPremiumActivation(userId: String, expiresAt: Date?) {
        info("Premium activated", category: Categories.premium, metadata: [
            "userId": userId,
            "expiresAt": expiresAt?.ISO8601Format() ?? "lifetime"
        ])
    }
    
    // Discover logs
    func logDiscoverFilter(filters: [String: String]) {
        info("Discover filters applied", category: Categories.filter, metadata: filters)
    }
    
    func logNoUsersInRange(distance: Int) {
        info("No users found in range", category: Categories.discover, metadata: ["distance": "\(distance)km"])
    }
    
    // Chat logs
    func logMessageSent(chatId: String, messageType: String) {
        debug("Message sent", category: Categories.chat, metadata: ["chatId": chatId, "type": messageType])
    }
    
    func logChatOpened(chatId: String, friendId: String) {
        debug("Chat opened", category: Categories.chat, metadata: ["chatId": chatId, "friendId": friendId])
    }
    
    // Story logs
    func logStoryViewed(storyId: String, ownerId: String) {
        debug("Story viewed", category: Categories.story, metadata: ["storyId": storyId, "ownerId": ownerId])
    }
    
    func logStoryCreated(storyId: String, type: String) {
        info("Story created", category: Categories.story, metadata: ["storyId": storyId, "type": type])
    }
    
    // Profile logs
    func logProfileUpdate(fields: [String]) {
        info("Profile updated", category: Categories.profile, metadata: ["fields": fields.joined(separator: ", ")])
    }
    
    // Screen tracking
    func logScreenView(_ screenName: String) {
        debug("Screen viewed: \(screenName)", category: Categories.ui)
    }
}
