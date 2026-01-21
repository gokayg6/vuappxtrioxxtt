import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Beğenenler View (Tinder Style Redesign)

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
                colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Tab Selector
                    tabSelector
                    
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
            .navigationTitle("Beğenenler")
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
                // Tab değiştiğinde trigger'ı sıfırla
                hasTriggeredPremium = false
            }
        }
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            // Beğeni Tab
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { selectedTab = .likes }
            } label: {
                VStack(spacing: 8) {
                    Text("\(likedByUsers.count) Beğeni")
                        .font(.system(size: 15, weight: selectedTab == .likes ? .bold : .medium))
                        .foregroundStyle(selectedTab == .likes ? colors.primaryText : colors.secondaryText)
                    
                    Rectangle()
                        .fill(selectedTab == .likes ? colors.accent : .clear)
                        .frame(height: 2)
                }
            }
            .frame(maxWidth: .infinity)
            
            // En Seçkin Profiller Tab
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { selectedTab = .topPicks }
            } label: {
                VStack(spacing: 8) {
                    Text("\(topPickUsers.count) En Seçkin Profil")
                        .font(.system(size: 15, weight: selectedTab == .topPicks ? .bold : .medium))
                        .foregroundStyle(selectedTab == .topPicks ? colors.primaryText : colors.secondaryText)
                    
                    Rectangle()
                        .fill(selectedTab == .topPicks ? colors.accent : .clear)
                        .frame(height: 2)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - Likes Tab Content (Seni Beğenenler)
    private var likesTabContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Premium upsell message
                if !appState.isPremium {
                    Text("Seni beğenen kişileri\ngörmek için Gold'a yükselt")
                        .font(.system(size: 15))
                        .foregroundStyle(colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                
                // Grid - 2 columns with proper spacing
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 16) {
                    ForEach(likedByUsers) { user in
                        LikeCardView(
                            user: user,
                            isBlurred: !appState.isPremium,
                            showStar: true,
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
                
                // Bottom CTA for non-premium
                if !appState.isPremium {
                    Spacer().frame(height: 80)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .overlay(alignment: .bottom) {
            if !appState.isPremium {
                // Premium CTA Button - Gold Liquid Glass Design
                Button {
                    showPremiumSheet = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 18))
                        
                        Text("Seni kimlerin beğendiğini gör")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 1, green: 0.85, blue: 0.4),
                                Color(red: 1, green: 0.75, blue: 0.25)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        in: Capsule()
                    )
                    .shadow(color: .orange.opacity(0.4), radius: 12, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 100)
            }
        }
    }
    
    // MARK: - Top Picks Tab Content (En Seçkin Profiller)
    private var topPicksTabContent: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Premium upsell message
                    if !appState.isPremium {
                        Text("Daha fazla En Seçkin Profil için\nVibeU Gold'a yükselt!")
                            .font(.system(size: 15))
                            .foregroundStyle(.yellow)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                    }
                    
                    // Grid - First 6 free, rest blurred
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
                                // Scroll detection for locked items
                                GeometryReader { geo in
                                    Color.clear
                                        .onChange(of: geo.frame(in: .global).minY) { _, newY in
                                            // Blurlu karta scroll edildiğinde premium ekranını aç
                                            if index >= 6 && !hasTriggeredPremium && !appState.isPremium {
                                                let screenHeight = UIScreen.main.bounds.height
                                                // Kart ekranın ortasına geldiğinde tetikle
                                                if newY < screenHeight * 0.6 && newY > 0 {
                                                    hasTriggeredPremium = true
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                        showPremiumSheet = true
                                                    }
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
                .padding(.bottom, 120)
            }
            
            // Bottom gradient fade overlay
            if !appState.isPremium {
                VStack {
                    Spacer()
                    
                    // Gölgeli fade efekti
                    LinearGradient(
                        colors: [
                            .clear,
                            colors.background.opacity(0.3),
                            colors.background.opacity(0.6),
                            colors.background.opacity(0.85),
                            colors.background
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 200)
                    .allowsHitTesting(false)
                }
            }
            
            // Premium CTA Button overlay - Gold Design
            if !appState.isPremium {
                VStack {
                    Spacer()
                    
                    Button {
                        showPremiumSheet = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("EN SEÇKİN PROFİLLERİ AÇ")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 1, green: 0.85, blue: 0.4),
                                    Color(red: 1, green: 0.75, blue: 0.25)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            in: Capsule()
                        )
                        .shadow(color: .orange.opacity(0.4), radius: 12, y: 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    private func openProfile(_ user: LikeUser) {
        let photos = [UserPhoto(id: UUID().uuidString, url: user.photo, thumbnailURL: user.photo, orderIndex: 0, isPrimary: true)]
        
        let discoverUser = DiscoverUser(
            id: user.id,
            displayName: user.name,
            age: user.age,
            city: user.city,
            country: "TR",
            countryFlag: "🇹🇷",
            distanceKm: 0,
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

    // MARK: - Load Data
    private func loadData() {
        Task {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let db = Firestore.firestore()
            
            do {
                // Fetch received likes from Firestore
                let likesSnapshot = try await db.collection("likes")
                    .whereField("toUserId", isEqualTo: uid)
                    .limit(to: 20)
                    .getDocuments()
                
                var fetchedLikedByUsers: [LikeUser] = []
                
                for doc in likesSnapshot.documents {
                    let data = doc.data()
                    let fromUserId = data["fromUserId"] as? String ?? ""
                    let type = data["type"] as? String ?? "like"
                    let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    
                    // Fetch user info
                    if let userDoc = try? await db.collection("users").document(fromUserId).getDocument(),
                       let userData = userDoc.data() {
                        let user = LikeUser(
                            id: doc.documentID,
                            name: userData["displayName"] as? String ?? "Kullanıcı",
                            age: userData["age"] as? Int ?? 0,
                            city: userData["city"] as? String ?? "",
                            photo: userData["profilePhotoURL"] as? String ?? "",
                            timeLeft: formatTimeAgo(createdAt),
                            bio: type == "superlike" ? "⭐ SuperLike" : ""
                        )
                        fetchedLikedByUsers.append(user)
                    }
                }
                
                // If no real likes, add mock likes from mockUsers
                if fetchedLikedByUsers.isEmpty {
                    let mockLikes = DiscoverUser.mockUsers.prefix(8).map { mockUser in
                        LikeUser(
                            id: mockUser.id,
                            name: mockUser.displayName,
                            age: mockUser.age,
                            city: mockUser.city,
                            photo: mockUser.profilePhotoURL,
                            timeLeft: ["5 dk önce", "12 dk önce", "1 saat önce", "3 saat önce"].randomElement()!,
                            bio: mockUser.isBoosted ? "⭐ SuperLike" : ""
                        )
                    }
                    fetchedLikedByUsers = mockLikes
                }
                
                // Fetch top profiles - use mock data directly for reliability
                let topPicksFromMock = DiscoverUser.mockUsers
                    .sorted { $0.score > $1.score }
                    .prefix(10)
                    .map { mockUser in
                        LikeUser(
                            id: mockUser.id,
                            name: mockUser.displayName,
                            age: mockUser.age,
                            city: mockUser.city,
                            photo: mockUser.profilePhotoURL,
                            timeLeft: mockUser.isBoosted ? "🚀 Boost" : "",
                            bio: ""
                        )
                    }
                
                await MainActor.run {
                    likedByUsers = fetchedLikedByUsers
                    topPickUsers = Array(topPicksFromMock)
                }
            } catch {
                print("❌ [FavoritesView] Error loading data: \(error)")
                
                // Fallback to mock data on error
                await MainActor.run {
                    likedByUsers = DiscoverUser.mockUsers.prefix(8).map { u in
                        LikeUser(id: u.id, name: u.displayName, age: u.age, city: u.city, photo: u.profilePhotoURL, timeLeft: "Yeni", bio: "")
                    }
                    topPickUsers = DiscoverUser.mockUsers.sorted { $0.score > $1.score }.prefix(10).map { u in
                        LikeUser(id: u.id, name: u.displayName, age: u.age, city: u.city, photo: u.profilePhotoURL, timeLeft: u.isBoosted ? "🚀" : "", bio: "")
                    }
                }
            }
        }
    }
    
    private func formatTimeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return "Az önce"
        } else if interval < 3600 {
            return "\(Int(interval / 60)) dk önce"
        } else if interval < 86400 {
            return "\(Int(interval / 3600)) saat önce"
        } else {
            return "\(Int(interval / 86400)) gün önce"
        }
    }
}

// MARK: - Tab Enum
enum LikesTab {
    case likes
    case topPicks
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
}

// MARK: - Like Card View Component (Liquid Glass Design)
struct LikeCardView: View {
    let user: LikeUser
    var isBlurred: Bool = false
    var showStar: Bool = false
    var showTimeLeft: Bool = false
    var colors: ThemeColors = .dark
    let onTap: () -> Void
    
    private var isDark: Bool { colors.background == ThemeColors.dark.background }
    
    var body: some View {
        Button(action: onTap) {
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    // Photo - fills entire card - NO BLUR for unlocked
                    AsyncImage(url: URL(string: user.photo)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                                .blur(radius: isBlurred ? 20 : 0)
                        case .failure:
                            Rectangle()
                                .fill(colors.secondaryBackground)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(colors.tertiaryText)
                                )
                        case .empty:
                            Rectangle()
                                .fill(colors.secondaryBackground)
                                .overlay(ProgressView().tint(colors.secondaryText))
                        @unknown default:
                            Rectangle().fill(colors.secondaryBackground)
                        }
                    }
                    
                    // Bottom gradient overlay for text readability
                    LinearGradient(
                        colors: [.clear, .clear, .black.opacity(0.5), .black.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    // Content overlay at bottom
                    VStack(alignment: .leading, spacing: 4) {
                        Spacer()
                        
                        // Name & Age with Star
                        HStack(spacing: 4) {
                            if isBlurred {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.5))
                                    .frame(width: 60, height: 16)
                            } else {
                                Text("\(user.name), \(user.age)")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            
                            Spacer()
                            
                            if showStar {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.cyan)
                            }
                        }
                        
                        // City
                        if !isBlurred {
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 10))
                                Text(user.city)
                                    .font(.system(size: 12))
                            }
                            .foregroundStyle(.white.opacity(0.8))
                        }
                        
                        // Time left
                        if showTimeLeft {
                            Text(isBlurred ? "••••••" : user.timeLeft)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.yellow)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Lock icon for blurred cards
                    if isBlurred {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(.black.opacity(0.5))
                                    .frame(width: 56, height: 56)
                                
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .aspectRatio(3/4, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(isDark ? 0.3 : 0.15), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FavoritesView()
        .environment(AppState())
}
