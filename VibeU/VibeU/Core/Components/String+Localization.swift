import Foundation
import SwiftUI

// MARK: - Direct Localization Extension
// This bypasses standard Bundle localization to guarantee text changes immediately
// based on ManualTranslations in AppState.swift

extension String {
    var localized: String {
        let language = UserDefaults.standard.string(forKey: "appLanguage") ?? "tr"
        // Try manual translation first
        if let translated = ManualTranslations.translate(key: self, language: language) {
            return translated
        }
        // Fallback to self
        return self
    }
}
