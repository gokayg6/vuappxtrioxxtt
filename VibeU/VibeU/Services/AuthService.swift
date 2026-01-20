import Foundation
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices

@Observable
class AuthService: @unchecked Sendable {
    static let shared = AuthService()
    
    var currentUser: AuthUser?
    var authToken: String?
    
    var isAuthenticated: Bool {
        return Auth.auth().currentUser != nil
    }
    
    private init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                self?.authToken = user.uid
                Task { [weak self] in
                    await self?.fetchUserProfile(uid: user.uid)
                }
            } else {
                self?.authToken = nil
                self?.currentUser = nil
            }
        }
    }
    
    // MARK: - AppState Support
    
    func getCurrentUser() async throws -> User {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw AuthError.notAuthenticated
        }
        
        // Use UserService to fetch user
        if let user = try await UserService.shared.fetchUser(uid: uid) {
            return user
        }
        
        // Fallback or error
        throw AuthError.serverError("Kullanıcı verisi alınamadı")
    }
    
    // MARK: - Email Auth
    
    func register(data: RegistrationData) async throws -> AuthData {
        let authResult = try await Auth.auth().createUser(withEmail: data.email, password: data.password)
        let uid = authResult.user.uid
        
        let newUser = User(
            id: uid,
            username: data.email.components(separatedBy: "@").first ?? "user",
            displayName: "\(data.firstName) \(data.lastName)",
            dateOfBirth: data.dateOfBirth,
            age: Calendar.current.dateComponents([.year], from: data.dateOfBirth, to: Date()).year ?? 18,
            ageGroup: .adult,
            gender: Gender(rawValue: data.gender.rawValue) ?? .preferNotToSay,
            country: data.country ?? "Turkey",
            city: data.city ?? "Istanbul",
            bio: data.bio ?? "VibeU dünyasına katıldım! 👋",
            profilePhotoURL: "https://ui-avatars.com/api/?name=\(data.firstName)+\(data.lastName)&background=random",
            photos: [],
            tags: [],
            interests: [],
            isPremium: false,
            premiumExpiresAt: nil,
            isVerified: false,
            socialLinks: nil,
            lastActiveAt: Date(),
            createdAt: Date()
        )
        
        // Save via UserService with retry logic
        do {
            try await UserService.shared.saveUser(newUser)
        } catch let error as NSError {
            // If offline error during registration, still proceed
            if error.domain == "FIRFirestoreErrorDomain" && (error.code == 14 || error.code == 7) {
                print("⚠️ Offline during registration, user will sync later")
            } else {
                throw error
            }
        }
        
        let authUser = mapUserToAuthUser(user: newUser)
        self.currentUser = authUser
        
        return AuthData(user: authUser, token: uid, needsProfileCompletion: false)
    }
    
    func login(email: String, password: String) async throws -> AuthData {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        let uid = authResult.user.uid
        
        do {
            if let user = try await UserService.shared.fetchUser(uid: uid) {
                let authUser = mapUserToAuthUser(user: user)
                self.currentUser = authUser
                return AuthData(user: authUser, token: uid, needsProfileCompletion: false)
            } else {
                throw AuthError.serverError("Kullanıcı profili bulunamadı")
            }
        } catch let error as NSError {
            // If offline error, create temporary auth data
            if error.domain == "FIRFirestoreErrorDomain" && (error.code == 14 || error.code == 7) {
                print("⚠️ Offline during login, using cached auth")
                let tempUser = AuthUser(
                    id: uid,
                    username: email.components(separatedBy: "@").first ?? "user",
                    email: email,
                    displayName: "User",
                    dateOfBirth: ISO8601DateFormatter().string(from: Date()),
                    gender: "prefer_not_to_say",
                    country: "Turkey",
                    city: "Istanbul",
                    bio: "",
                    profilePhotoUrl: "https://ui-avatars.com/api/?name=User&background=random",
                    zodiacSign: "Leo",
                    instagramUsername: nil,
                    tiktokUsername: nil,
                    snapchatUsername: nil,
                    isPremium: false,
                    isVerified: false,
                    createdAt: ISO8601DateFormatter().string(from: Date())
                )
                self.currentUser = tempUser
                return AuthData(user: tempUser, token: uid, needsProfileCompletion: false)
            }
            throw error
        }
    }
    
    // MARK: - Social Auth
    
    struct SocialAuthResponse {
        let user: User
        let accessToken: String
        let refreshToken: String
    }
    
    func signInWithGoogle(idToken: String, accessToken: String, email: String, name: String, photoURL: String) async throws -> SocialAuthResponse {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let authResult = try await Auth.auth().signIn(with: credential)
        let uid = authResult.user.uid
        
        return try await handleSocialLoginSuccess(uid: uid, email: email, name: name, photoURL: photoURL)
    }
    
    func signInWithApple(identityToken: String, authorizationCode: String, fullName: String?) async throws -> SocialAuthResponse {
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: identityToken, rawNonce: UUID().uuidString)
        let authResult = try await Auth.auth().signIn(with: credential)
        let uid = authResult.user.uid
        let email = authResult.user.email ?? "apple_user@vibeu.app"
        
        return try await handleSocialLoginSuccess(uid: uid, email: email, name: fullName ?? "Apple User", photoURL: nil)
    }
    
    func authenticateWithBackend(firebaseToken: String) async throws -> SocialAuthResponse {
        guard let uid = Auth.auth().currentUser?.uid else {
             throw AuthError.notAuthenticated
        }
        return try await handleSocialLoginSuccess(uid: uid, email: "phone_user", name: "Phone User", photoURL: nil as String?)
    }
    
    func clearAuth() {
        logout()
    }
    
    private func handleSocialLoginSuccess(uid: String, email: String, name: String, photoURL: String?) async throws -> SocialAuthResponse {
        // Check via UserService
        if let existingUser = try await UserService.shared.fetchUser(uid: uid) {
            self.currentUser = mapUserToAuthUser(user: existingUser)
            return SocialAuthResponse(user: existingUser, accessToken: uid, refreshToken: uid)
        } else {
            // New User
            let newUser = User(
                id: uid,
                username: email.components(separatedBy: "@").first ?? "user_\(uid.prefix(5))",
                displayName: name,
                dateOfBirth: Date(),
                age: 18,
                ageGroup: .adult,
                gender: .preferNotToSay,
                country: "Turkey",
                city: "Istanbul",
                bio: "VibeU'ya yeni katıldım!",
                profilePhotoURL: photoURL ?? "https://ui-avatars.com/api/?name=\(name)&background=random",
                photos: [],
                tags: [],
                interests: [],
                isPremium: false,
                premiumExpiresAt: nil,
                isVerified: false,
                socialLinks: nil,
                lastActiveAt: Date(),
                createdAt: Date()
            )
            
            try await UserService.shared.saveUser(newUser)
            self.currentUser = mapUserToAuthUser(user: newUser)
            return SocialAuthResponse(user: newUser, accessToken: uid, refreshToken: uid)
        }
    }
    
    // MARK: - Helpers
    
    private func fetchUserProfile(uid: String) async {
        do {
            if let user = try await UserService.shared.fetchUser(uid: uid) {
                await MainActor.run {
                    self.currentUser = mapUserToAuthUser(user: user)
                }
            }
        } catch {
            print("Error fetching profile: \(error)")
        }
    }
    
    func logout() {
        try? Auth.auth().signOut()
        self.currentUser = nil
        self.authToken = nil
    }
    
    private func mapUserToAuthUser(user: User) -> AuthUser {
         let dateFormatter = ISO8601DateFormatter()
         dateFormatter.formatOptions = [.withFullDate]
         
         return AuthUser(
             id: user.id,
             username: user.username,
             email: Auth.auth().currentUser?.email ?? user.username,
             displayName: user.displayName,
             dateOfBirth: dateFormatter.string(from: user.dateOfBirth),
             gender: user.gender.rawValue,
             country: user.country,
             city: user.city,
             bio: user.bio ?? "",
             profilePhotoUrl: user.profilePhotoURL,
             zodiacSign: "Leo",
             instagramUsername: user.socialLinks?.instagram?.username,
             tiktokUsername: user.socialLinks?.tiktok?.username,
             snapchatUsername: user.socialLinks?.snapchat?.username,
             isPremium: user.isPremium,
             isVerified: user.isVerified,
             createdAt: ISO8601DateFormatter().string(from: user.createdAt)
         )
    }
}

// MARK: - AuthError Definition
enum AuthError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(String)
    case notAuthenticated
    case validationError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response from server"
        case .serverError(let message): return message
        case .notAuthenticated: return "Oturum açılmadı"
        case .validationError(let message): return message
        }
    }
}
