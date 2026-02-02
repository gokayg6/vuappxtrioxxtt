import SwiftUI
import Observation
import FirebaseAuth

enum AuthState: Equatable {
    case loading
    case onboarding
    case unauthenticated
    case authenticated
    case needsProfileSetup // Yeni durum - kayıt sonrası profil tamamlama
}

enum AppTheme: String, CaseIterable {
    case dark = "dark"
    case light = "light"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .dark: return "Koyu"
        case .light: return "Açık"
        case .system: return "Sistem"
        }
    }
    
    var icon: String {
        switch self {
        case .dark: return "moon.fill"
        case .light: return "sun.max.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .dark: return .dark
        case .light: return .light
        case .system: return nil
        }
    }
}

enum AppLanguage: String, CaseIterable {
    case turkish = "tr"
    case english = "en"
    case spanish = "es"
    case portuguese = "pt"
    case french = "fr"
    
    var displayName: String {
        switch self {
        case .turkish: return "Türkçe"
        case .english: return "English"
        case .spanish: return "Español"
        case .portuguese: return "Português"
        case .french: return "Français"
        }
    }
    
    var flag: String {
        switch self {
        case .turkish: return "🇹🇷"
        case .english: return "🇺🇸"
        case .spanish: return "🇪🇸"
        case .portuguese: return "🇧🇷"
        case .french: return "🇫🇷"
        }
    }
    
    var locale: Locale {
        Locale(identifier: rawValue)
    }
}

// MARK: - Localization Bundle Override
nonisolated(unsafe) private var bundleKey: UInt8 = 0

final class LocalizedBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
              let bundle = Bundle(path: path) else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    static func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, LocalizedBundle.self)
        }
        objc_setAssociatedObject(Bundle.main, &bundleKey, Bundle.main.path(forResource: language, ofType: "lproj"), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

@Observable @MainActor
final class AppState {
    var authState: AuthState = .loading
    var currentUser: User?
    var showPremiumOnLaunch = false
    
    // Navigation
    var selectedTab: Int = 0
    var pendingConversation: Conversation?
    var shouldNavigateToChat: Bool = false
    var isTabBarHidden: Bool = false
    
    // New conversations created from matches
    var newConversations: [Conversation] = []
    
    // Theme
    var currentTheme: AppTheme {
        get {
            if let saved = UserDefaults.standard.string(forKey: "appTheme"),
               let theme = AppTheme(rawValue: saved) {
                return theme
            }
            return .dark
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "appTheme")
        }
    }
    
    // Language
    var currentLanguage: AppLanguage {
        get {
            if let saved = UserDefaults.standard.string(forKey: "appLanguage"),
               let lang = AppLanguage(rawValue: saved) {
                return lang
            }
            return .turkish
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "appLanguage")
            UserDefaults.standard.set([newValue.rawValue], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            Bundle.setLanguage(newValue.rawValue)
        }
    }
    
    // Language refresh trigger
    var languageRefreshId = UUID()
    
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        languageRefreshId = UUID()
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
    }
    
    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding") }
    }
    
    // MARK: - Profile Completeness Check
    // Property 14: Profile Completeness Check
    // Validates: Requirements 1.1, 1.2, 1.3
    // Zorunlu alanlar: displayName, dateOfBirth, gender, country, city, profilePhotoUrl
    var isProfileComplete: Bool {
        guard let user = currentUser else { return false }
        
        // Check displayName is not empty
        let hasDisplayName = !user.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // Check dateOfBirth is valid (not default/placeholder date)
        // A valid date should be in the past and user should be at least 15 years old
        let hasValidDateOfBirth = isValidDateOfBirth(user.dateOfBirth)
        
        // Check gender is set (any value is valid since we have preferNotToSay option)
        let hasGender = true // Gender is always set since it's an enum with default
        
        // Check country is not empty
        let hasCountry = !user.country.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // Check city is not empty
        let hasCity = !user.city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // Check profilePhotoURL is not empty and is a valid URL
        let hasProfilePhoto = !user.profilePhotoURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                              URL(string: user.profilePhotoURL) != nil
        
        return hasDisplayName && hasValidDateOfBirth && hasGender && hasCountry && hasCity && hasProfilePhoto
    }
    
    // Helper function to validate date of birth
    private func isValidDateOfBirth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        // Date should be in the past
        guard date < now else { return false }
        
        // Calculate age
        let ageComponents = calendar.dateComponents([.year], from: date, to: now)
        guard let age = ageComponents.year else { return false }
        
        // User must be at least 15 years old (per Requirements 1.4, 1.5)
        return age >= 15
    }
    
    var isPremium: Bool {
        get { 
            // Read from UserDefaults
            return UserDefaults.standard.bool(forKey: "isPremium")
        }
        set { 
            UserDefaults.standard.set(newValue, forKey: "isPremium")
            UserDefaults.standard.set(newValue, forKey: "user_isPremium")
        }
    }
    
    // Boost sistemi - 5 boost = kendini öne çıkarma
    var boostCount: Int {
        get { UserDefaults.standard.integer(forKey: "boostCount") }
        set { UserDefaults.standard.set(newValue, forKey: "boostCount") }
    }
    
    func useBoost(count: Int = 5) -> Bool {
        guard boostCount >= count else { return false }
        boostCount -= count
        return true
    }
    
    func addBoosts(_ count: Int) {
        boostCount += count
    }
    
    var hasSkippedPremium: Bool {
        get { UserDefaults.standard.bool(forKey: "hasSkippedPremium") }
        set { UserDefaults.standard.set(newValue, forKey: "hasSkippedPremium") }
    }
    
    // Remember login
    var isLoggedIn: Bool {
        get { UserDefaults.standard.bool(forKey: "isLoggedIn") }
        set { UserDefaults.standard.set(newValue, forKey: "isLoggedIn") }
    }
    
    init() {
        // Load saved language
        Bundle.setLanguage(currentLanguage.rawValue)
        checkAuthState()
        
        // Start location services
        Task { @MainActor in
            LocationManager.shared.requestLocationPermission()
        }
    }
    
    func checkAuthState() {
        Task {
            try? await Task.sleep(for: .seconds(1))
            
            print("🔐 [AppState] Checking auth state...")
            
            // Check if AuthService has a token
            if AuthService.shared.isAuthenticated {
                print("✅ [AppState] User is authenticated")
                do {
                    // Get user from backend
                    currentUser = try await AuthService.shared.getCurrentUser()
                    print("✅ [AppState] User loaded: \(currentUser?.displayName ?? "Unknown")")
                    authState = .authenticated
                    isLoggedIn = true
                    checkPremiumStatus()
                    return
                } catch {
                    // Token expired or invalid
                    print("❌ [AppState] Failed to load user: \(error.localizedDescription)")
                    AuthService.shared.clearAuth()
                    authState = .unauthenticated
                    isLoggedIn = false
                }
            } else if !hasCompletedOnboarding {
                print("📱 [AppState] Showing onboarding")
                authState = .onboarding
            } else {
                print("🔓 [AppState] User not authenticated")
                authState = .unauthenticated
            }
        }
    }
    
    func checkPremiumStatus() {
        // Premium değilse ve daha önce geçmediyse göster
        if !isPremium && !hasSkippedPremium {
            showPremiumOnLaunch = true
        }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        authState = .unauthenticated
    }
    
    func signIn(user: User, accessToken: String, refreshToken: String) {
        var finalToken = accessToken
        #if DEBUG
        // In debug mode, if we don't have a real JWT, use the special ID format
        // so backend knows who we are (instead of assuming test-user-1)
        finalToken = "firebase_uid_" + user.id
        print("🔧 [AppState] Using debug token: \(finalToken)")
        #endif
        
        KeychainManager.shared.saveAccessToken(finalToken)
        KeychainManager.shared.saveRefreshToken(refreshToken)
        currentUser = user
        isLoggedIn = true
        
        // Check if user has completed onboarding (profile_completed_at exists)
        if user.profileCompletedAt == nil {
            print("📝 [AppState] User needs to complete onboarding")
            authState = .needsProfileSetup
        } else {
            print("✅ [AppState] User profile is complete")
            authState = .authenticated
            checkPremiumStatus()
        }
        
        // Sync user to backend database for friend requests
        Task {
            await syncUserToBackend(user: user)
        }
    }
    
    private func syncUserToBackend(user: User) async {
        do {
            let dateFormatter = ISO8601DateFormatter()
            
            struct SyncUserBody: Codable {
                let userId: String
                let displayName: String
                let email: String
                let profilePhotoUrl: String?
                let dateOfBirth: String
                let gender: String
                let country: String
                let city: String
            }
            
            let body = SyncUserBody(
                userId: user.id,
                displayName: user.displayName,
                email: user.username,
                profilePhotoUrl: user.profilePhotoURL,
                dateOfBirth: dateFormatter.string(from: user.dateOfBirth),
                gender: user.gender.rawValue,
                country: user.country,
                city: user.city
            )
            
            try await APIClient.shared.requestVoid(
                endpoint: "/auth/sync",
                method: .post,
                body: body,
                requiresAuth: false
            )
            print("✅ User synced to backend: \(user.id)")
        } catch {
            print("⚠️ Failed to sync user to backend: \(error)")
        }
    }
    
    func signOut() {
        // AuthService'den çıkış
        AuthService.shared.logout()
        
        // Firebase'den çıkış
        try? Auth.auth().signOut()
        
        // Keychain temizle
        KeychainManager.shared.deleteTokens()
        
        // Tüm kullanıcı verilerini temizle (ProfileKeys)
        let userKeys = [
            "user_displayName",
            "user_bio",
            "user_city",
            "user_jobTitle",
            "user_interests",
            "user_instagram",
            "user_tiktok",
            "user_snapchat",
            "user_twitter",
            "user_spotify",
            "user_photos",
            "user_superLikes",
            "user_boosts",
            "user_isPremium",
            "isPremium",
            "boostCount",
            "hasSkippedPremium",
            "isLoggedIn",
            // Safety settings
            "safety_hideAge",
            "safety_hideDistance",
            "safety_hideOnlineStatus",
            "safety_readReceipts",
            // Filter settings
            "filter_minAge",
            "filter_maxAge",
            "filter_maxDistance",
            "filter_verifiedOnly",
            "filter_onlineOnly",
            "filter_withPhoto",
            "filter_withBio",
            // Notification settings
            "notifications_enabled",
            "location_enabled"
        ]
        
        for key in userKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
        
        // State temizle
        currentUser = nil
        isLoggedIn = false
        hasSkippedPremium = false
        showPremiumOnLaunch = false
        newConversations = []
        pendingConversation = nil
        shouldNavigateToChat = false
        selectedTab = 0
        
        authState = .unauthenticated
        
        Task {
            await LogService.shared.info("Kullanıcı çıkış yaptı - tüm veriler temizlendi", category: "Auth")
        }
    }
    
    func purchasePremium() {
        isPremium = true
        hasSkippedPremium = true
        showPremiumOnLaunch = false
    }
    
    func skipPremium() {
        hasSkippedPremium = true
        showPremiumOnLaunch = false
    }
    
    // Create new conversation from match
    func createConversationFromMatch(name: String, age: Int, city: String, photoURL: String, compatibility: Int) {
        let newConversation = Conversation(
            id: "match_\(UUID().uuidString)",
            participant: ChatParticipant(
                id: UUID().uuidString,
                displayName: name,
                profilePhotoURL: photoURL,
                isOnline: true,
                lastActiveAt: Date()
            ),
            lastMessage: ChatMessage(
                id: UUID().uuidString,
                conversationId: "match_\(UUID().uuidString)",
                senderId: "system",
                content: "🎉 %\(compatibility) uyum ile eşleştiniz!",
                messageType: .text,
                isRead: false,
                createdAt: Date()
            ),
            unreadCount: 1,
            updatedAt: Date()
        )
        
        newConversations.insert(newConversation, at: 0)
        pendingConversation = newConversation
        shouldNavigateToChat = true
        selectedTab = 3 // Chat tab
    }
    
    // MARK: - Discover Users Cache
    var cachedDiscoverUsers: [DiscoverUser] = []
    var lastDiscoverFetch: Date?
    
    func prefetchDiscoverUsers() {
        Task {
            do {
                let response = try await DiscoverService.shared.getDiscoverFeed(
                    mode: .forYou,
                    limit: 50,
                    countryFilter: nil
                )
                await MainActor.run {
                    self.cachedDiscoverUsers = response.users
                    self.lastDiscoverFetch = Date()
                }
                print("✅ Prefetched \(response.users.count) discover users")
            } catch {
                print("⚠️ Failed to prefetch discover users: \(error)")
            }
        }
    }
    
    func shouldRefreshDiscoverCache() -> Bool {
        guard let lastFetch = lastDiscoverFetch else { return true }
        return Date().timeIntervalSince(lastFetch) > 300 // 5 minutes
    }
}
