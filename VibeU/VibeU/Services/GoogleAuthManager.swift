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
                
                GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let user = result?.user,
                          let idToken = user.idToken?.tokenString else {
                        continuation.resume(throwing: NSError(domain: "GoogleAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get tokens"]))
                        return
                    }
                    
                    continuation.resume(returning: (idToken, user.accessToken.tokenString, user))
                }
            }
        }
    }
}
