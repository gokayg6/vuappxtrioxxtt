import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Beğenenler View (Premium Clean Redesign)

struct FavoritesView: View {
    @State private var selectedTab: LikesTab = .likes
    @State private var likedByUsers: [LikeUser] = []
    @State private var topPickUsers: [LikeUser] = []
    @State private var showPremiumSheet = false
    @State private var hasTriggeredPremium = false
    @State private var selectedUser: DiscoverUser? // For navigation
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
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background - Clean System Background
                colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Clean Tab Selector
                    glassTabSelector
                        .padding(.top, 10)
                        .padding(.bottom, 16)
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        // Beğeni Tab (Seni Beğenenler)
                        likesTabContent
                            .tag(LikesTab.likes)
                        
                        // En Seçkin Profiller Tab
                        topPicksTabContent
                            .tag(LikesTab.topPicks)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Beğenenler".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
            .sheet(isPresented: $showPremiumSheet) {
                SubscriptionSheet()
            }
            .fullScreenCover(item: $selectedUser) { user in
                ProfileDetailView(user: user)
            }
            .onAppear { loadData() }
            .onChange(of: selectedTab) { _, _ in
                hasTriggeredPremium = false
            }
        }
    }
    
    // MARK: - Glass Tab Selector
    private var glassTabSelector: some View {
        HStack(spacing: 0) {
            tabButton(title: "Beğeniler".localized, count: likedByUsers.count, tab: .likes)
            tabButton(title: "Seçkinler".localized, count: topPickUsers.count, tab: .topPicks)
        }
        .padding(4)
        .background(
            Capsule()
                .fill(isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                .background(.ultraThinMaterial, in: Capsule())
        )
        .padding(.horizontal, 16)
    }
    
    private func tabButton(title: String, count: Int, tab: LikesTab) -> some View {
        let isSelected = selectedTab == tab
        
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isSelected ? (isDark ? Color.black.opacity(0.2) : Color.white.opacity(0.3)) : Color.gray.opacity(0.2))
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? (isDark ? Color.white : Color.black) : Color.clear)
            )
            .foregroundStyle(isSelected ? (isDark ? Color.black : Color.white) : colors.secondaryText)
        }
    }
    
    // MARK: - Likes Tab Content
    private var likesTabContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Premium Banner if not Premium
                if !appState.isPremium {
                    premiumUpsellCard(
                        title: "Seni Beğenenleri Gör".localized,
                        subtitle: "Gold üyeler seni beğenen herkesi anında görür ve eşleşir.".localized,
                        icon: "heart.fill",
                        color: .pink
                    )
                    .padding(.horizontal, 16)
                }
                
                // Real Data Grid
                if likedByUsers.isEmpty {
                    emptyStateView(
                        icon: "star.slash",
                        title: "Henüz Superlike Yok".localized,
                        subtitle: "Seni çok beğenen özel biri olduğunda burada görünecek.".localized
                    )
                    .padding(.top, 40)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 16) {
                        ForEach(likedByUsers) { user in
                            LikeCardView(
                                user: user,
                                isBlurred: !appState.isPremium,
                                showStar: user.isSuperLike, // Show star if superlike
                                colors: colors
                            ) {
                                if appState.isPremium {
                                    openProfile(user)
                                } else {
                                    showPremiumSheet = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                Spacer().frame(height: 100)
            }
            .padding(.top, 16)
        }
        .overlay(alignment: .bottom) {
            if !appState.isPremium {
                premiumFloatButton(
                    text: "Seni Kimlerin Beğendiğini Gör".localized,
                    icon: "eye.fill"
                )
            }
        }
    }
    
    // MARK: - Top Picks Tab Content
    private var topPicksTabContent: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    if !appState.isPremium {
                        premiumUpsellCard(
                            title: "En Seçkin Profiller".localized,
                            subtitle: "Sana özel seçilmiş en popüler kullanıcılarla tanış.".localized,
                            icon: "star.fill",
                            color: .yellow
                        )
                        .padding(.horizontal, 16)
                    }
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 16) {
                        ForEach(Array(topPickUsers.enumerated()), id: \.element.id) { index, user in
                            LikeCardView(
                                user: user,
                                isBlurred: index >= 6,
                                showStar: true,
                                showTimeLeft: true,
                                colors: colors
                            ) {
                                if index >= 6 {
                                    showPremiumSheet = true
                                } else {
                                    openProfile(user)
                                }
                            }
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onChange(of: geo.frame(in: .global).minY) { _, newY in
                                            if index >= 6 && !hasTriggeredPremium && !appState.isPremium {
                                                let screenHeight = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.height ?? 800
                                                if newY < screenHeight * 0.6 && newY > 0 {
                                                    hasTriggeredPremium = true
                                                    showPremiumSheet = true
                                                }
                                            }
                                        }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer().frame(height: 120)
                }
                .padding(.top, 16)
            }
            
            // Bottom gradient fade
             if !appState.isPremium {
                VStack {
                    Spacer()
                    LinearGradient(
                        colors: [
                            .clear,
                            colors.background.opacity(0.8),
                            colors.background
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 150)
                    .allowsHitTesting(false)
                }
            }
            
            // Premium Button Overlay
            if !appState.isPremium {
                VStack {
                    Spacer()
                    premiumFloatButton(
                        text: "EN SEÇKİN PROFİLLERİ AÇ".localized,
                        icon: "crown.fill",
                        isGold: true
                    )
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func premiumUpsellCard(title: String, subtitle: String, icon: String, color: Color) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        )
    }
    
    private func emptyStateView(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(Color.gray.opacity(0.5))
            
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(colors.primaryText)
            
            Text(subtitle)
                .font(.body)
                .foregroundStyle(colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
    
    private func premiumFloatButton(text: String, icon: String, isGold: Bool = false) -> some View {
        Button {
            showPremiumSheet = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                
                Text(text)
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: isGold ? 
                        [Color(red: 1, green: 0.85, blue: 0.4), Color(red: 1, green: 0.75, blue: 0.25)] : // Gold
                        [Color(red: 1, green: 0.85, blue: 0.4), Color(red: 1, green: 0.75, blue: 0.25)], 
                    startPoint: .top,
                    endPoint: .bottom
                ),
                in: Capsule()
            )
            .shadow(color: .orange.opacity(0.4), radius: 12, y: 4)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 30)
    }
    
    // MARK: - Logic
    
    private func openProfile(_ user: LikeUser) {
        let photos = [UserPhoto(id: UUID().uuidString, url: user.photo, thumbnailURL: user.photo, orderIndex: 0, isPrimary: true)]
        
        let discoverUser = DiscoverUser(
            id: user.id,
            displayName: user.name,
            age: user.age,
            city: user.city,
            country: "TR",
            countryFlag: "🇹🇷",
            distanceKm: 2,
            profilePhotoURL: user.photo,
            photos: photos,
            tags: [],
            commonInterests: [],
            score: 100,
            isBoosted: false,
            tiktokUsername: nil,
            instagramUsername: nil,
            snapchatUsername: nil,
            isFriend: false
        )
        
        selectedUser = discoverUser
    }
    
    private func loadData() {
        Task {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let db = Firestore.firestore()
            
            do {
                // Fetch ONLY Superlikes (As requested: "Only when superlike... only then fall into likes")
                let likesSnapshot = try await db.collection("likes")
                    .whereField("toUserId", isEqualTo: uid)
                    .whereField("type", isEqualTo: "superlike")
                    .order(by: "createdAt", descending: true)
                    .limit(to: 30)
                    .getDocuments()
                
                var fetchedLikes: [LikeUser] = []
                
                for doc in likesSnapshot.documents {
                    let data = doc.data()
                    let fromUserId = data["fromUserId"] as? String ?? ""
                    let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    
                    if let userDoc = try? await db.collection("users").document(fromUserId).getDocument(),
                       let userData = userDoc.data() {
                        fetchedLikes.append(LikeUser(
                            id: doc.documentID,
                            name: userData["displayName"] as? String ?? "Kullanıcı",
                            age: userData["age"] as? Int ?? 0,
                            city: userData["city"] as? String ?? "",
                            photo: userData["profilePhotoURL"] as? String ?? "",
                            timeLeft: formatTimeAgo(createdAt),
                            bio: "Seni Superlike'ladı! ⭐".localized,
                            isSuperLike: true
                        ))
                    }
                }
                
                // Top Picks (Still Mock for now as it's a premium algorithm usually)
                let picks = DiscoverUser.mockUsers.sorted { $0.score > $1.score }.prefix(12).map { u in
                    LikeUser(id: u.id, name: u.displayName, age: u.age, city: u.city, photo: u.profilePhotoURL, timeLeft: "Popüler".localized, bio: "", isSuperLike: false)
                }
                
                await MainActor.run {
                    self.likedByUsers = fetchedLikes
                    self.topPickUsers = Array(picks)
                }
                
            } catch {
                print("Error loading likes: \(error)")
                await MainActor.run {
                    self.likedByUsers = []
                }
            }
        }
    }
    
    private func formatTimeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Az önce" }
        else if interval < 3600 { return "\(Int(interval / 60)) dk" }
        else if interval < 86400 { return "\(Int(interval / 3600)) sa" }
        else { return "\(Int(interval / 86400)) gn" }
    }
}

// MARK: - Like User Model
struct LikeUser: Identifiable {
    let id: String
    let name: String
    let age: Int
    let city: String
    let photo: String
    let timeLeft: String
    let bio: String
    let isSuperLike: Bool
}

// MARK: - Enums
enum LikesTab {
    case likes
    case topPicks
}

// MARK: - New Premium Like Card
struct LikeCardView: View {
    let user: LikeUser
    var isBlurred: Bool
    var showStar: Bool
    var showTimeLeft: Bool = false
    var colors: ThemeColors
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    // Image Layer
                    AsyncImage(url: URL(string: user.photo)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                                .blur(radius: isBlurred ? 15 : 0)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                        }
                    }
                    
                    // Gradient Overlay
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.6), .black.opacity(0.9)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    
                    // Content
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            if isBlurred {
                                CapsuledText(text: "Gizli".localized, color: .white.opacity(0.7))
                            } else {
                                Text("\(user.name), \(user.age)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            if showStar { // Superlike Indicator
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                    .font(.system(size: 14))
                                    .padding(4)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                        }
                        
                        if !isBlurred {
                            Text(user.city)
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        
                        if showTimeLeft {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 10))
                                Text(user.timeLeft)
                                    .font(.system(size: 11))
                            }
                            .foregroundStyle(.yellow.opacity(0.9))
                        }
                    }
                    .padding(12)
                    
                    // Lock Overlay
                    if isBlurred {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "lock.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                // Superlike Border
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(user.isSuperLike ? Color.yellow : Color.clear, lineWidth: user.isSuperLike ? 3 : 0)
                )
            }
            .aspectRatio(3/4, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(LinearGradient(colors: [.white.opacity(0.3), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
            )
        }
        .buttonStyle(FavoritesScaleButtonStyle())
    }
}

// MARK: - Helpers
struct CapsuledText: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial, in: Capsule())
    }
}

struct FavoritesScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    FavoritesView()
        .environment(AppState())
}
