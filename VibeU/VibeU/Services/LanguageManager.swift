import Foundation
import SwiftUI

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "appLanguage")
        }
    }
    
    init() {
        self.currentLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "tr"
    }
    
    var locale: Locale {
        return Locale(identifier: currentLanguage)
    }
    
    func setLanguage(_ language: String) {
        withAnimation {
            currentLanguage = language
        }
    }
}
