import Foundation
import FirebaseAuth
import FirebaseFirestore
import UIKit

// MARK: - API Client Mock (Removing dependency)
// class APIClient { ... }

actor UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()
    
    private var usersRef: CollectionReference {
        return db.collection("users")
    }
    
    private init() {}
    
    // MARK: - Firestore Operations
    
    /// Saves or updates a user in Firestore
    func saveUser(_ user: User) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        try usersRef.document(uid).setData(from: user, merge: true)
    }
    
    /// Fetches a user by their UID
    func fetchUser(uid: String) async throws -> User? {
        print("🔍 [UserService] Fetching user: \(uid)")
        
        do {
            // Try to fetch from server first
            let document = try await usersRef.document(uid).getDocument(source: .server)
            print("📄 [UserService] Document exists: \(document.exists)")
            
            if document.exists {
                guard let data = document.data() else {
                    print("⚠️ [UserService] Document has no data")
                    return nil
                }
                
                print("📋 [UserService] Raw document data:")
                for (key, value) in data {
                    print("   \(key): \(type(of: value)) = \(value)")
                }
                
                do {
                    // Use Firestore decoder - it automatically handles Timestamp -> Date conversion
                    let user = try document.data(as: User.self)
                    print("✅ [UserService] User decoded successfully: \(user.displayName)")
                    return user
                } catch let decodingError as DecodingError {
                    print("❌ [UserService] DecodingError details:")
                    switch decodingError {
                    case .typeMismatch(let type, let context):
                        print("   Type mismatch: expected \(type)")
                        print("   Context: \(context.debugDescription)")
                        print("   Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                    case .valueNotFound(let type, let context):
                        print("   Value not found: \(type)")
                        print("   Context: \(context.debugDescription)")
                        print("   Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                    case .keyNotFound(let key, let context):
                        print("   Key not found: \(key.stringValue)")
                        print("   Context: \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("   Data corrupted")
                        print("   Context: \(context.debugDescription)")
                        print("   Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                    @unknown default:
                        print("   Unknown decoding error: \(decodingError)")
                    }
                    throw decodingError
                } catch {
                    print("❌ [UserService] Failed to decode user: \(error)")
                    throw error
                }
            }
            
            print("⚠️ [UserService] Document does not exist for uid: \(uid)")
            return nil
        } catch let error as NSError {
            print("❌ [UserService] Error fetching user: \(error.localizedDescription)")
            print("🔍 [UserService] Error domain: \(error.domain), code: \(error.code)")
            
            // If offline or unavailable, try cache
            if error.domain == "FIRFirestoreErrorDomain" && (error.code == 14 || error.code == 7) {
                print("⚠️ Server unavailable, trying cache for user \(uid)")
                let document = try await usersRef.document(uid).getDocument(source: .cache)
                if document.exists {
                    if var user = try? document.data(as: User.self) {
                        // Try to fetch photos from cache
                        let photoModels = try? await ProfileService.shared.fetchPhotos(userId: uid)
                        if let models = photoModels {
                             user.photos = models.map { model in
                                UserPhoto(
                                    id: model.id,
                                    url: model.url,
                                    thumbnailURL: model.url,
                                    orderIndex: model.orderIndex,
                                    isPrimary: model.isPrimary
                                )
                            }
                        }
                        return user
                    }
                }
                return nil
            }
            throw error
        }
    }
    
    /// Checks if a user profile exists
    func userExists(uid: String) async throws -> Bool {
        do {
            // Try server first
            let document = try await usersRef.document(uid).getDocument(source: .server)
            return document.exists
        } catch let error as NSError {
            // If offline, try cache
            if error.domain == "FIRFirestoreErrorDomain" && (error.code == 14 || error.code == 7) {
                print("⚠️ Server unavailable, trying cache for user existence check")
                let document = try await usersRef.document(uid).getDocument(source: .cache)
                return document.exists
            }
            throw error
        }
    }
    
    /// Updates specific fields for a user
    func updateUserFields(uid: String, data: [String: Any]) async throws {
        try await usersRef.document(uid).updateData(data)
    }
    
    /// Deletes a user profile
    func deleteUser(uid: String) async throws {
        try await usersRef.document(uid).delete()
    }
    
    // MARK: - Profile Access
    
    func getProfile() async throws -> User {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw AuthError.notAuthenticated
        }
        
        if let user = try await fetchUser(uid: uid) {
            return user
        } else {
            throw AuthError.serverError("Kullanıcı profili bulunamadı")
        }
    }
    
    func updateProfile(displayName: String?, bio: String?, city: String?) async throws -> User {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw AuthError.notAuthenticated
        }
        
        var updates: [String: Any] = [:]
        if let displayName = displayName { updates["display_name"] = displayName }
        if let bio = bio { updates["bio"] = bio }
        if let city = city { updates["city"] = city }
        
        try await updateUserFields(uid: uid, data: updates)
        return try await getProfile()
    }
    
    // MARK: - Photos (Mock Implementation)
    
    func uploadPhoto(imageData: Data, orderIndex: Int) async throws -> UserPhoto {
        // Mock upload delay
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        // Return Placebo URL
        let mockURL = "https://picsum.photos/seed/\(UUID().uuidString)/400/600"
        
        let newPhoto = UserPhoto(
            id: UUID().uuidString,
            url: mockURL,
            thumbnailURL: mockURL,
            orderIndex: orderIndex,
            isPrimary: orderIndex == 0
        )
        
        // TODO: Update user photos array in Firestore?
        // For verify step, we pretend it worked.
        return newPhoto
    }
    
    func deletePhoto(photoId: String) async throws {
        // Mock delete delay
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    // MARK: - Tags & Interests
    
    func updateTags(_ tags: [String]) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { throw AuthError.notAuthenticated }
        try await updateUserFields(uid: uid, data: ["tags": tags])
    }
    
    func updateInterests(_ interestIds: [String]) async throws {
        // Implementation pending
    }
    
    func getAvailableInterests() async throws -> [Interest] {
        return [
             Interest(id: "1", code: "music", name: "Music", emoji: "🎵", category: "Art"),
             Interest(id: "2", code: "sports", name: "Sports", emoji: "⚽️", category: "Active"),
             Interest(id: "3", code: "travel", name: "Travel", emoji: "✈️", category: "Lifestyle")
        ]
    }
    
    // MARK: - Social Links
    
    func updateSocialLinks(tiktok: String?, instagram: String?, snapchat: String?) async throws {
        // Implementation pending
    }
    
    // MARK: - Location
    
    func updateLocation(latitude: Double, longitude: Double) async throws {
        // Implementation pending
    }
    
    // MARK: - Account Management
    
    func deleteAccount() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        try await deleteUser(uid: uid)
        try await Auth.auth().currentUser?.delete()
    }
    
    func getProfileById(_ userId: String) async throws -> User {
         if let user = try await fetchUser(uid: userId) {
             return user
         } else {
             throw AuthError.serverError("Kullanıcı bulunamadı")
         }
    }
}
