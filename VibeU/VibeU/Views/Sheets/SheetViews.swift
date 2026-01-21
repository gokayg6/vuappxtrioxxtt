import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Favorites Sheet

struct FavoritesSheet: View {
    @State private var favorites: [Favorite] = []
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss
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
                
                if isLoading {
                    GlassLoadingView()
                } else if favorites.isEmpty {
                    GlassEmptyState(
                        icon: "star",
                        title: "no_favorites",
                        message: "no_favorites_message"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(favorites) { favorite in
                                FavoriteRow(favorite: favorite, colors: colors)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .navigationTitle("favorites")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("done") { dismiss() }
                        .foregroundStyle(colors.accent)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .task {
            do {
                favorites = try await DiscoverService.shared.getFavorites()
            } catch {}
            isLoading = false
        }
    }
}

struct FavoriteRow: View {
    let favorite: Favorite
    var colors: ThemeColors = .dark
    
    var body: some View {
        HStack(spacing: 14) {
            GlassAvatar(url: favorite.user.profilePhotoURL, size: 56)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(favorite.user.displayName)
                        .font(.headline)
                        .foregroundStyle(colors.primaryText)
                    Text("\(favorite.user.age)")
                        .font(.subheadline)
                        .foregroundStyle(colors.secondaryText)
                }
                Text(favorite.user.city)
                    .font(.caption)
                    .foregroundStyle(colors.secondaryText)
            }
            
            Spacer()
            
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
        }
        .padding(14)
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(colors.border, lineWidth: 0.5))
    }
}

// MARK: - Incoming Requests Sheet

struct IncomingRequestsSheet: View {
    @State private var requests: [SocialRequest] = []
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss
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
                
                if isLoading {
                    GlassLoadingView()
                } else if requests.isEmpty {
                    GlassEmptyState(
                        icon: "tray",
                        title: "no_requests",
                        message: "no_requests_message"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(requests) { request in
                                PremiumRequestCard(
                                    request: request,
                                    onAccept: { acceptRequest(request) },
                                    onReject: { rejectRequest(request) }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .navigationTitle("requests")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("done") { dismiss() }
                        .foregroundStyle(colors.accent)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .task {
            do {
                requests = try await SocialService.shared.getReceivedRequests()
            } catch {}
            isLoading = false
        }
    }
    
    private func acceptRequest(_ request: SocialRequest) {
        requests.removeAll { $0.id == request.id }
        Task {
            try? await SocialService.shared.acceptRequest(requestId: request.id)
        }
    }
    
    private func rejectRequest(_ request: SocialRequest) {
        requests.removeAll { $0.id == request.id }
        Task {
            try? await SocialService.shared.rejectRequest(requestId: request.id)
        }
    }
}

// MARK: - Boost Sheet

struct BoostSheet: View {
    @State private var boostProducts: [PremiumProduct] = []
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss
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
                
                // Subtle gradient overlay
                LinearGradient(
                    colors: [.clear, .orange.opacity(isDark ? 0.1 : 0.05), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(RadialGradient(colors: [.orange.opacity(0.3), .clear], center: .center, startRadius: 20, endRadius: 60))
                                .frame(width: 100, height: 100)
                                .blur(radius: 15)
                            
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.orange)
                        }
                        
                        Text("boost_your_profile")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(colors.primaryText)
                        
                        Text("boost_description")
                            .font(.subheadline)
                            .foregroundStyle(colors.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)
                    
                    // Boost Options
                    VStack(spacing: 12) {
                        ForEach(boostProducts) { product in
                            BoostOptionRow(product: product, colors: colors) {
                                Task {
                                    try? await PremiumService.shared.activateBoost(type: .thirtyMin)
                                    dismiss()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(colors.secondaryText)
                            .frame(width: 32, height: 32)
                            .background(colors.secondaryBackground, in: Circle())
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .task {
            do {
                boostProducts = try await PremiumService.shared.getProducts().filter { $0.id.contains("boost") }
            } catch {}
            isLoading = false
        }
    }
}

struct BoostOptionRow: View {
    let product: PremiumProduct
    var colors: ThemeColors = .dark
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(colors.secondaryBackground)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "bolt.fill")
                        .font(.title2)
                        .foregroundStyle(.orange)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(product.name)
                        .font(.headline)
                        .foregroundStyle(colors.primaryText)
                    Text("boost_benefit")
                        .font(.caption)
                        .foregroundStyle(colors.secondaryText)
                }
                
                Spacer()
                
                Text(product.price)
                    .font(.headline)
                    .foregroundStyle(.orange)
            }
            .padding(16)
            .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(colors.border, lineWidth: 0.5))
        }
        .buttonStyle(GlassButtonPressStyle())
    }
}

// MARK: - Liked You Sheet (Premium)

struct LikedYouSheet: View {
    @State private var likes: [Like] = []
    @State private var isLoading = true
    @State private var isPremium = false
    @Environment(\.dismiss) private var dismiss
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
                
                if !isPremium {
                    // Premium Upsell
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(RadialGradient(colors: [.pink.opacity(0.3), .clear], center: .center, startRadius: 20, endRadius: 60))
                                .frame(width: 120, height: 120)
                                .blur(radius: 15)
                            
                            Image(systemName: "eyes")
                                .font(.system(size: 60))
                                .foregroundStyle(.pink)
                        }
                        
                        Text("see_who_liked_you")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(colors.primaryText)
                        
                        Text("premium_required_likes")
                            .font(.subheadline)
                            .foregroundStyle(colors.secondaryText)
                            .multilineTextAlignment(.center)
                        
                        GlassButton("upgrade_to_premium", icon: "crown.fill", style: .accent) {
                            // Show premium
                        }
                        .frame(width: 220)
                    }
                    .padding(32)
                } else if isLoading {
                    GlassLoadingView()
                } else if likes.isEmpty {
                    GlassEmptyState(
                        icon: "heart",
                        title: "no_likes_yet",
                        message: "no_likes_message"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(likes) { like in
                                LikeRow(like: like, colors: colors)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .navigationTitle("liked_you")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("done") { dismiss() }
                        .foregroundStyle(colors.accent)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear {
            isPremium = appState.currentUser?.isPremium ?? false
        }
        .task {
            guard isPremium else { return }
            do {
                likes = try await DiscoverService.shared.getReceivedLikes()
            } catch {}
            isLoading = false
        }
    }
}

struct LikeRow: View {
    let like: Like
    var colors: ThemeColors = .dark
    
    var body: some View {
        HStack(spacing: 14) {
            GlassAvatar(url: like.user.profilePhotoURL, size: 56)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(like.user.displayName)
                        .font(.headline)
                        .foregroundStyle(colors.primaryText)
                    Text("\(like.user.age)")
                        .font(.subheadline)
                        .foregroundStyle(colors.secondaryText)
                }
                Text(like.user.city)
                    .font(.caption)
                    .foregroundStyle(colors.secondaryText)
            }
            
            Spacer()
            
            Image(systemName: "heart.fill")
                .foregroundStyle(.red)
        }
        .padding(14)
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(colors.border, lineWidth: 0.5))
    }
}

// MARK: - Search Sheet

struct SearchSheet: View {
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
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
                
                VStack {
                    // Search Field
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(colors.secondaryText)
                        
                        TextField("search_users", text: $searchText)
                            .textFieldStyle(.plain)
                            .foregroundStyle(colors.primaryText)
                    }
                    .padding(14)
                    .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(colors.border, lineWidth: 0.5))
                    .padding(.horizontal, 16)
                    
                    if searchText.isEmpty {
                        Spacer()
                        Text("search_hint")
                            .font(.subheadline)
                            .foregroundStyle(colors.secondaryText)
                        Spacer()
                    } else {
                        // Search Results
                        ScrollView {
                            // Results would go here
                        }
                    }
                }
            }
            .navigationTitle("search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("cancel") { dismiss() }
                        .foregroundStyle(colors.accent)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Diamond Screen (Elmas Ekranı)
struct DiamondScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    
    @State private var balance: Int = 0
    @State private var canClaimReward = false
    @State private var isLoading = true
    @State private var isClaiming = false
    @State private var timeUntilNextReward: TimeInterval?
    
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
                
                LinearGradient(
                    colors: [.clear, .cyan.opacity(isDark ? 0.1 : 0.05), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                } else {
                    VStack(spacing: 32) {
                        balanceCard
                        dailyRewardSection
                        infoSection
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
            }
            .navigationTitle("Elmaslarım")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(colors.secondaryText)
                            .frame(width: 32, height: 32)
                            .background(colors.secondaryBackground, in: Circle())
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .task { await loadData() }
    }
    
    private var balanceCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [.cyan.opacity(0.4), .clear], center: .center, startRadius: 20, endRadius: 80))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image(systemName: "diamond.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: .cyan.opacity(0.5), radius: 10)
            }
            
            VStack(spacing: 4) {
                Text("\(balance)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(colors.primaryText)
                
                Text("Elmas")
                    .font(.subheadline)
                    .foregroundStyle(colors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(LinearGradient(colors: [.cyan.opacity(0.3), .blue.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
    }
    
    private var dailyRewardSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "gift.fill").foregroundStyle(.orange)
                Text("Günlük Ödül").font(.headline).foregroundStyle(colors.primaryText)
                Spacer()
                Text("+100").font(.headline.weight(.bold)).foregroundStyle(.cyan)
                Image(systemName: "diamond.fill").foregroundStyle(.cyan)
            }
            
            if canClaimReward {
                Button { Task { await claimReward() } } label: {
                    HStack {
                        if isClaiming { ProgressView().tint(.white) }
                        else { Image(systemName: "gift.fill"); Text("Ödülümü Al") }
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 16))
                }
                .disabled(isClaiming)
            } else {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                        Text("Bugünkü ödülünü aldın!").font(.subheadline).foregroundStyle(colors.secondaryText)
                    }
                    if let time = timeUntilNextReward, time > 0 {
                        Text("Yeni ödül: \(formatTime(time))").font(.caption).foregroundStyle(colors.tertiaryText)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(colors.secondaryBackground, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(20)
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(colors.border, lineWidth: 0.5))
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Elmas Nasıl Kullanılır?").font(.headline).foregroundStyle(colors.primaryText)
            
            HStack(spacing: 12) {
                Image(systemName: "heart.fill").foregroundStyle(.pink).frame(width: 24)
                Text("Eşleşme isteği göndermek: 10 elmas").font(.subheadline).foregroundStyle(colors.secondaryText)
            }
            HStack(spacing: 12) {
                Image(systemName: "gift.fill").foregroundStyle(.orange).frame(width: 24)
                Text("Her gün ücretsiz 100 elmas al").font(.subheadline).foregroundStyle(colors.secondaryText)
            }
        }
        .padding(20)
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(colors.border, lineWidth: 0.5))
    }
    
    private func loadData() async {
        guard let uid = Auth.auth().currentUser?.uid else { isLoading = false; return }
        
        let db = Firestore.firestore()
        do {
            let doc = try await db.collection("users").document(uid).getDocument()
            balance = doc.data()?["diamond_balance"] as? Int ?? 100
            
            if let lastClaim = doc.data()?["daily_reward_last_claim_at"] as? Timestamp {
                let istanbul = TimeZone(identifier: "Europe/Istanbul")!
                var calendar = Calendar.current
                calendar.timeZone = istanbul
                let lastDay = calendar.startOfDay(for: lastClaim.dateValue())
                let today = calendar.startOfDay(for: Date())
                canClaimReward = today > lastDay
                
                let tomorrow = calendar.date(byAdding: .day, value: 1, to: lastDay)!
                timeUntilNextReward = tomorrow.timeIntervalSince(Date())
            } else {
                canClaimReward = true
            }
        } catch {
            print("❌ [DiamondScreen] Error: \(error)")
        }
        isLoading = false
    }
    
    private func claimReward() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // IMMEDIATELY disable button to prevent double claims
        canClaimReward = false
        isClaiming = true
        
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid)
        
        do {
            // First check if already claimed today (double check)
            let checkDoc = try await docRef.getDocument()
            if let lastClaim = checkDoc.data()?["daily_reward_last_claim_at"] as? Timestamp {
                let istanbul = TimeZone(identifier: "Europe/Istanbul")!
                var calendar = Calendar.current
                calendar.timeZone = istanbul
                let lastDay = calendar.startOfDay(for: lastClaim.dateValue())
                let today = calendar.startOfDay(for: Date())
                
                if today <= lastDay {
                    print("⚠️ [DiamondScreen] Already claimed today!")
                    isClaiming = false
                    return
                }
            }
            
            try await db.runTransaction { (transaction, errorPointer) -> Any? in
                let snapshot: DocumentSnapshot
                do { snapshot = try transaction.getDocument(docRef) }
                catch let e as NSError { errorPointer?.pointee = e; return nil }
                
                let current = snapshot.data()?["diamond_balance"] as? Int ?? 100
                transaction.updateData([
                    "diamond_balance": current + 100,
                    "daily_reward_last_claim_at": FieldValue.serverTimestamp()
                ], forDocument: docRef)
                return nil
            }
            
            try await db.collection("diamond_transactions").addDocument(data: [
                "userId": uid, "type": "daily_reward", "amount": 100, "created_at": FieldValue.serverTimestamp()
            ])
            
            balance += 100
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            print("❌ [DiamondScreen] Claim error: \(error)")
            // If failed, allow retry
            canClaimReward = true
        }
        isClaiming = false
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return hours > 0 ? "\(hours) saat \(minutes) dakika" : "\(minutes) dakika"
    }
}
