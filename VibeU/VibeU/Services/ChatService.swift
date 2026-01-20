import Foundation

actor ChatService {
    static let shared = ChatService()
    private init() {}
    
    // MARK: - Conversations
    
    func getConversations() async throws -> [Conversation] {
        // Mock data for now
        return Conversation.mockConversations
    }
    
    func getMessages(conversationId: String, page: Int = 1) async throws -> [ChatMessage] {
        // Mock data
        return ChatMessage.mockMessages(for: conversationId)
    }
    
    func sendMessage(conversationId: String, content: String, type: MessageType = .text) async throws -> ChatMessage {
        // Mock response
        return ChatMessage(
            id: UUID().uuidString,
            conversationId: conversationId,
            senderId: "current_user",
            content: content,
            messageType: type,
            isRead: false,
            createdAt: Date()
        )
    }
    
    func markAsRead(conversationId: String) async throws {
        // API call
    }
    
    // MARK: - Likes & Favorites
    
    func getLikedUsers() async throws -> [LikedUser] {
        return LikedUser.mockLikedUsers
    }
    
    func getFavoriteUsers() async throws -> [FavoriteUser] {
        return FavoriteUser.mockFavorites
    }
    
    func addToFavorites(userId: String) async throws {
        // API call
    }
    
    func removeFromFavorites(userId: String) async throws {
        // API call
    }
    
    func likeUser(userId: String) async throws {
        // API call
    }
    
    func unlikeUser(userId: String) async throws {
        // API call
    }
}

// MARK: - Mock Data

extension Conversation {
    static let mockConversations: [Conversation] = [
        Conversation(
            id: "conv1",
            participant: ChatParticipant(
                id: "1",
                displayName: "Elif",
                profilePhotoURL: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400",
                isOnline: true,
                lastActiveAt: Date()
            ),
            lastMessage: ChatMessage(
                id: "msg1",
                conversationId: "conv1",
                senderId: "1",
                content: "Merhaba! Nasılsın? 😊",
                messageType: .text,
                isRead: false,
                createdAt: Date().addingTimeInterval(-300)
            ),
            unreadCount: 2,
            updatedAt: Date().addingTimeInterval(-300)
        ),
        Conversation(
            id: "conv2",
            participant: ChatParticipant(
                id: "2",
                displayName: "Zeynep",
                profilePhotoURL: "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400",
                isOnline: false,
                lastActiveAt: Date().addingTimeInterval(-3600)
            ),
            lastMessage: ChatMessage(
                id: "msg2",
                conversationId: "conv2",
                senderId: "current_user",
                content: "Yarın görüşelim mi?",
                messageType: .text,
                isRead: true,
                createdAt: Date().addingTimeInterval(-7200)
            ),
            unreadCount: 0,
            updatedAt: Date().addingTimeInterval(-7200)
        ),
        Conversation(
            id: "conv3",
            participant: ChatParticipant(
                id: "3",
                displayName: "Ayşe",
                profilePhotoURL: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400",
                isOnline: true,
                lastActiveAt: Date()
            ),
            lastMessage: ChatMessage(
                id: "msg3",
                conversationId: "conv3",
                senderId: "3",
                content: "Fotoğrafların çok güzel!",
                messageType: .text,
                isRead: true,
                createdAt: Date().addingTimeInterval(-86400)
            ),
            unreadCount: 0,
            updatedAt: Date().addingTimeInterval(-86400)
        )
    ]
}

extension ChatMessage {
    static func mockMessages(for conversationId: String) -> [ChatMessage] {
        [
            ChatMessage(id: "m1", conversationId: conversationId, senderId: "other", content: "Merhaba! 👋", messageType: .text, isRead: true, createdAt: Date().addingTimeInterval(-3600)),
            ChatMessage(id: "m2", conversationId: conversationId, senderId: "current_user", content: "Selam! Nasılsın?", messageType: .text, isRead: true, createdAt: Date().addingTimeInterval(-3500)),
            ChatMessage(id: "m3", conversationId: conversationId, senderId: "other", content: "İyiyim teşekkürler, sen nasılsın?", messageType: .text, isRead: true, createdAt: Date().addingTimeInterval(-3400)),
            ChatMessage(id: "m4", conversationId: conversationId, senderId: "current_user", content: "Ben de iyiyim 😊", messageType: .text, isRead: true, createdAt: Date().addingTimeInterval(-3300)),
            ChatMessage(id: "m5", conversationId: conversationId, senderId: "other", content: "Profilini gördüm, çok güzel fotoğrafların var!", messageType: .text, isRead: false, createdAt: Date().addingTimeInterval(-300))
        ]
    }
}

extension LikedUser {
    static let mockLikedUsers: [LikedUser] = [
        LikedUser(
            id: "like1",
            user: DiscoverUser.mockUsers[0],
            likedAt: Date().addingTimeInterval(-3600),
            isMatched: true
        ),
        LikedUser(
            id: "like2",
            user: DiscoverUser.mockUsers[1],
            likedAt: Date().addingTimeInterval(-7200),
            isMatched: false
        ),
        LikedUser(
            id: "like3",
            user: DiscoverUser.mockUsers[2],
            likedAt: Date().addingTimeInterval(-86400),
            isMatched: true
        )
    ]
}

extension FavoriteUser {
    static let mockFavorites: [FavoriteUser] = [
        FavoriteUser(
            id: "fav1",
            user: DiscoverUser.mockUsers[0],
            addedAt: Date().addingTimeInterval(-1800)
        ),
        FavoriteUser(
            id: "fav2",
            user: DiscoverUser.mockUsers[3],
            addedAt: Date().addingTimeInterval(-86400)
        )
    ]
}
