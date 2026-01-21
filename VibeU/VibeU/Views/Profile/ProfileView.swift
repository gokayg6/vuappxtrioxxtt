import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()
    @State private var currentPage = 0
    @State private var localCompletion: Int = 0
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
                // Tema bazlı background
                colors.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Profile Header
                        ProfileHeaderCard(
                            user: appState.currentUser,
                            completionPercentage: localCompletion,
                            colors: colors
                        )
                        
                        // Double Date Banner
                        DoubleDateBannerCard(colors: colors)
                        
                        // Quick Stats Row
                        QuickStatsRowView(colors: colors)
                        
                        // Menu Items (Fotoğraflar, İlgi Alanları, Sosyal Medya, QR)
                        ProfileMenuSection(colors: colors)
                        
                        // Logout & Settings
                        AccountSection(viewModel: viewModel, appState: appState, colors: colors)
                        
                        Color.clear.frame(height: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            viewModel.showSafety = true
                        } label: {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(colors.secondaryText)
                        }
                        
                        Button {
                            viewModel.showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(colors.secondaryText)
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showPremium) {
                PremiumView()
            }
            .sheet(isPresented: $viewModel.showSettings) {
                SettingsSheetView()
            }
            .sheet(isPresented: $viewModel.showSafety) {
                SafetySettingsSheet()
            }
            .confirmationDialog("Çıkış yapmak istediğine emin misin?", isPresented: $viewModel.showLogoutConfirm, titleVisibility: .visible) {
                Button("Çıkış Yap", role: .destructive) {
                    appState.signOut()
                }
                Button("İptal", role: .cancel) {}
            }
            .onAppear { calculateLocalCompletion() }
        }
    }
    
    private func calculateLocalCompletion() {
        var completed = 0
        let total = 6 // Total fields to check
        
        // Check displayName
        if let name = UserDefaults.standard.string(forKey: ProfileKeys.displayName), !name.isEmpty {
            completed += 1
        }
        
        // Check bio
        if let bio = UserDefaults.standard.string(forKey: ProfileKeys.bio), !bio.isEmpty {
            completed += 1
        }
        
        // Check city
        if let city = UserDefaults.standard.string(forKey: ProfileKeys.city), !city.isEmpty {
            completed += 1
        }
        
        // Check photos
        if let photos = UserDefaults.standard.array(forKey: ProfileKeys.photos) as? [Data], !photos.isEmpty {
            completed += 1
        }
        
        // Check interests
        if let interests = UserDefaults.standard.array(forKey: ProfileKeys.interests) as? [String], !interests.isEmpty {
            completed += 1
        }
        
        // Check social links (at least one)
        let instagram = UserDefaults.standard.string(forKey: ProfileKeys.instagram) ?? ""
        let tiktok = UserDefaults.standard.string(forKey: ProfileKeys.tiktok) ?? ""
        let snapchat = UserDefaults.standard.string(forKey: ProfileKeys.snapchat) ?? ""
        if !instagram.isEmpty || !tiktok.isEmpty || !snapchat.isEmpty {
            completed += 1
        }
        
        localCompletion = Int((Double(completed) / Double(total)) * 100)
    }
}

// MARK: - Profile Header Card (Premium Design)
struct ProfileHeaderCard: View {
    let user: User?
    let completionPercentage: Int
    var colors: ThemeColors = .dark
    @State private var isButtonPressed = false
    @State private var savedPhoto: UIImage?
    
    private var isDark: Bool { colors.background == ThemeColors.dark.background }
    
    // Elegant Apple-style ring - subtle silver/white gradient
    private var ringGradient: LinearGradient {
        LinearGradient(
            colors: isDark ? [Color(white: 0.85), Color(white: 0.55), Color(white: 0.75)] : [Color(white: 0.4), Color(white: 0.6), Color(white: 0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private let buttonGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.84, blue: 0.0),    // #FFD700
            Color(red: 1.0, green: 0.55, blue: 0.0)     // #FF8C00
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    private var isProfileComplete: Bool {
        completionPercentage >= 100
    }
    
    private var completionColor: [Color] {
        if isProfileComplete {
            return [Color.green, Color.mint]
        } else {
            return [Color(red: 1.0, green: 0.18, blue: 0.33), Color(red: 0.9, green: 0.1, blue: 0.4)]
        }
    }
    
    var body: some View {
        HStack(spacing: 18) {
            // Profile Photo with elegant ring
            ZStack {
                // Subtle glow behind photo
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                (isDark ? Color.white : colors.accent).opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 60
                        )
                    )
                    .frame(width: 110, height: 110)
                    .blur(radius: 10)
                
                // Elegant ring
                Circle()
                    .stroke(ringGradient, lineWidth: 2.5)
                    .frame(width: 94, height: 94)
                
                // Profile photo
                Group {
                    if let photo = savedPhoto {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 82, height: 82)
                            .clipped()
                    } else {
                        // FIX: Do NOT load if URL contains "dicebear" (it causes "GG" initals)
                        let urlString = user?.profilePhotoURL ?? ""
                        if !urlString.isEmpty && !urlString.contains("dicebear") {
                            AsyncImage(url: URL(string: urlString)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 82, height: 82)
                                    .clipped()
                            } placeholder: {
                                Circle()
                                    .fill(colors.secondaryBackground)
                                    .overlay {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 36))
                                            .foregroundStyle(colors.tertiaryText)
                                    }
                            }
                        } else {
                             Circle()
                                .fill(colors.secondaryBackground)
                                .overlay {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 36))
                                        .foregroundStyle(colors.tertiaryText)
                                }
                        }
                    }
                }
                .frame(width: 82, height: 82)
                .clipShape(Circle())
                
                // Percentage badge
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: completionColor,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                        .shadow(color: completionColor[0].opacity(0.5), radius: 6, x: 0, y: 2)
                    
                    Text("\(completionPercentage)%")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                }
                .offset(x: 32, y: 32)
            }
            .frame(width: 100, height: 100)
            
            // Name, verification and button
            VStack(alignment: .leading, spacing: 14) {
                // Name row with verification
                HStack(spacing: 10) {
                    Text("\(user?.displayName ?? "Kullanıcı"), \(user?.age ?? 0)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(colors.primaryText)
                    
                    // Verified badge with glow
                    ZStack {
                        Circle()
                            .fill(Color(red: 0, green: 0.48, blue: 1.0))
                            .frame(width: 22, height: 22)
                            .shadow(color: Color(red: 0, green: 0.48, blue: 1.0).opacity(0.6), radius: 6, x: 0, y: 0)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                
                // Complete profile button with gradient
                NavigationLink {
                    EditProfileView()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: isProfileComplete ? "pencil" : "pencil")
                            .font(.system(size: 13, weight: .bold))
                        Text(isProfileComplete ? "Profili Düzenle" : "Profili Tamamla")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 11)
                    .background(
                        Capsule()
                            .fill(buttonGradient)
                            .shadow(color: Color(red: 1.0, green: 0.55, blue: 0.0).opacity(0.4), radius: 8, x: 0, y: 4)
                    )
                }
                .scaleEffect(isButtonPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isButtonPressed)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(colors.border, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(isDark ? 0.3 : 0.1), radius: 12, x: 0, y: 6)
        )
        .onAppear { loadSavedPhoto() }
    }
    
    private func loadSavedPhoto() {
        // Priority 1: User photos array from Firebase subcollection
        var photoUrlString = user?.photos.first?.url
        
        // Priority 2: profilePhotoURL if not a dicebear placeholder
        if photoUrlString == nil || photoUrlString?.isEmpty == true {
            if let profileUrl = user?.profilePhotoURL, 
               !profileUrl.contains("dicebear"),
               !profileUrl.isEmpty {
                photoUrlString = profileUrl
            }
        }
        
        guard let urlString = photoUrlString, let url = URL(string: urlString) else { return }
        
        Task {
            if let data = try? await URLSession.shared.data(from: url).0,
               let image = UIImage(data: data) {
                await MainActor.run {
                    savedPhoto = image
                }
            }
        }
    }
}

// MARK: - Double Date Banner (Minimal Gray Design)
struct DoubleDateBannerCard: View {
    @State private var showDoubleDateSheet = false
    var colors: ThemeColors = .dark
    
    var body: some View {
        Button {
            showDoubleDateSheet = true
        } label: {
            HStack(spacing: 14) {
                // Gray icon background
                RoundedRectangle(cornerRadius: 10)
                    .fill(colors.secondaryBackground)
                    .frame(width: 42, height: 42)
                    .overlay(
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(colors.secondaryText)
                    )
                
                // Text content
                VStack(alignment: .leading, spacing: 3) {
                    Text("Çifte Randevu")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                    
                    Text("Arkadaşlarınla birlikte eşleş")
                        .font(.system(size: 13))
                        .foregroundStyle(colors.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(colors.tertiaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(colors.border, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDoubleDateSheet) {
            DoubleDateSheet()
        }
    }
}

// MARK: - Quick Stats Row (Premium Design)
struct QuickStatsRowView: View {
    @State private var superLikeCount: Int = 0
    @State private var boostCount: Int = 0
    @State private var showSuperLikeSheet = false
    @State private var showBoostSheet = false
    @State private var showSubscriptionSheet = false
    var colors: ThemeColors = .dark
    
    var body: some View {
        HStack(spacing: 12) {
            // Super Like Card
            QuickStatCardNew(
                icon: "star.fill",
                iconColor: Color(red: 0, green: 0.83, blue: 1.0),
                count: "\(superLikeCount)",
                title: "Super Like",
                actionText: "DAHA FAZLA AL",
                showPlus: true,
                colors: colors
            ) {
                showSuperLikeSheet = true
            }
            
            // Boost Card (opens combined sheet)
            QuickStatCardNew(
                icon: "bolt.fill",
                iconColor: Color(red: 0.62, green: 0.31, blue: 0.87),
                count: "\(boostCount)",
                title: "Boost'larım",
                actionText: "DAHA FAZLA AL",
                showPlus: true,
                colors: colors
            ) {
                showBoostSheet = true
            }
            
            // Subscriptions Card
            QuickStatCardNew(
                icon: "flame.fill",
                iconColor: Color(red: 1.0, green: 0.42, blue: 0.42),
                count: nil,
                title: "Abonelikler",
                actionText: "GÖRÜNTÜLE",
                showPlus: false,
                colors: colors
            ) {
                showSubscriptionSheet = true
            }
        }
        .onAppear { loadCounts() }
        .sheet(isPresented: $showSuperLikeSheet) {
            SuperLikePurchaseSheet(currentCount: $superLikeCount)
        }
        .sheet(isPresented: $showBoostSheet) {
            BoostDiamondCombinedSheet()
        }
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionSheet()
        }
    }
    
    private func loadCounts() {
        superLikeCount = UserDefaults.standard.integer(forKey: ProfileKeys.superLikes)
        boostCount = UserDefaults.standard.integer(forKey: ProfileKeys.boosts)
        
        Task {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            do {
                let doc = try await Firestore.firestore().collection("users").document(uid).getDocument()
                let data = doc.data() ?? [:]
                
                await MainActor.run {
                    superLikeCount = data["superlike_count"] as? Int ?? superLikeCount
                    boostCount = data["boost_count"] as? Int ?? boostCount
                }
            } catch {
                print("❌ [QuickStatsRowView] Error loading counts: \(error)")
            }
        }
    }
}

// MARK: - Super Like Purchase Sheet
struct SuperLikePurchaseSheet: View {
    @Binding var currentCount: Int
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var showPurchasedAlert = false
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    
    var body: some View {
        ZStack {
            colors.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(colors.tertiaryText)
                    }
                }
                .padding(.horizontal)
                
                // Icon
                ZStack {
                    Circle()
                        .fill(RadialGradient(colors: [Color.cyan.opacity(0.4), Color.clear], center: .center, startRadius: 20, endRadius: 80))
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom))
                }
                
                Text("Super Like")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                
                Text("Mevcut: \(currentCount)")
                    .font(.system(size: 16))
                    .foregroundStyle(colors.secondaryText)
                
                Text("Super Like ile öne çık ve eşleşme şansını 3 kat artır!")
                    .font(.system(size: 15))
                    .foregroundStyle(colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Spacer()
                
                // Purchase Options
                VStack(spacing: 12) {
                    ThemedPurchaseOptionRow(count: 5, price: "₺29.99", isPopular: false, colors: colors) { purchase(5) }
                    ThemedPurchaseOptionRow(count: 15, price: "₺69.99", isPopular: true, colors: colors) { purchase(15) }
                    ThemedPurchaseOptionRow(count: 30, price: "₺119.99", isPopular: false, colors: colors) { purchase(30) }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 16)
        }
        .alert("Satın Alındı ✓", isPresented: $showPurchasedAlert) {
            Button("Tamam") { dismiss() }
        } message: {
            Text("\(currentCount) Super Like hesabına eklendi!")
        }
    }
    
    private func purchase(_ amount: Int) {
        currentCount += amount
        UserDefaults.standard.set(currentCount, forKey: ProfileKeys.superLikes)
        Task { await LogService.shared.info("Super Like satın alındı", category: "Purchase", metadata: ["amount": "\(amount)"]) }
        showPurchasedAlert = true
    }
}

// MARK: - Boost Purchase Sheet
struct BoostPurchaseSheet: View {
    @Binding var currentCount: Int
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var showPurchasedAlert = false
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    
    var body: some View {
        ZStack {
            colors.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(colors.tertiaryText)
                    }
                }
                .padding(.horizontal)
                
                ZStack {
                    Circle()
                        .fill(RadialGradient(colors: [Color.purple.opacity(0.4), Color.clear], center: .center, startRadius: 20, endRadius: 80))
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)
                    
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(LinearGradient(colors: [.purple, .pink], startPoint: .top, endPoint: .bottom))
                }
                
                Text("Boost")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                
                Text("Mevcut: \(currentCount)")
                    .font(.system(size: 16))
                    .foregroundStyle(colors.secondaryText)
                
                Text("30 dakika boyunca profilini öne çıkar ve 10 kat daha fazla görüntülenme al!")
                    .font(.system(size: 15))
                    .foregroundStyle(colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Spacer()
                
                VStack(spacing: 12) {
                    ThemedPurchaseOptionRow(count: 1, price: "₺39.99", isPopular: false, colors: colors) { purchase(1) }
                    ThemedPurchaseOptionRow(count: 5, price: "₺149.99", isPopular: true, colors: colors) { purchase(5) }
                    ThemedPurchaseOptionRow(count: 10, price: "₺249.99", isPopular: false, colors: colors) { purchase(10) }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 16)
        }
        .alert("Satın Alındı ✓", isPresented: $showPurchasedAlert) {
            Button("Tamam") { dismiss() }
        } message: {
            Text("\(currentCount) Boost hesabına eklendi!")
        }
    }
    
    private func purchase(_ amount: Int) {
        currentCount += amount
        UserDefaults.standard.set(currentCount, forKey: ProfileKeys.boosts)
        Task { await LogService.shared.info("Boost satın alındı", category: "Purchase", metadata: ["amount": "\(amount)"]) }
        showPurchasedAlert = true
    }
}

// MARK: - Themed Purchase Option Row
struct ThemedPurchaseOptionRow: View {
    let count: Int
    let price: String
    let isPopular: Bool
    let colors: ThemeColors
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text("\(count) adet")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(colors.primaryText)
                
                if isPopular {
                    Text("EN İYİ FİYAT")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green, in: Capsule())
                }
                
                Spacer()
                
                Text(price)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isPopular ? .green : colors.primaryText)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isPopular ? Color.green.opacity(0.5) : colors.border, lineWidth: isPopular ? 2 : 1)
                    )
            )
        }
    }
}

// MARK: - Subscription Sheet (Full VibeU Gold)
struct SubscriptionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var selectedPlanIndex = 1
    @State private var showActivatedAlert = false
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    
    private let plans = [
        (duration: "1 Hafta", price: "₺79.99", perWeek: "₺79.99/hafta", isPopular: false),
        (duration: "1 Ay", price: "₺149.99", perWeek: "₺37.50/hafta", isPopular: true),
        (duration: "6 Ay", price: "₺449.99", perWeek: "₺18.75/hafta", isPopular: false)
    ]
    
    var body: some View {
        ZStack {
            colors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Close button
                    HStack {
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(colors.tertiaryText)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Header with icon
                    ZStack {
                        Circle()
                            .fill(RadialGradient(colors: [Color.orange.opacity(0.4), Color.clear], center: .center, startRadius: 20, endRadius: 80))
                            .frame(width: 140, height: 140)
                            .blur(radius: 20)
                        
                        Image(systemName: "flame.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom))
                    }
                    
                    // Title
                    HStack(spacing: 8) {
                        Text("VibeU")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        
                        Text("GOLD")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.yellow, in: RoundedRectangle(cornerRadius: 6))
                    }
                    
                    Text("Tüm premium özelliklere eriş!")
                        .font(.system(size: 16))
                        .foregroundStyle(colors.secondaryText)
                    
                    // Features
                    VStack(spacing: 14) {
                        ThemedGoldFeatureRow(icon: "heart.fill", text: "Sınırsız Beğeni", color: .pink, colors: colors)
                        ThemedGoldFeatureRow(icon: "star.fill", text: "5 Super Like / Gün", color: .cyan, colors: colors)
                        ThemedGoldFeatureRow(icon: "bolt.fill", text: "1 Boost / Ay", color: .purple, colors: colors)
                        ThemedGoldFeatureRow(icon: "eye.fill", text: "Seni Kimlerin Beğendiğini Gör", color: .green, colors: colors)
                        ThemedGoldFeatureRow(icon: "arrow.uturn.backward", text: "Geri Alma", color: .orange, colors: colors)
                        ThemedGoldFeatureRow(icon: "mappin.circle.fill", text: "Konum Değiştir", color: .blue, colors: colors)
                        ThemedGoldFeatureRow(icon: "eye.slash.fill", text: "Gizli Mod", color: .gray, colors: colors)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    
                    // Plan Selection
                    VStack(spacing: 12) {
                        ForEach(Array(plans.enumerated()), id: \.offset) { index, plan in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedPlanIndex = index
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 8) {
                                            Text(plan.duration)
                                                .font(.system(size: 17, weight: .semibold))
                                                .foregroundStyle(colors.primaryText)
                                            if plan.isPopular {
                                                Text("EN POPÜLER")
                                                    .font(.system(size: 9, weight: .bold))
                                                    .foregroundStyle(.black)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Color.yellow, in: Capsule())
                                            }
                                        }
                                        Text(plan.perWeek)
                                            .font(.system(size: 13))
                                            .foregroundStyle(colors.secondaryText)
                                    }
                                    Spacer()
                                    
                                    // Radio button
                                    ZStack {
                                        Circle()
                                            .stroke(selectedPlanIndex == index ? Color.yellow : colors.border, lineWidth: 2)
                                            .frame(width: 22, height: 22)
                                        
                                        if selectedPlanIndex == index {
                                            Circle()
                                                .fill(Color.yellow)
                                                .frame(width: 12, height: 12)
                                        }
                                    }
                                    
                                    Text(plan.price)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(selectedPlanIndex == index ? .yellow : colors.primaryText)
                                        .frame(width: 80, alignment: .trailing)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(colors.cardBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(selectedPlanIndex == index ? Color.yellow.opacity(0.5) : colors.border, lineWidth: selectedPlanIndex == index ? 2 : 1)
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Purchase Button - Activates premium for testing
                    Button {
                        activatePremium()
                    } label: {
                        Text("Satın Al - \(plans[selectedPlanIndex].price)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing),
                                in: RoundedRectangle(cornerRadius: 28)
                            )
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Terms
                    Text("Abonelik otomatik olarak yenilenir. İstediğin zaman iptal edebilirsin.")
                        .font(.system(size: 12))
                        .foregroundStyle(colors.tertiaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Color.clear.frame(height: 20)
                }
                .padding(.top, 16)
            }
        }
        .alert("Premium Aktif! 🎉", isPresented: $showActivatedAlert) {
            Button("Harika!") { dismiss() }
        } message: {
            Text("VibeU Gold \(plans[selectedPlanIndex].duration) aboneliğin aktif edildi!")
        }
    }
    
    private func activatePremium() {
        // Activate premium for testing (no payment)
        UserDefaults.standard.set(true, forKey: ProfileKeys.isPremium)
        UserDefaults.standard.set(true, forKey: "isPremium")
        UserDefaults.standard.synchronize()
        
        // Update AppState
        appState.currentUser?.isPremium = true
        appState.isPremium = true
        
        // Give bonus super likes and boosts
        let currentSuperLikes = UserDefaults.standard.integer(forKey: ProfileKeys.superLikes)
        let currentBoosts = UserDefaults.standard.integer(forKey: ProfileKeys.boosts)
        UserDefaults.standard.set(currentSuperLikes + 5, forKey: ProfileKeys.superLikes)
        UserDefaults.standard.set(currentBoosts + 1, forKey: ProfileKeys.boosts)
        UserDefaults.standard.synchronize()
        
        Task {
            await LogService.shared.info("Premium aktif edildi (TEST)", category: "Purchase", metadata: [
                "plan": plans[selectedPlanIndex].duration,
                "price": plans[selectedPlanIndex].price,
                "isPremium": "true"
            ])
        }
        showActivatedAlert = true
    }
}

// MARK: - Themed Gold Feature Row
struct ThemedGoldFeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    let colors: ThemeColors
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
                .frame(width: 28)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundStyle(colors.primaryText)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(.green)
        }
    }
}

struct GoldFeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
                .frame(width: 28)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundStyle(.white)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(.green)
        }
    }
}

struct PurchaseOptionRow: View {
    let count: Int
    let price: String
    let isPopular: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text("\(count) adet")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                
                if isPopular {
                    Text("EN İYİ FİYAT")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green, in: Capsule())
                }
                
                Spacer()
                
                Text(price)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isPopular ? .green : .white)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(white: 0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isPopular ? Color.green.opacity(0.5) : Color(white: 0.2), lineWidth: isPopular ? 2 : 1)
                    )
            )
        }
    }
}

struct QuickStatCardNew: View {
    let icon: String
    let iconColor: Color
    let count: String?
    let title: String
    let actionText: String?
    let showPlus: Bool
    var colors: ThemeColors = .dark
    let action: () -> Void
    
    private var isDark: Bool { colors.background == ThemeColors.dark.background }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Plus button in top right
                HStack {
                    Spacer()
                    if showPlus {
                        ZStack {
                            Circle()
                                .fill(colors.secondaryBackground)
                                .frame(width: 24, height: 24)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(colors.secondaryText)
                        }
                    } else {
                        Color.clear.frame(width: 24, height: 24)
                    }
                }
                
                // Icon with glow effect and count badge
                ZStack {
                    // Glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    iconColor.opacity(0.5),
                                    iconColor.opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 5,
                                endRadius: 30
                            )
                        )
                        .frame(width: 60, height: 60)
                        .blur(radius: 10)
                    
                    // Icon
                    Image(systemName: icon)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    iconColor,
                                    iconColor.opacity(0.8)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: iconColor.opacity(0.5), radius: 6, x: 0, y: 3)
                    
                    // Count badge
                    if let count = count {
                        Text(count)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(iconColor, in: Capsule())
                            .offset(x: 18, y: -14)
                    }
                }
                .frame(height: 44)
                
                // Title
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(colors.secondaryText)
                
                // Action text or spacer
                if let actionText = actionText {
                    Text(actionText)
                        .font(.system(size: 8, weight: .heavy, design: .rounded))
                        .foregroundStyle(iconColor)
                } else {
                    Text(" ")
                        .font(.system(size: 8, weight: .heavy))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(colors.border, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(isDark ? 0.25 : 0.08), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Scale animation button style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Profile Menu Section (Premium Redesign)
struct ProfileMenuSection: View {
    var colors: ThemeColors = .dark
    
    var body: some View {
        VStack(spacing: 0) {
            // Photos - camera with sparkle
            NavigationLink { PhotosEditView() } label: {
                ProfileMenuRowMinimal(icon: "camera.fill", title: "Fotoğraflar", subtitle: "Profilini öne çıkar", colors: colors)
            }
            
            MinimalDivider(colors: colors)
            
            // Interests - sparkles for interests
            NavigationLink { InterestsEditView() } label: {
                ProfileMenuRowMinimal(icon: "sparkles", title: "İlgi Alanları", subtitle: "Ortak noktalarını bul", colors: colors)
            }
            
            MinimalDivider(colors: colors)
            
            // Social Media - at symbol
            NavigationLink { SocialLinksEditView() } label: {
                ProfileMenuRowMinimal(icon: "at", title: "Sosyal Medya", subtitle: "Hesaplarını bağla", colors: colors)
            }
            
            MinimalDivider(colors: colors)
            
            // QR Profile
            NavigationLink { QRProfileView() } label: {
                ProfileMenuRowMinimal(icon: "qrcode.viewfinder", title: "QR Profilim", subtitle: "Hızlıca paylaş", colors: colors)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(colors.border, lineWidth: 1)
                )
        )
    }
}

struct ProfileMenuRowMinimal: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var colors: ThemeColors = .dark
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon with subtle background
            RoundedRectangle(cornerRadius: 10)
                .fill(colors.secondaryBackground)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(colors.secondaryText)
                )
            
            // Title and subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(colors.primaryText)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(colors.tertiaryText)
                }
            }
            
            Spacer()
            
            // Simple chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(colors.tertiaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

struct MinimalDivider: View {
    var colors: ThemeColors = .dark
    
    var body: some View {
        Rectangle()
            .fill(Color(white: 0.17))
            .frame(height: 0.5)
            .padding(.leading, 70)
    }
}

struct ProfileMenuRow: View {
    let icon: String
    let title: String
    let color: Color
    var colors: ThemeColors = .dark
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
                .frame(width: 28)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(colors.primaryText)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(colors.tertiaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

// MARK: - Account Section
struct AccountSection: View {
    let viewModel: ProfileViewModel
    let appState: AppState
    var colors: ThemeColors = .dark
    
    var body: some View {
        VStack(spacing: 0) {
            Button { viewModel.showLogoutConfirm = true } label: {
                ProfileMenuRow(icon: "rectangle.portrait.and.arrow.right", title: "Çıkış Yap", color: .orange, colors: colors)
            }
        }
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Settings Sheet View
struct SettingsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var notificationsEnabled = true
    @State private var locationEnabled = true
    @State private var showDeleteConfirm = false
    
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
                
                List {
                    // Appearance Section
                    Section("Görünüm") {
                        NavigationLink {
                            ThemeSettingsView()
                        } label: {
                            ThemedSettingsRow(icon: "moon.fill", iconColor: .purple, title: "Tema", value: appState.currentTheme.displayName, colors: colors)
                        }
                        .listRowBackground(colors.cardBackground)
                        
                        NavigationLink {
                            LanguageSettingsView()
                        } label: {
                            ThemedSettingsRow(icon: "globe", iconColor: .blue, title: "Dil", value: appState.currentLanguage.displayName, colors: colors)
                        }
                        .listRowBackground(colors.cardBackground)
                    }
                    
                    // Notifications Section
                    Section("Bildirimler") {
                        Toggle(isOn: $notificationsEnabled) {
                            ThemedSettingsRowLabel(icon: "bell.fill", iconColor: .orange, title: "Bildirimler", colors: colors)
                        }
                        .tint(.cyan)
                        .listRowBackground(colors.cardBackground)
                        .onChange(of: notificationsEnabled) { _, newValue in
                            UserDefaults.standard.set(newValue, forKey: "notifications_enabled")
                            Task { await LogService.shared.info("Bildirimler değiştirildi", category: "Settings", metadata: ["enabled": "\(newValue)"]) }
                        }
                        
                        Toggle(isOn: $locationEnabled) {
                            ThemedSettingsRowLabel(icon: "location.fill", iconColor: .green, title: "Konum", colors: colors)
                        }
                        .tint(.cyan)
                        .listRowBackground(colors.cardBackground)
                        .onChange(of: locationEnabled) { _, newValue in
                            UserDefaults.standard.set(newValue, forKey: "location_enabled")
                            Task { await LogService.shared.info("Konum değiştirildi", category: "Settings", metadata: ["enabled": "\(newValue)"]) }
                        }
                    }
                    
                    // Account Section
                    Section("Hesap") {
                        NavigationLink {
                            PrivacySettingsView()
                        } label: {
                            ThemedSettingsRow(icon: "hand.raised.fill", iconColor: .pink, title: "Gizlilik", value: nil, colors: colors)
                        }
                        .listRowBackground(colors.cardBackground)
                        
                        NavigationLink {
                            BlockedUsersView()
                        } label: {
                            ThemedSettingsRow(icon: "person.crop.circle.badge.xmark", iconColor: .red, title: "Engellenenler", value: nil, colors: colors)
                        }
                        .listRowBackground(colors.cardBackground)
                    }
                    
                    // Support Section
                    Section("Destek") {
                        Button {
                            if let url = URL(string: "https://vibeu.app/help") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            ThemedSettingsRow(icon: "questionmark.circle.fill", iconColor: .cyan, title: "Yardım Merkezi", value: nil, colors: colors)
                        }
                        .listRowBackground(colors.cardBackground)
                        
                        Button {
                            if let url = URL(string: "mailto:destek@vibeu.app") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            ThemedSettingsRow(icon: "envelope.fill", iconColor: .blue, title: "Bize Ulaşın", value: nil, colors: colors)
                        }
                        .listRowBackground(colors.cardBackground)
                    }
                    
                    // About Section
                    Section {
                        HStack {
                            Text("Sürüm")
                                .foregroundStyle(colors.primaryText)
                            Spacer()
                            Text(Bundle.main.appVersion)
                                .foregroundStyle(colors.secondaryText)
                        }
                        .listRowBackground(colors.cardBackground)
                    }
                    
                    // Danger Zone
                    Section {
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Hesabı Sil")
                            }
                            .foregroundStyle(.red)
                        }
                        .listRowBackground(colors.cardBackground)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tamam") { dismiss() }
                        .foregroundStyle(.cyan)
                }
            }
            .onAppear {
                notificationsEnabled = UserDefaults.standard.bool(forKey: "notifications_enabled")
                locationEnabled = UserDefaults.standard.bool(forKey: "location_enabled")
                Task { await LogService.shared.info("Ayarlar açıldı", category: "Settings") }
            }
            .alert("Hesabı Sil", isPresented: $showDeleteConfirm) {
                Button("İptal", role: .cancel) {}
                Button("Sil", role: .destructive) {
                    Task { await LogService.shared.info("Hesap silme istendi", category: "Settings") }
                }
            } message: {
                Text("Bu işlem geri alınamaz. Tüm verileriniz silinecektir.")
            }
        }
    }
}

struct ThemedSettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String?
    let colors: ThemeColors
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(iconColor)
                .frame(width: 28)
            Text(title)
                .foregroundStyle(colors.primaryText)
            Spacer()
            if let value = value {
                Text(value)
                    .foregroundStyle(colors.secondaryText)
            }
        }
    }
}

struct ThemedSettingsRowLabel: View {
    let icon: String
    let iconColor: Color
    let title: String
    let colors: ThemeColors
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(iconColor)
                .frame(width: 28)
            Text(title)
                .foregroundStyle(colors.primaryText)
        }
    }
}

// MARK: - Safety Settings Sheet
struct SafetySettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var hideAge = false
    @State private var hideDistance = false
    @State private var hideOnlineStatus = false
    @State private var readReceipts = true
    
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
                
                List {
                    Section("Gizlilik") {
                        Toggle(isOn: $hideAge) {
                            ThemedSettingsRowLabel(icon: "calendar", iconColor: .orange, title: "Yaşımı Gizle", colors: colors)
                        }
                        .tint(.cyan)
                        .listRowBackground(colors.cardBackground)
                        
                        Toggle(isOn: $hideDistance) {
                            ThemedSettingsRowLabel(icon: "location.slash.fill", iconColor: .green, title: "Mesafeyi Gizle", colors: colors)
                        }
                        .tint(.cyan)
                        .listRowBackground(colors.cardBackground)
                        
                        Toggle(isOn: $hideOnlineStatus) {
                            ThemedSettingsRowLabel(icon: "circle.fill", iconColor: .green, title: "Çevrimiçi Durumu Gizle", colors: colors)
                        }
                        .tint(.cyan)
                        .listRowBackground(colors.cardBackground)
                    }
                    
                    Section("Güvenlik") {
                        NavigationLink {
                            ReportUserView()
                        } label: {
                            ThemedSettingsRow(icon: "exclamationmark.triangle.fill", iconColor: .yellow, title: "Kullanıcı Bildir", value: nil, colors: colors)
                        }
                        .listRowBackground(colors.cardBackground)
                        
                        NavigationLink {
                            SafetyTipsView()
                        } label: {
                            ThemedSettingsRow(icon: "shield.checkered", iconColor: .cyan, title: "Güvenlik İpuçları", value: nil, colors: colors)
                        }
                        .listRowBackground(colors.cardBackground)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Güvenlik")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kaydet") { saveSettings() }
                        .foregroundStyle(.cyan)
                }
            }
            .onAppear { loadSettings() }
        }
    }
    
    private func loadSettings() {
        hideAge = UserDefaults.standard.bool(forKey: "safety_hideAge")
        hideDistance = UserDefaults.standard.bool(forKey: "safety_hideDistance")
        hideOnlineStatus = UserDefaults.standard.bool(forKey: "safety_hideOnlineStatus")
        readReceipts = UserDefaults.standard.bool(forKey: "safety_readReceipts")
        Task { await LogService.shared.info("Güvenlik ayarları açıldı", category: "Safety") }
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(hideAge, forKey: "safety_hideAge")
        UserDefaults.standard.set(hideDistance, forKey: "safety_hideDistance")
        UserDefaults.standard.set(hideOnlineStatus, forKey: "safety_hideOnlineStatus")
        UserDefaults.standard.set(readReceipts, forKey: "safety_readReceipts")
        Task { 
            await LogService.shared.info("Güvenlik ayarları kaydedildi", category: "Safety", metadata: [
                "hideAge": "\(hideAge)",
                "hideDistance": "\(hideDistance)",
                "hideOnlineStatus": "\(hideOnlineStatus)",
                "readReceipts": "\(readReceipts)"
            ]) 
        }
        dismiss()
    }
}

// MARK: - Privacy Settings View
struct PrivacySettingsView: View {
    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.02, blue: 0.08).ignoresSafeArea()
            Text("Gizlilik Ayarları")
                .foregroundStyle(.white)
        }
        .navigationTitle("Gizlilik")
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Blocked Users View
struct BlockedUsersView: View {
    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.02, blue: 0.08).ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle.badge.xmark")
                    .font(.system(size: 50))
                    .foregroundStyle(Color(white: 0.4))
                Text("Engellenen kullanıcı yok")
                    .foregroundStyle(Color(white: 0.5))
            }
        }
        .navigationTitle("Engellenenler")
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Report User View
struct ReportUserView: View {
    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.02, blue: 0.08).ignoresSafeArea()
            Text("Kullanıcı Bildir")
                .foregroundStyle(.white)
        }
        .navigationTitle("Bildir")
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Safety Tips View
struct SafetyTipsView: View {
    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.02, blue: 0.08).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SafetyTipCard(icon: "person.badge.shield.checkmark.fill", title: "Kişisel Bilgiler", description: "Adres, telefon numarası gibi kişisel bilgilerinizi paylaşmayın.")
                    SafetyTipCard(icon: "video.fill", title: "Video Görüşme", description: "Buluşmadan önce video görüşme yapın.")
                    SafetyTipCard(icon: "mappin.and.ellipse", title: "Halka Açık Yerler", description: "İlk buluşmalarınızı halka açık yerlerde yapın.")
                    SafetyTipCard(icon: "person.2.fill", title: "Arkadaşlarınıza Söyleyin", description: "Nereye gittiğinizi birine söyleyin.")
                }
                .padding()
            }
        }
        .navigationTitle("Güvenlik İpuçları")
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct SafetyTipCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(.cyan)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Text(description)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(white: 0.6))
            }
        }
        .padding(16)
        .background(Color(white: 0.1), in: RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Bundle Extension
extension Bundle {
    var appVersion: String {
        (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
    }
}

// MARK: - Boost + Diamond Combined Sheet
struct BoostDiamondCombinedSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    
    @State private var selectedTab = 0 // 0 = Diamond, 1 = Boost
    @State private var boostCount = 0
    @State private var diamondBalance = 0
    @State private var canClaimReward = true
    @State private var isClaiming = false
    @State private var isLoading = true
    
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
                    // Tab Picker
                    Picker("", selection: $selectedTab) {
                        Text("💎 Elmas").tag(0)
                        Text("⚡ Boost").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    if isLoading {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else {
                        TabView(selection: $selectedTab) {
                            // Diamond Tab
                            diamondTabContent
                                .tag(0)
                            
                            // Boost Tab
                            boostTabContent
                                .tag(1)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                    }
                }
            }
            .navigationTitle("Boost & Elmas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(colors.tertiaryText)
                    }
                }
            }
        }
        .task { await loadData() }
    }
    
    // MARK: - Diamond Tab
    private var diamondTabContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Balance
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 50))
                        .foregroundStyle(LinearGradient(colors: [.cyan, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    
                    Text("\(diamondBalance)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(colors.primaryText)
                    
                    Text("Elmas")
                        .font(.subheadline)
                        .foregroundStyle(colors.secondaryText)
                }
                .padding(.top, 20)
                
                // Daily Reward
                if canClaimReward {
                    Button {
                        Task { await claimDailyReward() }
                    } label: {
                        HStack {
                            if isClaiming {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "gift.fill")
                                Text("Günlük 100 Elmas Al")
                            }
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(isClaiming)
                    .padding(.horizontal)
                } else {
                    HStack {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                        Text("Bugünkü ödülünüzü aldınız!").foregroundStyle(colors.secondaryText)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(colors.secondaryBackground, in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 12) {
                    Text("Elmas Kullanımı").font(.headline).foregroundStyle(colors.primaryText)
                    
                    HStack {
                        Image(systemName: "heart.fill").foregroundStyle(.pink).frame(width: 24)
                        Text("Eşleşme isteği: 10 elmas").foregroundStyle(colors.secondaryText)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Boost Tab
    private var boostTabContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Count
                VStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(LinearGradient(colors: [.purple, .pink], startPoint: .top, endPoint: .bottom))
                    
                    Text("\(boostCount)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(colors.primaryText)
                    
                    Text("Boost")
                        .font(.subheadline)
                        .foregroundStyle(colors.secondaryText)
                }
                .padding(.top, 20)
                
                // Info
                Text("30 dakika boyunca profilini öne çıkar!")
                    .font(.subheadline)
                    .foregroundStyle(colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Purchase Options
                VStack(spacing: 12) {
                    purchaseRow(count: 1, price: "₺39.99")
                    purchaseRow(count: 5, price: "₺149.99", isPopular: true)
                    purchaseRow(count: 10, price: "₺249.99")
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func purchaseRow(count: Int, price: String, isPopular: Bool = false) -> some View {
        Button {} label: {
            HStack {
                Text("\(count) Boost").font(.headline).foregroundStyle(colors.primaryText)
                if isPopular {
                    Text("EN İYİ").font(.caption.bold()).foregroundStyle(.black).padding(.horizontal, 6).padding(.vertical, 2).background(Color.green, in: Capsule())
                }
                Spacer()
                Text(price).font(.headline).foregroundStyle(isPopular ? .green : colors.primaryText)
            }
            .padding()
            .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(isPopular ? Color.green.opacity(0.5) : colors.border, lineWidth: isPopular ? 2 : 1))
        }
    }
    
    private func loadData() async {
        guard let uid = Auth.auth().currentUser?.uid else { isLoading = false; return }
        
        do {
            let doc = try await Firestore.firestore().collection("users").document(uid).getDocument()
            let data = doc.data() ?? [:]
            
            diamondBalance = data["diamond_balance"] as? Int ?? 100
            boostCount = data["boost_count"] as? Int ?? 0
            
            if let lastClaim = data["daily_reward_last_claim_at"] as? Timestamp {
                let istanbul = TimeZone(identifier: "Europe/Istanbul")!
                var calendar = Calendar.current
                calendar.timeZone = istanbul
                let lastDay = calendar.startOfDay(for: lastClaim.dateValue())
                let today = calendar.startOfDay(for: Date())
                canClaimReward = today > lastDay
            } else {
                canClaimReward = true
            }
        } catch {
            print("Error: \(error)")
        }
        isLoading = false
    }
    
    private func claimDailyReward() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        canClaimReward = false
        isClaiming = true
        
        do {
            let db = Firestore.firestore()
            let docRef = db.collection("users").document(uid)
            
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
            
            diamondBalance += 100
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            canClaimReward = true
        }
        isClaiming = false
    }
}
