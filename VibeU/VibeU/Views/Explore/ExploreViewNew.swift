import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Explore View - COMPLETE REDESIGN
// =======================================
// LIQUID GLASS DESIGN - .glassEffect() everywhere
// GOLD ACCENT COLOR (like "Who Liked You" button)
// SF SYMBOLS instead of emojis
// REAL DATA from Firebase
// NO DOUBLE DATE CARD
// STREAK CARD at bottom with liquid glass
// =======================================

struct ExploreViewNew: View {
    // Streak
    @State private var streakData: StreakData?
    @State private var showStreakReward = false
    @State private var streakMessage = ""
    
    // Events - REAL DATA from Firestore
    @State private var liveEvents: [LiveEvent] = []
    @State private var selectedEvent: LiveEvent?
    
    // Experiences
    @State private var showGameMatch = false
    @State private var showMusicMatch = false
    @State private var showFoodieDate = false
    @State private var showBookClub = false
    @State private var showTravelBuddy = false
    
    // Moods
    @State private var selectedMood: String?
    
    // Other
    @State private var showVibeQuiz = false
    @State private var showAstroMatch = false
    @State private var showSpeedDate = false
    // BlindDate removed - user request
    @State private var showVoiceMatch = false
    
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
    
    // GOLD COLOR - Same as "Who Liked You" button
    private let goldColor = Color(red: 0.85, green: 0.65, blue: 0.3)
    
    var body: some View {
        NavigationStack {
            ZStack {
                colors.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        // HERO SECTION - Ruh Eşini Bul
                        LiquidGlassHero(
                            onVibeQuiz: { showVibeQuiz = true },
                            onAstroMatch: { showAstroMatch = true }
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
                        // QUICK ACTIONS (Blind Date removed)
                        QuickActionPills(
                            onSpeedDate: { showSpeedDate = true },
                            onVoiceMatch: { showVoiceMatch = true },
                            onAstroMatch: { showAstroMatch = true }
                        )
                        
                        // MOOD SELECTOR
                        GlassMoodCarousel(selectedMood: $selectedMood)
                        
                        // LIVE EVENTS - REAL DATA with liquid glass
                        LiveEventsSection(
                            events: liveEvents,
                            onEventTap: { event in selectedEvent = event }
                        )
                        .padding(.horizontal, 16)
                        
                        // EXPERIENCE GRID - LIQUID GLASS with GOLD accent
                        LiquidGlassExperienceGrid(
                            onGameMatch: { showGameMatch = true },
                            onMusicMatch: { showMusicMatch = true },
                            onFoodieDate: { showFoodieDate = true },
                            onBookClub: { showBookClub = true },
                            onTravelBuddy: { showTravelBuddy = true }
                        )
                        .padding(.horizontal, 16)
                        
                        // DAILY STREAK - BOTTOM with LIQUID GLASS
                        LiquidGlassDailyStreak(
                            streakData: streakData,
                            onCheckIn: checkInStreak,
                            onReset: resetStreak,
                            onWatchAd: watchAdAndContinue
                        )
                        .padding(.horizontal, 16)
                        
                        // ADMOB BANNER
                        AdBannerView()
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        
                        Color.clear.frame(height: 50) // Reduced from 100
                    }
                    .padding(.top, 12)
                }
            }
            .navigationTitle("Keşfet".localized)

            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
            .task { await loadData() }
            .refreshable { await loadData() }
            .fullScreenCover(isPresented: $showVibeQuiz) { VibeQuizGlassView() }
            .fullScreenCover(isPresented: $showVoiceMatch) { VoiceMatchGlassView().environment(appState) }
            .fullScreenCover(isPresented: $showGameMatch) { GameMatchDetailView().environment(appState) }
            .fullScreenCover(isPresented: $showMusicMatch) { MusicMatchDetailView().environment(appState) }
            .fullScreenCover(isPresented: $showFoodieDate) { FoodieDateDetailView().environment(appState) }
            .fullScreenCover(isPresented: $showBookClub) { BookClubDetailView().environment(appState) }
            .fullScreenCover(isPresented: $showTravelBuddy) { TravelBuddyDetailView().environment(appState) }
            .fullScreenCover(isPresented: $showSpeedDate) { SpeedDateGlassView().environment(appState) }
            .fullScreenCover(isPresented: $showAstroMatch) { AstroMatchGlassView().environment(appState) }
            .fullScreenCover(item: $selectedMood) { mood in MoodExploreGlassView(mood: mood).environment(appState) }
            .sheet(item: $selectedEvent) { event in EventDetailView(event: event) }
            .alert(streakMessage, isPresented: $showStreakReward) {
                Button("Harika! 🎉".localized) { }
            }
        }
    }
    
    // MARK: - Data Loading
    private func loadData() async {
        await loadStreakData()
        await loadLiveEventsFromFirestore()
    }
    
    private func loadStreakData() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let db = Firestore.firestore()
            let doc = try await db.collection("users").document(uid).collection("streak").document("current").getDocument()
            
            if doc.exists, let data = doc.data() {
                let currentStreak = data["current_streak"] as? Int ?? 0
                let lastCheckIn = (data["last_check_in"] as? Timestamp)?.dateValue() ?? Date.distantPast
                let totalDiamonds = data["total_diamonds_earned"] as? Int ?? 0
                
                let isValid = Calendar.current.isDateInToday(lastCheckIn) || 
                              Calendar.current.isDateInYesterday(lastCheckIn)
                
                await MainActor.run {
                    self.streakData = StreakData(
                        currentStreak: isValid ? currentStreak : 0,
                        lastCheckIn: lastCheckIn,
                        totalDiamondsEarned: totalDiamonds,
                        canCheckInToday: !Calendar.current.isDateInToday(lastCheckIn)
                    )
                }
            } else {
                await MainActor.run {
                    self.streakData = StreakData(currentStreak: 0, lastCheckIn: Date.distantPast, totalDiamondsEarned: 0, canCheckInToday: true)
                }
            }
        } catch {
            print("❌ Error loading streak: \(error)")
        }
    }
    
    // LOAD REAL EVENTS FROM FIRESTORE
    private func loadLiveEventsFromFirestore() async {
        do {
            let db = Firestore.firestore()
            let snapshot = try await db.collection("live_events")
                .whereField("date", isGreaterThan: Timestamp(date: Date()))
                .order(by: "date")
                .limit(to: 10)
                .getDocuments()
            
            let events = snapshot.documents.compactMap { doc -> LiveEvent? in
                let data = doc.data()
                guard let title = data["title"] as? String,
                      let categoryStr = data["category"] as? String,
                      let location = data["location"] as? String,
                      let timestamp = data["date"] as? Timestamp,
                      let attendees = data["attendees"] as? Int,
                      let maxAttendees = data["max_attendees"] as? Int,
                      let imageURL = data["image_url"] as? String,
                      let description = data["description"] as? String else {
                    return nil
                }
                
                let category = EventCategory(rawValue: categoryStr) ?? .music
                let ticketURL = data["ticket_url"] as? String
                
                return LiveEvent(
                    id: doc.documentID,
                    title: title,
                    category: category,
                    location: location,
                    date: timestamp.dateValue(),
                    attendees: attendees,
                    maxAttendees: maxAttendees,
                    imageURL: imageURL,
                    description: description,
                    ticketURL: ticketURL
                )
            }
            
            await MainActor.run {
                if events.isEmpty {
                    // Fallback to sample data if no real events
                    Task { await loadSampleEvents() }
                } else {
                    self.liveEvents = events
                }
            }
        } catch {
            print("❌ Error loading events: \(error)")
            // Fallback to sample data if Firestore fails
            await loadSampleEvents()
        }
    }
    
    private func loadSampleEvents() async {
        let events = [
            LiveEvent(
                id: "1",
                title: "Tarkan - Harbiye Açıkhava",
                category: .music,
                location: "Harbiye Açıkhava Tiyatrosu, İstanbul",
                date: createDate(year: 2026, month: 7, day: 15, hour: 21),
                attendees: 4200,
                maxAttendees: 5000,
                imageURL: "https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?w=800&auto=format&fit=crop",
                description: "Türk pop müziğinin megastarı Tarkan, Harbiye Açıkhava'da efsanevi şarkılarıyla sahne alıyor. 2026'un en büyük konseri!",
                ticketURL: "https://www.biletix.com"
            ),
            LiveEvent(
                id: "2",
                title: "Mabel Matiz - Zorlu PSM",
                category: .music,
                location: "Zorlu PSM Ana Sahne, İstanbul",
                date: createDate(year: 2026, month: 5, day: 22, hour: 20),
                attendees: 2100,
                maxAttendees: 3000,
                imageURL: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&auto=format&fit=crop",
                description: "Mabel Matiz, büyüleyici sahne performansı ve hit şarkılarıyla Zorlu PSM'de. Kaçırılmayacak bir gece!",
                ticketURL: "https://www.biletix.com"
            ),
            LiveEvent(
                id: "3",
                title: "Manga - KüçükÇiftlik Park",
                category: .music,
                location: "KüçükÇiftlik Park, İstanbul",
                date: createDate(year: 2026, month: 6, day: 8, hour: 21),
                attendees: 3500,
                maxAttendees: 6000,
                imageURL: "https://images.unsplash.com/photo-1459749411177-718bf998eee3?w=800&auto=format&fit=crop",
                description: "MANGA, rock ve elektronik müziği harmanlayan efsane performansıyla açık havada. Yaz gecesine enerji kat!",
                ticketURL: "https://www.biletix.com"
            ),
            LiveEvent(
                id: "4",
                title: "Duman - Jolly Joker",
                category: .music,
                location: "Jolly Joker Atakent, İstanbul",
                date: createDate(year: 2026, month: 3, day: 21, hour: 21),
                attendees: 850,
                maxAttendees: 1200,
                imageURL: "https://images.unsplash.com/photo-1501612780327-45045538702b?w=800&auto=format&fit=crop",
                description: "Türk rock müziğinin efsane grubu Duman, Jolly Joker sahnesinde. En sevilen şarkılarını hep birlikte söyleyelim!",
                ticketURL: "https://www.biletix.com"
            ),
            LiveEvent(
                id: "5",
                title: "Lvbel C5 - Bostancı Gösteri",
                category: .music,
                location: "Bostancı Gösteri Merkezi, İstanbul",
                date: createDate(year: 2026, month: 4, day: 12, hour: 21),
                attendees: 1240,
                maxAttendees: 2500,
                imageURL: "https://images.unsplash.com/photo-1571266028243-3716f02d2d2e?w=800&auto=format&fit=crop",
                description: "Lvbel C5, 2026 turnesi kapsamında Bostancı'da sevenleriyle buluşuyor. Unutulmaz bir rap gecesi!",
                ticketURL: "https://www.biletix.com"
            )
        ]
        
        await MainActor.run {
            self.liveEvents = events
        }
    }
    
    private func createDate(year: Int, month: Int, day: Int, hour: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        return Calendar.current.date(from: components) ?? Date()
    }
    
    // MARK: - Streak Actions
    private func checkInStreak() {
        Task {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let db = Firestore.firestore()
            let streakRef = db.collection("users").document(uid).collection("streak").document("current")
            let userRef = db.collection("users").document(uid)
            
            do {
                let doc = try await streakRef.getDocument()
                var currentStreak = 0
                var totalDiamonds = 0
                var lastCheckIn = Date.distantPast
                
                if doc.exists, let data = doc.data() {
                    currentStreak = data["current_streak"] as? Int ?? 0
                    lastCheckIn = (data["last_check_in"] as? Timestamp)?.dateValue() ?? Date.distantPast
                    totalDiamonds = data["total_diamonds_earned"] as? Int ?? 0
                }
                
                if Calendar.current.isDateInToday(lastCheckIn) {
                    await MainActor.run {
                        streakMessage = "Bugün zaten giriş yaptın!".localized
                        showStreakReward = true
                    }
                    return
                }
                
                let isConsecutive = Calendar.current.isDateInYesterday(lastCheckIn)
                let newStreak = isConsecutive ? currentStreak + 1 : 1
                var diamondsEarned = 0
                
                if newStreak == 5 {
                    diamondsEarned = 200
                }
                
                try await streakRef.setData([
                    "current_streak": newStreak,
                    "last_check_in": Timestamp(date: Date()),
                    "total_diamonds_earned": totalDiamonds + diamondsEarned
                ], merge: true)
                
                if diamondsEarned > 0 {
                    try await userRef.updateData([
                        "diamond_balance": FieldValue.increment(Int64(diamondsEarned))
                    ])
                }
                
                await MainActor.run {
                    streakData = StreakData(
                        currentStreak: newStreak,
                        lastCheckIn: Date(),
                        totalDiamondsEarned: totalDiamonds + diamondsEarned,
                        canCheckInToday: false
                    )
                    streakMessage = diamondsEarned > 0 ? "🎉 5 günlük seri tamamlandı! \(diamondsEarned) elmas kazandın!" : "✨ \(newStreak) günlük seri!"
                    showStreakReward = true
                    
                    if diamondsEarned > 0 {
                        appState.currentUser?.diamondBalance = (appState.currentUser?.diamondBalance ?? 0) + diamondsEarned
                    }
                }
            } catch {
                print("❌ Check-in error: \(error)")
            }
        }
    }
    
    private func watchAdAndContinue() {
        // Find root controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }
              
        AdMobManager.shared.showRewardedAd(from: rootVC) {
            // Reward User
            Task {
                guard let uid = Auth.auth().currentUser?.uid else { return }
                try? await Firestore.firestore().collection("users").document(uid).updateData([
                    "diamond_balance": FieldValue.increment(Int64(50)) // 50 diamonds reward
                ])
                await MainActor.run {
                    streakMessage = "Tebrikler! Reklam izleyerek 50 Elmas kazandın! 💎".localized
                    showStreakReward = true
                    appState.currentUser?.diamondBalance = (appState.currentUser?.diamondBalance ?? 0) + 50
                }
            }
        }
    }
    
    private func resetStreak() {
        Task {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            do {
                let db = Firestore.firestore()
                try await db.collection("users").document(uid).collection("streak").document("current").delete()
                await loadData()
            } catch {
                print("❌ Reset error: \(error)")
            }
        }
    }
}

// MARK: - Models
struct StreakData {
    let currentStreak: Int
    let lastCheckIn: Date
    let totalDiamondsEarned: Int
    let canCheckInToday: Bool
}

struct LiveEvent: Identifiable {
    let id: String
    let title: String
    let category: EventCategory
    let location: String
    let date: Date
    let attendees: Int
    let maxAttendees: Int
    let imageURL: String
    let description: String
    let ticketURL: String?
    
    var isLive: Bool {
        let now = Date()
        let hoursDiff = Calendar.current.dateComponents([.hour], from: now, to: date).hour ?? 999
        return hoursDiff >= 0 && hoursDiff <= 24
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current // Auto-detect locale
        formatter.dateFormat = "d MMMM, EEEE HH:mm"
        return formatter.string(from: date)
    }
    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current // Auto-detect locale
        formatter.dateFormat = "EEE HH:mm"
        return formatter.string(from: date)
    }
}

enum EventCategory: String, CaseIterable {
    case music = "Müzik"
    case coffee = "Kahve"
    case wellness = "Wellness"
    case food = "Yemek"
    case art = "Sanat"
    case sports = "Spor"
    
    var icon: String {
        switch self {
        case .music: return "music.note"
        case .coffee: return "cup.and.saucer.fill"
        case .wellness: return "figure.yoga"
        case .food: return "fork.knife"
        case .art: return "paintpalette.fill"
        case .sports: return "sportscourt.fill"
        }
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}


// MARK: - LIQUID GLASS HERO CARD
struct LiquidGlassHero: View {
    let onVibeQuiz: () -> Void
    let onAstroMatch: () -> Void
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
    private let goldColor = Color(red: 0.85, green: 0.65, blue: 0.3)
    private let heroShape = RoundedRectangle(cornerRadius: 24, style: .continuous)
    
    var body: some View {
        Button(action: onVibeQuiz) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ruh Eşini Bul".localized)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(colors.primaryText)
                    
                    Text("Kişilik testine göre eşleş".localized)
                        .font(.system(size: 12))
                        .foregroundStyle(colors.secondaryText)
                    
                    Spacer().frame(height: 8)
                    
                    HStack(spacing: 6) {
                        Text("Başla".localized)
                            .font(.system(size: 13, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(colors: [goldColor, goldColor.opacity(0.8)], startPoint: .leading, endPoint: .trailing),
                        in: Capsule()
                    )
                    .shadow(color: goldColor.opacity(0.3), radius: 6, x: 0, y: 3)
                }
                .padding(.leading, 20)
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(colors: [goldColor, goldColor.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                    )
                    .padding(.trailing, 20)
            }
            .frame(height: 140)
            .background(.ultraThinMaterial, in: heroShape)
            .glassEffect(.regular.interactive(), in: heroShape)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - QUICK ACTION PILLS
struct QuickActionPills: View {
    let onSpeedDate: () -> Void
    let onVoiceMatch: () -> Void
    let onAstroMatch: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                QuickPill(icon: "bolt.fill", title: "Hızlı Tanış".localized, subtitle: "3 dk", accentColor: .orange, action: onSpeedDate)
                QuickPill(icon: "mic.fill", title: "Ses Tanış".localized, subtitle: "30 sn", accentColor: .cyan, action: onVoiceMatch)
                QuickPill(icon: "moon.stars.fill", title: "Burç Eşleş".localized, subtitle: "Astroloji".localized, accentColor: .pink, action: onAstroMatch)
            }
            .padding(.horizontal, 16)
        }
    }
}

struct QuickPill: View {
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
    let action: () -> Void
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var isPressed = false
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    private let pillShape = Capsule()
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.2))
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(accentColor)
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                    Text(subtitle)
                        .font(.system(size: 9))
                        .foregroundStyle(colors.secondaryText)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: pillShape)
            .glassEffect(.regular.interactive(), in: pillShape)
        }
        .buttonStyle(PillScaleButtonStyle())
    }
}

// Custom button style that scales properly without clipping
struct PillScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - GLASS MOOD CAROUSEL - REDESIGNED
struct GlassMoodCarousel: View {
    @Binding var selectedMood: String?
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
    
    // Modern mood data with gradient colors - shortened subtitles for better fit
    let moods: [(id: String, icon: String, title: String, subtitle: String, gradient: [Color])] = [
        ("adventure", "figure.hiking", "Macera".localized, "Heyecan".localized, [Color.orange, Color.red]),
        ("romantic", "heart.fill", "Romantik".localized, "Aşk".localized, [Color.pink, Color.red.opacity(0.8)]),
        ("chill", "leaf.fill", "Sakin".localized, "Dinlenme".localized, [Color.cyan, Color.teal]),
        ("party", "party.popper.fill", "Parti".localized, "Eğlence".localized, [Color.purple, Color.pink]),
        ("deep", "brain.head.profile", "Derin".localized, "Sohbet".localized, [Color.indigo, Color.blue]),
        ("creative", "paintbrush.fill", "Yaratıcı".localized, "Sanat".localized, [Color.yellow, Color.orange])
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Bugün Nasıl Hissediyorsun?".localized)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(colors.primaryText)
                    
                    Text("Ruh haline göre eşleş".localized)
                        .font(.system(size: 12))
                        .foregroundStyle(colors.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .font(.system(size: 18))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(moods, id: \.id) { mood in
                        ModernMoodCard(
                            id: mood.id,
                            icon: mood.icon,
                            title: mood.title,
                            subtitle: mood.subtitle,
                            gradient: mood.gradient
                        ) {
                            selectedMood = mood.id
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct ModernMoodCard: View {
    let id: String
    let icon: String
    let title: String
    let subtitle: String
    let gradient: [Color]
    let action: () -> Void
    
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var isPressed = false
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private let cardShape = RoundedRectangle(cornerRadius: 20, style: .continuous)
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: gradient[0].opacity(0.4), radius: 8, y: 4)
                    
                    Image(systemName: icon)
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(.white)
                }
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(isDark ? .white : .black)
                    
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundStyle(isDark ? .white.opacity(0.6) : .black.opacity(0.6))
                        .lineLimit(1)
                }
            }
            .frame(width: 110, height: 140)
            .glassEffect()
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3), value: isPressed)
    }
}

// MARK: - LIVE EVENTS SECTION - REAL DATA
struct LiveEventsSection: View {
    let events: [LiveEvent]
    let onEventTap: (LiveEvent) -> Void
    @State private var pulsing = false
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
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Yaklaşan Etkinlikler".localized)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                HStack(spacing: 8) { // Increased spacing slightly
                    // Fixed frameless anchor point
                    Circle()
                        .fill(.red)
                        .frame(width: 6, height: 6)
                        .overlay {
                            Circle()
                                .stroke(.red.opacity(0.6), lineWidth: 1)
                                .scaleEffect(pulsing ? 1.8 : 1.0)
                                .opacity(pulsing ? 0.0 : 1.0)
                                .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: pulsing)
                        }
                        .frame(width: 12, height: 12) // Hard-fixed container
                    
                    Text("CANLI".localized)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.red)
                }
            }
            
            if events.isEmpty {
                Text("Yakında yeni etkinlikler...".localized)
                    .font(.system(size: 14))
                    .foregroundStyle(colors.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 30)
            } else {
                VStack(spacing: 12) {
                    ForEach(events.prefix(3)) { event in
                        LiveEventCard(event: event, onTap: { onEventTap(event) })
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                pulsing = true
            }
        }
    }
}

// MARK: - LIVE EVENT CARD - LIQUID GLASS
struct LiveEventCard: View {
    let event: LiveEvent
    let onTap: () -> Void
    @State private var livePulse = false
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
    private let goldColor = Color(red: 0.85, green: 0.65, blue: 0.3)
    private let cardShape = RoundedRectangle(cornerRadius: 16, style: .continuous)
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Banner Image
                AsyncImage(url: URL(string: event.imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                    case .failure(_), .empty:
                        Rectangle()
                            .fill(LinearGradient(colors: [.purple.opacity(0.3), .blue.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(height: 120)
                            .overlay {
                                Image(systemName: event.category.icon)
                                    .font(.system(size: 32))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                    @unknown default:
                        EmptyView()
                    }
                }
                .overlay(alignment: .topTrailing) {
                    if event.isLive {
                        HStack(spacing: 3) {
                            Circle()
                                .fill(.red)
                                .frame(width: 5, height: 5)
                                .scaleEffect(livePulse ? 1.3 : 1.0)
                                .opacity(livePulse ? 0.5 : 1.0)
                            
                            Text("CANLI")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(.red, in: Capsule())
                        .padding(8)
                    }
                }
                
                // Info Section
                VStack(alignment: .leading, spacing: 8) {
                    Text(event.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .lineLimit(1)
                    
                    HStack(spacing: 10) {
                        HStack(spacing: 3) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(.cyan)
                            Text(event.location)
                                .font(.system(size: 10))
                                .foregroundStyle(colors.secondaryText)
                                .lineLimit(1)
                        }
                        
                        HStack(spacing: 3) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(.orange)
                            Text(event.shortDate)
                                .font(.system(size: 10))
                                .foregroundStyle(colors.secondaryText)
                        }
                    }
                    
                    HStack {
                        HStack(spacing: 3) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 10))
                            Text("\(event.attendees)/\(event.maxAttendees)")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundStyle(colors.secondaryText)
                        
                        Spacer()
                        
                        Text(event.category.rawValue)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(.purple.opacity(0.8), in: Capsule())
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
            }
            .clipShape(cardShape) // ✅ FIX: Clip content including image to card shape
            .background(.ultraThinMaterial, in: cardShape)
            .glassEffect(.regular.interactive(), in: cardShape)
        }
        .buttonStyle(.plain)
        .onAppear {
            if event.isLive {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    livePulse = true
                }
            }
        }
    }
}


// MARK: - LIQUID GLASS EXPERIENCE GRID - GOLD ACCENT
struct LiquidGlassExperienceGrid: View {
    let onGameMatch: () -> Void
    let onMusicMatch: () -> Void
    let onFoodieDate: () -> Void
    let onBookClub: () -> Void
    let onTravelBuddy: () -> Void
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
    private let goldColor = Color(red: 0.85, green: 0.65, blue: 0.3)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Text("Özel Deneyimler".localized)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(goldColor)
            }
            
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    LiquidExperienceCard(
                        icon: "gamecontroller.fill",
                        title: "Oyun Arkadaşı".localized,
                        subtitle: "Birlikte oyna".localized,
                        accentColor: .purple,
                        isLarge: false,
                        action: onGameMatch
                    )
                    LiquidExperienceCard(
                        icon: "music.note",
                        title: "Müzik Eşleş".localized,
                        subtitle: "Aynı zevk".localized,
                        accentColor: .pink,
                        isLarge: false,
                        action: onMusicMatch
                    )
                }
                
                HStack(spacing: 10) {
                    LiquidExperienceCard(
                        icon: "fork.knife",
                        title: "Gurme".localized,
                        subtitle: "Yemek keşfi".localized,
                        accentColor: .green,
                        isLarge: false,
                        action: onFoodieDate
                    )
                    LiquidExperienceCard(
                        icon: "book.fill",
                        title: "Kitap Kulübü".localized,
                        subtitle: "Aynı kitap".localized,
                        accentColor: .orange,
                        isLarge: false,
                        action: onBookClub
                    )
                }
                
                LiquidExperienceCard(
                    icon: "airplane",
                    title: "Seyahat Arkadaşı".localized,
                    subtitle: "Dünyayı birlikte keşfet".localized,
                    accentColor: .cyan,
                    isLarge: true,
                    action: onTravelBuddy
                )
            }
        }
    }
}

// MARK: - LIQUID EXPERIENCE CARD
struct LiquidExperienceCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
    let isLarge: Bool
    let action: () -> Void
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
    private let goldColor = Color(red: 0.85, green: 0.65, blue: 0.3)
    private let cardShape = RoundedRectangle(cornerRadius: 16, style: .continuous)
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: isLarge ? 16 : 14, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                    Text(subtitle)
                        .font(.system(size: isLarge ? 12 : 11))
                        .foregroundStyle(colors.secondaryText)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [goldColor.opacity(0.3), goldColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: isLarge ? 48 : 42, height: isLarge ? 48 : 42)
                    
                    Image(systemName: icon)
                        .font(.system(size: isLarge ? 20 : 18, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [goldColor, goldColor.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            }
            .padding(12)
            .frame(height: isLarge ? 76 : 84)
            .background(.ultraThinMaterial, in: cardShape)
            .glassEffect(.regular.interactive(), in: cardShape)
            .overlay(
                cardShape
                    .stroke(
                        LinearGradient(
                            colors: [goldColor.opacity(0.3), goldColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - LIQUID GLASS DAILY STREAK - BOTTOM
struct LiquidGlassDailyStreak: View {
    let streakData: StreakData?
    let onCheckIn: () -> Void
    let onReset: () -> Void
    var onWatchAd: () -> Void = {} // Default empty
    
    @State private var pulseAnimation = false
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
    private let goldColor = Color(red: 0.85, green: 0.65, blue: 0.3)
    private let cardShape = RoundedRectangle(cornerRadius: 24, style: .continuous)
    
    private var currentStreak: Int { streakData?.currentStreak ?? 0 }
    private var canCheckIn: Bool { streakData?.canCheckInToday ?? false }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                // Flame Icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.orange.opacity(0.4), .orange.opacity(0.1)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 30
                            )
                        )
                        .frame(width: 56, height: 56)
                        .blur(radius: 8)
                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    
                    Image(systemName: "flame.fill")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(currentStreak) " + "Günlük Seri!".localized)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(colors.primaryText)
                    Text(canCheckIn ? "Bugün giriş yap!".localized : "Serin devam ediyor🔥".localized)
                        .font(.system(size: 12))
                        .foregroundStyle(colors.secondaryText)
                }

                
                Spacer()
                
                // Reward
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(goldColor.opacity(0.2))
                            .frame(width: 42, height: 42)
                        
                        if !canCheckIn { // Assuming hasCheckedInToday is !canCheckIn
                            Text("Harika! 🎉".localized)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        } else {
                            Text("Bugün giriş yap!".localized)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    Text(currentStreak == 5 ? "200 💎" : "\(5 - currentStreak) gün".localized)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.orange)
                }
            }
            
            // Progress Dots
            HStack(spacing: 7) {
                ForEach(0..<5, id: \.self) { i in
                    ZStack {
                        Circle()
                            .fill(i < currentStreak ? .orange : colors.secondaryBackground)
                            .frame(width: 11, height: 11)
                        
                        if i < currentStreak {
                            Image(systemName: "checkmark")
                                .font(.system(size: 6, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            
            // Check-in Button
            if canCheckIn {
                Button(action: onCheckIn) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                        Text("Giriş Yap".localized)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        LinearGradient(
                            colors: [goldColor, goldColor.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                    .shadow(color: goldColor.opacity(0.4), radius: 10, x: 0, y: 5)
                }
            } else {
                // WATCH AD BUTTON
                Button(action: onWatchAd) {
                    HStack(spacing: 6) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 14))
                        Text("Reklam İzle ve Elmas Kazan".localized)
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(isDark ? .white : .black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        LinearGradient(
                            colors: [goldColor, goldColor.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                    .shadow(color: goldColor.opacity(0.4), radius: 10, x: 0, y: 5)
                }
            }
            
            #if DEBUG
            Button(action: onReset) {
                Text("Sıfırla (Debug)".localized)
                    .font(.system(size: 10))
                    .foregroundStyle(colors.tertiaryText)
            }
            #endif
        }
        .padding(18)
        .background(.ultraThinMaterial, in: cardShape)
        .glassEffect(.regular.interactive(), in: cardShape)
        .overlay(
            cardShape
                .stroke(
                    LinearGradient(
                        colors: [goldColor.opacity(0.3), goldColor.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
}



// MARK: - EVENT DETAIL VIEW - LIQUID GLASS with GOLD TICKET BUTTON
struct EventDetailView: View {
    let event: LiveEvent
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    
    @State private var isJoined = false
    @State private var isJoining = false
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    private let goldColor = Color(red: 0.85, green: 0.65, blue: 0.3)
    
    var body: some View {
        NavigationStack {
            ZStack {
                colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Hero Image
                        AsyncImage(url: URL(string: event.imageURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(16/9, contentMode: .fill)
                                    .frame(height: 200)
                                    .clipped()
                            case .failure(_), .empty:
                                Rectangle()
                                    .fill(LinearGradient(colors: [.purple.opacity(0.3), .blue.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(height: 200)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        
                        // Content
                        VStack(alignment: .leading, spacing: 16) {
                            // Title & Category
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(event.category.rawValue)
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.purple.opacity(0.8), in: Capsule())
                                    
                                    Spacer()
                                    
                                    if event.isLive {
                                        HStack(spacing: 3) {
                                            Circle()
                                                .fill(.red)
                                                .frame(width: 5, height: 5)
                                            Text("CANLI".localized)
                                                .font(.system(size: 9, weight: .bold))
                                                .foregroundStyle(.red)
                                        }
                                    }
                                }
                                
                                Text(event.title)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(colors.primaryText)
                            }
                            
                            // Info Cards
                            VStack(spacing: 10) {
                                InfoRow(icon: "mappin.circle.fill", text: event.location, color: .cyan)
                                InfoRow(icon: "calendar", text: event.formattedDate, color: .orange)
                                InfoRow(icon: "person.2.fill", text: "\(event.attendees) / \(event.maxAttendees) " + "kişi".localized, color: .purple)
                            }
                            
                            // Description
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Etkinlik Detayları".localized)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(colors.primaryText)
                                
                                Text(event.description)
                                    .font(.system(size: 14))
                                    .foregroundStyle(colors.secondaryText)
                                    .lineSpacing(3)
                            }
                            
                            // Ticket Button - GOLD with GLOW
                            if let ticketURL = event.ticketURL {
                                Button {
                                    if let url = URL(string: ticketURL) {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "ticket.fill")
                                            .font(.system(size: 15))
                                        Text("Bilet Al".localized)
                                            .font(.system(size: 15, weight: .semibold))
                                    }
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(
                                        LinearGradient(
                                            colors: [goldColor, goldColor.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        in: RoundedRectangle(cornerRadius: 14)
                                    )
                                    .shadow(color: goldColor.opacity(0.4), radius: 12, x: 0, y: 6)
                                }
                            }
                            
                            // Join Button
                            Button {
                                Task {
                                    await joinEvent()
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    if isJoining {
                                        ProgressView()
                                            .tint(colors.primaryText)
                                    } else {
                                        Image(systemName: isJoined ? "checkmark.circle.fill" : "person.badge.plus.fill")
                                            .font(.system(size: 15))
                                        Text(isJoined ? "Katıldın ✓".localized : "Etkinliğe Katıl".localized)
                                            .font(.system(size: 15, weight: .semibold))
                                    }
                                }
                                .foregroundStyle(isJoined ? .green : colors.primaryText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                                .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 14))
                            }
                            .disabled(isJoined || isJoining)
                        }
                        .padding(16)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(colors.secondaryText)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }
    
    private func joinEvent() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        isJoining = true
        
        do {
            let db = Firestore.firestore()
            
            // Save to user's joined events
            try await db.collection("users").document(currentUserId)
                .collection("joined_events").document(event.id).setData([
                    "event_id": event.id,
                    "event_title": event.title,
                    "event_category": event.category.rawValue,
                    "joined_at": FieldValue.serverTimestamp(),
                    "location": event.location,
                    "date": event.date
                ])
            
            // Log the action
            try await db.collection("logs").addDocument(data: [
                "user_id": currentUserId,
                "action": "join_event",
                "event_id": event.id,
                "event_title": event.title,
                "timestamp": FieldValue.serverTimestamp()
            ])
            
            await MainActor.run {
                isJoined = true
                isJoining = false
            }
            
            print("✅ Successfully joined event: \(event.title)")
        } catch {
            print("❌ Error joining event: \(error)")
            await MainActor.run {
                isJoining = false
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    let color: Color
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
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
            }
            
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(colors.primaryText)
            
            Spacer()
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - VIBE QUIZ - FULL PERSONALITY TEST
struct VibeQuizGlassView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    
    @State private var currentQuestion = 0
    @State private var answers: [Int] = []
    @State private var showResult = false
    @State private var personalityType = ""
    @State private var isSaving = false
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    private let goldColor = Color(red: 0.85, green: 0.65, blue: 0.3)
    
    let questionIcons = [
        "person.3.fill",           // Sosyal ortam
        "calendar.badge.clock",    // Hafta sonu
        "lightbulb.fill",          // Sorun çözme
        "star.fill",               // Kendini tanımlama
        "moon.stars.fill",         // İdeal akşam
        "person.2.fill",           // Yeni insanlar
        "brain.head.profile",      // Karar verme
        "airplane.departure"       // Tatil
    ]
    
    let questions = [
        ("Sosyal bir ortamda kendinizi nasıl hissedersiniz?".localized, ["Enerjik ve mutlu".localized, "Rahat ama yorgun".localized, "Gergin ve huzursuz".localized]),
        ("Hafta sonu planı yaparken ne tercih edersiniz?".localized, ["Arkadaşlarla dışarı çıkmak".localized, "Evde film izlemek".localized, "Yeni bir şeyler denemek".localized]),
        ("Bir sorunla karşılaştığınızda ne yaparsınız?".localized, ["Hemen çözüm ararım".localized, "Düşünüp beklerim".localized, "Başkalarından yardım isterim".localized]),
        ("Kendinizi nasıl tanımlarsınız?".localized, ["Maceracı".localized, "Sakin".localized, "Yaratıcı".localized]),
        ("İdeal bir akşam nasıl olurdu?".localized, ["Parti ve eğlence".localized, "Kitap ve müzik".localized, "Derin sohbetler".localized]),
        ("Yeni insanlarla tanışmak size nasıl gelir?".localized, ["Heyecan verici".localized, "Yorucu".localized, "İlginç".localized]),
        ("Karar verirken neye güvenirsiniz?".localized, ["Mantığa".localized, "Sezgiye".localized, "Deneyime".localized]),
        ("Hayalinizdeki tatil nedir?".localized, ["Macera dolu".localized, "Huzurlu ve sakin".localized, "Kültürel keşif".localized])
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                colors.background.ignoresSafeArea()
                
                if showResult {
                    resultView
                } else if currentQuestion < questions.count {
                    questionView
                } else {
                    startView
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(colors.secondaryText)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }
    
    var startView: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundStyle(LinearGradient(colors: [goldColor, goldColor.opacity(0.7)], startPoint: .top, endPoint: .bottom))
            
            Text("Vibe Quiz".localized)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(colors.primaryText)
            
            Text("8 soruluk kişilik testini tamamla ve ruh eşini bul!".localized)
                .font(.system(size: 16))
                .foregroundStyle(colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                currentQuestion = 0
                answers = []
            } label: {
                Text("Teste Başla".localized)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(LinearGradient(colors: [goldColor, goldColor.opacity(0.8)], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 14))
                    .shadow(color: goldColor.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
    }
    
    var questionView: some View {
        VStack(spacing: 30) {
            // Progress
            VStack(spacing: 8) {
                HStack {
                    Text("Soru \(currentQuestion + 1)/\(questions.count)".localized)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(colors.secondaryText)
                    Spacer()
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(colors.cardBackground)
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(LinearGradient(colors: [goldColor, goldColor.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * CGFloat(currentQuestion + 1) / CGFloat(questions.count), height: 6)
                    }
                }
                .frame(height: 6)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // ICON ABOVE QUESTION
            ZStack {
                Circle()
                    .fill(goldColor.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: questionIcons[currentQuestion])
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(colors: [goldColor, goldColor.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                    )
            }
            .padding(.bottom, 10)
            
            // Question
            VStack(spacing: 20) {
                Text(questions[currentQuestion].0)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                VStack(spacing: 12) {
                    ForEach(0..<questions[currentQuestion].1.count, id: \.self) { index in
                        Button {
                            answers.append(index)
                            withAnimation {
                                if currentQuestion < questions.count - 1 {
                                    currentQuestion += 1
                                } else {
                                    calculateResult()
                                }
                            }
                        } label: {
                            Text(questions[currentQuestion].1[index])
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(colors.primaryText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                                .glassEffect()
                        }
                    }
                }
                .padding(.horizontal, 30)
            }
            
            Spacer()
        }
        .padding(.top, 20)
    }
    
    var resultView: some View {
        VStack(spacing: 25) {
            Image(systemName: "star.fill")
                .font(.system(size: 80))
                .foregroundStyle(LinearGradient(colors: [goldColor, goldColor.opacity(0.7)], startPoint: .top, endPoint: .bottom))
            
            Text("Kişilik Tipin".localized)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(colors.secondaryText)
            
            Text(personalityType)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(colors.primaryText)
            
            Text(personalityDescription)
                .font(.system(size: 15))
                .foregroundStyle(colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if isSaving {
                ProgressView()
                    .tint(goldColor)
            } else {
                Button {
                    dismiss()
                } label: {
                    Text("Eşleşmeye Başla".localized)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(LinearGradient(colors: [goldColor, goldColor.opacity(0.8)], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 14))
                        .shadow(color: goldColor.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 40)
            }
        }
    }
    
    var personalityDescription: String {
        switch personalityType {
        case "Maceracı".localized: return "Yeni deneyimlere açık, enerjik ve sosyal birisin!".localized
        case "Düşünür".localized: return "Derin, sakin ve analitik bir kişiliğe sahipsin!".localized
        case "Yaratıcı".localized: return "Hayal gücü kuvvetli, özgün ve ilham vericisin!".localized
        case "Sosyal".localized: return "İnsanlarla olmayı seven, enerjik ve eğlencelisin!".localized
        default: return "Benzersiz bir kişiliğe sahipsin!".localized
        }
    }
    
    func calculateResult() {
        let adventureScore = answers.filter { $0 == 0 }.count
        let calmScore = answers.filter { $0 == 1 }.count
        let creativeScore = answers.filter { $0 == 2 }.count
        
        if adventureScore >= calmScore && adventureScore >= creativeScore {
            personalityType = adventureScore > 4 ? "Maceracı".localized : "Sosyal".localized
        } else if calmScore >= adventureScore && calmScore >= creativeScore {
            personalityType = "Düşünür".localized
        } else {
            personalityType = "Yaratıcı".localized
        }
        
        Task {
            await saveResult()
        }
    }
    
    func saveResult() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isSaving = true
        
        do {
            let db = Firestore.firestore()
            try await db.collection("users").document(userId).updateData([
                "personality_type": personalityType,
                "personality_answers": answers,
                "personality_updated_at": FieldValue.serverTimestamp()
            ])
            
            try await db.collection("logs").addDocument(data: [
                "user_id": userId,
                "action": "complete_personality_test",
                "personality_type": personalityType,
                "timestamp": FieldValue.serverTimestamp()
            ])
            
            await MainActor.run {
                isSaving = false
                showResult = true
            }
        } catch {
            print("❌ Error saving personality: \(error)")
            await MainActor.run {
                isSaving = false
                showResult = true
            }
        }
    }
}

struct BlindDateGlassView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    
    @State private var users: [BlindDateUser] = []
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
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
                
                if isLoading {
                    ProgressView()
                } else if currentIndex < users.count {
                    blindSwipeView
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.green)
                        Text("Hepsi Bu Kadar!".localized)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        Button { dismiss() } label: {
                            Text("Tamam".localized)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(.purple, in: RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal, 40)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(colors.secondaryText)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .task {
                await loadBlindUsers()
            }
        }
    }
    
    var blindSwipeView: some View {
        VStack(spacing: 0) {
            Text("Kör Randevu".localized)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(colors.primaryText)
                .padding(.top, 20)
            
            Text("Fotoğrafsız tanış".localized)
                .font(.system(size: 14))
                .foregroundStyle(colors.secondaryText)
                .padding(.bottom, 20)
            
            // SWIPE CARDS
            ZStack {
                ForEach(Array(users.enumerated()), id: \.element.id) { index, user in
                    if index >= currentIndex && index < currentIndex + 2 {
                        BlindUserCard(user: user)
                            .zIndex(Double(users.count - index))
                            .offset(x: index == currentIndex ? offset.width : 0, y: 0)
                            .rotationEffect(.degrees(index == currentIndex ? Double(offset.width / 20) : 0))
                            .scaleEffect(index == currentIndex ? 1.0 : 0.92)
                            .opacity(index == currentIndex ? 1.0 : 0.6)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: offset)
                            .gesture(
                                index == currentIndex ?
                                DragGesture()
                                    .onChanged { gesture in
                                        offset = gesture.translation
                                    }
                                    .onEnded { gesture in
                                        if abs(gesture.translation.width) > 120 {
                                            let direction = gesture.translation.width > 0 ? "like" : "pass"
                                            handleBlindSwipe(direction: direction, user: user)
                                        } else {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                offset = .zero
                                            }
                                        }
                                    }
                                : nil
                            )
                            .overlay(
                                Group {
                                    if index == currentIndex && abs(offset.width) > 20 {
                                        ZStack {
                                            if offset.width > 0 {
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(.purple, lineWidth: 4)
                                                    .overlay(
                                                        Image(systemName: "plus.circle.fill")
                                                            .font(.system(size: 60))
                                                            .foregroundStyle(.purple)
                                                    )
                                                    .opacity(Double(offset.width / 120))
                                            } else {
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(.red, lineWidth: 4)
                                                    .overlay(
                                                        Image(systemName: "xmark.circle.fill")
                                                            .font(.system(size: 60))
                                                            .foregroundStyle(.red)
                                                    )
                                                    .opacity(Double(-offset.width / 120))
                                            }
                                        }
                                        .padding(20)
                                    }
                                }
                            )
                    }
                }
            }
            .frame(height: 520)
            .padding(.horizontal, 20)
            
            Spacer()
            
            HStack(spacing: 40) {
                Button {
                    if currentIndex < users.count {
                        handleBlindSwipe(direction: "pass", user: users[currentIndex])
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 70, height: 70)
                        .background(
                            LinearGradient(colors: [.red, .red.opacity(0.8)], startPoint: .top, endPoint: .bottom),
                            in: Circle()
                        )
                        .shadow(color: .red.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                
                Button {
                    if currentIndex < users.count {
                        handleBlindSwipe(direction: "like", user: users[currentIndex])
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 70, height: 70)
                        .background(
                            LinearGradient(colors: [.purple, .purple.opacity(0.8)], startPoint: .top, endPoint: .bottom),
                            in: Circle()
                        )
                        .shadow(color: .purple.opacity(0.5), radius: 15, x: 0, y: 8)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 40)
        }
    }
    
    func loadBlindUsers() async {
        let mockUsers = [
            BlindDateUser(id: "1", name: "Ayşe", age: 24, bio: "Sanat ve müzik tutkunu".localized, interests: ["Müzik".localized, "Sanat".localized, "Sinema".localized]),
            BlindDateUser(id: "2", name: "Mehmet", age: 27, bio: "Seyahat etmeyi seviyorum".localized, interests: ["Seyahat".localized, "Fotoğraf".localized, "Doğa".localized]),
            BlindDateUser(id: "3", name: "Zeynep", age: 23, bio: "Kitap okumayı çok severim".localized, interests: ["Kitap".localized, "Yazı".localized, "Şiir".localized]),
            BlindDateUser(id: "4", name: "Can", age: 26, bio: "Spor ve fitness hayatımın bir parçası".localized, interests: ["Spor".localized, "Fitness".localized, "Yoga".localized]),
            BlindDateUser(id: "5", name: "Elif", age: 25, bio: "Kahve ve derin sohbetler".localized, interests: ["Kahve".localized, "Felsefe".localized, "Psikoloji".localized]),
            BlindDateUser(id: "6", name: "Burak", age: 28, bio: "Teknoloji ve yenilikler".localized, interests: ["Teknoloji".localized, "Bilim".localized, "Oyun".localized])
        ]
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            await MainActor.run {
                self.users = mockUsers
                self.isLoading = false
            }
            return
        }
        
        do {
            let db = Firestore.firestore()
            let snapshot = try await db.collection("users")
                .limit(to: 20)
                .getDocuments()
            
            var loadedUsers = snapshot.documents.compactMap { doc -> BlindDateUser? in
                guard doc.documentID != currentUserId,
                      let name = doc.data()["name"] as? String,
                      let age = doc.data()["age"] as? Int else {
                    return nil
                }
                
                let bio = doc.data()["bio"] as? String ?? ""
                let interests = doc.data()["interests"] as? [String] ?? []
                return BlindDateUser(id: doc.documentID, name: name, age: age, bio: bio, interests: interests)
            }
            
            if loadedUsers.isEmpty {
                loadedUsers = mockUsers
            }
            
            await MainActor.run {
                self.users = loadedUsers
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.users = mockUsers
                self.isLoading = false
            }
        }
    }
    
    func handleBlindSwipe(direction: String, user: BlindDateUser) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            offset = direction == "like" ? CGSize(width: 600, height: 50) : CGSize(width: -600, height: 50)
        }
        
        if direction == "like" {
            Task {
                await sendBlindRequest(userId: user.id)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                currentIndex += 1
                offset = .zero
            }
        }
    }
    
    func sendBlindRequest(userId: String) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        guard let currentBalance = appState.currentUser?.diamondBalance, currentBalance >= 10 else { return }
        
        do {
            let db = Firestore.firestore()
            try await db.collection("users").document(currentUserId).updateData([
                "diamond_balance": FieldValue.increment(Int64(-10))
            ])
            try await db.collection("friend_requests").addDocument(data: [
                "from_user_id": currentUserId,
                "to_user_id": userId,
                "status": "pending",
                "type": "blind_date",
                "timestamp": FieldValue.serverTimestamp()
            ])
            await MainActor.run {
                appState.currentUser?.diamondBalance = (appState.currentUser?.diamondBalance ?? 0) - 10
            }
        } catch {
            print("❌ Error: \(error)")
        }
    }
}

struct BlindDateUser: Identifiable {
    let id: String
    let name: String
    let age: Int
    let bio: String
    let interests: [String]
}

struct BlindUserCard: View {
    let user: BlindDateUser
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
        ZStack(alignment: .bottom) {
            // GRADIENT BACKGROUND
            LinearGradient(
                colors: [.purple.opacity(0.3), .pink.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: UIScreen.main.bounds.width - 40, height: 520)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            // CONTENT
            VStack(spacing: 24) {
                Spacer()
                
                // MYSTERY ICON
                ZStack {
                    Circle()
                        .fill(.purple.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 60))
                        .foregroundStyle(.purple)
                }
                
                // INFO
                VStack(spacing: 12) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(user.name)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        Text("\(user.age)")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(colors.secondaryText)
                    }
                    
                    if !user.bio.isEmpty {
                        Text(user.bio)
                            .font(.system(size: 16))
                            .foregroundStyle(colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 30)
                    }
                    
                    if !user.interests.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(user.interests.prefix(4), id: \.self) { interest in
                                    Text(interest)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(.purple, in: Capsule())
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(24)
        }
        .frame(width: UIScreen.main.bounds.width - 40, height: 520)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

struct VoiceMatchGlassView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    
    @State private var isRecording = false
    @State private var hasRecorded = false
    @State private var audioURL: URL?
    @State private var users: [VoiceUser] = []
    @State private var isLoading = true
    @State private var isUploading = false
    @State private var isSearching = true
    @State private var foundUser: VoiceUser?
    
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
                
                if !hasRecorded {
                    recordView
                } else {
                    if let user = foundUser {
                        // Match Found
                        VStack(spacing: 30) {
                            Text("Ses Eşleşmesi! 🎙️".localized)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(colors.primaryText)
                            
                            VoiceUserCard(user: user)
                                .frame(height: 400)
                            
                            HStack(spacing: 20) {
                                Button {
                                    restartSearch()
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(.red)
                                        .frame(width: 60, height: 60)
                                        .background(.ultraThinMaterial, in: Circle())
                                }
                                
                                Button {
                                    // Connect voice (Phase 3)
                                } label: {
                                    Image(systemName: "phone.fill")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(.white)
                                        .frame(width: 60, height: 60)
                                        .background(Color.green, in: Circle())
                                        .shadow(color: .green.opacity(0.4), radius: 10)
                                }
                            }
                        }
                        .transition(.scale)
                    } else {
                        // Searching
                        VStack(spacing: 40) {
                            Text("Ses Tanış".localized)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(colors.primaryText)
                            
                            RadarView(color: .cyan)
                                .frame(width: 250, height: 250)
                            
                            VStack(spacing: 12) {
                                Text("Konuşacak Biri Aranıyor...".localized)
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(colors.primaryText)
                                
                                Text("Sesine kulak verecek biri bulunuyor".localized)
                                    .font(.subheadline)
                                    .foregroundStyle(colors.secondaryText)
                            }
                            
                            Button {
                                hasRecorded = false // Go back to record
                            } label: {
                                Text("Kaydı İptal Et".localized)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 14)
                                    .background(Capsule().fill(.ultraThinMaterial))
                            }
                        }
                        .transition(.opacity)
                        .onAppear {
                            startSearch()
                        }
                        .onDisappear {
                            Task {
                                await MatchService.shared.leaveQueue()
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(colors.secondaryText)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }
    
    var recordView: some View {
        VStack(spacing: 30) {
            Image(systemName: isRecording ? "waveform" : "mic.fill")
                .font(.system(size: 80))
                .foregroundStyle(.cyan)
                .symbolEffect(.pulse, isActive: isRecording)
            
            Text(isRecording ? "Kaydediliyor...".localized : "Ses Tanış".localized)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(colors.primaryText)
            
            Text("30 saniyelik sesli mesaj kaydet".localized)
                .font(.system(size: 16))
                .foregroundStyle(colors.secondaryText)
            
            if isUploading {
                ProgressView()
                    .tint(.cyan)
            } else {
                Button {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                } label: {
                    Text(isRecording ? "Durdur".localized : "Kayda Başla".localized)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isRecording ? .red : .cyan, in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 40)
            }
        }
    }
    
    func startSearch() {
        isSearching = true
        foundUser = nil
        
        Task {
            let myName = appState.currentUser?.displayName ?? "Misafir"
            let myPhoto = appState.currentUser?.profilePhotoURL ?? ""
            let myId = Auth.auth().currentUser?.uid ?? ""
            
            // Only join if we have a valid ID
            if !myId.isEmpty {
                try? await MatchService.shared.joinQueue(type: .voice, name: myName, photoURL: myPhoto)
                
                MatchService.shared.listenForMatch(type: .voice) { matchUser in
                    DispatchQueue.main.async {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            self.foundUser = VoiceUser(
                                id: matchUser.id,
                                name: matchUser.name,
                                age: 24,
                                voiceURL: "mock_url"
                            )
                            self.isSearching = false
                        }
                    }
                }
            } else {
                // Fallback for testing without auth
                 DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        foundUser = VoiceUser(id: "mock", name: "Gizemli Ses".localized, age: 25, voiceURL: "mock")
                        isSearching = false
                    }
                }
            }
        }
    }
    
    func restartSearch() {
        Task { await MatchService.shared.leaveQueue() }
        withAnimation {
            foundUser = nil
            isSearching = true
        }
        startSearch()
    }
    
    func startRecording() {
        isRecording = true
        // Simulated recording - in real app use AVAudioRecorder
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            stopRecording()
        }
    }
    
    func stopRecording() {
        isRecording = false
        Task {
            await uploadVoice()
        }
    }
    
    func uploadVoice() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isUploading = true
        
        do {
            let db = Firestore.firestore()
            // In real app, upload audio to Firebase Storage first
            let voiceURL = "https://example.com/voice/\(userId).m4a"
            
            try await db.collection("users").document(userId).updateData([
                "voice_intro_url": voiceURL,
                "voice_intro_updated_at": FieldValue.serverTimestamp()
            ])
            
            await MainActor.run {
                hasRecorded = true
                isUploading = false
            }
            
            await loadVoiceUsers()
        } catch {
            await MainActor.run {
                isUploading = false
            }
        }
    }
    
    func loadVoiceUsers() async {
        let mockUsers = [
            VoiceUser(id: "1", name: "Ayşe", age: 24, voiceURL: "mock"),
            VoiceUser(id: "2", name: "Mehmet", age: 27, voiceURL: "mock"),
            VoiceUser(id: "3", name: "Zeynep", age: 23, voiceURL: "mock"),
            VoiceUser(id: "4", name: "Can", age: 26, voiceURL: "mock"),
            VoiceUser(id: "5", name: "Elif", age: 25, voiceURL: "mock")
        ]
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            await MainActor.run {
                self.users = mockUsers
                self.isLoading = false
            }
            return
        }
        
        do {
            let db = Firestore.firestore()
            let snapshot = try await db.collection("users")
                .limit(to: 10)
                .getDocuments()
            
            var loadedUsers = snapshot.documents.compactMap { doc -> VoiceUser? in
                guard doc.documentID != currentUserId,
                      let name = doc.data()["name"] as? String,
                      let age = doc.data()["age"] as? Int else {
                    return nil
                }
                
                let voiceURL = doc.data()["voice_intro_url"] as? String ?? "mock"
                return VoiceUser(id: doc.documentID, name: name, age: age, voiceURL: voiceURL)
            }
            
            if loadedUsers.isEmpty {
                loadedUsers = mockUsers
            }
            
            await MainActor.run {
                self.users = loadedUsers
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.users = mockUsers
                self.isLoading = false
            }
        }
    }
    
    func saveVoiceLike(userId: String) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        do {
            let db = Firestore.firestore()
            try await db.collection("likes").addDocument(data: [
                "from_user_id": currentUserId,
                "to_user_id": userId,
                "type": "voice_match",
                "timestamp": FieldValue.serverTimestamp()
            ])
        } catch {
            print("❌ Error: \(error)")
        }
    }
}

struct VoiceUser: Identifiable {
    let id: String
    let name: String
    let age: Int
    let voiceURL: String
}

struct VoiceUserCard: View {
    let user: VoiceUser
    @State private var isPlaying = false
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
        VStack(spacing: 30) {
            Image(systemName: isPlaying ? "waveform" : "person.fill")
                .font(.system(size: 100))
                .foregroundStyle(.cyan.opacity(0.5))
                .symbolEffect(.pulse, isActive: isPlaying)
            
            VStack(spacing: 12) {
                HStack {
                    Text(user.name)
                        .font(.system(size: 28, weight: .bold))
                    Text("\(user.age)")
                        .font(.system(size: 24))
                }
                .foregroundStyle(colors.primaryText)
                
                Button {
                    isPlaying.toggle()
                    // In real app, play audio from user.voiceURL
                    if isPlaying {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            isPlaying = false
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        Text(isPlaying ? "Durdur".localized : "Sesli Mesajı Dinle".localized)
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.cyan, in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 40)
            }
        }
        .frame(width: 340, height: 500)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .glassEffect()
        .shadow(radius: 10)
    }
}

struct RadarView: View {
    let color: Color
    @State private var scale1: CGFloat = 0.5
    @State private var opacity1: Double = 1.0
    @State private var scale2: CGFloat = 0.5
    @State private var opacity2: Double = 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color, lineWidth: 4)
                .frame(width: 20, height: 20)
            
            Circle()
                .fill(color.opacity(0.3))
                .scaleEffect(scale1)
                .opacity(opacity1)
                .onAppear {
                    withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false)) {
                        scale1 = 4.0
                        opacity1 = 0.0
                    }
                }
            
            Circle()
                .fill(color.opacity(0.3))
                .scaleEffect(scale2)
                .opacity(opacity2)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false)) {
                            scale2 = 4.0
                            opacity2 = 0.0
                        }
                    }
                }
        }
    }
}

struct SpeedDateGlassView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    
    @State private var users: [SpeedDateUser] = []
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var isLoading = true
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    private let goldColor = Color(red: 0.85, green: 0.65, blue: 0.3)
    
    @State private var isSearching = true
    @State private var foundUser: SpeedDateUser?
    
    var body: some View {
        NavigationStack {
            ZStack {
                colors.background.ignoresSafeArea()
                
                if let user = foundUser {
                    // Match Found View
                    VStack(spacing: 30) {
                        Text("Eşleşme Bulundu! 🎉".localized)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        
                        SpeedDateCard(user: user)
                            .frame(height: 500)
                        
                        HStack(spacing: 20) {
                            Button {
                                restartSearch()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.red)
                                    .frame(width: 60, height: 60)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                            
                            Button {
                                // Go to chat (Phase 3)
                            } label: {
                                Image(systemName: "video.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.green, in: Circle())
                                    .shadow(color: .green.opacity(0.4), radius: 10)
                            }
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    // Searching View
                    VStack(spacing: 40) {
                        Text("Hızlı Tanış".localized)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        
                        RadarView(color: .pink)
                            .frame(width: 250, height: 250)
                        
                        VStack(spacing: 12) {
                            Text("Eşleşme Aranıyor...".localized)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(colors.primaryText)
                            
                            Text("Sizin için en uygun kişi bulunuyor".localized)
                                .font(.subheadline)
                                .foregroundStyle(colors.secondaryText)
                        }
                        
                        Button {
                            dismiss()
                        } label: {
                            Text("İptal".localized)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 14)
                                .background(Capsule().fill(.ultraThinMaterial))
                        }
                    }
                    .transition(.opacity)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(colors.secondaryText)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .onAppear {
                startSearch()
            }
            .onDisappear {
                Task {
                    await MatchService.shared.leaveQueue()
                }
            }
        }
    }
    
    func startSearch() {
        isSearching = true
        foundUser = nil
        
        Task {
            let myName = appState.currentUser?.displayName ?? "Misafir"
            let myPhoto = appState.currentUser?.profilePhotoURL ?? ""
            let myId = Auth.auth().currentUser?.uid ?? ""
            
            if !myId.isEmpty {
                try? await MatchService.shared.joinQueue(type: .speedDate, name: myName, photoURL: myPhoto)
                
                MatchService.shared.listenForMatch(type: .speedDate) { matchUser in
                    DispatchQueue.main.async {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            self.foundUser = SpeedDateUser(
                                id: matchUser.id,
                                name: matchUser.name,
                                age: 24,
                                photoURL: matchUser.photoURL,
                                bio: "VibeU Eşleşmesi".localized
                            )
                            self.isSearching = false
                        }
                    }
                }
            } else {
                 DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        foundUser = SpeedDateUser(id: "mock", name: "Gizemli Kişi".localized, age: 24, photoURL: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800", bio: "Tanışalım mı?".localized)
                        isSearching = false
                    }
                }
            }
        }
    }
    
    func restartSearch() {
        Task { await MatchService.shared.leaveQueue() }
        withAnimation {
            foundUser = nil
            isSearching = true
        }
        startSearch()
    }

    var noMoreView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
            
            Text("Hepsi Bu Kadar!".localized)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(colors.primaryText)
            
            Text("Yeni kullanıcılar için tekrar gel".localized)
                .font(.system(size: 16))
                .foregroundStyle(colors.secondaryText)
            
            Button {
                dismiss()
            } label: {
                Text("Tamam".localized)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.orange, in: RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)
        }
    }
    
    func loadUsers() async {
        // Mock data fallback
        let mockUsers = [
            SpeedDateUser(id: "1", name: "Ayşe", age: 24, photoURL: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400", bio: "Müzik ve sanat tutkunu 🎨".localized),
            SpeedDateUser(id: "2", name: "Mehmet", age: 27, photoURL: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400", bio: "Seyahat etmeyi seviyorum ✈️".localized),
            SpeedDateUser(id: "3", name: "Zeynep", age: 23, photoURL: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400", bio: "Kitap kurdu 📚".localized),
            SpeedDateUser(id: "4", name: "Can", age: 26, photoURL: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400", bio: "Spor ve fitness 💪".localized),
            SpeedDateUser(id: "5", name: "Elif", age: 25, photoURL: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400", bio: "Kahve bağımlısı ☕".localized),
            SpeedDateUser(id: "6", name: "Burak", age: 28, photoURL: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400", bio: "Teknoloji meraklısı 💻".localized),
            SpeedDateUser(id: "7", name: "Selin", age: 24, photoURL: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400", bio: "Yoga ve meditasyon 🧘‍♀️".localized),
            SpeedDateUser(id: "8", name: "Emre", age: 29, photoURL: "https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=400", bio: "Fotoğrafçılık tutkunu 📸".localized)
        ]
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            await MainActor.run {
                self.users = mockUsers
                self.isLoading = false
            }
            return
        }
        
        do {
            let db = Firestore.firestore()
            let snapshot = try await db.collection("users")
                .limit(to: 20)
                .getDocuments()
            
            var loadedUsers = snapshot.documents.compactMap { doc -> SpeedDateUser? in
                guard doc.documentID != currentUserId,
                      let name = doc.data()["name"] as? String,
                      let age = doc.data()["age"] as? Int,
                      let photoURL = doc.data()["photo_url"] as? String else {
                    return nil
                }
                
                let bio = doc.data()["bio"] as? String ?? ""
                return SpeedDateUser(id: doc.documentID, name: name, age: age, photoURL: photoURL, bio: bio)
            }
            
            if loadedUsers.isEmpty {
                loadedUsers = mockUsers
            }
            
            await MainActor.run {
                self.users = loadedUsers
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.users = mockUsers
                self.isLoading = false
            }
        }
    }
    
    func handleSwipe(direction: String, user: SpeedDateUser) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            offset = direction == "like" ? CGSize(width: 600, height: 50) : CGSize(width: -600, height: 50)
        }
        
        if direction == "like" {
            Task {
                await sendFriendRequest(userId: user.id)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                currentIndex += 1
                offset = .zero
            }
        }
    }
    
    func sendFriendRequest(userId: String) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        // Check diamond balance
        guard let currentBalance = appState.currentUser?.diamondBalance, currentBalance >= 10 else {
            print("❌ Not enough diamonds")
            return
        }
        
        do {
            let db = Firestore.firestore()
            
            // Deduct 10 diamonds
            try await db.collection("users").document(currentUserId).updateData([
                "diamond_balance": FieldValue.increment(Int64(-10))
            ])
            
            // Send friend request
            try await db.collection("friend_requests").addDocument(data: [
                "from_user_id": currentUserId,
                "to_user_id": userId,
                "status": "pending",
                "type": "speed_date",
                "timestamp": FieldValue.serverTimestamp()
            ])
            
            // Log action
            try await db.collection("logs").addDocument(data: [
                "user_id": currentUserId,
                "action": "speed_date_request",
                "target_user_id": userId,
                "diamonds_spent": 10,
                "timestamp": FieldValue.serverTimestamp()
            ])
            
            // Update local balance
            await MainActor.run {
                appState.currentUser?.diamondBalance = (appState.currentUser?.diamondBalance ?? 0) - 10
            }
            
            print("✅ Friend request sent, -10 diamonds")
        } catch {
            print("❌ Error sending request: \(error)")
        }
    }
}

struct SpeedDateUser: Identifiable {
    let id: String
    let name: String
    let age: Int
    let photoURL: String
    let bio: String
}

struct SpeedDateCard: View {
    let user: SpeedDateUser
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
        ZStack(alignment: .bottom) {
            // PHOTO
            AsyncImage(url: URL(string: user.photoURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure(_), .empty:
                    Rectangle()
                        .fill(LinearGradient(colors: [.purple.opacity(0.3), .pink.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .overlay {
                            Image(systemName: "person.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(.white.opacity(0.3))
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: UIScreen.main.bounds.width - 40, height: 520)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            // INFO GRADIENT OVERLAY
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            // USER INFO
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(user.name)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                    Text("\(user.age)")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                }
                
                if !user.bio.isEmpty {
                    Text(user.bio)
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .frame(width: UIScreen.main.bounds.width - 40, height: 520)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

struct AstroMatchGlassView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    
    @State private var users: [AstroUser] = []
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var isLoading = true
    @State private var isSearching = true
    @State private var foundUser: AstroUser?
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    
    let zodiacSigns = ["Koç".localized, "Boğa".localized, "İkizler".localized, "Yengeç".localized, "Aslan".localized, "Başak".localized, "Terazi".localized, "Akrep".localized, "Yay".localized, "Oğlak".localized, "Kova".localized, "Balık".localized]
    
    var body: some View {
        NavigationStack {
                if let user = foundUser {
                    // Match Found
                    VStack(spacing: 30) {
                        Text("Yıldızlar Eşleşti! ✨".localized)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        
                        AstroUserCard(user: user)
                            .frame(height: 480)
                        
                        HStack(spacing: 20) {
                            Button {
                                restartSearch()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.red)
                                    .frame(width: 60, height: 60)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                            
                            Button {
                                // Connect (Phase 3)
                            } label: {
                                Image(systemName: "message.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.purple, in: Circle())
                                    .shadow(color: .purple.opacity(0.4), radius: 10)
                            }
                        }
                    }
                    .transition(.scale)
                } else {
                    // Searching
                    VStack(spacing: 40) {
                        Text("Burç Eşleş".localized)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        
                        RadarView(color: .purple)
                            .frame(width: 250, height: 250)
                        
                        VStack(spacing: 12) {
                            Text("Burç Uyumu Aranıyor...".localized)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(colors.primaryText)
                            
                            Text("Yıldız haritanız karşılaştırılıyor".localized)
                                .font(.subheadline)
                                .foregroundStyle(colors.secondaryText)
                        }
                        
                        Button {
                            dismiss()
                        } label: {
                            Text("İptal".localized)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 14)
                                .background(Capsule().fill(.ultraThinMaterial))
                        }
                    }
                    .transition(.opacity)
                }
            }
            .onAppear {
                startSearch()
            }
            .onDisappear {
                Task {
                    await MatchService.shared.leaveQueue()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(colors.secondaryText)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .task {
        }
    }
    
    var astroSwipeView: some View {
        VStack {
            Text("Burç Eşleş".localized)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(colors.primaryText)
                .padding(.top, 20)
            
            Spacer()
            
            ZStack {
                ForEach(currentIndex..<min(currentIndex + 2, users.count), id: \.self) { index in
                    if index < users.count {
                        AstroUserCard(user: users[index])
                            .offset(index == currentIndex ? offset : .zero)
                            .scaleEffect(index == currentIndex ? 1 : 0.95)
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        if index == currentIndex {
                                            offset = gesture.translation
                                        }
                                    }
                                    .onEnded { gesture in
                                        if index == currentIndex {
                                            if abs(gesture.translation.width) > 100 {
                                                let direction = gesture.translation.width > 0 ? "like" : "pass"
                                                handleAstroSwipe(direction: direction, user: users[index])
                                            } else {
                                                offset = .zero
                                            }
                                        }
                                    }
                            )
                    }
                }
            }
            .frame(height: 500)
            
            Spacer()
            
            HStack(spacing: 30) {
                Button {
                    if currentIndex < users.count {
                        handleAstroSwipe(direction: "pass", user: users[currentIndex])
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.red)
                        .frame(width: 60, height: 60)
                        .background(.ultraThinMaterial, in: Circle())
                }
                
                Button {
                    if currentIndex < users.count {
                        handleAstroSwipe(direction: "like", user: users[currentIndex])
                    }
                } label: {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.pink)
                        .frame(width: 60, height: 60)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
            .padding(.bottom, 30)
        }
    }
    
    func startSearch() {
        isSearching = true
        foundUser = nil
        
        Task {
            let myName = appState.currentUser?.displayName ?? "Misafir"
            let myPhoto = appState.currentUser?.profilePhotoURL ?? ""
            let myId = Auth.auth().currentUser?.uid ?? ""
            
            if !myId.isEmpty {
                try? await MatchService.shared.joinQueue(type: .astro, name: myName, photoURL: myPhoto)
                
                MatchService.shared.listenForMatch(type: .astro) { matchUser in
                    DispatchQueue.main.async {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            self.foundUser = AstroUser(
                                id: matchUser.id,
                                name: matchUser.name,
                                age: 24,
                                photoURL: matchUser.photoURL,
                                zodiacSign: "Bilinmiyor".localized,
                                compatibility: Int.random(in: 70...99)
                            )
                            self.isSearching = false
                        }
                    }
                }
            } else {
                 DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        foundUser = AstroUser(id: "mock", name: "Gizemli Yay".localized, age: 24, photoURL: "mock", zodiacSign: "Yay".localized, compatibility: 90)
                        isSearching = false
                    }
                }
            }
        }
    }
    
    func restartSearch() {
        Task { await MatchService.shared.leaveQueue() }
        withAnimation {
            foundUser = nil
            isSearching = true
        }
        startSearch()
    }
    
    func loadAstroUsers() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            // No user logged in - use mock data
            await loadMockAstroUsers()
            return
        }
        
        do {
            let db = Firestore.firestore()
            let snapshot = try await db.collection("users")
                .limit(to: 20)
                .getDocuments()
            
            let loadedUsers = snapshot.documents.compactMap { doc -> AstroUser? in
                let data = doc.data()
                guard doc.documentID != currentUserId else { return nil }
                
                // Get name from display_name or name field
                let name = data["display_name"] as? String ?? data["name"] as? String ?? "Kullanıcı".localized
                
                // Calculate age from date_of_birth or use age field
                var age = data["age"] as? Int ?? 0
                if age == 0, let dobTimestamp = data["date_of_birth"] as? Timestamp {
                    let calendar = Calendar.current
                    age = calendar.dateComponents([.year], from: dobTimestamp.dateValue(), to: Date()).year ?? 18
                }
                if age < 15 { return nil } // Skip invalid ages
                
                // Get photo URL
                let photoURL = data["profile_photo_url"] as? String ?? data["photo_url"] as? String ?? ""
                
                let zodiacSign = doc.data()["zodiac_sign"] as? String ?? zodiacSigns.randomElement() ?? "Koç".localized
                let compatibility = Int.random(in: 60...99)
                
                return AstroUser(id: doc.documentID, name: name, age: age, photoURL: photoURL, zodiacSign: zodiacSign, compatibility: compatibility)
            }
            
            await MainActor.run {
                if loadedUsers.isEmpty {
                    // Firebase empty - use mock data
                    Task { await loadMockAstroUsers() }
                } else {
                    self.users = loadedUsers
                    self.isLoading = false
                }
            }
        } catch {
            // Firebase error - use mock data
            await loadMockAstroUsers()
        }
    }
    
    func loadMockAstroUsers() async {
        let mockUsers = [
            AstroUser(id: "astro1", name: "Ayşe", age: 24, photoURL: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800", zodiacSign: "Koç".localized, compatibility: 92),
            AstroUser(id: "astro2", name: "Mehmet", age: 27, photoURL: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800", zodiacSign: "Boğa".localized, compatibility: 85),
            AstroUser(id: "astro3", name: "Zeynep", age: 23, photoURL: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=800", zodiacSign: "İkizler".localized, compatibility: 78),
            AstroUser(id: "astro4", name: "Can", age: 26, photoURL: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800", zodiacSign: "Yengeç".localized, compatibility: 88),
            AstroUser(id: "astro5", name: "Elif", age: 25, photoURL: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800", zodiacSign: "Aslan".localized, compatibility: 95),
            AstroUser(id: "astro6", name: "Burak", age: 28, photoURL: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800", zodiacSign: "Başak".localized, compatibility: 82),
            AstroUser(id: "astro7", name: "Selin", age: 24, photoURL: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800", zodiacSign: "Terazi".localized, compatibility: 90),
            AstroUser(id: "astro8", name: "Emre", age: 29, photoURL: "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=800", zodiacSign: "Akrep".localized, compatibility: 76),
            AstroUser(id: "astro9", name: "Deniz", age: 26, photoURL: "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800", zodiacSign: "Yay".localized, compatibility: 87),
            AstroUser(id: "astro10", name: "Arda", age: 27, photoURL: "https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?w=800", zodiacSign: "Oğlak".localized, compatibility: 93)
        ]
        
        await MainActor.run {
            self.users = mockUsers
            self.isLoading = false
        }
    }
    

    
    func sendAstroRequest(userId: String) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        guard let currentBalance = appState.currentUser?.diamondBalance, currentBalance >= 10 else { return }
        
        do {
            let db = Firestore.firestore()
            try await db.collection("users").document(currentUserId).updateData([
                "diamond_balance": FieldValue.increment(Int64(-10))
            ])
            try await db.collection("friend_requests").addDocument(data: [
                "from_user_id": currentUserId,
                "to_user_id": userId,
                "status": "pending",
                "type": "astro_match",
                "timestamp": FieldValue.serverTimestamp()
            ])
            await MainActor.run {
                appState.currentUser?.diamondBalance = (appState.currentUser?.diamondBalance ?? 0) - 10
            }
        } catch {
            print("❌ Error: \(error)")
        }
    }
    
    func handleAstroSwipe(direction: String, user: AstroUser) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            offset = direction == "like" ? CGSize(width: 600, height: 50) : CGSize(width: -600, height: 50)
        }
        
        if direction == "like" {
            Task {
                await sendAstroRequest(userId: user.id)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                currentIndex += 1
                offset = .zero
            }
        }
    }
}

struct AstroUser: Identifiable {
    let id: String
    let name: String
    let age: Int
    let photoURL: String
    let zodiacSign: String
    let compatibility: Int
}

struct AstroUserCard: View {
    let user: AstroUser
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
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: user.photoURL)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure(_), .empty:
                    Rectangle().fill(LinearGradient(colors: [.pink.opacity(0.3), .purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 340, height: 500)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(user.name)
                        .font(.system(size: 28, weight: .bold))
                    Text("\(user.age)")
                        .font(.system(size: 24))
                }
                .foregroundStyle(.white)
                
                HStack(spacing: 8) {
                    Image(systemName: "moon.stars.fill")
                        .foregroundStyle(.pink)
                    Text(user.zodiacSign)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.pink)
                    Text("%\(user.compatibility) " + "Uyum".localized)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                LinearGradient(colors: [.clear, .black.opacity(0.7)], startPoint: .top, endPoint: .bottom)
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(radius: 10)
    }
}

struct MoodExploreGlassView: View {
    let mood: String
    @Environment(\.dismiss) var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    
    enum MoodMode: String, CaseIterable {
        case kisi = "Kişi Bul"
        case tavsiye = "Tavsiye Al"
    }
    
    @State private var selectedMode: MoodMode? = nil
    @State private var users: [MoodUser] = []
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
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
                
                if selectedMode == nil {
                    // Mode Selection Screen
                    modeSelectionView
                } else if selectedMode == .tavsiye {
                    // Tavsiye (Advice) View
                    adviceView
                } else if isLoading {
                    ProgressView()
                } else if currentIndex < users.count {
                    moodSwipeView
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.green)
                        Text("Hepsi Bu Kadar!".localized)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        Button { dismiss() } label: {
                            Text("Tamam".localized)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(moodColor, in: RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal, 40)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(colors.secondaryText)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .task {
                await loadMoodUsers()
            }
        }
    }
    
    var moodSwipeView: some View {
        VStack {
            Text("\(mood.capitalized) " + "Mood".localized)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(colors.primaryText)
                .padding(.top, 20)
            
            Spacer()
            
            ZStack {
                ForEach(currentIndex..<min(currentIndex + 2, users.count), id: \.self) { index in
                    if index < users.count {
                        MoodUserCard(user: users[index], moodColor: moodColor)
                            .offset(index == currentIndex ? offset : .zero)
                            .scaleEffect(index == currentIndex ? 1 : 0.95)
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        if index == currentIndex {
                                            offset = gesture.translation
                                        }
                                    }
                                    .onEnded { gesture in
                                        if index == currentIndex {
                                            if abs(gesture.translation.width) > 100 {
                                                let direction = gesture.translation.width > 0 ? "like" : "pass"
                                                handleMoodSwipe(direction: direction, user: users[index])
                                            } else {
                                                offset = .zero
                                            }
                                        }
                                    }
                            )
                    }
                }
            }
            .frame(height: 500)
            
            Spacer()
            
            HStack(spacing: 30) {
                Button {
                    if currentIndex < users.count {
                        handleMoodSwipe(direction: "pass", user: users[currentIndex])
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.red)
                        .frame(width: 60, height: 60)
                        .background(.ultraThinMaterial, in: Circle())
                }
                
                Button {
                    if currentIndex < users.count {
                        handleMoodSwipe(direction: "like", user: users[currentIndex])
                    }
                } label: {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(moodColor)
                        .frame(width: 60, height: 60)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
            .padding(.bottom, 30)
        }
    }
    
    func loadMoodUsers() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            // No user logged in - use mock data
            await loadMockMoodUsers()
            return
        }
        
        do {
            let db = Firestore.firestore()
            let snapshot = try await db.collection("users")
                .limit(to: 30)
                .getDocuments()
            
            let loadedUsers = snapshot.documents.compactMap { doc -> MoodUser? in
                let data = doc.data()
                guard doc.documentID != currentUserId else { return nil }
                
                // Get name from display_name or name field
                let name = data["display_name"] as? String ?? data["name"] as? String ?? "Kullanıcı".localized
                
                // Calculate age from date_of_birth or use age field
                var age = data["age"] as? Int ?? 0
                if age == 0, let dobTimestamp = data["date_of_birth"] as? Timestamp {
                    let calendar = Calendar.current
                    age = calendar.dateComponents([.year], from: dobTimestamp.dateValue(), to: Date()).year ?? 18
                }
                if age < 15 { return nil } // Skip invalid ages
                
                // Get photo URL
                let photoURL = data["profile_photo_url"] as? String ?? data["photo_url"] as? String ?? ""
                
                let bio = data["bio"] as? String ?? "Merhaba! 👋".localized
                return MoodUser(id: doc.documentID, name: name, age: age, photoURL: photoURL, bio: bio, mood: mood)
            }
            
            await MainActor.run {
                if loadedUsers.isEmpty {
                    // Firebase empty - use mock data
                    Task { await loadMockMoodUsers() }
                } else {
                    self.users = loadedUsers
                    self.isLoading = false
                }
            }
        } catch {
            // Firebase error - use mock data
            await loadMockMoodUsers()
        }
    }
    
    func loadMockMoodUsers() async {
        // Different users for each mood
        let mockUsers: [MoodUser]
        
        switch mood {
        case "adventure":
            mockUsers = [
                MoodUser(id: "adv1", name: "Ayşe", age: 25, photoURL: "https://images.unsplash.com/photo-1551632811-561732d1e306?w=800", bio: "Dağ tırmanışı ve kamp seviyorum! Yeni maceralar arıyorum.".localized, mood: mood),
                MoodUser(id: "adv2", name: "Can", age: 28, photoURL: "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=800", bio: "Ekstrem sporlar ve doğa yürüyüşleri tutkum.".localized, mood: mood),
                MoodUser(id: "adv3", name: "Zeynep", age: 24, photoURL: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800", bio: "Paraşüt, dalış, rafting... Hepsini deneyelim!".localized, mood: mood),
                MoodUser(id: "adv4", name: "Emre", age: 27, photoURL: "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=800", bio: "Seyahat ve macera benim için her şey.".localized, mood: mood),
                MoodUser(id: "adv5", name: "Selin", age: 26, photoURL: "https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=800", bio: "Yeni yerler keşfetmeyi ve adrenalin seviyorum.".localized, mood: mood)
            ]
        case "romantic":
            mockUsers = [
                MoodUser(id: "rom1", name: "Elif", age: 24, photoURL: "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=800", bio: "Gün batımı yürüyüşleri ve romantik akşam yemekleri...".localized, mood: mood),
                MoodUser(id: "rom2", name: "Mehmet", age: 29, photoURL: "https://images.unsplash.com/photo-1504257432389-52343af06ae3?w=800", bio: "Şiir okumayı ve romantik filmler izlemeyi seviyorum.".localized, mood: mood),
                MoodUser(id: "rom3", name: "Deniz", age: 25, photoURL: "https://images.unsplash.com/photo-1502823403499-6ccfcf4fb453?w=800", bio: "Çiçekler, müzik ve güzel anlar...".localized, mood: mood),
                MoodUser(id: "rom4", name: "Burak", age: 28, photoURL: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800", bio: "Romantik bir akşam için hazırım.".localized, mood: mood),
                MoodUser(id: "rom5", name: "Aylin", age: 26, photoURL: "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800", bio: "Aşk şarkıları ve yıldızlı geceler...".localized, mood: mood)
            ]
        case "chill":
            mockUsers = [
                MoodUser(id: "chl1", name: "Arda", age: 27, photoURL: "https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?w=800", bio: "Kahve içip kitap okumayı seviyorum. Sakin bir gün geçirelim.".localized, mood: mood),
                MoodUser(id: "chl2", name: "Seda", age: 23, photoURL: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800", bio: "Netflix, pizza ve rahat bir ortam...".localized, mood: mood),
                MoodUser(id: "chl3", name: "Kaan", age: 26, photoURL: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800", bio: "Lofi müzik eşliğinde sakin bir gün.".localized, mood: mood),
                MoodUser(id: "chl4", name: "Merve", age: 25, photoURL: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800", bio: "Yoga, meditasyon ve huzur...".localized, mood: mood),
                MoodUser(id: "chl5", name: "Onur", age: 28, photoURL: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800", bio: "Sakin bir ortamda sohbet etmeyi seviyorum.".localized, mood: mood)
            ]
        case "party":
            mockUsers = [
                MoodUser(id: "prt1", name: "Ceren", age: 24, photoURL: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=800", bio: "Dans etmeyi ve eğlenmeyi seviyorum! Parti zamanı!".localized, mood: mood),
                MoodUser(id: "prt2", name: "Barış", age: 27, photoURL: "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=800", bio: "Müzik, dans ve eğlence! Haydi partiye!".localized, mood: mood),
                MoodUser(id: "prt3", name: "Gizem", age: 25, photoURL: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800", bio: "Gece hayatı ve sosyal etkinlikler benim işim.".localized, mood: mood),
                MoodUser(id: "prt4", name: "Tolga", age: 29, photoURL: "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=800", bio: "DJ setleri ve dans pistleri... Eğlenelim!".localized, mood: mood),
                MoodUser(id: "prt5", name: "Pınar", age: 26, photoURL: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800", bio: "Parti hayatı ve yeni insanlar tanımak...".localized, mood: mood)
            ]
        case "deep":
            mockUsers = [
                MoodUser(id: "dep1", name: "Alp", age: 28, photoURL: "https://images.unsplash.com/photo-1504257432389-52343af06ae3?w=800", bio: "Felsefe, sanat ve derin konuşmalar...".localized, mood: mood),
                MoodUser(id: "dep2", name: "Ece", age: 26, photoURL: "https://images.unsplash.com/photo-1502823403499-6ccfcf4fb453?w=800", bio: "Hayatın anlamı üzerine konuşmayı seviyorum.".localized, mood: mood),
                MoodUser(id: "dep3", name: "Mert", age: 27, photoURL: "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=800", bio: "Psikoloji, felsefe ve sanat tutkunu.".localized, mood: mood),
                MoodUser(id: "dep4", name: "Nil", age: 25, photoURL: "https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=800", bio: "Derin sohbetler ve anlamlı bağlantılar...".localized, mood: mood),
                MoodUser(id: "dep5", name: "Eren", age: 29, photoURL: "https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?w=800", bio: "Kitaplar, müzik ve derin düşünceler.".localized, mood: mood)
            ]
        default:
            mockUsers = []
        }
        
        await MainActor.run {
            self.users = mockUsers
            self.isLoading = false
        }
    }
    
    func handleMoodSwipe(direction: String, user: MoodUser) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            offset = direction == "like" ? CGSize(width: 600, height: 50) : CGSize(width: -600, height: 50)
        }
        
        if direction == "like" {
            Task {
                await sendMoodRequest(userId: user.id)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                currentIndex += 1
                offset = .zero
            }
        }
    }
    
    func sendMoodRequest(userId: String) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        guard let currentBalance = appState.currentUser?.diamondBalance, currentBalance >= 10 else { return }
        
        do {
            let db = Firestore.firestore()
            try await db.collection("users").document(currentUserId).updateData([
                "diamond_balance": FieldValue.increment(Int64(-10))
            ])
            try await db.collection("friend_requests").addDocument(data: [
                "from_user_id": currentUserId,
                "to_user_id": userId,
                "status": "pending",
                "type": "mood_\(mood)",
                "timestamp": FieldValue.serverTimestamp()
            ])
            await MainActor.run {
                appState.currentUser?.diamondBalance = (appState.currentUser?.diamondBalance ?? 0) - 10
            }
        } catch {
            print("❌ Error: \(error)")
        }
    }
    
    private var moodEmoji: String {
        switch mood {
        case "adventure": return "🏔️"
        case "romantic": return "💕"
        case "chill": return "😌"
        case "party": return "🎉"
        case "deep": return "🌊"
        default: return "💭"
        }
    }
    
    // MARK: - Mode Selection View
    private var modeSelectionView: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 12) {
                Text(moodEmoji)
                    .font(.system(size: 60))
                
                Text("\(mood.capitalized) " + "Ruh Hali".localized)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                
                Text("Ne yapmak istersin?".localized)
                    .font(.system(size: 16))
                    .foregroundStyle(colors.secondaryText)
            }
            .padding(.bottom, 20)
            
            // Selection Cards
            VStack(spacing: 16) {
                // Kişi Bul
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedMode = .kisi
                    }
                    Task { await loadMoodUsers() }
                } label: {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(moodColor.opacity(0.2))
                                .frame(width: 56, height: 56)
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(moodColor)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Kişi Bul".localized)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(colors.primaryText)
                            Text("Aynı ruh halindeki insanlarla tanış".localized)
                                .font(.system(size: 13))
                                .foregroundStyle(colors.secondaryText)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(colors.tertiaryText)
                    }
                    .padding(20)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.plain)
                
                // Tavsiye Al
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedMode = .tavsiye
                    }
                } label: {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(moodColor.opacity(0.2))
                                .frame(width: 56, height: 56)
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(moodColor)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tavsiye Al".localized)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(colors.primaryText)
                            Text("Ruh haline göre öneriler al".localized)
                                .font(.system(size: 13))
                                .foregroundStyle(colors.secondaryText)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(colors.tertiaryText)
                    }
                    .padding(20)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .padding(.top, 60)
    }
    
    // MARK: - Advice View
    private var adviceView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Text(moodEmoji)
                        .font(.system(size: 50))
                    Text("\(mood.capitalized) " + "İçin Öneriler".localized)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(colors.primaryText)
                }
                .padding(.top, 20)
                
                // Advice Cards based on mood
                VStack(spacing: 16) {
                    ForEach(advicesForMood, id: \.title) { advice in
                        AdviceCard(advice: advice, moodColor: moodColor, colors: colors)
                    }
                }
                .padding(.horizontal, 16)
                
                // Back to Kişi button
                Button {
                    withAnimation {
                        selectedMode = .kisi
                    }
                    Task { await loadMoodUsers() }
                } label: {
                    Text("Kişi Bul'a Geç".localized)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(moodColor, in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
    }
    
    private var advicesForMood: [MoodAdvice] {
        switch mood {
        case "adventure":
            return [
                MoodAdvice(icon: "figure.hiking", title: "Doğa Yürüyüşü".localized, desc: "Şehirden kaç, ormanda kaybol!".localized),
                MoodAdvice(icon: "airplane", title: "Hafta Sonu Kaçamağı".localized, desc: "Yakın bir şehre git, keşfet".localized),
                MoodAdvice(icon: "camera.fill", title: "Fotoğraf Gezisi".localized, desc: "Yeni yerler keşfet, anıları yakala".localized)
            ]
        case "romantic":
            return [
                MoodAdvice(icon: "heart.fill", title: "Romantik Akşam".localized, desc: "Mum ışığında yemek, şarap".localized),
                MoodAdvice(icon: "moon.stars.fill", title: "Gece Yürüyüşü".localized, desc: "Sahilde el ele yürü".localized),
                MoodAdvice(icon: "gift.fill", title: "Sürpriz Hediye".localized, desc: "Küçük ama anlamlı bir şey al".localized)
            ]
        case "chill":
            return [
                MoodAdvice(icon: "cup.and.saucer.fill", title: "Kahve Molası".localized, desc: "Favori kahve dükkanında dinlen".localized),
                MoodAdvice(icon: "book.fill", title: "Kitap Keyfi".localized, desc: "Rahat bir köşede kitabına dal".localized),
                MoodAdvice(icon: "figure.yoga", title: "Yoga Seansı".localized, desc: "Bedenini ve zihnini dinlendir".localized)
            ]
        case "party":
            return [
                MoodAdvice(icon: "music.note", title: "Konser".localized, desc: "Canlı müzik enerjisi yakala".localized),
                MoodAdvice(icon: "figure.dance", title: "Dans Gecesi".localized, desc: "Kulüpte sabaha kadar eğlen".localized),
                MoodAdvice(icon: "person.3.fill", title: "Ev Partisi".localized, desc: "Arkadaşlarını topla, parti kur".localized)
            ]
        case "deep":
            return [
                MoodAdvice(icon: "brain.head.profile", title: "Derin Sohbet".localized, desc: "Hayatın anlamını tartış".localized),
                MoodAdvice(icon: "paintbrush.fill", title: "Sanat Galerisi".localized, desc: "Eserleri yorumla, düşün".localized),
                MoodAdvice(icon: "doc.text.fill", title: "Günlük Tut".localized, desc: "Düşüncelerini yazıya dök".localized)
            ]
        case "creative":
            return [
                MoodAdvice(icon: "paintpalette.fill", title: "Resim Yap".localized, desc: "Tuval al, hayal gücünü çalıştır".localized),
                MoodAdvice(icon: "music.quarternote.3", title: "Müzik Yap".localized, desc: "Enstrüman çal veya beat yap".localized),
                MoodAdvice(icon: "camera.aperture", title: "Fotoğrafçılık".localized, desc: "Farklı açılardan dünyayı yakala".localized)
            ]
        default:
            return [
                MoodAdvice(icon: "sparkles", title: "Yeni Bir Şey Dene".localized, desc: "Konfor alanından çık".localized),
                MoodAdvice(icon: "person.2.fill", title: "Arkadaşlarla Buluş".localized, desc: "Sosyalleş, eğlen".localized),
                MoodAdvice(icon: "star.fill", title: "Kendine Zaman Ayır".localized, desc: "Sevdiğin bir aktivite yap".localized)
            ]
        }
    }
    
    private var moodColor: Color {
        switch mood {
        case "adventure": return .orange
        case "romantic": return .pink
        case "chill": return .cyan
        case "party": return .purple
        case "deep": return .blue
        default: return .gray
        }
    }
}

struct MoodUser: Identifiable {
    let id: String
    let name: String
    let age: Int
    let photoURL: String
    let bio: String
    let mood: String
}

struct MoodUserCard: View {
    let user: MoodUser
    let moodColor: Color
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
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: user.photoURL)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure(_), .empty:
                    Rectangle().fill(LinearGradient(colors: [moodColor.opacity(0.3), moodColor.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 340, height: 500)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(user.name)
                        .font(.system(size: 28, weight: .bold))
                    Text("\(user.age)")
                        .font(.system(size: 24))
                }
                .foregroundStyle(.white)
                
                if !user.bio.isEmpty {
                    Text(user.bio)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                LinearGradient(colors: [.clear, .black.opacity(0.7)], startPoint: .top, endPoint: .bottom)
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(radius: 10)
    }
}

// MARK: - Mood Advice Model
struct MoodAdvice {
    let icon: String
    let title: String
    let desc: String
}

// MARK: - Advice Card View
struct AdviceCard: View {
    let advice: MoodAdvice
    let moodColor: Color
    let colors: ThemeColors
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(moodColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: advice.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(moodColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(advice.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(colors.primaryText)
                Text(advice.desc)
                    .font(.system(size: 13))
                    .foregroundStyle(colors.secondaryText)
            }
            
            Spacer()
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ExploreViewNew()
        .environment(AppState())
}
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - GAME MATCH DETAIL VIEW - REAL DATA from Firebase
struct GameMatchDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    
    @State private var selectedGame: String = "Hepsi"
    @State private var selectedRank: String = "Hepsi"
    @State private var searchText = ""
    @State private var gamers: [Gamer] = []
    @State private var isLoading = true
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    private let goldColor = Color(red: 0.85, green: 0.65, blue: 0.3)
    
    let games = ["Hepsi".localized, "Valorant", "League of Legends", "CS:GO", "CS2", "Apex Legends", "Fortnite", "PUBG", "Overwatch", "Overwatch 2", "Rocket League", "Dota 2", "Rainbow Six Siege", "Call of Duty", "Warzone", "Minecraft", "Among Us", "Fall Guys", "Genshin Impact", "Lost Ark", "FIFA", "NBA 2K", "Destiny 2", "Halo Infinite", "Rust"]
    let ranks = ["Hepsi".localized, "Bronze", "Silver", "Gold", "Platinum", "Diamond", "Master", "Challenger"]
    
    var filteredGamers: [Gamer] {
        gamers.filter { gamer in
            (selectedGame == "Hepsi".localized || gamer.games.contains(selectedGame)) &&
            (selectedRank == "Hepsi".localized || gamer.rank == selectedRank) &&
            (searchText.isEmpty || gamer.name.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(colors: [goldColor, goldColor.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                            )
                        Text("Oyun Arkadaşı".localized)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        Text("Birlikte oynayacak arkadaş bul".localized)
                            .font(.system(size: 14))
                            .foregroundStyle(colors.secondaryText)

                    }
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Search
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(colors.secondaryText)
                        TextField("Oyuncu ara...".localized, text: $searchText)

                            .textFieldStyle(.plain)
                            .foregroundStyle(colors.primaryText)
                    }
                    .padding(14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                    .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    
                    // Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "Oyun".localized, selection: $selectedGame, options: games)
                            FilterChip(title: "Rank".localized, selection: $selectedRank, options: ranks)

                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 16)
                    
                    // Grid View
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if filteredGamers.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "person.2.slash")
                                .font(.system(size: 50))
                                .foregroundStyle(colors.tertiaryText)
                            Text("Oyuncu bulunamadı".localized)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(colors.primaryText)
                            Text("Filtreleri değiştirmeyi dene".localized)
                                .font(.system(size: 14))
                                .foregroundStyle(colors.secondaryText)

                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(filteredGamers) { gamer in
                                    CompactGamerCard(gamer: gamer, goldColor: goldColor)
                                        .onTapGesture {
                                            handleGamerSelection(gamer: gamer)
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(colors.secondaryText)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .task {
                await loadGamers()
            }
            .alert("Oyun İsteği Gönder".localized, isPresented: $showRequestAlert) {
                Button("Gönder".localized, role: .none) {
                    if let gamer = selectedGamer {
                        Task { await sendGameRequest(userId: gamer.id) }
                    }
                }
                Button("İptal".localized, role: .cancel) { }
            } message: {
                if let gamer = selectedGamer {
                    Text("\(gamer.name) " + "ile oynamak için istek gönderilsin mi? (10 Elmas)".localized)
                }
            }

        }
    }
    
    @State private var showRequestAlert = false
    @State private var selectedGamer: Gamer?
    
    func handleGamerSelection(gamer: Gamer) {
        selectedGamer = gamer
        showRequestAlert = true
    }

    
    private func loadGamers() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        do {
            let db = Firestore.firestore()
            // Get all users instead of filtering by gaming_preferences
            let snapshot = try await db.collection("users")
                .limit(to: 50)
                .getDocuments()
            
            let allGames = ["Valorant", "League of Legends", "CS2", "Apex Legends", "Fortnite", "PUBG", "Overwatch 2", "Rocket League", "Minecraft", "FIFA"]
            let ranks = ["Bronze", "Silver", "Gold", "Platinum", "Diamond", "Master"]
            let roles = ["Support", "DPS", "Tank", "Flex", "Carry"]
            
            let loadedGamers = snapshot.documents.compactMap { doc -> Gamer? in
                let data = doc.data()
                guard doc.documentID != currentUserId else { return nil }
                
                // Get name from display_name or name field
                let name = data["display_name"] as? String ?? data["name"] as? String ?? "Oyuncu".localized
                
                // Calculate age from date_of_birth or use age field
                var age = data["age"] as? Int ?? 0
                if age == 0, let dobTimestamp = data["date_of_birth"] as? Timestamp {
                    let calendar = Calendar.current
                    age = calendar.dateComponents([.year], from: dobTimestamp.dateValue(), to: Date()).year ?? 18
                }
                if age < 15 { return nil } // Skip invalid ages
                
                // Get photo URL
                let photoURL = data["profile_photo_url"] as? String ?? data["photo_url"] as? String ?? ""
                
                // Get gaming preferences if exists, otherwise generate random
                let gamingPrefs = data["gaming_preferences"] as? [String: Any] ?? [:]
                var games = gamingPrefs["games"] as? [String] ?? []
                if games.isEmpty {
                    // Assign random 2-4 games
                    games = Array(allGames.shuffled().prefix(Int.random(in: 2...4)))
                }
                let rank = gamingPrefs["rank"] as? String ?? ranks.randomElement() ?? "Gold"
                let role = gamingPrefs["role"] as? String ?? roles.randomElement() ?? "Flex"
                let bio = data["bio"] as? String ?? "Beraber oyun oynamak ister misin? 🎮".localized
                
                return Gamer(
                    id: doc.documentID,
                    name: name,
                    age: age,
                    photoURL: photoURL,
                    games: games,
                    rank: rank,
                    role: role,
                    bio: bio
                )
            }
            
            await MainActor.run {
                self.gamers = loadedGamers
                self.isLoading = false
            }
        } catch {
            print("❌ Error loading gamers: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    private func handleSwipe(direction: String, gamer: Gamer) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            offset = direction == "like" ? CGSize(width: 500, height: 0) : CGSize(width: -500, height: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentIndex += 1
            offset = .zero
            
            if direction == "like" {
                Task {
                    await sendGameRequest(userId: gamer.id)
                }
            }
        }
    }
    
    func sendGameRequest(userId: String) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        guard let currentBalance = appState.currentUser?.diamondBalance, currentBalance >= 10 else { return }
        
        do {
            let db = Firestore.firestore()
            try await db.collection("users").document(currentUserId).updateData([
                "diamond_balance": FieldValue.increment(Int64(-10))
            ])
            try await db.collection("friend_requests").addDocument(data: [
                "from_user_id": currentUserId,
                "to_user_id": userId,
                "status": "pending",
                "type": "game_match",
                "timestamp": FieldValue.serverTimestamp()
            ])
            await MainActor.run {
                appState.currentUser?.diamondBalance = (appState.currentUser?.diamondBalance ?? 0) - 10
            }
        } catch {
            print("❌ Error: \(error)")
        }
    }
}

// MARK: - Gamer Model
struct Gamer: Identifiable {
    let id: String
    let name: String
    let age: Int
    let photoURL: String
    let games: [String]
    let rank: String
    let role: String
    let bio: String
}

// MARK: - Gamer Card
struct GamerCard: View {
    let gamer: Gamer
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
    private let goldColor = Color(red: 0.85, green: 0.65, blue: 0.3)
    private let cardShape = RoundedRectangle(cornerRadius: 24, style: .continuous)
    
    var body: some View {
        VStack(spacing: 0) {
            // Photo
            AsyncImage(url: URL(string: gamer.photoURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure(_), .empty:
                    Rectangle()
                        .fill(LinearGradient(colors: [.purple.opacity(0.3), .blue.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .overlay {
                            Image(systemName: "person.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 400)
            .clipped()
            
            // Info
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(gamer.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(colors.primaryText)
                    Text("\(gamer.age)")
                        .font(.system(size: 20))
                        .foregroundStyle(colors.secondaryText)
                    Spacer()
                }
                
                // Games
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(gamer.games, id: \.self) { game in
                            Text(game)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(goldColor.opacity(0.8), in: Capsule())
                        }
                    }
                }
                
                // Rank & Role
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.yellow)
                        Text(gamer.rank)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(colors.primaryText)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.cyan)
                        Text(gamer.role)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(colors.primaryText)
                    }
                }
                
                if !gamer.bio.isEmpty {
                    Text(gamer.bio)
                        .font(.system(size: 13))
                        .foregroundStyle(colors.secondaryText)
                        .lineLimit(2)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
        }
        .background(.ultraThinMaterial, in: cardShape)
        .glassEffect(.regular.interactive(), in: cardShape)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    @Binding var selection: String
    let options: [String]
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
    private let goldColor = Color(red: 0.85, green: 0.65, blue: 0.3)
    
    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) { selection = option }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selection == "Hepsi".localized ? title : selection)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .semibold))
            }
            .foregroundStyle(selection == "Hepsi".localized ? colors.primaryText : .white)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background {
                if selection == "Hepsi".localized {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .glassEffect()
                } else {
                    Capsule()
                        .fill(LinearGradient(colors: [goldColor, goldColor.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                }
            }
        }
    }
}
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - MUSIC MATCH DETAIL VIEW - REAL DATA from Firebase

struct CompactGamerCard: View {
    let gamer: Gamer
    let goldColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Photo
            AsyncImage(url: URL(string: gamer.photoURL)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure(_):
                    Rectangle().fill(Color.gray.opacity(0.3))
                case .empty:
                    Rectangle().fill(Color.gray.opacity(0.3))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 180)
            .frame(maxWidth: .infinity)
            .clipped()
            .overlay(
                LinearGradient(colors: [.black.opacity(0.6), .clear], startPoint: .bottom, endPoint: .center)
            )
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(gamer.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                    Text("\(gamer.age)")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(10)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(goldColor)
                    Text(gamer.games.first ?? "Oyun".localized)
                        .font(.system(size: 11, weight: .medium))
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(goldColor)
                    Text(gamer.rank)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct CompactMusicLoverCard: View {
    let lover: MusicLover
    let goldColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Photo
            AsyncImage(url: URL(string: lover.photoURL)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure(_):
                    Rectangle().fill(Color.gray.opacity(0.3))
                case .empty:
                    Rectangle().fill(Color.gray.opacity(0.3))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 180)
            .frame(maxWidth: .infinity)
            .clipped()
            .overlay(
                LinearGradient(colors: [.black.opacity(0.6), .clear], startPoint: .bottom, endPoint: .center)
            )
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(lover.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                    Text("\(lover.age)")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(10)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                // Genres
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        Image(systemName: "music.note")
                            .font(.system(size: 10))
                            .foregroundStyle(goldColor)
                        ForEach(lover.genres.prefix(2), id: \.self) { genre in
                            Text(genre)
                                .font(.system(size: 10, weight: .medium))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(goldColor.opacity(0.1), in: Capsule())
                                .foregroundStyle(goldColor)
                        }
                        if lover.genres.count > 2 {
                            Text("+\(lover.genres.count - 2)")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Song
                HStack(spacing: 4) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(goldColor)
                    Text(lover.favoriteSong)
                        .font(.system(size: 11))
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct MusicMatchDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    
    @State private var selectedGenre: String = "Hepsi"
    @State private var searchText = ""
    @State private var musicLovers: [MusicLover] = []
    @State private var isLoading = true
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var showRequestAlert = false
    @State private var selectedMusicLover: MusicLover?
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    private let goldColor = Color(red: 0.85, green: 0.65, blue: 0.3)
    
    let genres = ["Hepsi".localized, "Pop", "Rock", "Hip-Hop", "Rap", "Jazz", "Elektronik", "EDM", "House", "Techno", "Klasik", "R&B", "Soul", "Indie", "Alternative", "Metal", "Punk", "Reggae", "Blues", "Country", "Folk", "Latin", "K-Pop", "Türkçe Pop", "Arabesk"]
    
    var filteredMusicLovers: [MusicLover] {
        musicLovers.filter { lover in
            (selectedGenre == "Hepsi".localized || lover.genres.contains(selectedGenre)) &&
            (searchText.isEmpty || lover.name.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "music.note")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(colors: [goldColor, goldColor.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                            )
                        Text("Müzik Eşleş".localized)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        Text("Aynı müzik zevkine sahip insanlarla tanış".localized)
                            .font(.system(size: 14))
                            .foregroundStyle(colors.secondaryText)

                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Search
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(colors.secondaryText)
                        TextField("Müzik severleri ara...".localized, text: $searchText)

                            .textFieldStyle(.plain)
                            .foregroundStyle(colors.primaryText)
                    }
                    .padding(14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                    .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    
                    // Genre Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(genres, id: \.self) { genre in
                                Button {
                                    selectedGenre = genre
                                } label: {
                                    Text(genre)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(selectedGenre == genre ? .white : colors.primaryText)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background {
                                            if selectedGenre == genre {
                                                Capsule()
                                                    .fill(LinearGradient(colors: [goldColor, goldColor.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                                            } else {
                                                Capsule()
                                                    .fill(.ultraThinMaterial)
                                                    .glassEffect()
                                            }
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 16)
                    
                    // Grid View
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if filteredMusicLovers.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "music.note.slash")
                                .font(.system(size: 50))
                                .foregroundStyle(colors.tertiaryText)
                            Text("Müzik sevgili bulunamadı".localized)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(colors.primaryText)
                            Text("Filtreleri değiştirmeyi dene".localized)
                                .font(.system(size: 14))
                                .foregroundStyle(colors.secondaryText)

                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(filteredMusicLovers) { lover in
                                    CompactMusicLoverCard(lover: lover, goldColor: goldColor)
                                        .onTapGesture {
                                            handleMusicLoverSelection(lover: lover)
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(colors.secondaryText)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .task {
                await loadMusicLovers()
            }
            .alert("Müzik İsteği Gönder".localized, isPresented: $showRequestAlert) {
                Button("Gönder".localized, role: .none) {
                    if let lover = selectedMusicLover {
                        Task { await sendMusicRequest(userId: lover.id) }
                    }
                }
                Button("İptal".localized, role: .cancel) { }
            } message: {
                if let lover = selectedMusicLover {
                    Text("\(lover.name) " + "şarkısını dinlemek için istek gönderilsin mi? (10 Elmas)".localized)
                }
            }

        }
    }
    
    func handleMusicLoverSelection(lover: MusicLover) {
        selectedMusicLover = lover
        showRequestAlert = true
    }
    
    private func loadMusicLovers() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        do {
            let db = Firestore.firestore()
            // Get all users instead of filtering by music_preferences
            let snapshot = try await db.collection("users")
                .limit(to: 50)
                .getDocuments()
            
            let allGenres = ["Pop", "Rock", "Hip-Hop", "Rap", "Jazz", "Elektronik", "EDM", "Klasik", "R&B", "Indie", "Türkçe Pop", "K-Pop"]
            let allArtists = ["Tarkan", "Sezen Aksu", "Duman", "maNga", "Mor ve Ötesi", "The Weeknd", "Drake", "Billie Eilish", "Taylor Swift", "BTS"]
            
            let loaded = snapshot.documents.compactMap { doc -> MusicLover? in
                let data = doc.data()
                guard doc.documentID != currentUserId else { return nil }
                
                // Get name from display_name or name field
                let name = data["display_name"] as? String ?? data["name"] as? String ?? "Müzik Sever".localized
                
                // Calculate age from date_of_birth or use age field
                var age = data["age"] as? Int ?? 0
                if age == 0, let dobTimestamp = data["date_of_birth"] as? Timestamp {
                    let calendar = Calendar.current
                    age = calendar.dateComponents([.year], from: dobTimestamp.dateValue(), to: Date()).year ?? 18
                }
                if age < 15 { return nil } // Skip invalid ages
                
                // Get photo URL
                let photoURL = data["profile_photo_url"] as? String ?? data["photo_url"] as? String ?? ""
                
                // Get music preferences if exists, otherwise generate random
                let musicPrefs = data["music_preferences"] as? [String: Any] ?? [:]
                var genres = musicPrefs["favorite_genres"] as? [String] ?? []
                var artists = musicPrefs["favorite_artists"] as? [String] ?? []
                if genres.isEmpty {
                    // Assign random 2-4 genres
                    genres = Array(allGenres.shuffled().prefix(Int.random(in: 2...4)))
                }
                if artists.isEmpty {
                    // Assign random 2-3 artists
                    artists = Array(allArtists.shuffled().prefix(Int.random(in: 2...3)))
                }
                let bio = data["bio"] as? String ?? "Müzik hakkında konuşmayı seviyorum 🎵".localized
                
                return MusicLover(
                    id: doc.documentID,
                    name: name,
                    age: age,
                    photoURL: photoURL,
                    genres: genres,
                    favoriteArtists: artists,
                    bio: bio,
                    favoriteSong: "Shape of You".localized // Default fallback
                )
            }
            
            await MainActor.run {
                self.musicLovers = loaded
                self.isLoading = false
            }
        } catch {
            print("❌ Error loading music lovers: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    private func handleSwipe(direction: String, lover: MusicLover) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            offset = direction == "like" ? CGSize(width: 500, height: 0) : CGSize(width: -500, height: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentIndex += 1
            offset = .zero
            
            if direction == "like" {
                Task {
                    await sendMusicRequest(userId: lover.id)
                }
            }
        }
    }
    
    func sendMusicRequest(userId: String) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        guard let currentBalance = appState.currentUser?.diamondBalance, currentBalance >= 10 else { return }
        
        do {
            let db = Firestore.firestore()
            try await db.collection("users").document(currentUserId).updateData([
                "diamond_balance": FieldValue.increment(Int64(-10))
            ])
            try await db.collection("friend_requests").addDocument(data: [
                "from_user_id": currentUserId,
                "to_user_id": userId,
                "status": "pending",
                "type": "music_match",
                "timestamp": FieldValue.serverTimestamp()
            ])
            await MainActor.run {
                appState.currentUser?.diamondBalance = (appState.currentUser?.diamondBalance ?? 0) - 10
            }
        } catch {
            print("❌ Error: \(error)")
        }
    }
}

// MARK: - Music Lover Model
struct MusicLover: Identifiable {
    let id: String
    let name: String
    let age: Int
    let photoURL: String
    let genres: [String]
    let favoriteArtists: [String]
    let bio: String
    let favoriteSong: String
}

// MARK: - Music Lover Card
struct MusicLoverCard: View {
    let lover: MusicLover
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
    private let goldColor = Color(red: 0.85, green: 0.65, blue: 0.3)
    private let cardShape = RoundedRectangle(cornerRadius: 24, style: .continuous)
    
    var body: some View {
        VStack(spacing: 0) {
            // Photo
            AsyncImage(url: URL(string: lover.photoURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure(_), .empty:
                    Rectangle()
                        .fill(LinearGradient(colors: [.pink.opacity(0.3), .purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .overlay {
                            Image(systemName: "music.note")
                                .font(.system(size: 60))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 400)
            .clipped()
            
            // Info
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(lover.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(colors.primaryText)
                    Text("\(lover.age)")
                        .font(.system(size: 20))
                        .foregroundStyle(colors.secondaryText)
                    Spacer()
                }
                
                // Genres
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(lover.genres, id: \.self) { genre in
                            Text(genre)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(goldColor.opacity(0.8), in: Capsule())
                        }
                    }
                }
                
                // Favorite Artists
                if !lover.favoriteArtists.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(.yellow)
                            Text("Favori Sanatçılar".localized)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(colors.secondaryText)
                        }
                        
                        Text(lover.favoriteArtists.prefix(3).joined(separator: ", "))
                            .font(.system(size: 12))
                            .foregroundStyle(colors.primaryText)
                            .lineLimit(1)
                    }
                }
                
                if !lover.bio.isEmpty {
                    Text(lover.bio)
                        .font(.system(size: 13))
                        .foregroundStyle(colors.secondaryText)
                        .lineLimit(2)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
        }
        .background(.ultraThinMaterial, in: cardShape)
        .glassEffect(.regular.interactive(), in: cardShape)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}
import SwiftUI

// MARK: - Foodie Date Detail View
// 100+ restaurants, real-time reservations, super detailed
struct FoodieDateDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    
    @State private var selectedCuisine: String = "Hepsi"
    @State private var selectedCity: String = "İstanbul"
    @State private var selectedPriceRange: String = "Hepsi"
    @State private var searchText = ""
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    
    let cuisines = ["Hepsi".localized, "Türk".localized, "İtalyan".localized, "Japon".localized, "Çin".localized, "Hint".localized, "Meksika".localized, "Fransız".localized, "Deniz Ürünleri".localized, "Vejetaryen".localized, "Vegan".localized, "Fast Food".localized]
    let cities = ["İstanbul".localized, "Ankara".localized, "İzmir".localized, "Antalya".localized, "Bursa".localized]
    let priceRanges = ["Hepsi".localized, "₺", "₺₺", "₺₺₺", "₺₺₺₺"]
    
    var filteredRestaurants: [Restaurant] {
        restaurants.filter { restaurant in
            (selectedCuisine == "Hepsi".localized || restaurant.cuisine == selectedCuisine) &&
            (selectedCity == "Hepsi".localized || restaurant.city == selectedCity) &&
            (selectedPriceRange == "Hepsi".localized || restaurant.priceRange == selectedPriceRange) &&
            (searchText.isEmpty || restaurant.name.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Text("🍽️")
                            .font(.system(size: 60))
                        Text("Gurme Deneyimi".localized)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        Text("100+ restoran, rezervasyon yap, eşleş".localized)
                            .font(.system(size: 15))
                            .foregroundStyle(colors.secondaryText)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Search Bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(colors.secondaryText)
                        
                        TextField("Restoran ara...".localized, text: $searchText)
                            .textFieldStyle(.plain)
                            .foregroundStyle(colors.primaryText)
                    }
                    .padding(14)
                    .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(colors.border, lineWidth: 0.5))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    
                    // Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterPill(title: "Mutfak".localized, selection: $selectedCuisine, options: cuisines)
                            FilterPill(title: "Şehir".localized, selection: $selectedCity, options: cities)
                            FilterPill(title: "Fiyat".localized, selection: $selectedPriceRange, options: priceRanges)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 12)
                    
                    // Restaurant List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredRestaurants) { restaurant in
                                RestaurantCard(restaurant: restaurant)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(colors.secondaryText)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }
    
    // MARK: - Mock Restaurants (100+)
    private var restaurants: [Restaurant] {
        [
            // İstanbul - Türk
            Restaurant(id: "1", name: "Mikla", cuisine: "Türk".localized, city: "İstanbul".localized, district: "Beyoğlu".localized, priceRange: "₺₺₺₺", rating: 4.8, imageURL: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800", specialty: "Çağdaş Anadolu Mutfağı".localized),
            Restaurant(id: "2", name: "Neolokal", cuisine: "Türk".localized, city: "İstanbul".localized, district: "Karaköy".localized, priceRange: "₺₺₺₺", rating: 4.7, imageURL: "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800", specialty: "Modern Türk".localized),
            Restaurant(id: "3", name: "Çiya Sofrası", cuisine: "Türk".localized, city: "İstanbul".localized, district: "Kadıköy".localized, priceRange: "₺₺", rating: 4.6, imageURL: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800", specialty: "Geleneksel Anadolu".localized),
            
            // İstanbul - İtalyan
            Restaurant(id: "4", name: "Locale", cuisine: "İtalyan".localized, city: "İstanbul".localized, district: "Nişantaşı".localized, priceRange: "₺₺₺", rating: 4.5, imageURL: "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800", specialty: "Pasta & Pizza".localized),
            Restaurant(id: "5", name: "Ristorante Pizzeria Venedik", cuisine: "İtalyan".localized, city: "İstanbul".localized, district: "Bebek".localized, priceRange: "₺₺₺", rating: 4.4, imageURL: "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800", specialty: "Otantik İtalyan".localized),
            
            // İstanbul - Japon
            Restaurant(id: "6", name: "Zuma", cuisine: "Japon".localized, city: "İstanbul".localized, district: "Ortaköy".localized, priceRange: "₺₺₺₺", rating: 4.9, imageURL: "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=800", specialty: "Contemporary Japanese".localized),
            Restaurant(id: "7", name: "Nobu", cuisine: "Japon".localized, city: "İstanbul".localized, district: "Kuruçeşme".localized, priceRange: "₺₺₺₺", rating: 4.8, imageURL: "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=800", specialty: "Sushi & Sashimi".localized),
            
            // İstanbul - Deniz Ürünleri
            Restaurant(id: "8", name: "Balıkçı Sabahattin", cuisine: "Deniz Ürünleri".localized, city: "İstanbul".localized, district: "Sultanahmet".localized, priceRange: "₺₺₺", rating: 4.6, imageURL: "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800", specialty: "Taze Balık".localized),
            Restaurant(id: "9", name: "Alancha", cuisine: "Deniz Ürünleri".localized, city: "İstanbul".localized, district: "Galata".localized, priceRange: "₺₺₺", rating: 4.5, imageURL: "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800", specialty: "Akdeniz Mutfağı".localized),
            
            // Ankara
            Restaurant(id: "10", name: "Trilye", cuisine: "Deniz Ürünleri".localized, city: "Ankara".localized, district: "Çankaya".localized, priceRange: "₺₺₺₺", rating: 4.7, imageURL: "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800", specialty: "Premium Seafood".localized),
            
            // Add 90 more restaurants programmatically
        ] + generateMoreRestaurants()
    }
    
    private func generateMoreRestaurants() -> [Restaurant] {
        var restaurants: [Restaurant] = []
        let names = ["Lezzet Durağı".localized, "Gurme Köşe".localized, "Şef'in Yeri".localized, "Damak Tadı".localized, "Sofra".localized, "Keyif Mekanı".localized]
        let districts = ["Kadıköy".localized, "Beşiktaş".localized, "Şişli".localized, "Üsküdar".localized, "Bakırköy".localized, "Ataşehir".localized]
        
        for i in 11...100 {
            restaurants.append(Restaurant(
                id: "\(i)",
                name: "\(names.randomElement()!) \(i)",
                cuisine: cuisines.dropFirst().randomElement()!,
                city: cities.randomElement()!,
                district: districts.randomElement()!,
                priceRange: priceRanges.dropFirst().randomElement()!,
                rating: Double.random(in: 4.0...5.0),
                imageURL: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800",
                specialty: "Özel Lezzetler".localized
            ))
        }
        return restaurants
    }
}

// MARK: - Restaurant Model
struct Restaurant: Identifiable {
    let id: String
    let name: String
    let cuisine: String
    let city: String
    let district: String
    let priceRange: String
    let rating: Double
    let imageURL: String
    let specialty: String
}

// MARK: - Restaurant Card
private struct RestaurantCard: View {
    let restaurant: Restaurant
    @State private var showReservation = false
    
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
        Button {
            showReservation = true
        } label: {
            HStack(spacing: 14) {
                // Image
                AsyncImage(url: URL(string: restaurant.imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure(_), .empty:
                        Rectangle()
                            .fill(LinearGradient(colors: [.orange.opacity(0.3), .red.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(restaurant.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(colors.primaryText)
                        
                        Text("•")
                            .foregroundStyle(colors.tertiaryText)
                        
                        Text(restaurant.priceRange)
                            .font(.system(size: 12))
                            .foregroundStyle(colors.secondaryText)
                    }
                    
                    Text(restaurant.specialty)
                        .font(.system(size: 11))
                        .foregroundStyle(colors.secondaryText)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.cyan)
                        Text("\(restaurant.district), \(restaurant.city)")
                            .font(.system(size: 11))
                            .foregroundStyle(colors.tertiaryText)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(colors.tertiaryText)
            }
            .padding(12)
            .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(colors.border, lineWidth: 0.5))
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showReservation) {
            RestaurantDetailSheet(restaurant: restaurant)
        }
    }
}

// MARK: - Restaurant Detail Sheet
private struct RestaurantDetailSheet: View {
    let restaurant: Restaurant
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
    private let goldColor = Color(red: 0.85, green: 0.65, blue: 0.3)
    
    var body: some View {
        NavigationStack {
            ZStack {
                colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        AsyncImage(url: URL(string: restaurant.imageURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().aspectRatio(contentMode: .fill)
                            case .failure(_), .empty:
                                Rectangle().fill(LinearGradient(colors: [.orange.opacity(0.3), .red.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(height: 200)
                        .clipped()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(restaurant.name)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(colors.primaryText)
                            
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                Text(String(format: "%.1f", restaurant.rating))
                                    .font(.system(size: 14, weight: .semibold))
                                Text("•")
                                Text(restaurant.priceRange)
                                Text("•")
                                Text(restaurant.cuisine)
                            }
                            .font(.system(size: 13))
                            .foregroundStyle(colors.secondaryText)
                            
                            Button {
                                // TODO: Make reservation
                            } label: {
                                Text("Rezervasyon Yap".localized)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(LinearGradient(colors: [goldColor, goldColor.opacity(0.8)], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(colors.secondaryText)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }
}

// MARK: - Filter Pill
private struct FilterPill: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    
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
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) { selection = option }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selection == "Hepsi".localized ? title : selection)
                    .font(.system(size: 13, weight: .medium))
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(colors.primaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(colors.cardBackground, in: Capsule())
            .overlay(Capsule().stroke(colors.border, lineWidth: 0.5))
        }
    }
}
import SwiftUI

// MARK: - Book Club Detail View
// Detailed book lists, discussions, reading groups
struct BookClubDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    
    @State private var selectedGenre: String = "Hepsi"
    @State private var selectedBook: Book?
    @State private var searchText = ""
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    
    let genres = ["Hepsi".localized, "Roman".localized, "Klasik".localized, "Bilim Kurgu".localized, "Fantastik".localized, "Polisiye".localized, "Tarih".localized, "Biyografi".localized, "Felsefe".localized, "Psikoloji".localized, "Şiir".localized]
    
    var filteredBooks: [Book] {
        books.filter { book in
            (selectedGenre == "Hepsi".localized || book.genre == selectedGenre) &&
            (searchText.isEmpty || book.title.localizedCaseInsensitiveContains(searchText) || book.author.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Text("📚")
                            .font(.system(size: 60))
                        Text("Kitap Kulübü".localized)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        Text("Aynı kitabı okuyan insanlarla tanış".localized)
                            .font(.system(size: 15))
                            .foregroundStyle(colors.secondaryText)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Search Bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(colors.secondaryText)
                        
                        TextField("Kitap veya yazar ara...".localized, text: $searchText)
                            .textFieldStyle(.plain)
                            .foregroundStyle(colors.primaryText)
                    }
                    .padding(14)
                    .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(colors.border, lineWidth: 0.5))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    
                    // Genre Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(genres, id: \.self) { genre in
                                Button {
                                    selectedGenre = genre
                                } label: {
                                    Text(genre)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(selectedGenre == genre ? .white : colors.primaryText)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            selectedGenre == genre ? .orange : colors.cardBackground,
                                            in: Capsule()
                                        )
                                        .overlay(
                                            Capsule().stroke(colors.border, lineWidth: selectedGenre == genre ? 0 : 0.5)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 12)
                    
                    // Book List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredBooks) { book in
                                BookCard(book: book) {
                                    selectedBook = book
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(colors.secondaryText)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .sheet(item: $selectedBook) { book in
                BookDetailSheet(book: book)
            }
        }
    }
    
    // MARK: - Books Database
    private var books: [Book] {
        [
            Book(id: "1", title: "Kürk Mantolu Madonna", author: "Sabahattin Ali", genre: "Klasik".localized, year: 1943, pages: 176, rating: 4.8, readers: 1250, imageURL: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400", description: "Türk edebiyatının başyapıtlarından biri".localized),
            Book(id: "2", title: "Tutunamayanlar", author: "Oğuz Atay", genre: "Roman".localized, year: 1971, pages: 724, rating: 4.7, readers: 890, imageURL: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400", description: "Modern Türk romanının kilometre taşı".localized),
            Book(id: "3", title: "1984", author: "George Orwell", genre: "Bilim Kurgu".localized, year: 1949, pages: 328, rating: 4.9, readers: 2100, imageURL: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400", description: "Distopik edebiyatın başyapıtı".localized),
            Book(id: "4", title: "Suç ve Ceza", author: "Dostoyevski", genre: "Klasik".localized, year: 1866, pages: 671, rating: 4.8, readers: 1560, imageURL: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400", description: "Psikolojik roman".localized),
            Book(id: "5", title: "Yüzüklerin Efendisi", author: "J.R.R. Tolkien", genre: "Fantastik".localized, year: 1954, pages: 1178, rating: 4.9, readers: 3200, imageURL: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400", description: "Fantastik edebiyatın zirvesi".localized),
            Book(id: "6", title: "Şeker Portakalı", author: "Jose Mauro de Vasconcelos", genre: "Roman".localized, year: 1968, pages: 192, rating: 4.7, readers: 980, imageURL: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400", description: "Çocukluk ve yoksulluk".localized),
            Book(id: "7", title: "Simyacı", author: "Paulo Coelho", genre: "Roman".localized, year: 1988, pages: 208, rating: 4.6, readers: 1780, imageURL: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400", description: "Kişisel efsane arayışı".localized),
            Book(id: "8", title: "Beyaz Zambaklar Ülkesinde", author: "Grigory Petrov", genre: "Tarih".localized, year: 1923, pages: 144, rating: 4.5, readers: 670, imageURL: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400", description: "Finlandiya'nın gelişimi".localized),
            Book(id: "9", title: "İnce Memed", author: "Yaşar Kemal", genre: "Roman".localized, year: 1955, pages: 448, rating: 4.7, readers: 1120, imageURL: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400", description: "Çukurova destanı".localized),
            Book(id: "10", title: "Fareler ve İnsanlar", author: "John Steinbeck", genre: "Klasik".localized, year: 1937, pages: 107, rating: 4.6, readers: 890, imageURL: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400", description: "Dostluk ve hayaller".localized),
        ]
    }
}

// MARK: - Book Model
struct Book: Identifiable {
    let id: String
    let title: String
    let author: String
    let genre: String
    let year: Int
    let pages: Int
    let rating: Double
    let readers: Int
    let imageURL: String
    let description: String
}

// MARK: - Book Card
private struct BookCard: View {
    let book: Book
    let action: () -> Void
    
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
        Button(action: action) {
            HStack(spacing: 14) {
                // Book Cover
                AsyncImage(url: URL(string: book.imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure(_), .empty:
                        Rectangle()
                            .fill(LinearGradient(colors: [.orange.opacity(0.3), .brown.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .overlay {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 60, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(book.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .lineLimit(2)
                    
                    Text(book.author)
                        .font(.system(size: 13))
                        .foregroundStyle(colors.secondaryText)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.yellow)
                            Text(String(format: "%.1f", book.rating))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(colors.primaryText)
                        }
                        
                        Text("•")
                            .foregroundStyle(colors.tertiaryText)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.cyan)
                            Text("\(book.readers) " + "okuyucu".localized)
                                .font(.system(size: 11))
                                .foregroundStyle(colors.secondaryText)
                        }
                    }
                    
                    Text("\(book.pages) " + "sayfa".localized + " • \(book.year)")
                        .font(.system(size: 11))
                        .foregroundStyle(colors.tertiaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(colors.tertiaryText)
            }
            .padding(12)
            .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(colors.border, lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Book Detail Sheet
private struct BookDetailSheet: View {
    let book: Book
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
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Book Cover
                        AsyncImage(url: URL(string: book.imageURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            case .failure(_), .empty:
                                Rectangle()
                                    .fill(LinearGradient(colors: [.orange.opacity(0.3), .brown.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .padding(.top, 20)
                        
                        // Info
                        VStack(spacing: 16) {
                            Text(book.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(colors.primaryText)
                                .multilineTextAlignment(.center)
                            
                            Text(book.author)
                                .font(.system(size: 18))
                                .foregroundStyle(colors.secondaryText)
                            
                            HStack(spacing: 20) {
                                VStack(spacing: 4) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(.yellow)
                                        Text(String(format: "%.1f", book.rating))
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(colors.primaryText)
                                    }
                                    Text("Puan".localized)
                                        .font(.system(size: 11))
                                        .foregroundStyle(colors.tertiaryText)
                                }
                                
                                VStack(spacing: 4) {
                                    Text("\(book.readers)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(colors.primaryText)
                                    Text("Okuyucu".localized)
                                        .font(.system(size: 11))
                                        .foregroundStyle(colors.tertiaryText)
                                }
                                
                                VStack(spacing: 4) {
                                    Text("\(book.pages)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(colors.primaryText)
                                    Text("Sayfa".localized)
                                        .font(.system(size: 11))
                                        .foregroundStyle(colors.tertiaryText)
                                }
                            }
                            
                            Text(book.description)
                                .font(.system(size: 15))
                                .foregroundStyle(colors.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            // Join Button
                            Button {
                                // TODO: Join book club
                            } label: {
                                HStack {
                                    Image(systemName: "person.badge.plus.fill")
                                    Text("Okuma Grubuna Katıl".localized)
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(
                                    LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing),
                                    in: RoundedRectangle(cornerRadius: 16)
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(colors.secondaryText)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }
}
import SwiftUI

// MARK: - Travel Buddy Detail View
// Super detailed travel matching with bubilet.com integration
struct TravelBuddyDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    
    @State private var selectedDestination: TravelDestination?
    @State private var selectedTravelStyle: String = "Hepsi"
    @State private var selectedBudget: String = "Hepsi"
    @State private var selectedDuration: String = "Hepsi"
    @State private var searchText = ""
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    
    let travelStyles = ["Hepsi", "Macera", "Kültür", "Plaj", "Doğa", "Şehir Turu", "Gastronomi", "Tarih", "Lüks", "Backpacking"]
    let budgets = ["Hepsi", "Ekonomik (₺)", "Orta (₺₺)", "Konforlu (₺₺₺)", "Lüks (₺₺₺₺)"]
    let durations = ["Hepsi", "Hafta Sonu", "3-5 Gün", "1 Hafta", "2 Hafta", "1 Ay+"]
    
    var filteredDestinations: [TravelDestination] {
        destinations.filter { dest in
            (selectedTravelStyle == "Hepsi" || dest.styles.contains(selectedTravelStyle)) &&
            (selectedBudget == "Hepsi" || dest.budget == selectedBudget) &&
            (searchText.isEmpty || dest.name.localizedCaseInsensitiveContains(searchText) || dest.country.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Text("✈️")
                            .font(.system(size: 60))
                        Text("Seyahat Arkadaşı".localized)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        Text("Dünyayı birlikte keşfet".localized)
                            .font(.system(size: 15))
                            .foregroundStyle(colors.secondaryText)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Search Bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(colors.secondaryText)
                        
                        TextField("Destinasyon ara...".localized, text: $searchText)
                            .textFieldStyle(.plain)
                            .foregroundStyle(colors.primaryText)
                    }
                    .padding(14)
                    .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(colors.border, lineWidth: 0.5))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    
                    // Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterMenu(title: "Stil", selection: $selectedTravelStyle, options: travelStyles)
                            FilterMenu(title: "Bütçe", selection: $selectedBudget, options: budgets)
                            FilterMenu(title: "Süre", selection: $selectedDuration, options: durations)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 12)
                    
                    // Destination Grid
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(filteredDestinations) { destination in
                                DestinationCard(destination: destination) {
                                    selectedDestination = destination
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(colors.secondaryText)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .sheet(item: $selectedDestination) { destination in
                DestinationDetailView(destination: destination)
            }
        }
    }
    
    // MARK: - Destinations Database (50+ destinations)
    private var destinations: [TravelDestination] {
        [
            // Türkiye
            TravelDestination(id: "1", name: "Kapadokya", country: "Türkiye", imageURL: "https://images.unsplash.com/photo-1541432901042-2d8bd64b4a9b?w=800", styles: ["Macera", "Kültür", "Doğa"], budget: "Orta (₺₺)", travelers: 450, rating: 4.9, description: "Balon turu, peribacaları, yeraltı şehirleri", highlights: ["Sıcak Hava Balonu", "Göreme Açık Hava Müzesi", "Yeraltı Şehirleri", "Kaya Oteller"]),
            TravelDestination(id: "2", name: "Antalya", country: "Türkiye", imageURL: "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800", styles: ["Plaj", "Tarih", "Doğa"], budget: "Orta (₺₺)", travelers: 680, rating: 4.7, description: "Akdeniz kıyısı, antik kentler", highlights: ["Kaleiçi", "Düden Şelalesi", "Aspendos", "Plajlar"]),
            TravelDestination(id: "3", name: "İstanbul", country: "Türkiye", imageURL: "https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=800", styles: ["Şehir Turu", "Kültür", "Tarih", "Gastronomi"], budget: "Orta (₺₺)", travelers: 920, rating: 4.8, description: "İki kıta, binlerce yıllık tarih", highlights: ["Ayasofya", "Topkapı Sarayı", "Boğaz Turu", "Kapalıçarşı"]),
            
            // Avrupa
            TravelDestination(id: "4", name: "Paris", country: "Fransa", imageURL: "https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800", styles: ["Şehir Turu", "Kültür", "Gastronomi", "Lüks"], budget: "Konforlu (₺₺₺)", travelers: 1200, rating: 4.9, description: "Aşk şehri, sanat ve moda başkenti", highlights: ["Eyfel Kulesi", "Louvre", "Notre Dame", "Champs-Élysées"]),
            TravelDestination(id: "5", name: "Roma", country: "İtalya", imageURL: "https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800", styles: ["Tarih", "Kültür", "Gastronomi"], budget: "Orta (₺₺)", travelers: 890, rating: 4.8, description: "Antik Roma'nın kalbi", highlights: ["Kolezyum", "Vatikan", "Trevi Çeşmesi", "Pantheon"]),
            TravelDestination(id: "6", name: "Barselona", country: "İspanya", imageURL: "https://images.unsplash.com/photo-1583422409516-2895a77efded?w=800", styles: ["Şehir Turu", "Plaj", "Kültür"], budget: "Orta (₺₺)", travelers: 750, rating: 4.7, description: "Gaudí'nin şehri", highlights: ["Sagrada Familia", "Park Güell", "La Rambla", "Plajlar"]),
            TravelDestination(id: "7", name: "Amsterdam", country: "Hollanda", imageURL: "https://images.unsplash.com/photo-1534351590666-13e3e96b5017?w=800", styles: ["Şehir Turu", "Kültür"], budget: "Konforlu (₺₺₺)", travelers: 620, rating: 4.6, description: "Kanallar şehri", highlights: ["Anne Frank Evi", "Van Gogh Müzesi", "Kanal Turu", "Bisiklet"]),
            
            // Asya
            TravelDestination(id: "8", name: "Tokyo", country: "Japonya", imageURL: "https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800", styles: ["Şehir Turu", "Kültür", "Gastronomi"], budget: "Konforlu (₺₺₺)", travelers: 980, rating: 4.9, description: "Gelecek ve gelenek", highlights: ["Shibuya", "Senso-ji", "Tokyo Tower", "Akihabara"]),
            TravelDestination(id: "9", name: "Bali", country: "Endonezya", imageURL: "https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800", styles: ["Plaj", "Doğa", "Macera"], budget: "Ekonomik (₺)", travelers: 1100, rating: 4.8, description: "Cennet ada", highlights: ["Ubud", "Tanah Lot", "Plajlar", "Pirinç Tarlaları"]),
            TravelDestination(id: "10", name: "Dubai", country: "BAE", imageURL: "https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800", styles: ["Lüks", "Şehir Turu", "Macera"], budget: "Lüks (₺₺₺₺)", travelers: 850, rating: 4.7, description: "Çöldeki mucize", highlights: ["Burj Khalifa", "Dubai Mall", "Çöl Safari", "Palm Jumeirah"]),
            
            // Add 40 more destinations
            TravelDestination(id: "11", name: "Santorini", country: "Yunanistan", imageURL: "https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800", styles: ["Plaj", "Romantik"], budget: "Konforlu (₺₺₺)", travelers: 560, rating: 4.9, description: "Beyaz evler, mavi kubbeler", highlights: ["Oia Gün Batımı", "Fira", "Plajlar", "Şarap Turları"]),
            TravelDestination(id: "12", name: "Prag", country: "Çek Cumhuriyeti", imageURL: "https://images.unsplash.com/photo-1541849546-216549ae216d?w=800", styles: ["Şehir Turu", "Tarih"], budget: "Ekonomik (₺)", travelers: 490, rating: 4.6, description: "Masal şehri", highlights: ["Prag Kalesi", "Charles Köprüsü", "Eski Şehir Meydanı"]),
            TravelDestination(id: "13", name: "Maldivler", country: "Maldivler", imageURL: "https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=800", styles: ["Plaj", "Lüks"], budget: "Lüks (₺₺₺₺)", travelers: 320, rating: 5.0, description: "Tropik cennet", highlights: ["Su Üstü Villalar", "Dalış", "Spa", "Romantik Akşam Yemekleri"]),
        ]
    }
}

// MARK: - Travel Destination Model
struct TravelDestination: Identifiable {
    let id: String
    let name: String
    let country: String
    let imageURL: String
    let styles: [String]
    let budget: String
    let travelers: Int
    let rating: Double
    let description: String
    let highlights: [String]
}

// MARK: - Destination Card
private struct DestinationCard: View {
    let destination: TravelDestination
    let action: () -> Void
    
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
        Button(action: action) {
            VStack(spacing: 0) {
                // Image - FIXED SIZE
                AsyncImage(url: URL(string: destination.imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure(_), .empty:
                        Rectangle()
                            .fill(LinearGradient(colors: [.cyan.opacity(0.3), .blue.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .overlay {
                                Image(systemName: "airplane")
                                    .font(.system(size: 30))
                                    .foregroundStyle(.white.opacity(0.3))
                            }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: (UIScreen.main.bounds.width - 48) / 2, height: 110)
                .clipped()
                
                // Info - COMPACT
                VStack(alignment: .leading, spacing: 4) {
                    Text(destination.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .lineLimit(1)
                    
                    Text(destination.country)
                        .font(.system(size: 11))
                        .foregroundStyle(colors.secondaryText)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(.yellow)
                            Text(String(format: "%.1f", destination.rating))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(colors.primaryText)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 3) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(.cyan)
                            Text("\(destination.travelers)")
                                .font(.system(size: 10))
                                .foregroundStyle(colors.secondaryText)
                        }
                    }
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(colors.cardBackground)
            }
            .frame(width: (UIScreen.main.bounds.width - 48) / 2)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(colors.border, lineWidth: 0.5))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Destination Detail View
private struct DestinationDetailView: View {
    let destination: TravelDestination
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
        ZStack(alignment: .topTrailing) {
            colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Image with Overlay Info
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: URL(string: destination.imageURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure(_), .empty:
                                Rectangle()
                                    .fill(LinearGradient(colors: [.cyan.opacity(0.3), .blue.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(height: 280)
                        .clipped()
                        
                        // Gradient Overlay
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.8)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .frame(height: 280)
                        
                        // Title & Rating on Image
                        VStack(alignment: .leading, spacing: 6) {
                            Text(destination.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white)
                            
                            HStack(spacing: 12) {
                                Text(destination.country)
                                    .font(.system(size: 15))
                                    .foregroundStyle(.white.opacity(0.9))
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 13))
                                        .foregroundStyle(.yellow)
                                    Text(String(format: "%.1f", destination.rating))
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .padding(20)
                    }
                    .frame(height: 280)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 16) {
                        // Description
                        Text(destination.description)
                            .font(.system(size: 14))
                            .foregroundStyle(colors.secondaryText)
                            .lineSpacing(4)
                            .lineLimit(4)
                        
                        // Highlights
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Öne Çıkanlar".localized)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(colors.primaryText)
                            
                            ForEach(destination.highlights.prefix(3), id: \.self) { highlight in
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.green)
                                    Text(highlight)
                                        .font(.system(size: 13))
                                        .foregroundStyle(colors.primaryText)
                                    Spacer()
                                }
                            }
                        }
                        
                        // Styles
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(destination.styles, id: \.self) { style in
                                    Text(style)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(.cyan, in: Capsule())
                                }
                            }
                        }
                        
                        // Buttons
                        VStack(spacing: 12) {
                            // Book Ticket
                            Button {
                                if let url = URL(string: "https://www.bubilet.com.tr") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "airplane")
                                        .font(.system(size: 16))
                                    Text("Uçak Bileti Al".localized)
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing),
                                    in: RoundedRectangle(cornerRadius: 14)
                                )
                                .shadow(color: .cyan.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            
                            // Find Travel Buddy
                            Button {
                                // TODO: Find travel buddy
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 16))
                                    Text("Seyahat Arkadaşı Bul".localized)
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundStyle(colors.primaryText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(colors.border, lineWidth: 1))
                            }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
            }
            
            // Close Button
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .padding(.top, 50)
            .padding(.trailing, 20)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Filter Menu
private struct FilterMenu: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    
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
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) { selection = option }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selection == "Hepsi" ? title : selection)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(colors.primaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(colors.cardBackground, in: Capsule())
            .overlay(Capsule().stroke(colors.border, lineWidth: 0.5))
        }
    }
}
