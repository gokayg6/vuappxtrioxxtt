import SwiftUI

// MARK: - FriendsView
struct FriendsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @State private var friends: [Friend] = []
    @State private var searchText = ""
    @State private var selectedFriend: Friend?
    @State private var isLoading = false
    @State private var selectedFilter: FriendFilter = .all
    @State private var sortOption: SortOption = .recent
    @State private var friendToRemove: Friend?
    @State private var showRemoveAlert = false
    @State private var isSearchExpanded = false

    @State private var showNotifications = false
    @FocusState private var isSearchFocused: Bool
    
    init() {
        // Configure navigation bar appearance for this view
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        
        // Large title attributes
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.label // Adapts to light/dark mode
        ]
        
        // Standard title attributes
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    enum FriendFilter: String, CaseIterable {
        case all = "Tümü"
        case online = "Çevrimiçi"
    }
    
    enum SortOption: String, CaseIterable {
        case recent = "Son Eklenen"
        case name = "İsme Göre"
        case online = "Çevrimiçi Önce"
    }
    
    private var isDark: Bool { appState.currentTheme == .dark || (appState.currentTheme == .system && colorScheme == .dark) }
    private var colors: ThemeColors { isDark ? .dark : .light }
    
    private var filteredFriends: [Friend] {
        var result = friends
        if !searchText.isEmpty {
            result = result.filter { $0.displayName.localizedCaseInsensitiveContains(searchText) }
        }
        switch selectedFilter {
        case .online: result = result.filter { $0.isOnline }
        case .all: break
        }
        switch sortOption {
        case .recent: result = result.sorted { $0.friendshipCreatedAt > $1.friendshipCreatedAt }
        case .name: result = result.sorted { $0.displayName < $1.displayName }
        case .online: result = result.sorted { $0.isOnline && !$1.isOnline }
        }
        return result
    }
    
    private var onlineCount: Int { friends.filter { $0.isOnline }.count }

    var body: some View {
        NavigationStack {
            ZStack {
                colors.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        statsSection
                        filterSection
                        
                        if isLoading {
                            loadingView
                        } else if filteredFriends.isEmpty {
                            emptyState
                        } else {
                            friendsList
                        }
                        
                        Color.clear.frame(height: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .refreshable {
                    loadFriends()
                }
            }
            .navigationTitle("Arkadaşlar")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showNotifications = true
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Circle()
                                .fill(colors.cardBackground)
                                .frame(width: 40, height: 40) // Border removed
                                .overlay(
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 16)) // Slightly smaller icon
                                        .foregroundStyle(colors.primaryText)
                                )
                            
                            // Bildirim noktası - better positioned
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)
                                .overlay(Circle().stroke(colors.background, lineWidth: 2))
                                .padding(2) // Push it slightly inside
                        }
                    }
                    .buttonStyle(.plain) // Ensure button doesn't distort shape
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    sortMenu
                }
            }
            .onAppear {
                loadFriends()
            }

            .sheet(isPresented: $showNotifications) {
                IncomingFriendRequestsSheet(isDark: isDark)
            }
            .sheet(item: $selectedFriend) { friend in
                FriendDetailSheet(
                    friend: friend,
                    isDark: isDark,
                    onRemove: {
                        friendToRemove = friend
                        selectedFriend = nil
                        showRemoveAlert = true
                    }
                )
            }
            .alert("Arkadaşlıktan Çıkar", isPresented: $showRemoveAlert) {
                Button("İptal", role: .cancel) { friendToRemove = nil }
                Button("Çıkar", role: .destructive) {
                    if let friend = friendToRemove {
                        withAnimation { friends.removeAll { $0.id == friend.id } }
                    }
                }
            } message: {
                if let friend = friendToRemove {
                    Text("\(friend.displayName) arkadaş listenizden çıkarılacak.")
                }
            }
        }
    }
    
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        if isDark {
            // Dark mode
            appearance.backgroundColor = UIColor(red: 0.04, green: 0.02, blue: 0.08, alpha: 1)
            appearance.largeTitleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 34, weight: .bold)
            ]
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
            ]
        } else {
            // Light mode
            appearance.backgroundColor = .white
            appearance.shadowColor = UIColor(white: 0.9, alpha: 1)
            appearance.largeTitleTextAttributes = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 34, weight: .bold)
            ]
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
            ]
        }
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    private var sortMenu: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button {
                    sortOption = option
                } label: {
                    HStack {
                        Text(option.rawValue)
                        if sortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(colors.secondaryText)
        }
    }
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            FriendStatCard(icon: "person.2.fill", iconColor: colors.accent, value: "\(friends.count)", label: "Arkadaş", colors: colors, isDark: isDark)
            FriendStatCard(icon: "circle.fill", iconColor: .green, value: "\(onlineCount)", label: "Çevrimiçi", colors: colors, isDark: isDark)
        }
    }
    
    private var filterSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                ForEach(FriendFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        count: filter == .all ? friends.count : onlineCount,
                        isSelected: selectedFilter == filter,
                        colors: colors,
                        isDark: isDark
                    ) {
                        withAnimation(.spring(response: 0.3)) { selectedFilter = filter }
                    }
                }
                Spacer()
            }
            searchBar
        }
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            // Search icon with subtle glow when active
            ZStack {
                if isSearchExpanded {
                    Circle()
                        .fill(colors.accent.opacity(0.2))
                        .frame(width: 32, height: 32)
                        .blur(radius: 6)
                }
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(isSearchExpanded ? colors.accent : colors.tertiaryText)
            }
            
            if isSearchExpanded {
                TextField("Arkadaş ara...", text: $searchText)
                    .font(.system(size: 15))
                    .foregroundStyle(colors.primaryText)
                    .focused($isSearchFocused)
                
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(colors.tertiaryText)
                    }
                }
                
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isSearchExpanded = false
                        searchText = ""
                        isSearchFocused = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(colors.secondaryText)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(isDark ? colors.cardBackground.opacity(0.5) : Color.white.opacity(0.8))
                        )
                        .shadow(color: isDark ? .clear : Color.black.opacity(0.05), radius: 4, y: 2)
                }
            } else {
                Text("Arkadaş ara...")
                    .font(.system(size: 15))
                    .foregroundStyle(colors.tertiaryText)
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isDark ? colors.cardBackground.opacity(0.5) : Color.white.opacity(0.7))
                .shadow(color: isDark ? .clear : Color.black.opacity(0.05), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isDark ? Color.white.opacity(0.1) : Color.gray.opacity(0.15), lineWidth: 1)
        )
        .onTapGesture {
            if !isSearchExpanded {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isSearchExpanded = true
                    isSearchFocused = true
                }
            }
        }
    }
    
    private var friendsList: some View {
        LazyVStack(spacing: 10) {
            ForEach(filteredFriends) { friend in
                FriendRowView(friend: friend, colors: colors) {
                    selectedFriend = friend
                }
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().tint(colors.accent).scaleEffect(1.2)
            Text("Yükleniyor...").font(.system(size: 14)).foregroundStyle(colors.secondaryText)
        }
        .frame(height: 200)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: searchText.isEmpty ? "person.2.slash" : "magnifyingglass")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(colors.accent.opacity(0.6))
            Text(searchText.isEmpty ? "Henüz arkadaşın yok" : "Sonuç bulunamadı")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(colors.primaryText)
            Text(searchText.isEmpty ? "Keşfet'ten yeni insanlarla tanış" : "Farklı bir arama dene")
                .font(.system(size: 14))
                .foregroundStyle(colors.secondaryText)
        }
        .frame(height: 220)
    }
    
    private func loadFriends() {
        isLoading = true
        Task {
            do {
                friends = try await FriendsService.shared.getFriends()
            } catch {
                print("Failed to load friends: \(error)")
                // Optional: Show error alert or toast
            }
            isLoading = false
        }
    }
}

// MARK: - Stat Card (Liquid Glass Design)
private struct FriendStatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    let colors: ThemeColors
    let isDark: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            // Glowing Icon Container
            ZStack {
                // Outer glow
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 52, height: 52)
                    .blur(radius: 8)
                
                // Glass circle with theme-aware background
                Circle()
                    .fill(isDark ? colors.cardBackground.opacity(0.5) : Color.white.opacity(0.7))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [iconColor.opacity(0.6), iconColor.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: isDark ? .clear : Color.black.opacity(0.05), radius: 8, y: 2)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .shadow(color: iconColor.opacity(0.5), radius: 4)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(colors.primaryText)
                
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(colors.secondaryText)
            }
            
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(isDark ? colors.cardBackground.opacity(0.5) : Color.white.opacity(0.7))
                .shadow(color: isDark ? .clear : Color.black.opacity(0.05), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(isDark ? Color.white.opacity(0.1) : Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Filter Chip (Liquid Glass Design)
private struct FilterChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let colors: ThemeColors
    let isDark: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                
                // Count badge with glass effect
                Text("\(count)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(isSelected ? .white : colors.secondaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(isSelected ? colors.accent : (isDark ? colors.cardBackground.opacity(0.5) : Color.white.opacity(0.8)))
                    )
            }
            .foregroundStyle(isSelected ? .white : colors.primaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? colors.accent.opacity(0.25) : (isDark ? colors.cardBackground.opacity(0.3) : Color.white.opacity(0.5)))
            )
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: isSelected 
                                ? [colors.accent.opacity(0.8), colors.accent.opacity(0.3)]
                                : (isDark ? [.white.opacity(0.3), .white.opacity(0.1)] : [Color.gray.opacity(0.2), Color.gray.opacity(0.05)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: isSelected ? colors.accent.opacity(0.3) : (isDark ? .clear : Color.black.opacity(0.05)), radius: 8, y: 4)
        }
    }
}

// MARK: - Friend Row (Liquid Glass Design)
private struct FriendRowView: View {
    let friend: Friend
    let colors: ThemeColors
    let onTap: () -> Void
    
    private var isDark: Bool { colors.background == ThemeColors.dark.background }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Profile Photo with Online Indicator (NO GREEN BORDER)
                ZStack(alignment: .bottomTrailing) {
                    // Photo with subtle border
                    AsyncImage(url: URL(string: friend.profilePhotoURL)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Circle()
                            .fill(isDark ? colors.cardBackground.opacity(0.5) : Color.white.opacity(0.8))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(colors.tertiaryText)
                            )
                    }
                    .frame(width: 58, height: 58)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(isDark ? Color.white.opacity(0.1) : Color.gray.opacity(0.2), lineWidth: 1.5)
                    )
                    
                    // Online indicator (small dot only)
                    if friend.isOnline {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 14, height: 14)
                            .overlay(
                                Circle()
                                    .stroke(isDark ? colors.background : .white, lineWidth: 2.5)
                            )
                            .offset(x: 2, y: 2)
                    }
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(friend.displayName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        // Age badge
                        Text("\(friend.age)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(colors.primaryText.opacity(0.8))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(isDark ? colors.cardBackground.opacity(0.5) : Color.white.opacity(0.8))
                            )
                        
                        // Location
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 10))
                            Text(friend.city)
                                .lineLimit(1)
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(colors.secondaryText)
                    }
                }
                .layoutPriority(1)
                
                Spacer()
                
                // Social Icons removed as requested
                
                // Arrow with glass circle
                ZStack {
                    Circle()
                        .fill(isDark ? colors.cardBackground.opacity(0.5) : Color.white.opacity(0.8))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(colors.secondaryText)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(isDark ? colors.cardBackground.opacity(0.5) : Color.white.opacity(0.7))
                .shadow(color: isDark ? .clear : Color.black.opacity(0.05), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(isDark ? Color.white.opacity(0.1) : Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
    
    private func socialIcon(_ name: String) -> some View {
        Image(name)
            .resizable()
            .frame(width: 24, height: 24)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
    }
}


// MARK: - Friend Detail Sheet (Redesigned with Glass Morphism & Expandable Photos)
struct FriendDetailSheet: View {
    let friend: Friend
    let isDark: Bool
    let onRemove: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var currentPhotoIndex = 0
    @State private var isPhotosExpanded = false
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    
    // Mock data
    private let mockPhotos = [
        "https://picsum.photos/400/600?random=1",
        "https://picsum.photos/400/600?random=2",
        "https://picsum.photos/400/600?random=3"
    ]
    
    private let mockHobbies = ["Müzik", "Seyahat", "Fotoğrafçılık", "Yüzme", "Yoga", "Kitap"]
    
    var body: some View {
        ZStack {
            colors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Stylish close button at top
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(isDark ? colors.cardBackground.opacity(0.6) : Color.white.opacity(0.9))
                                    .frame(width: 36, height: 36)
                                    .shadow(color: isDark ? .clear : Color.black.opacity(0.1), radius: 8, y: 2)
                                
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(colors.secondaryText)
                            }
                        }
                    }
                    .padding(.top, 8)
                    
                    // Name & Info at top
                    profileHeader
                    
                    // Expandable Photos Button
                    photosExpandButton
                    
                    // Expandable Photo Carousel (9:16)
                    if isPhotosExpanded {
                        photoCarousel
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .scale(scale: 0.8).combined(with: .opacity)
                            ))
                    }
                    
                    // Social Media (with title, icons only, horizontal)
                    if friend.hasInstagram || friend.hasTikTok || friend.hasSnapchat {
                        socialMediaSection
                    }
                    
                    // Hobbies (with golden gradients)
                    hobbiesSection
                    
                    // Bio
                    bioSection
                    
                    // Remove Button
                    removeButton
                    
                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal, 16)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(28)
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        HStack(spacing: 12) {
            // Profile photo
            AsyncImage(url: URL(string: friend.profilePhotoURL)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Circle()
                    .fill(isDark ? colors.cardBackground.opacity(0.5) : Color.white.opacity(0.8))
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundStyle(colors.tertiaryText)
                    )
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(colors.accent.opacity(0.5), lineWidth: 2)
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.displayName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                
                HStack(spacing: 8) {
                    Text("\(friend.age)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(colors.secondaryText)
                    
                    Circle()
                        .fill(colors.tertiaryText)
                        .frame(width: 3, height: 3)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 11))
                        Text(friend.city)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(colors.secondaryText)
                    .fixedSize(horizontal: true, vertical: false)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isDark ? colors.cardBackground.opacity(0.5) : Color.white.opacity(0.7))
                .shadow(color: isDark ? .clear : Color.black.opacity(0.05), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isDark ? Color.white.opacity(0.1) : Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
    
    // MARK: - Photos Expand Button
    private var photosExpandButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                isPhotosExpanded.toggle()
            }
        } label: {
            HStack {
                Image(systemName: "photo.stack")
                    .font(.system(size: 16, weight: .semibold))
                Text("Fotoğraflar")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Image(systemName: isPhotosExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(colors.primaryText)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isDark ? colors.cardBackground.opacity(0.5) : Color.white.opacity(0.7))
                    .shadow(color: isDark ? .clear : Color.black.opacity(0.05), radius: 8, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isDark ? Color.white.opacity(0.1) : Color.gray.opacity(0.15), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Photo Carousel (9:16 Aspect Ratio)
    private var photoCarousel: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPhotoIndex) {
                ForEach(Array(mockPhotos.enumerated()), id: \.offset) { index, url in
                    AsyncImage(url: URL(string: url)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Rectangle()
                            .fill(isDark ? colors.cardBackground.opacity(0.5) : Color.white.opacity(0.8))
                            .overlay(ProgressView().tint(colors.accent))
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .aspectRatio(9/16, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isDark ? Color.white.opacity(0.1) : Color.gray.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: isDark ? .clear : Color.black.opacity(0.08), radius: 12, y: 4)
            
            // Photo Indicators
            HStack(spacing: 6) {
                ForEach(0..<mockPhotos.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPhotoIndex ? colors.accent : colors.tertiaryText.opacity(0.4))
                        .frame(width: index == currentPhotoIndex ? 20 : 8, height: 4)
                        .animation(.spring(response: 0.3), value: currentPhotoIndex)
                }
            }
            .padding(.top, 12)
        }
    }
    
    // MARK: - Social Media (Enhanced Design with Working Links)
    private var socialMediaSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sosyal Medya")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(colors.primaryText)
            
            HStack(spacing: 12) {
                if friend.hasInstagram {
                    socialMediaButton(
                        icon: "InstagramIcon",
                        platform: "Instagram",
                        username: friend.instagramUsername ?? "instagram",
                        gradient: [Color(red: 0.97, green: 0.36, blue: 0.54), Color(red: 0.99, green: 0.65, blue: 0.29)]
                    )
                }
                if friend.hasTikTok {
                    socialMediaButton(
                        icon: "TikTokIcon",
                        platform: "TikTok",
                        username: friend.tiktokUsername ?? "tiktok",
                        gradient: [Color(red: 0.0, green: 0.96, blue: 0.88), Color(red: 1.0, green: 0.0, blue: 0.44)]
                    )
                }
                if friend.hasSnapchat {
                    socialMediaButton(
                        icon: "SnapchatIcon",
                        platform: "Snapchat",
                        username: friend.snapchatUsername ?? "snapchat",
                        gradient: [Color(red: 1.0, green: 0.99, blue: 0.0), Color(red: 1.0, green: 0.99, blue: 0.0)]
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isDark ? colors.cardBackground.opacity(0.5) : Color.white.opacity(0.7))
                .shadow(color: isDark ? .clear : Color.black.opacity(0.05), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isDark ? Color.white.opacity(0.1) : Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
    
    private func socialMediaButton(icon: String, platform: String, username: String, gradient: [Color]) -> some View {
        Button {
            openSocialMedia(platform: platform, username: username)
        } label: {
            VStack(spacing: 8) {
                // Icon container - clean design without glow or border
                RoundedRectangle(cornerRadius: 14)
                    .fill(isDark ? colors.cardBackground.opacity(0.6) : Color.white.opacity(0.9))
                    .frame(width: 56, height: 56)
                    .shadow(color: isDark ? .clear : Color.black.opacity(0.08), radius: 8, y: 2)
                    .overlay(
                        Image(icon)
                            .resizable()
                            .frame(width: 32, height: 32)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    )
                
                Text("@\(username)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(colors.secondaryText)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
    
    private func openSocialMedia(platform: String, username: String) {
        var urlString = ""
        
        switch platform {
        case "Instagram":
            urlString = "instagram://user?username=\(username)"
            let fallbackURL = "https://www.instagram.com/\(username)"
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else if let url = URL(string: fallbackURL) {
                UIApplication.shared.open(url)
            }
            return
            
        case "TikTok":
            urlString = "tiktok://user?username=\(username)"
            let fallbackURL = "https://www.tiktok.com/@\(username)"
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else if let url = URL(string: fallbackURL) {
                UIApplication.shared.open(url)
            }
            return
            
        case "Snapchat":
            urlString = "snapchat://add/\(username)"
            let fallbackURL = "https://www.snapchat.com/add/\(username)"
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else if let url = URL(string: fallbackURL) {
                UIApplication.shared.open(url)
            }
            return
            
        default:
            break
        }
    }
    
    // MARK: - Hobbies (Golden Gradients)
    private var hobbiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hobiler")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(colors.primaryText)
            
            FriendFlowLayout(spacing: 8) {
                ForEach(mockHobbies, id: \.self) { hobby in
                    Text(hobby)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1, green: 0.85, blue: 0.4),
                                            Color(red: 1, green: 0.75, blue: 0.25)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: Color.orange.opacity(0.3), radius: 4, y: 2)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isDark ? colors.cardBackground.opacity(0.5) : Color.white.opacity(0.7))
                .shadow(color: isDark ? .clear : Color.black.opacity(0.05), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isDark ? Color.white.opacity(0.1) : Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
    
    // MARK: - Bio Section
    private var bioSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hakkında")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(colors.primaryText)
            
            Text("Merhaba! Ben \(friend.displayName). Müzik dinlemeyi, seyahat etmeyi ve yeni insanlarla tanışmayı seviyorum. 🎵✈️")
                .font(.system(size: 14))
                .foregroundStyle(colors.secondaryText)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isDark ? colors.cardBackground.opacity(0.5) : Color.white.opacity(0.7))
                .shadow(color: isDark ? .clear : Color.black.opacity(0.05), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isDark ? Color.white.opacity(0.1) : Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
    
    // MARK: - Remove Button
    private var removeButton: some View {
        Button(role: .destructive) {
            onRemove()
        } label: {
            HStack {
                Image(systemName: "person.fill.xmark")
                    .font(.system(size: 16, weight: .semibold))
                Text("Arkadaşlıktan Çıkar")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red)
            )
            .shadow(color: Color.red.opacity(0.3), radius: 8, y: 4)
        }
    }
}

// MARK: - FriendFlowLayout for Hobbies
struct FriendFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    FriendsView()
        .environment(AppState())
}


struct IncomingFriendRequestsSheet: View {
    let isDark: Bool
    @Environment(\.dismiss) private var dismiss
    
    @State private var requests: [FriendsService.PendingRequest] = []
    @State private var isLoading = true
    
    private var backgroundColor: Color {
        isDark ? Color(red: 0.04, green: 0.02, blue: 0.08) : Color(red: 0.98, green: 0.98, blue: 0.99)
    }
    
    private var cardBackground: Color {
        isDark ? Color(white: 0.1) : Color.white
    }
    
    private var secondaryText: Color {
        isDark ? .white.opacity(0.6) : .black.opacity(0.6)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                        .tint(.purple)
                } else if requests.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 48))
                            .foregroundStyle(secondaryText.opacity(0.5))
                        Text("Bekleyen istek yok")
                            .font(.headline)
                            .foregroundStyle(secondaryText)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(requests) { request in
                                RequestRow(request: request, isDark: isDark, onAccept: {
                                    handleRequest(request, accepted: true)
                                }, onReject: {
                                    handleRequest(request, accepted: false)
                                })
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Arkadaşlık İstekleri")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(secondaryText)
                            .font(.system(size: 24))
                    }
                }
            }
            .onAppear {
                loadRequests()
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func loadRequests() {
        isLoading = true
        Task {
            do {
                requests = try await FriendsService.shared.getPendingRequests()
            } catch {
                print("Failed to load requests: \(error)")
            }
            isLoading = false
        }
    }
    
    private func handleRequest(_ request: FriendsService.PendingRequest, accepted: Bool) {
        Task {
            // Optimistic UI update
            withAnimation {
                requests.removeAll { $0.id == request.id }
            }
            
            do {
                if accepted {
                    try await FriendsService.shared.acceptRequest(requestId: request.id)
                } else {
                    try await FriendsService.shared.rejectRequest(requestId: request.id)
                }
            } catch {
                print("Failed to handle request: \(error)")
                // Revert if needed, but for now keep it simple
            }
        }
    }
}

private struct RequestRow: View {
    let request: FriendsService.PendingRequest
    let isDark: Bool
    let onAccept: () -> Void
    let onReject: () -> Void
    
    private var cardBackground: Color {
        isDark ? Color(white: 0.12) : Color.white
    }
    
    private var primaryText: Color {
        isDark ? .white : .black
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            AsyncImage(url: URL(string: request.fromUser.profilePhotoUrl)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Circle().fill(Color.gray.opacity(0.3))
            }
            .frame(width: 56, height: 56)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(request.fromUser.displayName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(primaryText)
                
                Text(request.fromUser.city)
                    .font(.system(size: 13))
                    .foregroundStyle(isDark ? .white.opacity(0.6) : .black.opacity(0.6))
            }
            
            Spacer()
            
            // Buttons
            HStack(spacing: 8) {
                // Reject Button
                Button(action: onReject) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(isDark ? .white.opacity(0.8) : .secondary)
                        .frame(width: 36, height: 36)
                        .background(isDark ? Color.white.opacity(0.1) : Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                
                // Accept Button
                Button(action: onAccept) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            LinearGradient(
                                colors: [.purple, .indigo],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                        .shadow(color: .purple.opacity(0.4), radius: 4, y: 2)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
        )
    }
}
