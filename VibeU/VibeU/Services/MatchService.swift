import Foundation
import FirebaseFirestore
import FirebaseAuth

enum MatchType: String {
    case speedDate = "speed_date"
    case voice = "voice"
    case astro = "astro"
}

enum MatchStatus: String {
    case searching = "searching"
    case matched = "matched"
}

struct MatchQueueUser: Codable {
    let id: String
    let name: String
    let photoURL: String
    let type: String
    let timestamp: Date
    var status: String
    var matchId: String?
    var matchedUserId: String?
}

class MatchService {
    static let shared = MatchService()
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    private init() {}
    
    // MARK: - Join Queue
    func joinQueue(type: MatchType, name: String, photoURL: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let data: [String: Any] = [
            "id": userId,
            "name": name,
            "photoURL": photoURL,
            "type": type.rawValue,
            "timestamp": FieldValue.serverTimestamp(),
            "status": MatchStatus.searching.rawValue
        ]
        
        try await db.collection("match_queue").document(userId).setData(data)
    }
    
    // MARK: - Leave Queue
    func leaveQueue() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        listener?.remove()
        try? await db.collection("match_queue").document(userId).delete()
    }
    
    // MARK: - Search for Match (Client-Side Logic)
    func listenForMatch(type: MatchType, onMatch: @escaping (MatchQueueUser) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        // 1. Listen to my own document to see if someone matched with me
        listener = db.collection("match_queue").document(currentUserId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let snapshot = snapshot, let data = snapshot.data() else { return }
                
                if let status = data["status"] as? String,
                   status == MatchStatus.matched.rawValue,
                   let matchedUserId = data["matchedUserId"] as? String {
                    
                    // I have been matched! Fetch the other user's info
                    self.fetchMatchedUser(userId: matchedUserId, onMatch: onMatch)
                }
            }
        
        // 2. Periodically look for available users to match WITH
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            Task {
                await self.findAvailableUser(type: type, currentUserId: currentUserId)
            }
        }
    }
    
    private func findAvailableUser(type: MatchType, currentUserId: String) async {
        do {
            // Find users who are searching, for the same type, and NOT me
            // Note: Cloud Firestore composite index might be needed here
            let snapshot = try await db.collection("match_queue")
                .whereField("type", isEqualTo: type.rawValue)
                .whereField("status", isEqualTo: MatchStatus.searching.rawValue)
                .limit(to: 10) // Fetch a few
                .getDocuments()
            
            for doc in snapshot.documents {
                let userId = doc.documentID
                
                if userId != currentUserId {
                    // FOUND A MATCH CANDIDATE!
                    // Try to claim this match atomically
                    try await self.claimMatch(currentUserId: currentUserId, targetUserId: userId)
                    break // Stop after finding one
                }
            }
        } catch {
            print("Error finding match: \(error)")
        }
    }
    
    private func claimMatch(currentUserId: String, targetUserId: String) async throws {
        let matchId = UUID().uuidString
        let batch = db.batch()
        
        let myRef = db.collection("match_queue").document(currentUserId)
        let targetRef = db.collection("match_queue").document(targetUserId)
        
        // Update MY doc
        batch.updateData([
            "status": MatchStatus.matched.rawValue,
            "matchId": matchId,
            "matchedUserId": targetUserId
        ], forDocument: myRef)
        
        // Update TARGET doc
        batch.updateData([
            "status": MatchStatus.matched.rawValue,
            "matchId": matchId,
            "matchedUserId": currentUserId
        ], forDocument: targetRef)
        
        try await batch.commit()
    }
    
    private func fetchMatchedUser(userId: String, onMatch: @escaping (MatchQueueUser) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let name = data["name"] as? String,
               let photoURL = data["photo_url"] as? String {
                
                let user = MatchQueueUser(
                    id: userId,
                    name: name,
                    photoURL: photoURL,
                    type: "", // Irrelevant here
                    timestamp: Date(),
                    status: "matched",
                    matchId: nil,
                    matchedUserId: nil
                )
                onMatch(user)
            }
        }
    }
}
