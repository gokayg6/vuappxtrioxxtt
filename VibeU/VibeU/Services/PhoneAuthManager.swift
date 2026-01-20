import Foundation
import FirebaseAuth

actor PhoneAuthManager {
    static let shared = PhoneAuthManager()
    
    func sendOTP(phone: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { verificationID, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let verificationID = verificationID else {
                    continuation.resume(throwing: NSError(domain: "PhoneAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Verification ID alınamadı"]))
                    return
                }
                
                continuation.resume(returning: verificationID)
            }
        }
    }
    
    func verifyOTP(verificationID: String, otp: String) async throws -> String {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: otp
        )
        
        let authResult = try await Auth.auth().signIn(with: credential)
        
        let token = try await authResult.user.getIDToken()
        return token
    }
}
