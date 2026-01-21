import Foundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - Likes Service
// Handles likes, top profiles, and mock like generation

actor LikesService {
    static let shared = LikesService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Get Received Likes
    func getReceivedLikes(limit: Int = 20) async throws -> [LikeNotification] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        
        let snapshot = try await db.collection("likes")
            .whereField("toUserId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        var likes: [LikeNotification] = []
        
        for doc in snapshot.documents {
            let data = doc.data()
            let fromUserId = data["fromUserId"] as? String ?? ""
            let type = data["type"] as? String ?? "like"
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            
            // Fetch user info
            if let userDoc = try? await db.collection("users").document(fromUserId).getDocument(),
               let userData = userDoc.data() {
                let like = LikeNotification(
                    id: doc.documentID,
                    fromUserId: fromUserId,
                    displayName: userData["displayName"] as? String ?? "Kullanıcı",
                    profilePhotoURL: userData["profilePhotoURL"] as? String ?? "",
                    age: userData["age"] as? Int ?? 0,
                    city: userData["city"] as? String ?? "",
                    type: type == "superlike" ? .superlike : .like,
                    createdAt: createdAt,
                    isMock: data["is_mock"] as? Bool ?? false
                )
                likes.append(like)
            }
        }
        
        return likes
    }
    
    // MARK: - Send Like
    func sendLike(toUserId: String, type: LikeType = .like) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let data: [String: Any] = [
            "fromUserId": uid,
            "toUserId": toUserId,
            "type": type == .superlike ? "superlike" : "like",
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("likes").addDocument(data: data)
        print("💖 [LikesService] Like sent to \(toUserId)")
    }
    
    // MARK: - Get Top Profiles (En Seçkin Profiller)
    func getTopProfiles(limit: Int = 10, countryFilter: String? = nil) async throws -> [TopProfile] {
        var query: Query = db.collection("users")
            .order(by: "activity_score", descending: true)
        
        if let country = countryFilter, !country.isEmpty {
            query = query.whereField("country", isEqualTo: country)
        }
        
        query = query.limit(to: limit)
        
        let snapshot = try await query.getDocuments()
        
        var profiles: [TopProfile] = []
        
        for doc in snapshot.documents {
            // Skip current user
            if doc.documentID == Auth.auth().currentUser?.uid { continue }
            
            let data = doc.data()
            let profile = TopProfile(
                id: doc.documentID,
                displayName: data["displayName"] as? String ?? "Kullanıcı",
                age: data["age"] as? Int ?? 0,
                city: data["city"] as? String ?? "",
                profilePhotoURL: data["profilePhotoURL"] as? String ?? "",
                activityScore: data["activity_score"] as? Int ?? 0,
                isBoosted: (data["boosted_until"] as? Timestamp)?.dateValue() ?? Date.distantPast > Date()
            )
            profiles.append(profile)
        }
        
        // Ensure we always return 10 profiles by adding mock if needed
        if profiles.count < limit {
            let mockProfiles = try await getMockProfiles(count: limit - profiles.count)
            profiles.append(contentsOf: mockProfiles)
        }
        
        return Array(profiles.prefix(limit))
    }
    
    // MARK: - Get Mock Profiles
    private func getMockProfiles(count: Int) async throws -> [TopProfile] {
        let snapshot = try await db.collection("users")
            .whereField("is_mock", isEqualTo: true)
            .limit(to: count)
            .getDocuments()
        
        return snapshot.documents.map { doc in
            let data = doc.data()
            return TopProfile(
                id: doc.documentID,
                displayName: data["displayName"] as? String ?? "Kullanıcı",
                age: data["age"] as? Int ?? 0,
                city: data["city"] as? String ?? "",
                profilePhotoURL: data["profilePhotoURL"] as? String ?? "",
                activityScore: data["activity_score"] as? Int ?? 0,
                isBoosted: false
            )
        }
    }
    
    // MARK: - Generate Mock Likes (for demo purposes)
    func generateMockLikesIfNeeded(forUserId: String, maxPerDay: Int = 10) async throws {
        // Check how many mock likes user received today
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        
        let existingMockLikes = try await db.collection("likes")
            .whereField("toUserId", isEqualTo: forUserId)
            .whereField("is_mock", isEqualTo: true)
            .whereField("createdAt", isGreaterThan: Timestamp(date: startOfDay))
            .getDocuments()
        
        if existingMockLikes.documents.count >= maxPerDay {
            print("📊 [LikesService] Already reached mock like limit for today")
            return
        }
        
        // Get random mock users
        let mockUsers = try await db.collection("users")
            .whereField("is_mock", isEqualTo: true)
            .limit(to: 5)
            .getDocuments()
        
        // Create 1-3 random mock likes
        let likesToCreate = Int.random(in: 1...min(3, maxPerDay - existingMockLikes.documents.count))
        
        for i in 0..<likesToCreate {
            guard let randomMock = mockUsers.documents.randomElement() else { continue }
            
            // Check if this mock user already liked
            let existingLike = try await db.collection("likes")
                .whereField("fromUserId", isEqualTo: randomMock.documentID)
                .whereField("toUserId", isEqualTo: forUserId)
                .getDocuments()
            
            if !existingLike.documents.isEmpty { continue }
            
            // Create delayed mock like
            let randomDelay = TimeInterval.random(in: 60...3600) // 1 min to 1 hour
            let likeTime = Date().addingTimeInterval(randomDelay * Double(i))
            
            let data: [String: Any] = [
                "fromUserId": randomMock.documentID,
                "toUserId": forUserId,
                "type": Bool.random() ? "superlike" : "like",
                "createdAt": Timestamp(date: likeTime),
                "is_mock": true
            ]
            
            try await db.collection("likes").addDocument(data: data)
            print("💖 [LikesService] Mock like scheduled from \(randomMock.data()["displayName"] ?? "Unknown")")
        }
    }
}

// MARK: - Models

struct LikeNotification: Identifiable {
    let id: String
    let fromUserId: String
    let displayName: String
    let profilePhotoURL: String
    let age: Int
    let city: String
    let type: LikeType
    let createdAt: Date
    let isMock: Bool
}

enum LikeType {
    case like
    case superlike
}

struct TopProfile: Identifiable {
    let id: String
    let displayName: String
    let age: Int
    let city: String
    let profilePhotoURL: String
    let activityScore: Int
    let isBoosted: Bool
}
