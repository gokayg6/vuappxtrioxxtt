import Foundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - Diamond Transaction Types
enum DiamondTransactionType: String, Codable {
    case dailyReward = "daily_reward"
    case matchRequest = "match_request"
    case purchase = "purchase"
    case admin = "admin"
}

// MARK: - Diamond Errors
enum DiamondError: Error, LocalizedError {
    case insufficientBalance
    case dailyRewardAlreadyClaimed
    case userNotFound
    case transactionFailed
    
    var errorDescription: String? {
        switch self {
        case .insufficientBalance:
            return "Yetersiz elmas bakiyesi"
        case .dailyRewardAlreadyClaimed:
            return "Bugünkü ödülünü zaten aldın"
        case .userNotFound:
            return "Kullanıcı bulunamadı"
        case .transactionFailed:
            return "İşlem başarısız oldu"
        }
    }
}

// MARK: - Diamond Service
actor DiamondService {
    static let shared = DiamondService()
    private let db = Firestore.firestore()
    
    private var usersRef: CollectionReference {
        db.collection("users")
    }
    
    private var transactionsRef: CollectionReference {
        db.collection("diamond_transactions")
    }
    
    private init() {}
    
    // MARK: - Get Balance
    func getBalance() async throws -> Int {
        guard let uid = Auth.auth().currentUser?.uid else { return 0 }
        
        let doc = try await usersRef.document(uid).getDocument()
        return doc.data()?["diamond_balance"] as? Int ?? 100 // Default 100 elmas
    }
    
    // MARK: - Can Claim Daily Reward
    func canClaimDailyReward() async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        
        let doc = try await usersRef.document(uid).getDocument()
        
        guard let lastClaim = doc.data()?["daily_reward_last_claim_at"] as? Timestamp else {
            return true // Never claimed
        }
        
        // Check if today (Istanbul time) is different from last claim
        let istanbul = TimeZone(identifier: "Europe/Istanbul")!
        var calendar = Calendar.current
        calendar.timeZone = istanbul
        
        let lastClaimDay = calendar.startOfDay(for: lastClaim.dateValue())
        let today = calendar.startOfDay(for: Date())
        
        return today > lastClaimDay
    }
    
    // MARK: - Claim Daily Reward (+100 diamonds)
    func claimDailyReward() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw DiamondError.userNotFound
        }
        
        // Check if can claim
        let canClaim = try await canClaimDailyReward()
        guard canClaim else {
            throw DiamondError.dailyRewardAlreadyClaimed
        }
        
        // Use transaction for atomic update
        let docRef = usersRef.document(uid)
        
        try await db.runTransaction { (transaction, errorPointer) -> Any? in
            let snapshot: DocumentSnapshot
            do {
                snapshot = try transaction.getDocument(docRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let currentBalance = snapshot.data()?["diamond_balance"] as? Int ?? 100
            let newBalance = currentBalance + 100
            
            transaction.updateData([
                "diamond_balance": newBalance,
                "daily_reward_last_claim_at": FieldValue.serverTimestamp()
            ], forDocument: docRef)
            
            return nil
        }
        
        // Log transaction
        try await logTransaction(
            type: .dailyReward,
            amount: 100,
            metadata: nil
        )
        
        print("✅ [DiamondService] Daily reward claimed! +100 diamonds")
    }
    
    // MARK: - Spend Diamonds
    func spendDiamonds(amount: Int, type: DiamondTransactionType, metadata: [String: Any]? = nil) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw DiamondError.userNotFound
        }
        
        let docRef = usersRef.document(uid)
        
        // Use transaction for atomic update (prevent negative balance)
        try await db.runTransaction { (transaction, errorPointer) -> Any? in
            let snapshot: DocumentSnapshot
            do {
                snapshot = try transaction.getDocument(docRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let currentBalance = snapshot.data()?["diamond_balance"] as? Int ?? 0
            
            // Check sufficient balance
            guard currentBalance >= amount else {
                let error = NSError(
                    domain: "DiamondService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Yetersiz elmas"]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            let newBalance = currentBalance - amount
            
            transaction.updateData([
                "diamond_balance": newBalance
            ], forDocument: docRef)
            
            return nil
        }
        
        // Log transaction
        try await logTransaction(
            type: type,
            amount: -amount,
            metadata: metadata
        )
        
        print("✅ [DiamondService] Spent \(amount) diamonds. Type: \(type.rawValue)")
    }
    
    // MARK: - Add Diamonds (for purchases/admin)
    func addDiamonds(amount: Int, type: DiamondTransactionType) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw DiamondError.userNotFound
        }
        
        let docRef = usersRef.document(uid)
        
        try await docRef.updateData([
            "diamond_balance": FieldValue.increment(Int64(amount))
        ])
        
        // Log transaction
        try await logTransaction(
            type: type,
            amount: amount,
            metadata: nil
        )
        
        print("✅ [DiamondService] Added \(amount) diamonds. Type: \(type.rawValue)")
    }
    
    // MARK: - Log Transaction
    private func logTransaction(type: DiamondTransactionType, amount: Int, metadata: [String: Any]?) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var data: [String: Any] = [
            "userId": uid,
            "type": type.rawValue,
            "amount": amount,
            "created_at": FieldValue.serverTimestamp()
        ]
        
        if let metadata = metadata {
            data["metadata"] = metadata
        }
        
        try await transactionsRef.addDocument(data: data)
    }
    
    // MARK: - Get Time Until Next Reward (for UI)
    func getTimeUntilNextReward() async throws -> TimeInterval? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        
        let doc = try await usersRef.document(uid).getDocument()
        
        guard let lastClaim = doc.data()?["daily_reward_last_claim_at"] as? Timestamp else {
            return nil // Can claim now
        }
        
        let istanbul = TimeZone(identifier: "Europe/Istanbul")!
        var calendar = Calendar.current
        calendar.timeZone = istanbul
        
        // Next midnight in Istanbul
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: lastClaim.dateValue()))!
        
        return tomorrow.timeIntervalSince(Date())
    }
}
