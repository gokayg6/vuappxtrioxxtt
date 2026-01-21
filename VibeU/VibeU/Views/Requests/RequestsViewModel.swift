import SwiftUI

@Observable
final class RequestsViewModel {
    var receivedRequests: [SocialRequest] = []
    var sentRequests: [SocialRequest] = []
    var friends: [Friendship] = []
    
    var isLoading = false
    var error: Error?
    
    // Mock Data removed
    
    func count(for segment: RequestsView.RequestSegment) -> Int {
        switch segment {
        case .received:
            return receivedRequests.filter { $0.status == .pending }.count
        case .sent:
            return sentRequests.filter { $0.status == .pending }.count
        case .friends:
            return friends.count
        }
    }
    
    @MainActor
    func loadData() async {
        isLoading = true
        error = nil
        
        do {
            // Concurrent fetching for performance
            async let received = FriendsService.shared.getReceivedRequests()
            async let sent = FriendsService.shared.getSentRequests()
            async let friendList = FriendsService.shared.getFriendships()
            
            self.receivedRequests = try await received
            self.sentRequests = try await sent
            self.friends = try await friendList
        } catch {
            print("❌ [RequestsViewModel] Error loading data: \(error.localizedDescription)")
            self.error = error
        }
        
        isLoading = false
    }
    
    @MainActor
    func acceptRequest(_ request: SocialRequest) {
        // Optimistic UI update
        if let index = receivedRequests.firstIndex(where: { $0.id == request.id }) {
            receivedRequests.remove(at: index)
            
            // Add to friends purely for UI feedback
            if let fromUser = request.fromUser {
                let friendship = Friendship(
                    id: UUID().uuidString,
                    friend: FriendUser(
                        id: fromUser.id,
                        displayName: fromUser.displayName,
                        profilePhotoURL: fromUser.profilePhotoURL,
                        socialLinks: nil,
                        lastActiveAt: Date()
                    ),
                    createdAt: Date()
                )
                friends.insert(friendship, at: 0)
            }
        }
        
        // Actual Service Call
        Task {
            do {
                try await FriendsService.shared.acceptRequest(requestId: request.id)
                // Reload to sync with server state
                await loadData()
            } catch {
                print("❌ Failed to accept request: \(error)")
                // Revert optimistic update ideally, but simpler to just reload
                await loadData()
            }
        }
    }
    
    @MainActor
    func rejectRequest(_ request: SocialRequest) {
        // Optimistic update
        if let index = receivedRequests.firstIndex(where: { $0.id == request.id }) {
            receivedRequests.remove(at: index)
        }
        
        Task {
            do {
                try await FriendsService.shared.rejectRequest(requestId: request.id)
            } catch {
                print("❌ Failed to reject request: \(error)")
                await loadData()
            }
        }
    }
    
    @MainActor
    func removeFriend(_ friendship: Friendship) {
        // Optimistic update
        if let index = friends.firstIndex(where: { $0.id == friendship.id }) {
            friends.remove(at: index)
        }
        
        Task {
            do {
                // We need friendId, which is friendship.friend.id in our model
                try await FriendsService.shared.removeFriend(friendId: friendship.friend.id)
            } catch {
                print("❌ Failed to remove friend: \(error)")
                await loadData()
            }
        }
    }
}
