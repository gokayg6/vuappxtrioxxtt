import Foundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - Mock Data Seeder
// This service creates realistic mock users for development/demo purposes

actor MockDataService {
    static let shared = MockDataService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // Turkish names for realistic mock data
    private let maleNames = ["Kaan", "Efe", "Berk", "Emre", "Arda", "Mert", "Yiğit", "Barış", "Can", "Deniz", "Ozan", "Alp", "Cem", "Onur", "Burak", "Tolga", "Serkan", "Kerem", "Elif", "Koray"]
    private let femaleNames = ["Elif", "Zeynep", "Ayşe", "Defne", "Ecrin", "Melis", "İrem", "Selin", "Ceren", "Derya", "Pelin", "Buse", "Gizem", "Cansu", "Burcu", "Özge", "Şeyma", "Aslı", "Esra", "Gamze"]
    
    private let cities = ["Istanbul", "Ankara", "Izmir", "Antalya", "Bursa", "Adana", "Konya", "Gaziantep", "Mersin", "Kayseri", "Eskişehir", "Samsun", "Trabzon", "Bodrum", "Muğla"]
    
    private let bios = [
        "Hayatı keşfetmeyi seven biri 🌍",
        "Müzik ve kahve tutkunu ☕️",
        "Seyahat, kitap, sinema 🎬",
        "Spontane planlar için buradayım 🚀",
        "Pozitif enerji arıyorum ✨",
        "Doğa yürüyüşleri ve kamp 🏕️",
        "Yemek yapmayı seviyorum 🍳",
        "Fitness ve sağlıklı yaşam 💪",
        "Fotoğrafçılık hobim 📸",
        "Dans etmeyi seviyorum 💃",
        "Yazılımcı, geek, oyuncu 🎮",
        "Sanat ve tasarım meraklısı 🎨",
        "Spor ve macera arıyorum ⚽️",
        "Film ve dizi önerileri için mesaj at 🍿",
        "Hayvanları çok severim 🐕"
    ]
    
    // Placeholder photo URLs (using Unsplash random portraits)
    private let malePhotos = [
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=600&fit=crop",
        "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=600&fit=crop",
        "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=600&fit=crop",
        "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400&h=600&fit=crop",
        "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=400&h=600&fit=crop",
        "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=600&fit=crop",
        "https://images.unsplash.com/photo-1463453091185-61582044d556?w=400&h=600&fit=crop",
        "https://images.unsplash.com/photo-1504257432389-52343af06ae3?w=400&h=600&fit=crop"
    ]
    
    private let femalePhotos = [
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=600&fit=crop",
        "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=600&fit=crop",
        "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=600&fit=crop",
        "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&h=600&fit=crop",
        "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400&h=600&fit=crop",
        "https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=400&h=600&fit=crop",
        "https://images.unsplash.com/photo-1502823403499-6ccfcf4fb453?w=400&h=600&fit=crop",
        "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=400&h=600&fit=crop"
    ]
    
    // MARK: - Seed Mock Users
    func seedMockUsers(count: Int = 50) async throws {
        print("🌱 [MockDataService] Seeding \(count) mock users...")
        
        let batch = db.batch()
        
        for i in 0..<count {
            let isFemale = Bool.random()
            let name = isFemale ? femaleNames.randomElement()! : maleNames.randomElement()!
            let age = Int.random(in: 18...35)
            let city = cities.randomElement()!
            let bio = bios.randomElement()!
            let photos = isFemale ? femalePhotos : malePhotos
            let profilePhoto = photos.randomElement()!
            
            // Create additional photos
            var userPhotos: [[String: Any]] = []
            let photoCount = Int.random(in: 2...5)
            for j in 0..<photoCount {
                userPhotos.append([
                    "url": photos[j % photos.count],
                    "orderIndex": j,
                    "isPrimary": j == 0
                ])
            }
            
            let docRef = db.collection("users").document()
            let userData: [String: Any] = [
                "id": docRef.documentID,
                "displayName": name,
                "age": age,
                "gender": isFemale ? "female" : "male",
                "city": city,
                "country": "Turkey",
                "bio": bio,
                "profilePhotoURL": profilePhoto,
                "photos": userPhotos,
                "diamond_balance": Int.random(in: 50...500),
                "superlike_count": Int.random(in: 0...5),
                "boost_count": Int.random(in: 0...3),
                "is_mock": true,
                "isOnboarded": true,
                "createdAt": FieldValue.serverTimestamp(),
                "lastActiveAt": FieldValue.serverTimestamp(),
                "activity_score": Int.random(in: 20...100)
            ]
            
            batch.setData(userData, forDocument: docRef)
            
            if i % 10 == 0 {
                print("📦 [MockDataService] Created \(i + 1)/\(count) mock users...")
            }
        }
        
        try await batch.commit()
        print("✅ [MockDataService] Successfully seeded \(count) mock users!")
    }
    
    // MARK: - Clean Mock Users
    func cleanMockUsers() async throws {
        print("🧹 [MockDataService] Cleaning mock users...")
        
        let snapshot = try await db.collection("users")
            .whereField("is_mock", isEqualTo: true)
            .getDocuments()
        
        let batch = db.batch()
        for doc in snapshot.documents {
            batch.deleteDocument(doc.reference)
        }
        
        try await batch.commit()
        print("✅ [MockDataService] Deleted \(snapshot.documents.count) mock users")
    }
    
    // MARK: - Generate Random Like (for mock likes feature)
    func generateRandomLike(forUserId: String) async throws {
        // Pick a random mock user
        let mockUsers = try await db.collection("users")
            .whereField("is_mock", isEqualTo: true)
            .limit(to: 20)
            .getDocuments()
        
        guard let randomMock = mockUsers.documents.randomElement() else { return }
        
        // Create a like from mock user to real user
        let likeData: [String: Any] = [
            "fromUserId": randomMock.documentID,
            "toUserId": forUserId,
            "type": "like",
            "createdAt": FieldValue.serverTimestamp(),
            "is_mock": true
        ]
        
        try await db.collection("likes").addDocument(data: likeData)
        print("💖 [MockDataService] Generated mock like from \(randomMock.data()["displayName"] ?? "Unknown")")
    }
}
