import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: MainTab = .home
    @State private var notificationCount = 3
    @State private var likesCount = 5
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    
    // Animation states
    @State private var starScale: CGFloat = 1.0
    @State private var starRotation: Double = 0
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    
    init() {
        // Revert hidden tab bar
        UITabBar.appearance().isHidden = false
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Keşfet (Tinder Style Swipe)
            DiscoverView()
                .tabItem {
                    TabIcon(name: "sparkles", isSelected: selectedTab == .home, isDark: isDark)
                    Text("Keşfet")
                }
                .tag(MainTab.home)
            
            // Göz At (Grid View) - Pusula ikonu
            ExploreViewNew()
                .tabItem {
                    TabIcon(name: "safari", isSelected: selectedTab == .explore, isDark: isDark)
                    Text("Göz At")
                }
                .tag(MainTab.explore)
            
            // Beğenenler - Kalp ikonu
            FavoritesView()
                .tabItem {
                    TabIcon(name: "heart", isSelected: selectedTab == .likes, isDark: isDark)
                    Text("Beğenenler")
                }
                .tag(MainTab.likes)
                .badge(likesCount > 0 ? likesCount : 0)
            
            // Arkadaşlar - İki kişi ikonu
            FriendsView()
                .tabItem {
                    TabIcon(name: "person.2", isSelected: selectedTab == .friends, isDark: isDark)
                    Text("Arkadaşlar")
                }
                .tag(MainTab.friends)
            
            // Profil
            ProfileView()
                .tabItem {
                    TabIcon(name: "person", isSelected: selectedTab == .profile, isDark: isDark)
                    Text("Profil")
                }
                .tag(MainTab.profile)
        }
        .tint(isDark ? .white : .black)
        .onAppear {
            configureTabBarAppearance()
        }
        .onChange(of: appState.currentTheme) { _, _ in
            configureTabBarAppearance()
        }
        .onChange(of: systemColorScheme) { _, _ in
            if appState.currentTheme == .system {
                configureTabBarAppearance()
            }
        }
        .task {
            await loadCounts()
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        
        if isDark {
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(red: 0.06, green: 0.04, blue: 0.1, alpha: 1)
            
            // Normal state
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(white: 0.5, alpha: 1)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(white: 0.5, alpha: 1)]
            
            // Selected state
            appearance.stackedLayoutAppearance.selected.iconColor = .white
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        } else {
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.shadowColor = UIColor(white: 0.9, alpha: 1)
            
            // Normal state - açık gri stroke görünümü
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1)]
            
            // Selected state - siyah fill
            appearance.stackedLayoutAppearance.selected.iconColor = .black
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.black]
        }
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func loadCounts() async {
        do {
            // Load likes count from service if available
            // For now using static value
        } catch {
            print("Failed to load counts: \(error)")
        }
    }
}

enum MainTab: String, CaseIterable {
    case home
    case explore
    case likes
    case friends
    case profile
}

#Preview {
    MainTabView()
        .environment(AppState())
}


// MARK: - Likes View
struct MainLikesView: View {
    @State private var selectedUser: DiscoverUser?
    @State private var showPremiumSheet = false
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    private let likedYouUsers = DiscoverUser.likedYouUsers
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                colors.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        if !appState.isPremium {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(colors: [.pink, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 70, height: 70)
                                    
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 32))
                                        .foregroundStyle(.white)
                                }
                                
                                Text("\(likedYouUsers.count) kişi seni beğendi")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(colors.primaryText)
                                
                                Text("Premium ile kimlerin beğendiğini gör")
                                    .font(.system(size: 14))
                                    .foregroundStyle(colors.secondaryText)
                            }
                            .padding(.top, 20)
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            ForEach(likedYouUsers) { user in
                                MainLikesCardView(user: user, isBlurred: !appState.isPremium, colors: colors) {
                                    if appState.isPremium {
                                        selectedUser = user
                                    } else {
                                        showPremiumSheet = true
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        
                        if !appState.isPremium {
                            Color.clear.frame(height: 100)
                        }
                    }
                }
                
                if !appState.isPremium {
                    Button {
                        showPremiumSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 18))
                            Text("Seni kimlerin beğendiğini gör")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(isDark ? colors.background : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient(colors: isDark ? [.white, Color(white: 0.9)] : [.black, Color(white: 0.2)], startPoint: .top, endPoint: .bottom))
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 90)
                }
            }
            .navigationTitle("Beğenenler")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
            .navigationDestination(item: $selectedUser) { user in
                ProfileDetailView(user: user)
            }
            .sheet(isPresented: $showPremiumSheet) {
                SubscriptionSheet()
            }
        }
    }
}

// MARK: - Likes Card View
struct MainLikesCardView: View {
    let user: DiscoverUser
    let isBlurred: Bool
    let colors: ThemeColors
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Rectangle().fill(colors.secondaryBackground)
                    }
                }
                .frame(height: 200)
                .clipped()
                .blur(radius: isBlurred ? 20 : 0)
                
                LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(user.displayName).font(.system(size: 15, weight: .bold))
                        Text("\(user.age)").font(.system(size: 14))
                    }
                    .foregroundStyle(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill").font(.system(size: 10))
                        Text(user.city).font(.system(size: 11))
                    }
                    .foregroundStyle(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                
                if isBlurred {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tab Icon Helper
struct TabIcon: View {
    let name: String
    let isSelected: Bool
    let isDark: Bool
    
    var body: some View {
        Image(systemName: iconName)
            .environment(\.symbolVariants, .none)
    }
    
    private var iconName: String {
        // Always return filled icon
        switch name {
        case "sparkles": return "sparkles"
        case "safari": return "safari.fill"
        case "heart": return "heart.fill"
        case "person.2": return "person.2.fill"
        case "person": return "person.fill"
        default: return name + ".fill"
        }
    }
}
