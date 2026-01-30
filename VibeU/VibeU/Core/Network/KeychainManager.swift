import Foundation
import Security

final class KeychainManager: @unchecked Sendable {
    static let shared = KeychainManager()
    
    private let accessTokenKey = "com.vibeu.accessToken"
    private let refreshTokenKey = "com.vibeu.refreshToken"
    
    private init() {}
    
    func saveAccessToken(_ token: String) {
        save(key: accessTokenKey, value: token)
    }
    
    func saveRefreshToken(_ token: String) {
        save(key: refreshTokenKey, value: token)
    }
    
    func getAccessToken() -> String? {
        return get(key: accessTokenKey)
    }
    
    func getRefreshToken() -> String? {
        return get(key: refreshTokenKey)
    }
    
    func deleteTokens() {
        delete(key: accessTokenKey)
        delete(key: refreshTokenKey)
    }
    
    private func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
