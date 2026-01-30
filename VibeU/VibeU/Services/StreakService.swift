import Foundation
import FirebaseAuth
import FirebaseFirestore

// MARK: - Daily Streak Service
// Real-time streak tracking with diamond rewards
actor StreakService {
    static let shared = StreakService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Streak Data
    func getStreak() async throws -> StreakData {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "StreakService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let doc = try await db.collection("users").document(uid).collection("streak").document("current").getDocument()
        
        if doc.exists, let data = doc.data() {
            let currentStreak = data["current_streak"] as? Int ?? 0
            let lastCheckIn = (data["last_check_in"] as? Timestamp)?.dateValue() ?? Date.distantPast
            let totalDiamonds = data["total_diamonds_earned"] as? Int ?? 0
            
            // Check if streak is still valid (within 24 hours)
            let isValid = Calendar.current.isDateInToday(lastCheckIn) || 
                          Calendar.current.isDateInYesterday(lastCheckIn)
            
            return StreakData(
                currentStreak: isValid ? currentStreak : 0,
                lastCheckIn: lastCheckIn,
                totalDiamondsEarned: totalDiamonds,
                canCheckInToday: !Calendar.current.isDateInToday(lastCheckIn)
            )
        }
        
        return StreakData(currentStreak: 0, lastCheckIn: Date.distantPast, totalDiamondsEarned: 0, canCheckInToday: true)
    }
    
    // MARK: - Check In
    func checkIn() async throws -> CheckInResult {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "StreakService", code: -1)
        }
        
        let streakRef = db.collection("users").document(uid).collection("streak").document("current")
        let userRef = db.collection("users").document(uid)
        
        let doc = try await streakRef.getDocument()
        var currentStreak = 0
        var totalDiamonds = 0
        var lastCheckIn = Date.distantPast
        
        if doc.exists, let data = doc.data() {
            currentStreak = data["current_streak"] as? Int ?? 0
            lastCheckIn = (data["last_check_in"] as? Timestamp)?.dateValue() ?? Date.distantPast
            totalDiamonds = data["total_diamonds_earned"] as? Int ?? 0
        }
        
        // Check if already checked in today
        if Calendar.current.isDateInToday(lastCheckIn) {
            return CheckInResult(success: false, newStreak: currentStreak, diamondsEarned: 0, message: "Bugün zaten giriş yaptın!")
        }
        
        // Check if streak continues (yesterday check-in)
        let isConsecutive = Calendar.current.isDateInYesterday(lastCheckIn)
        let newStreak = isConsecutive ? currentStreak + 1 : 1
        
        // Calculate diamonds (5 days = 200 diamonds)
        var diamondsEarned = 0
        if newStreak == 5 {
            diamondsEarned = 200
        }
        
        // Update streak
        try await streakRef.setData([
            "current_streak": newStreak,
            "last_check_in": Timestamp(date: Date()),
            "total_diamonds_earned": totalDiamonds + diamondsEarned
        ], merge: true)
        
        // Award diamonds if earned
        if diamondsEarned > 0 {
            try await userRef.updateData([
                "diamond_balance": FieldValue.increment(Int64(diamondsEarned))
            ])
        }
        
        return CheckInResult(
            success: true,
            newStreak: newStreak,
            diamondsEarned: diamondsEarned,
            message: diamondsEarned > 0 ? "🎉 5 günlük seri tamamlandı! \(diamondsEarned) elmas kazandın!" : "✨ \(newStreak) günlük seri!"
        )
    }
    
    // MARK: - Reset Streak (for testing)
    func resetStreak() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        try await db.collection("users").document(uid).collection("streak").document("current").delete()
    }
}

// MARK: - Models
struct StreakData {
    let currentStreak: Int
    let lastCheckIn: Date
    let totalDiamondsEarned: Int
    let canCheckInToday: Bool
}

struct CheckInResult {
    let success: Bool
    let newStreak: Int
    let diamondsEarned: Int
    let message: String
}
