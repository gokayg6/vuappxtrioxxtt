import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - Profile Completion Model
struct ProfileCompletion: Codable {
    let percentage: Int
    let isComplete: Bool
    let details: ProfileCompletionDetails
    
    // Mock data for when API fails
    static let mock = ProfileCompletion(
        percentage: 45,
        isComplete: false,
        details: ProfileCompletionDetails(
            profilePhoto: true,
            displayName: true,
            bio: false,
            photos: false,
            interests: false,
            socialLinks: false,
            location: true,
            dateOfBirth: true
        )
    )
}

struct ProfileCompletionDetails: Codable {
    let profilePhoto: Bool?
    let displayName: Bool?
    let bio: Bool?
    let photos: Bool?
    let interests: Bool?
    let socialLinks: Bool?
    let location: Bool?
    let dateOfBirth: Bool?
}

struct QRProfileData: Codable {
    let qrData: String
    let profileUrl: String
    let user: QRUser
}

struct QRUser: Codable {
    let id: String
    let username: String
    let displayName: String
    let profilePhotoUrl: String
}

// MARK: - Profile Service
@MainActor
final class ProfileService {
    static let shared = ProfileService()
    private let db = Firestore.firestore()
    private let baseURL = "http://192.168.140.129:3000/api" // Keep for other endpoints for now
    
    private init() {}
    
    // MARK: - Profile
    
    func getProfileCompletion(userId: String) async throws -> ProfileCompletion {
        guard !userId.isEmpty else { return .mock }
        
        let url = URL(string: "\(baseURL)/profile/\(userId)/completion")!
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return .mock
            }
            return try JSONDecoder().decode(ProfileCompletion.self, from: data)
        } catch {
            print("ProfileService: getProfileCompletion error - \(error)")
            return .mock
        }
    }
    
    func updateProfile(userId: String, data: [String: Any]) async throws {
        guard !userId.isEmpty else { return }
        
        var request = URLRequest(url: URL(string: "\(baseURL)/profile/\(userId)")!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: data)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("ProfileService: updateProfile failed")
            return
        }
    }
    
    // MARK: - Photos
    
    func fetchPhotos(userId: String) async throws -> [PhotoModel] {
        guard !userId.isEmpty else { return [] }
        
        print("ProfileService: fetchPhotos called for userId: \(userId)")
        
        do {
            let snapshot = try await db.collection("users").document(userId).collection("photos")
                .order(by: "orderIndex")
                .getDocuments()
            
            print("ProfileService: Found \(snapshot.documents.count) photo documents")
            
            let photos = snapshot.documents.compactMap { document -> PhotoModel? in
                let data = document.data()
                // Manual mapping since PhotoModel Codable expects specific JSON keys which might differ or we used dictionary saves
                // Let's rely on JSONDecoder with JSONSerialization for cleaner mapping if keys match
                // Or map manually
                guard let url = data["url"] as? String,
                      let photoId = data["id"] as? String else { return nil }
                      
                return PhotoModel(
                    id: photoId,
                    userId: data["userId"] as? String ?? userId,
                    url: url,
                    thumbnailUrl: data["thumbnailUrl"] as? String ?? url,
                    orderIndex: data["orderIndex"] as? Int ?? 0,
                    isPrimary: data["isPrimary"] as? Bool ?? false,
                    moderationStatus: data["moderationStatus"] as? String ?? "approved",
                    createdAt: data["createdAt"] as? String ?? ""
                )
            }
            return photos
        } catch {
            print("ProfileService: fetchPhotos error - \(error)")
            // Fallback to empty if fails, but don't try old API as we moved writers
            return []
        }
    }
    
    func deletePhoto(userId: String, photoId: String) async throws {
        // 1. Delete from subcollection (Legacy/Backup) - Make NON-FATAL
        do {
            try await db.collection("users").document(userId).collection("photos").document(photoId).delete()
        } catch {
            print("ProfileService: Subcollection delete failed (ignoring as legacy): \(error)")
        }
        
        // 2. Remove from main document array (Source of Truth)
        let userDocRef = db.collection("users").document(userId)
        let snapshot = try await userDocRef.getDocument()
        
        if let userData = snapshot.data(),
           var photos = userData["photos"] as? [[String: Any]] {
            
            let originalCount = photos.count
            photos.removeAll { ($0["id"] as? String) == photoId }
            
            if photos.count != originalCount {
                try await userDocRef.updateData(["photos": photos])
            }
        }
    }
    
    // MARK: - Interests
    
    func fetchAllInterests() async throws -> InterestsGroupedResponse {
        let url = URL(string: "\(baseURL)/profile/interests/all")!
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return InterestsGroupedResponse(interests: [], grouped: [:])
            }
            return try JSONDecoder().decode(InterestsGroupedResponse.self, from: data)
        } catch {
            print("ProfileService: fetchAllInterests error - \(error)")
            return InterestsGroupedResponse(interests: [], grouped: [:])
        }
    }
    
    func fetchUserInterests(userId: String) async throws -> [InterestModel] {
        guard !userId.isEmpty else { return [] }
        
        let url = URL(string: "\(baseURL)/profile/\(userId)/interests")!
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return []
            }
            return try JSONDecoder().decode([InterestModel].self, from: data)
        } catch {
            print("ProfileService: fetchUserInterests error - \(error)")
            return []
        }
    }
    
    func updateUserInterests(userId: String, interestIds: [String]) async throws {
        guard !userId.isEmpty else { return }
        
        var request = URLRequest(url: URL(string: "\(baseURL)/profile/\(userId)/interests")!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["interestIds": interestIds])
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("ProfileService: updateUserInterests failed")
            return
        }
    }
    
    // MARK: - Social Links
    
    func fetchSocialLinks(userId: String) async throws -> SocialLinksModel {
        guard !userId.isEmpty else { return SocialLinksModel(instagram: nil, tiktok: nil, snapchat: nil) }
        
        let url = URL(string: "\(baseURL)/profile/\(userId)/social")!
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return SocialLinksModel(instagram: nil, tiktok: nil, snapchat: nil)
            }
            return try JSONDecoder().decode(SocialLinksModel.self, from: data)
        } catch {
            print("ProfileService: fetchSocialLinks error - \(error)")
            return SocialLinksModel(instagram: nil, tiktok: nil, snapchat: nil)
        }
    }
    
    func updateSocialLinks(userId: String, instagram: String?, tiktok: String?, snapchat: String?) async throws -> SocialLinksModel {
        guard !userId.isEmpty else { return SocialLinksModel(instagram: nil, tiktok: nil, snapchat: nil) }
        
        var request = URLRequest(url: URL(string: "\(baseURL)/profile/\(userId)/social")!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = [:]
        if let instagram = instagram { body["instagram"] = instagram }
        if let tiktok = tiktok { body["tiktok"] = tiktok }
        if let snapchat = snapchat { body["snapchat"] = snapchat }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return SocialLinksModel(instagram: instagram, tiktok: tiktok, snapchat: snapchat)
            }
            return try JSONDecoder().decode(SocialLinksModel.self, from: data)
        } catch {
            return SocialLinksModel(instagram: instagram, tiktok: tiktok, snapchat: snapchat)
        }
    }
    
    // MARK: - QR Profile
    
    func getQRData(userId: String) async throws -> QRProfileData {
        let url = URL(string: "\(baseURL)/profile/\(userId)/qr")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(QRProfileData.self, from: data)
    }
}

// MARK: - Supporting Models
struct PhotoModel: Codable, Identifiable {
    let id: String
    let userId: String
    let url: String
    let thumbnailUrl: String?
    let orderIndex: Int
    let isPrimary: Bool
    let moderationStatus: String
    let createdAt: String
}

struct InterestModel: Codable, Identifiable, Hashable {
    let id: String
    let code: String
    let nameEn: String
    let nameEs: String
    let namePt: String
    let nameFr: String
    let nameTr: String
    let emoji: String?
    let category: String
    
    var localizedName: String {
        return nameTr.isEmpty ? nameEn : nameTr
    }
}

struct InterestsGroupedResponse: Codable {
    let interests: [InterestModel]
    let grouped: [String: [InterestModel]]
}

struct SocialLinksModel: Codable {
    let instagram: String?
    let tiktok: String?
    let snapchat: String?
}
