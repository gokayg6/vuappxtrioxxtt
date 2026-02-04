import Foundation
import GoogleSignIn

actor GoogleAuthManager {
    static let shared = GoogleAuthManager()
    
    func signIn() async throws -> (String, String, GIDGoogleUser) {
        return try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let rootViewController = windowScene.windows.first?.rootViewController else {
                    continuation.resume(throwing: NSError(domain: "GoogleAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller"]))
                    return
                }
                
                do {
                    let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
                    let user = result.user
                    guard let idToken = user.idToken?.tokenString else {
                         continuation.resume(throwing: NSError(domain: "GoogleAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get tokens"]))
                         return
                    }
                    continuation.resume(returning: (idToken, user.accessToken.tokenString, user))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
