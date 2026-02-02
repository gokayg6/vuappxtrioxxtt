import Foundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - Friend Request Errors
enum FriendRequestError: Error, LocalizedError {
    case userNotFound
    case insufficientDiamonds
    case requestFailed
    
    var errorDescription: String? {
        switch self {
        case .userNotFound: return "Kullanıcı bulunamadı"
        case .insufficientDiamonds: return "Yetersiz elmas bakiyesi"
        case .requestFailed: return "İstek gönderilemedi"
        }
    }
}

// MARK: - FriendsService
// This service handles friend-related operations via Firestore (Permanent Solution)
// It maps Firestore data to SocialModels (SocialRequest, Friend, Friendship) required by Views.
actor FriendsService {
    static let shared = FriendsService()
    private let db = Firestore.firestore()
    
    // Collection References
    private var requestsRef: CollectionReference {
        return db.collection("friend_requests")
    }
    
    // Subcollection: users/{userId}/friends/{friendId}
    private func userFriendsRef(userId: String) -> CollectionReference {
        return db.collection("users").document(userId).collection("friends")
    }
    
    private init() {}
    
    // MARK: - Operations
    
    // Returns [Friend] for FriendsView
    func getFriends() async throws -> [Friend] {
        guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
        
        let snapshot = try await userFriendsRef(userId: currentUid).getDocuments()
        var friends: [Friend] = []
        
        for doc in snapshot.documents {
            let friendId = doc.documentID
            let data = doc.data()
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            
            if let user = try? await UserService.shared.fetchUser(uid: friendId) {
                // Map User to Friend
                let friend = Friend(
                    id: user.id,
                    displayName: user.displayName,
                    age: user.age,
                    city: user.city,
                    profilePhotoURL: user.profilePhotoURL,
                    isOnline: false, // Online status could be fetched from separate "presence" system
                    lastActiveAt: user.lastActiveAt, // Assuming User has lastActiveAt
                    tiktokUsername: user.socialLinks?.tiktok?.username,
                    instagramUsername: user.socialLinks?.instagram?.username,
                    snapchatUsername: user.socialLinks?.snapchat?.username,
                    socialLinks: user.socialLinks,
                    friendshipId: doc.documentID, // Using friendId as friendshipId roughly
                    friendshipCreatedAt: createdAt
                )
                friends.append(friend)
            }
        }
        return friends
    }
    
    // Returns [Friendship] for RequestsView (Friends Tab)
    func getFriendships() async throws -> [Friendship] {
        guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
        
        let snapshot = try await userFriendsRef(userId: currentUid).getDocuments()
        var friendships: [Friendship] = []
        
        for doc in snapshot.documents {
            let friendId = doc.documentID
            let data = doc.data()
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            
            if let user = try? await UserService.shared.fetchUser(uid: friendId) {
                let friendUser = FriendUser(
                    id: user.id,
                    displayName: user.displayName,
                    profilePhotoURL: user.profilePhotoURL,
                    socialLinks: user.socialLinks,
                    lastActiveAt: user.lastActiveAt
                )
                
                let friendship = Friendship(
                    id: doc.documentID,
                    friend: friendUser,
                    createdAt: createdAt
                )
                friendships.append(friendship)
            }
        }
        return friendships
    }
    
    func removeFriend(friendId: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // Remove from my friends
        try await userFriendsRef(userId: currentUid).document(friendId).delete()
        
        // Remove me from their friends
        try await userFriendsRef(userId: friendId).document(currentUid).delete()
    }
    
    func sendFriendRequest(userId: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            print("❌ [FriendsService] No current user for sending request!")
            throw FriendRequestError.userNotFound
        }
        
        print("📤 [FriendsService] Sending request from \(currentUid) to \(userId)")
        
        // 1. Check if request already exists
        let query = requestsRef
            .whereField("fromId", isEqualTo: currentUid)
            .whereField("toId", isEqualTo: userId)
            .whereField("status", isEqualTo: "pending")
        
        let existing = try await query.getDocuments()
        if !existing.isEmpty {
            print("⚠️ [FriendsService] Request already pending")
            return
        }
        
        // 2. Charge 10 diamonds for the request (inline transaction)
        let userRef = db.collection("users").document(currentUid)
        
        do {
            try await db.runTransaction { (transaction, errorPointer) -> Any? in
                let snapshot: DocumentSnapshot
                do {
                    snapshot = try transaction.getDocument(userRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                
                // FIX: Safe extraction for Int/Int64/NSNumber
                let currentBalance: Int
                if let balance = snapshot.data()?["diamond_balance"] as? Int {
                    currentBalance = balance
                } else if let balance64 = snapshot.data()?["diamond_balance"] as? Int64 {
                    currentBalance = Int(balance64)
                } else if let balanceNSNumber = snapshot.data()?["diamond_balance"] as? NSNumber {
                    currentBalance = balanceNSNumber.intValue
                } else {
                    currentBalance = 100 // Default balance
                }
                
                // Check sufficient balance
                guard currentBalance >= 10 else {
                    let error = NSError(
                        domain: "DiamondService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Yetersiz elmas"]
                    )
                    errorPointer?.pointee = error
                    return nil
                }
                
                // Deduct diamonds
                transaction.updateData([
                    "diamond_balance": currentBalance - 10
                ], forDocument: userRef)
                
                return nil
            }
            
            // Log transaction
            try await db.collection("diamond_transactions").addDocument(data: [
                "userId": currentUid,
                "type": "match_request",
                "amount": -10,
                "created_at": FieldValue.serverTimestamp(),
                "metadata": ["targetUserId": userId]
            ])
            
            print("💎 [FriendsService] Charged 10 diamonds for request")
        } catch {
            print("❌ [FriendsService] Insufficient diamonds or transaction failed!")
            throw FriendRequestError.insufficientDiamonds
        }
        
        // 3. Create Request
        let data: [String: Any] = [
            "fromId": currentUid,
            "toId": userId,
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        let docRef = try await requestsRef.addDocument(data: data)
        print("✅ [FriendsService] Firestore Request Sent! DocID: \(docRef.documentID)")
    }
    
    /// Send friend request WITHOUT charging diamonds (used by Super Like which already charged)
    func sendFriendRequestWithoutCharge(userId: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            print("❌ [FriendsService] No current user for sending request!")
            throw FriendRequestError.userNotFound
        }
        
        print("📤 [FriendsService] Sending FREE request from \(currentUid) to \(userId) (Super Like)")
        
        // 1. Check if request already exists
        let query = requestsRef
            .whereField("fromId", isEqualTo: currentUid)
            .whereField("toId", isEqualTo: userId)
            .whereField("status", isEqualTo: "pending")
        
        let existing = try await query.getDocuments()
        if !existing.isEmpty {
            print("⚠️ [FriendsService] Request already pending")
            return
        }
        
        // 2. Create Request (NO diamond charge - Super Like already paid)
        let data: [String: Any] = [
            "fromId": currentUid,
            "toId": userId,
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp(),
            "superLike": true // Mark as super like origin
        ]
        
        let docRef = try await requestsRef.addDocument(data: data)
        print("✅ [FriendsService] Super Like Request Sent! DocID: \(docRef.documentID)")
    }
    
    // Fetch pending requests received by current user
    func getReceivedRequests() async throws -> [SocialRequest] {
        guard let currentUid = Auth.auth().currentUser?.uid else { 
            print("❌ [FriendsService] No current user!")
            return [] 
        }
        
        // EXTRA DEBUG: Print current user info
        if let currentUser = Auth.auth().currentUser {
            print("🔍 [FriendsService] Current Auth User:")
            print("   UID: \(currentUser.uid)")
            print("   Email: \(currentUser.email ?? "none")")
            print("   Provider: \(currentUser.providerData.map { $0.providerID })")
        }
        
        print("🔍 [FriendsService] Fetching requests for uid: \(currentUid)")
        
        // Simplified query without order (to avoid composite index requirement)
        let snapshot = try await requestsRef
            .whereField("toId", isEqualTo: currentUid)
            .whereField("status", isEqualTo: "pending")
            .getDocuments()
        
        print("📦 [FriendsService] Found \(snapshot.documents.count) pending requests")
        
        // EXTRA DEBUG: Print all requests in collection for this user
        let allRequests = try await requestsRef.whereField("toId", isEqualTo: currentUid).getDocuments()
        print("📊 [FriendsService] Total requests (all statuses): \(allRequests.documents.count)")
        for doc in allRequests.documents {
            let data = doc.data()
            print("   - Doc \(doc.documentID): status=\(data["status"] ?? "nil"), fromId=\(data["fromId"] ?? "nil")")
        }
            
        var requests: [SocialRequest] = []
        
        for doc in snapshot.documents {
            let data = doc.data()
            print("📄 [FriendsService] Request doc: \(doc.documentID), data: \(data)")
            
            guard let fromId = data["fromId"] as? String else { continue }
            
            // Fetch sender profile
            if let user = try? await UserService.shared.fetchUser(uid: fromId) {
                let fromRequestUser = RequestUser(
                    id: user.id,
                    displayName: user.displayName,
                    profilePhotoURL: user.profilePhotoURL,
                    age: user.age,
                    city: user.city
                )
                
                let timestamp = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                
                let request = SocialRequest(
                    id: doc.documentID,
                    fromUser: fromRequestUser,
                    toUser: nil,
                    status: .pending,
                    createdAt: timestamp,
                    respondedAt: nil
                )
                requests.append(request)
            } else {
                print("⚠️ [FriendsService] Could not fetch user for fromId: \(fromId)")
            }
        }
        
        print("✅ [FriendsService] Returning \(requests.count) SocialRequests")
        return requests
    }
    
    // Fetch pending requests sent by current user
    func getSentRequests() async throws -> [SocialRequest] {
        guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
        
        let snapshot = try await requestsRef
            .whereField("fromId", isEqualTo: currentUid)
            .whereField("status", isEqualTo: "pending")
            .order(by: "createdAt", descending: true)
            .getDocuments()
            
        var requests: [SocialRequest] = []
        
        for doc in snapshot.documents {
            let data = doc.data()
            guard let toId = data["toId"] as? String else { continue }
            
            // Fetch target user profile
            if let user = try? await UserService.shared.fetchUser(uid: toId) {
                let toRequestUser = RequestUser(
                    id: user.id,
                    displayName: user.displayName,
                    profilePhotoURL: user.profilePhotoURL,
                    age: user.age,
                    city: user.city
                )
                
                let timestamp = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                
                let request = SocialRequest(
                    id: doc.documentID,
                    fromUser: nil, // We are 'fromUser'
                    toUser: toRequestUser,
                    status: .pending,
                    createdAt: timestamp,
                    respondedAt: nil
                )
                requests.append(request)
            }
        }
        return requests
    }

    // Alias for getReceivedRequests to match previous API if needed, 
    // but code should switch to getReceivedRequests
    func getPendingRequests() async throws -> [SocialRequest] {
        return try await getReceivedRequests()
    }
    
    func acceptRequest(requestId: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            print("❌ [FriendsService] acceptRequest: No current user!")
            return
        }
        
        print("✅ [FriendsService] acceptRequest called")
        print("   RequestID: \(requestId)")
        print("   Current UID: \(currentUid)")
        
        let docRef = requestsRef.document(requestId)
        let doc = try await docRef.getDocument()
        
        guard doc.exists else {
            print("❌ [FriendsService] Request document does not exist!")
            return
        }
        
        guard let data = doc.data() else {
            print("❌ [FriendsService] Request document has no data!")
            return
        }
        
        print("📄 [FriendsService] Request data: \(data)")
        
        guard let fromId = data["fromId"] as? String else {
            print("❌ [FriendsService] No fromId in request!")
            return
        }
        
        guard let toId = data["toId"] as? String else {
            print("❌ [FriendsService] No toId in request!")
            return
        }
        
        print("   FromID: \(fromId)")
        print("   ToID: \(toId)")
        
        guard toId == currentUid else {
            print("❌ [FriendsService] toId (\(toId)) != currentUid (\(currentUid))")
            return
        }
              
        // 1. Update request status
        print("📝 [FriendsService] Updating request status to accepted...")
        try await docRef.updateData(["status": "accepted", "respondedAt": FieldValue.serverTimestamp()])
        print("✅ [FriendsService] Request status updated")
        
        // 2. Add to Friends Collections (Bidirectional)
        print("👥 [FriendsService] Adding to friends collections...")
        let timestamp = FieldValue.serverTimestamp()
        
        // Add fromId to my friends
        print("   Adding \(fromId) to \(currentUid)'s friends")
        try await userFriendsRef(userId: currentUid).document(fromId).setData(["createdAt": timestamp])
        
        // Add me to fromId's friends
        print("   Adding \(currentUid) to \(fromId)'s friends")
        try await userFriendsRef(userId: fromId).document(currentUid).setData(["createdAt": timestamp])
        
        print("✅ [FriendsService] Friends added successfully!")
    }
    
    func rejectRequest(requestId: String) async throws {
        // Just update status to rejected (or delete)
        try await requestsRef.document(requestId).updateData(["status": "rejected"])
    }
}
