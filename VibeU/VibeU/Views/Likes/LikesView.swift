import SwiftUI

// MARK: - Likes View - COMPLETE REDESIGN
// Clear sections, prominent friend requests, .glassEffect() throughout

struct LikesView: View {
    @State private var selectedUser: DiscoverUser?
    @State private var showPremiumSheet = false
    @State private var pendingRequests: [SocialRequest] = []
    @State private var isLoadingRequests = true
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    
    private let likedYouUsers = DiscoverUser.likedYouUsers
    private var isDark: Bool { colorScheme == .dark }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Background
                (isDark ? Color.black : Color(UIColor.systemBackground))
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // MARK: - Friend Requests Section (NEW - PROMINENT)
                        if !pendingRequests.isEmpty {
                            friendRequestsSection
                        }
                        
                        // MARK: - Likes Header
                        likesHeaderSection
                        
                        // MARK: - Who Liked You Grid
                        likesGridSection
                        
                        // Bottom padding for tab bar
                        Color.clear.frame(height: 120)
                    }
                    .padding(.top, 16)
                }
                
                // Floating Premium Button
                if !appState.isPremium {
                    premiumFloatingButton
                }
            }
            .navigationTitle("Beğenenler".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
            .navigationDestination(item: $selectedUser) { user in
                ProfileDetailView(user: user)
            }
            .sheet(isPresented: $showPremiumSheet) {
                SubscriptionSheet()
            }
            .task {
                await loadPendingRequests()
            }
        }
    }
    
    // MARK: - Friend Requests Section
    private var friendRequestsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "person.badge.plus.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.pink)
                
                Text("Gelen Arkadaşlık İstekleri".localized)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(isDark ? .white : .black)
                
                Spacer()
                
                // Badge
                Text("\(pendingRequests.count)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.red, in: Capsule())
            }
            
            VStack(spacing: 10) {
                ForEach(pendingRequests.prefix(3)) { request in
                    FriendRequestRow(request: request, onAccept: {
                        acceptRequest(request)
                    }, onReject: {
                        rejectRequest(request)
                    })
                }
                
                if pendingRequests.count > 3 {
                    NavigationLink {
                        AllRequestsView()
                    } label: {
                        HStack {
                            Text("\(pendingRequests.count - 3) \("istek daha".localized)")
                                .font(.system(size: 14, weight: .semibold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundStyle(.cyan)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                }
            }
            .padding(16)
            .glassEffect()
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Likes Header
    private var likesHeaderSection: some View {
        VStack(spacing: 16) {
            if !appState.isPremium {
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.pink, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .shadow(color: .pink.opacity(0.4), radius: 15, y: 5)
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.white)
                    }
                    
                    Text("\(likedYouUsers.count) \("kişi seni beğendi!".localized)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(isDark ? .white : .black)
                    
                    Text("Premium ile kimlerin beğendiğini gör".localized)
                        .font(.system(size: 14))
                        .foregroundStyle(isDark ? .white.opacity(0.5) : .black.opacity(0.5))
                }
                .padding(.vertical, 10)
            } else {
                HStack {
                    Text("Seni Beğenenler".localized)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(isDark ? .white : .black)
                    
                    Spacer()
                    
                    Text("\(likedYouUsers.count)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.pink)
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Likes Grid
    private var likesGridSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            ForEach(likedYouUsers) { user in
                LikesCardView(user: user, isBlurred: !appState.isPremium) {
                    if appState.isPremium {
                        selectedUser = user
                    } else {
                        showPremiumSheet = true
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Premium Floating Button
    private var premiumFloatingButton: some View {
        Button {
            showPremiumSheet = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 18))
                Text("Seni Kimlerin Beğendiğini Gör".localized)
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.85, blue: 0.4),
                        Color(red: 1.0, green: 0.7, blue: 0.3)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: Capsule()
            )
            .shadow(color: Color.orange.opacity(0.4), radius: 15, y: 5)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 100)
    }
    
    // MARK: - Functions
    private func loadPendingRequests() async {
        do {
            let requests = try await FriendsService.shared.getPendingRequests()
            await MainActor.run {
                pendingRequests = requests
                isLoadingRequests = false
            }
        } catch {
            print("❌ Error loading requests: \(error)")
            isLoadingRequests = false
        }
    }
    
    private func acceptRequest(_ request: SocialRequest) {
        Task {
            do {
                try await FriendsService.shared.acceptRequest(requestId: request.id)
                await MainActor.run {
                    pendingRequests.removeAll { $0.id == request.id }
                }
            } catch {
                print("❌ Accept failed: \(error)")
            }
        }
    }
    
    private func rejectRequest(_ request: SocialRequest) {
        Task {
            do {
                try await FriendsService.shared.rejectRequest(requestId: request.id)
                await MainActor.run {
                    pendingRequests.removeAll { $0.id == request.id }
                }
            } catch {
                print("❌ Reject failed: \(error)")
            }
        }
    }
}

// MARK: - Friend Request Row
struct FriendRequestRow: View {
    let request: SocialRequest
    let onAccept: () -> Void
    let onReject: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    private var isDark: Bool { colorScheme == .dark }
    
    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            AsyncImage(url: URL(string: request.fromUser?.profilePhotoURL ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.5), .pink.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        Text(String((request.fromUser?.displayName ?? "U").prefix(1)).uppercased())
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                    }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(request.fromUser?.displayName ?? "Kullanıcı".localized)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isDark ? .white : .black)
                
                Text("Arkadaşlık isteği gönderdi".localized)
                    .font(.system(size: 12))
                    .foregroundStyle(isDark ? .white.opacity(0.5) : .black.opacity(0.5))
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 8) {
                Button(action: onReject) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.red)
                        .frame(width: 36, height: 36)
                        .background(Color.red.opacity(0.15), in: Circle())
                }
                
                Button(action: onAccept) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.green)
                        .frame(width: 36, height: 36)
                        .background(Color.green.opacity(0.15), in: Circle())
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Likes Card View
struct LikesCardView: View {
    let user: DiscoverUser
    let isBlurred: Bool
    let onTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    private var isDark: Bool { colorScheme == .dark }
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple.opacity(0.3), .pink.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                .frame(height: 220)
                .clipped()
                .blur(radius: isBlurred ? 25 : 0)
                
                // Gradient overlay
                LinearGradient(
                    colors: [.clear, .black.opacity(0.8)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(user.displayName)
                            .font(.system(size: 16, weight: .bold))
                        Text("\(user.age)")
                            .font(.system(size: 15))
                    }
                    .foregroundStyle(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text(user.city)
                            .font(.system(size: 12))
                    }
                    .foregroundStyle(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                
                // Lock overlay
                if isBlurred {
                    ZStack {
                        Color.black.opacity(0.3)
                        
                        VStack(spacing: 6) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.white)
                            
                            Text("Premium")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(isDark ? 0.3 : 0.1), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - All Requests View (Full page for requests)
struct AllRequestsView: View {
    @State private var requests: [SocialRequest] = []
    @State private var isLoading = true
    @Environment(\.colorScheme) private var colorScheme
    
    private var isDark: Bool { colorScheme == .dark }
    
    var body: some View {
        List {
            ForEach(requests) { request in
                FriendRequestRow(request: request, onAccept: {
                    acceptRequest(request)
                }, onReject: {
                    rejectRequest(request)
                })
            }
        }
        .listStyle(.plain)
        .navigationTitle("Tüm İstekler".localized)
        .task {
            await loadRequests()
        }
    }
    
    private func loadRequests() async {
        do {
            requests = try await FriendsService.shared.getPendingRequests()
            isLoading = false
        } catch {
            isLoading = false
        }
    }
    
    private func acceptRequest(_ request: SocialRequest) {
        Task {
            try? await FriendsService.shared.acceptRequest(requestId: request.id)
            requests.removeAll { $0.id == request.id }
        }
    }
    
    private func rejectRequest(_ request: SocialRequest) {
        Task {
            try? await FriendsService.shared.rejectRequest(requestId: request.id)
            requests.removeAll { $0.id == request.id }
        }
    }
}

#Preview {
    LikesView()
        .environment(AppState())
}
