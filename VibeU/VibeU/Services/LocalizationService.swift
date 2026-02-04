import Foundation
import SwiftUI

/// LocalizationService - Handles runtime language switching
/// Works with both .lproj folders and Localizable.xcstrings
class LocalizationService: ObservableObject {
    static let shared = LocalizationService()
    
    @Published private(set) var currentLanguageCode: String
    @Published private(set) var bundle: Bundle = .main
    
    // Notification for language change
    static let languageDidChangeNotification = Notification.Name("LanguageDidChange")
    
    private init() {
        // Load saved language or use system default
        if let saved = UserDefaults.standard.string(forKey: "appLanguage") {
            currentLanguageCode = saved
        } else {
            // Get system preferred language
            let preferredLang = Locale.preferredLanguages.first ?? "en"
            currentLanguageCode = String(preferredLang.prefix(2))
        }
        
        loadBundle(for: currentLanguageCode)
    }
    
    /// Set the app language
    func setLanguage(_ languageCode: String) {
        guard currentLanguageCode != languageCode else { return }
        
        currentLanguageCode = languageCode
        
        // Save to UserDefaults
        UserDefaults.standard.set(languageCode, forKey: "appLanguage")
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Load the new bundle
        loadBundle(for: languageCode)
        
        // Apply to Bundle.main via swizzling
        applyLanguageToBundle(languageCode)
        
        // Post notification for any listeners
        NotificationCenter.default.post(name: LocalizationService.languageDidChangeNotification, object: nil)
    }
    
    /// Load the bundle for a specific language
    private func loadBundle(for languageCode: String) {
        // Try to find .lproj folder
        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            self.bundle = bundle
        } else if let path = Bundle.main.path(forResource: "Base", ofType: "lproj"),
                  let bundle = Bundle(path: path) {
            // Fallback to Base
            self.bundle = bundle
        } else {
            // Use main bundle
            self.bundle = .main
        }
    }
    
    /// Apply language via Bundle swizzling (more aggressive approach)
    private func applyLanguageToBundle(_ languageCode: String) {
        // This uses the Bundle extension defined in AppState.swift
        Bundle.setLanguage(languageCode)
    }
    
    /// Get localized string using the current bundle
    func localizedString(for key: String, defaultValue: String? = nil) -> String {
        let value = bundle.localizedString(forKey: key, value: defaultValue ?? key, table: nil)
        // If we got the key back, try main bundle
        if value == key {
            return Bundle.main.localizedString(forKey: key, value: defaultValue ?? key, table: nil)
        }
        return value
    }
    
    /// Check if language bundle exists
    func isLanguageSupported(_ languageCode: String) -> Bool {
        return Bundle.main.path(forResource: languageCode, ofType: "lproj") != nil
    }
}

// MARK: - String Extension for Easy Localization
extension String {
    /// Get localized version of this string
    var localized: String {
        return LocalizationService.shared.localizedString(for: self)
    }
    
    /// Get localized string with arguments
    func localized(with arguments: CVarArg...) -> String {
        let format = LocalizationService.shared.localizedString(for: self)
        return String(format: format, arguments: arguments)
    }
}

// MARK: - View Modifier for Language Changes
struct LocalizationRefreshModifier: ViewModifier {
    @State private var refreshId = UUID()
    
    func body(content: Content) -> some View {
        content
            .id(refreshId)
            .onReceive(NotificationCenter.default.publisher(for: LocalizationService.languageDidChangeNotification)) { _ in
                // Force view refresh when language changes
                refreshId = UUID()
            }
    }
}

extension View {
    /// Apply this modifier to refresh view when language changes
    func refreshOnLanguageChange() -> some View {
        modifier(LocalizationRefreshModifier())
    }
}
