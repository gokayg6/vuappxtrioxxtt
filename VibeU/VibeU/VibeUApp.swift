import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Configure Firestore settings
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        Firestore.firestore().settings = settings
        
        return true
    }
    
    // MARK: - Phone Auth Notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
        completionHandler(.newData)
    }
}

@main
struct VibeUApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @State private var appState = AppState()
    @State private var deepLinkUserId: String?
    @State private var deepLinkUser: DiscoverUser?
    @State private var showDeepLinkProfile: Bool = false
    @State private var isLoadingDeepLink: Bool = false
    @Environment(\.colorScheme) private var systemColorScheme
    
    private var activeTheme: ThemeColors {
        switch appState.currentTheme {
        case .dark: return .dark
        case .light: return .light
        case .system: return systemColorScheme == .dark ? .dark : .light
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .onOpenURL { url in
                    // Handle Google Sign In
                    if GIDSignIn.sharedInstance.handle(url) {
                        return
                    }
                    
                    // Handle Deep Links
                    handleDeepLink(url)
                }
                .sheet(isPresented: $showDeepLinkProfile) {
                    if let user = deepLinkUser {
                        NavigationStack {
                            ProfileDetailView(user: user)
                        }
                        .environment(appState)
                        .environment(\.themeColors, activeTheme)
                    }
                }
                .overlay {
                    if isLoadingDeepLink {
                        ZStack {
                            Color.black.opacity(0.5)
                                .ignoresSafeArea()
                            
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.cyan)
                                
                                Text("Profil yükleniyor...")
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                            }
                            .padding(24)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
        }
    }
    
    // MARK: - Deep Link Handler
    // Requirements: 7.3, 7.6 - Handle vibeu://profile/{userId} deep links
    
    private func handleDeepLink(_ url: URL) {
        // Safety check: only handle vibeu:// scheme
        guard url.scheme == "vibeu" else { return }
        
        // Delay processing to ensure app is fully initialized
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.processDeepLink(url)
        }
    }
    
    private func processDeepLink(_ url: URL) {
        // Parse vibeu://profile/{userId} format
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        
        // Check for profile deep link: vibeu://profile/{userId}
        guard url.host == "profile" || (pathComponents.first == "profile" && pathComponents.count >= 2) else {
            return
        }
        
        let userId: String
        
        if url.host == "profile" {
            // Format: vibeu://profile/{userId} where userId is in path
            userId = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        } else {
            // Format: vibeu://profile/{userId} where profile is first path component
            userId = pathComponents[1]
        }
        
        guard !userId.isEmpty else { return }
        
        // Fetch user profile and navigate
        Task { @MainActor in
            await self.fetchAndShowProfile(userId: userId)
        }
    }
    
    @MainActor
    private func fetchAndShowProfile(userId: String) async {
        // Safety: Only proceed if user is authenticated
        guard appState.authState == .authenticated else {
            // Store the userId to navigate after authentication
            deepLinkUserId = userId
            print("⚠️ Deep link received but not authenticated, storing for later: \(userId)")
            return
        }
        
        // Prevent multiple simultaneous requests
        guard !isLoadingDeepLink else { return }
        
        isLoadingDeepLink = true
        
        do {
            let user = try await UserService.shared.getProfileById(userId)
            let discoverUser = DiscoverUser(user: user)
            deepLinkUser = discoverUser
            isLoadingDeepLink = false
            showDeepLinkProfile = true
        } catch {
            isLoadingDeepLink = false
            print("❌ Failed to load profile: \(error)")
            // Don't crash - just silently fail
        }
    }
}
