import SwiftUI
import AuthenticationServices

@Observable @MainActor
final class AuthViewModel {
    var showError = false
    var errorMessage = ""
    var isLoading = false
    
    // Phone Auth
    var verificationID: String?
    
    // MARK: - Email Auth
    
    func login(email: String, password: String, isRemember: Bool = true, appState: AppState) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let authData = try await AuthService.shared.login(email: email, password: password)
            
            // If remember me is false, maybe we could clear persistence later, but for now we persist.
            // In a real app we might use a session token vs persistent token.
            
            appState.signIn(
                user: authData.user.toUser()!,
                accessToken: authData.token,
                refreshToken: authData.token
            )
        } catch {
            showError(message: error.localizedDescription)
        }
    }
    
    func register(data: RegistrationData, appState: AppState) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let authData = try await AuthService.shared.register(data: data)
            
            appState.signIn(
                user: authData.user.toUser()!,
                accessToken: authData.token,
                refreshToken: authData.token
            )
        } catch {
            showError(message: error.localizedDescription)
        }
    }

    // MARK: - Google Sign In
    
    func signInWithGoogle(appState: AppState) {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let (idToken, accessToken, googleUser) = try await GoogleAuthManager.shared.signIn()
                
                // Extract user info on main actor before passing to actor
                let email = googleUser.profile?.email ?? "user@gmail.com"
                let name = googleUser.profile?.name ?? "Google User"
                let photoURL = googleUser.profile?.imageURL(withDimension: 400)?.absoluteString ?? "https://picsum.photos/400/600"
                
                let response = try await AuthService.shared.signInWithGoogle(
                    idToken: idToken,
                    accessToken: accessToken,
                    email: email,
                    name: name,
                    photoURL: photoURL
                )
                
                appState.signIn(
                    user: response.user,
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
            } catch {
                showError(message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Phone Auth
    
    func sendOTP(phone: String) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        do {
            verificationID = try await PhoneAuthManager.shared.sendOTP(phone: phone)
            return true
        } catch {
            showError(message: error.localizedDescription)
            return false
        }
    }
    
    func verifyOTP(otp: String, appState: AppState) async -> Bool {
        guard let verificationID = verificationID else {
            showError(message: "Doğrulama ID bulunamadı")
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let token = try await PhoneAuthManager.shared.verifyOTP(
                verificationID: verificationID,
                otp: otp
            )
            
            let response = try await AuthService.shared.authenticateWithBackend(firebaseToken: token)
            
            appState.signIn(
                user: response.user,
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
            )
            
            return true
        } catch {
            showError(message: error.localizedDescription)
            return false
        }
    }
    
    // MARK: - Apple Sign In
    
    func handleAppleSignIn(result: Result<ASAuthorization, Error>, appState: AppState) {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityTokenData = appleIDCredential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8),
                  let authorizationCodeData = appleIDCredential.authorizationCode,
                  let authorizationCode = String(data: authorizationCodeData, encoding: .utf8) else {
                showError(message: "Apple kimlik bilgileri alınamadı")
                return
            }
            
            var fullName: String?
            if let givenName = appleIDCredential.fullName?.givenName {
                fullName = givenName
                if let familyName = appleIDCredential.fullName?.familyName {
                    fullName = "\(givenName) \(familyName)"
                }
            }
            
            Task {
                await signInWithApple(
                    identityToken: identityToken,
                    authorizationCode: authorizationCode,
                    fullName: fullName,
                    appState: appState
                )
            }
            
        case .failure(let error):
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                showError(message: error.localizedDescription)
            }
        }
    }
    
    private func signInWithApple(
        identityToken: String,
        authorizationCode: String,
        fullName: String?,
        appState: AppState
    ) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await AuthService.shared.signInWithApple(
                identityToken: identityToken,
                authorizationCode: authorizationCode,
                fullName: fullName
            )
            
            appState.signIn(
                user: response.user,
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
            )
        } catch {
            showError(message: error.localizedDescription)
        }
    }
    
    // MARK: - Guest Sign In
    
    func signInAsGuest(appState: AppState) {
        let mockUser = User.mockGuest()
        appState.signIn(
            user: mockUser,
            accessToken: "mock_access_token",
            refreshToken: "mock_refresh_token"
        )
    }
    
    // MARK: - Links
    
    func openTerms() {
        if let url = URL(string: "https://vibeu.app/terms") {
            UIApplication.shared.open(url)
        }
    }
    
    func openPrivacy() {
        if let url = URL(string: "https://vibeu.app/privacy") {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Error Handling
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
