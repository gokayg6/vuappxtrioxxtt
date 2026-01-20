import SwiftUI

@Observable
final class RequestsViewModel {
    var receivedRequests: [SocialRequest] = []
    var sentRequests: [SocialRequest] = []
    var friends: [Friendship] = []
    
    var isLoading = false
    var error: Error?
    
    // Mock Data
    static let mockReceivedRequests: [SocialRequest] = [
        SocialRequest(
            id: "r1",
            fromUser: RequestUser(
                id: "u1",
                displayName: "Merve",
                profilePhotoURL: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400",
                age: 22,
                city: "İstanbul"
            ),
            toUser: nil,
            status: .pending,
            createdAt: Date().addingTimeInterval(-3600),
            respondedAt: nil
        ),
        SocialRequest(
            id: "r2",
            fromUser: RequestUser(
                id: "u2",
                displayName: "Ceren",
                profilePhotoURL: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400",
                age: 24,
                city: "Ankara"
            ),
            toUser: nil,
            status: .pending,
            createdAt: Date().addingTimeInterval(-7200),
            respondedAt: nil
        ),
        SocialRequest(
            id: "r3",
            fromUser: RequestUser(
                id: "u3",
                displayName: "Büşra",
                profilePhotoURL: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400",
                age: 21,
                city: "İzmir"
            ),
            toUser: nil,
            status: .pending,
            createdAt: Date().addingTimeInterval(-10800),
            respondedAt: nil
        )
    ]
    
    static let mockSentRequests: [SocialRequest] = [
        SocialRequest(
            id: "s1",
            fromUser: nil,
            toUser: RequestUser(
                id: "u4",
                displayName: "Sude",
                profilePhotoURL: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400",
                age: 23,
                city: "Bursa"
            ),
            status: .pending,
            createdAt: Date().addingTimeInterval(-1800),
            respondedAt: nil
        ),
        SocialRequest(
            id: "s2",
            fromUser: nil,
            toUser: RequestUser(
                id: "u5",
                displayName: "İrem",
                profilePhotoURL: "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400",
                age: 25,
                city: "Antalya"
            ),
            status: .accepted,
            createdAt: Date().addingTimeInterval(-86400),
            respondedAt: Date().addingTimeInterval(-43200)
        )
    ]
    
    static let mockFriends: [Friendship] = [
        Friendship(
            id: "f1",
            friend: FriendUser(
                id: "u6",
                displayName: "Elif",
                profilePhotoURL: "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400",
                socialLinks: SocialLinks(
                    tiktok: nil,
                    instagram: SocialLink(username: "elif.yilmaz", deeplink: "instagram://user?username=elif.yilmaz", webURL: "https://instagram.com/elif.yilmaz"),
                    snapchat: SocialLink(username: "elif_snap", deeplink: "snapchat://add/elif_snap", webURL: "https://snapchat.com/add/elif_snap")
                ),
                lastActiveAt: Date().addingTimeInterval(-120)
            ),
            createdAt: Date().addingTimeInterval(-172800)
        ),
        Friendship(
            id: "f2",
            friend: FriendUser(
                id: "u7",
                displayName: "Zeynep",
                profilePhotoURL: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400",
                socialLinks: SocialLinks(
                    tiktok: SocialLink(username: "zeynep_tt", deeplink: "tiktok://user?username=zeynep_tt", webURL: "https://tiktok.com/@zeynep_tt"),
                    instagram: SocialLink(username: "zeynep.kaya", deeplink: "instagram://user?username=zeynep.kaya", webURL: "https://instagram.com/zeynep.kaya"),
                    snapchat: nil
                ),
                lastActiveAt: Date().addingTimeInterval(-3600)
            ),
            createdAt: Date().addingTimeInterval(-259200)
        ),
        Friendship(
            id: "f3",
            friend: FriendUser(
                id: "u8",
                displayName: "Ayşe",
                profilePhotoURL: "https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=400",
                socialLinks: SocialLinks(
                    tiktok: nil,
                    instagram: SocialLink(username: "ayse.demir", deeplink: "instagram://user?username=ayse.demir", webURL: "https://instagram.com/ayse.demir"),
                    snapchat: SocialLink(username: "ayse_snp", deeplink: "snapchat://add/ayse_snp", webURL: "https://snapchat.com/add/ayse_snp")
                ),
                lastActiveAt: Date().addingTimeInterval(-600)
            ),
            createdAt: Date().addingTimeInterval(-345600)
        ),
        Friendship(
            id: "f4",
            friend: FriendUser(
                id: "u9",
                displayName: "Deniz",
                profilePhotoURL: "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=400",
                socialLinks: SocialLinks(
                    tiktok: SocialLink(username: "deniz_tt", deeplink: "tiktok://user?username=deniz_tt", webURL: "https://tiktok.com/@deniz_tt"),
                    instagram: SocialLink(username: "deniz.ocean", deeplink: "instagram://user?username=deniz.ocean", webURL: "https://instagram.com/deniz.ocean"),
                    snapchat: SocialLink(username: "deniz_snap", deeplink: "snapchat://add/deniz_snap", webURL: "https://snapchat.com/add/deniz_snap")
                ),
                lastActiveAt: Date().addingTimeInterval(-7200)
            ),
            createdAt: Date().addingTimeInterval(-432000)
        )
    ]
    
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
        
        // Use mock data directly
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay for effect
        
        receivedRequests = Self.mockReceivedRequests
        sentRequests = Self.mockSentRequests
        friends = Self.mockFriends
        
        isLoading = false
    }
    
    @MainActor
    func acceptRequest(_ request: SocialRequest) {
        // Optimistic update
        if let index = receivedRequests.firstIndex(where: { $0.id == request.id }) {
            receivedRequests.remove(at: index)
            
            // Add to friends
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
    }
    
    @MainActor
    func rejectRequest(_ request: SocialRequest) {
        // Optimistic update
        if let index = receivedRequests.firstIndex(where: { $0.id == request.id }) {
            receivedRequests.remove(at: index)
        }
    }
    
    @MainActor
    func removeFriend(_ friendship: Friendship) {
        // Optimistic update
        if let index = friends.firstIndex(where: { $0.id == friendship.id }) {
            friends.remove(at: index)
        }
    }
}
