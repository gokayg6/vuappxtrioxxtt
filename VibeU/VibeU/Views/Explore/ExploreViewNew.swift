import SwiftUI

// MARK: - Premium Icon Components
// ================================
// Custom icon views to replace emojis with SF Symbols
// ================================

struct ExploreIcon: View {
    let name: String
    let size: CGFloat
    let colors: [Color]
    
    init(_ name: String, size: CGFloat = 24, colors: [Color] = [.white]) {
        self.name = name
        self.size = size
        self.colors = colors
    }
    
    var body: some View {
        Image(systemName: name)
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(
                colors.count > 1 
                    ? AnyShapeStyle(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    : AnyShapeStyle(colors.first ?? .white)
            )
    }
}

// MARK: - Explore View - Ultra Premium Glass Design
// =================================================
// Revolutionary design with real .glassEffect API
// Feature-focused, NO user profile cards
// Unique, creative, immersive experience
// =================================================

struct ExploreViewNew: View {
    @State private var showVibeQuiz = false
    @State private var showBlindDate = false
    @State private var showVoiceMatch = false
    @State private var showGameMatch = false
    @State private var showMusicMatch = false
    @State private var showFoodieDate = false
    @State private var showBookClub = false
    @State private var showEventDetail = false
    @State private var selectedMood: String?
    @State private var showSpeedDate = false
    @State private var showAstroMatch = false
    @State private var showTravelBuddy = false
    
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
                // Premium animated background
                ExploreAnimatedBackground(isDark: isDark)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // HERO SECTION - Floating Glass Orb
                        FloatingGlassHero(
                            onVibeQuiz: { showVibeQuiz = true },
                            onAstroMatch: { showAstroMatch = true }
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
                        // QUICK ACTIONS - Horizontal Pills
                        QuickActionPills(
                            onSpeedDate: { showSpeedDate = true },
                            onBlindDate: { showBlindDate = true },
                            onVoiceMatch: { showVoiceMatch = true },
                            onAstroMatch: { showAstroMatch = true }
                        )
                        
                        // MOOD SELECTOR - Glass Carousel
                        GlassMoodCarousel(selectedMood: $selectedMood)
                        
                        // EXPERIENCE GRID - Hexagonal Glass Cards
                        ExperienceGlassGrid(
                            onGameMatch: { showGameMatch = true },
                            onMusicMatch: { showMusicMatch = true },
                            onFoodieDate: { showFoodieDate = true },
                            onBookClub: { showBookClub = true },
                            onTravelBuddy: { showTravelBuddy = true }
                        )
                        .padding(.horizontal, 16)
                        
                        // LIVE EVENTS - Floating Glass Cards
                        LiveEventsSection(onEventTap: { showEventDetail = true })
                            .padding(.horizontal, 16)
                        
                        // DAILY STREAK - Gamification
                        DailyStreakGlass()
                            .padding(.horizontal, 16)
                        
                        Color.clear.frame(height: 100)
                    }
                    .padding(.top, 12)
                }
            }
            .navigationTitle("Keşfet")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
            .fullScreenCover(isPresented: $showVibeQuiz) { VibeQuizGlassView() }
            .fullScreenCover(isPresented: $showBlindDate) { BlindDateGlassView() }
            .fullScreenCover(isPresented: $showVoiceMatch) { VoiceMatchGlassView() }
            .fullScreenCover(isPresented: $showGameMatch) { GameMatchGlassView() }
            .fullScreenCover(isPresented: $showMusicMatch) { MusicMatchGlassView() }
            .fullScreenCover(isPresented: $showFoodieDate) { FoodieDateGlassView() }
            .fullScreenCover(isPresented: $showBookClub) { BookClubGlassView() }
            .fullScreenCover(isPresented: $showSpeedDate) { SpeedDateGlassView() }
            .fullScreenCover(isPresented: $showAstroMatch) { AstroMatchGlassView() }
            .fullScreenCover(isPresented: $showTravelBuddy) { TravelBuddyGlassView() }
            .fullScreenCover(item: $selectedMood) { mood in
                MoodExploreGlassView(mood: mood)
            }
            .sheet(isPresented: $showEventDetail) { EventDetailGlassView() }
        }
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}

// MARK: - Animated Background
struct ExploreAnimatedBackground: View {
    @State private var animate = false
    var isDark: Bool = true
    
    var body: some View {
        ZStack {
            isDark ? Color(red: 0.04, green: 0.02, blue: 0.08) : Color(red: 0.98, green: 0.98, blue: 0.99)
            
            // Floating orbs
            Circle()
                .fill(RadialGradient(colors: [.purple.opacity(isDark ? 0.4 : 0.15), .clear], center: .center, startRadius: 0, endRadius: 150))
                .frame(width: 300, height: 300)
                .offset(x: animate ? 50 : -50, y: animate ? -100 : -150)
                .blur(radius: 60)
            
            Circle()
                .fill(RadialGradient(colors: [.pink.opacity(isDark ? 0.3 : 0.1), .clear], center: .center, startRadius: 0, endRadius: 120))
                .frame(width: 250, height: 250)
                .offset(x: animate ? -80 : 80, y: animate ? 200 : 250)
                .blur(radius: 50)
            
            Circle()
                .fill(RadialGradient(colors: [.cyan.opacity(0.2), .clear], center: .center, startRadius: 0, endRadius: 100))
                .frame(width: 200, height: 200)
                .offset(x: animate ? 100 : 60, y: animate ? 400 : 350)
                .blur(radius: 40)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}


// MARK: - Premium Hero Card
struct FloatingGlassHero: View {
    let onVibeQuiz: () -> Void
    let onAstroMatch: () -> Void
    @State private var shimmerPhase: CGFloat = 0
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
        Button(action: onVibeQuiz) {
            ZStack {
                // Glass base
                RoundedRectangle(cornerRadius: 24)
                    .fill(colors.cardBackground)
                
                // Subtle purple accent at bottom
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [.clear, .purple.opacity(0.1), .purple.opacity(isDark ? 0.3 : 0.15)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Border
                RoundedRectangle(cornerRadius: 24)
                    .stroke(colors.border, lineWidth: 1)
                
                // Content
                HStack {
                    VStack(alignment: .leading, spacing: 16) {
                        // Title
                        Text("Ruh Eşini Bul")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        
                        // Subtitle
                        Text("Kişilik testine göre eşleş")
                            .font(.system(size: 14))
                            .foregroundStyle(colors.secondaryText)
                        
                        Spacer()
                        
                        // CTA
                        HStack(spacing: 8) {
                            Text("Başla")
                                .font(.system(size: 14, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(colors.primaryText)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [.purple, .purple.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: Capsule()
                        )
                    }
                    .padding(24)
                    
                    Spacer()
                    
                    // Icon - Premium SF Symbol
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.purple.opacity(0.3), .pink.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 70, height: 70)
                            .blur(radius: 10)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundStyle(LinearGradient(colors: [.purple, .pink], startPoint: .top, endPoint: .bottom))
                    }
                    .padding(.trailing, 24)
                }
            }
            .frame(height: 160)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: false)) {
                shimmerPhase = 1
            }
        }
    }
}


// MARK: - Quick Action Pills (Liquid Glass API)
// =====================================================
// DESIGN: Premium liquid glass pills using .glassEffect API
// - Each pill uses Capsule shape with .glassEffect(.regular.interactive())
// - Content: emoji + title + subtitle
// - No gradients, pure liquid glass aesthetic
// - Subtle color tint via overlay for differentiation
// =====================================================
struct QuickActionPills: View {
    let onSpeedDate: () -> Void
    let onBlindDate: () -> Void
    let onVoiceMatch: () -> Void
    let onAstroMatch: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                LiquidGlassPill(icon: "bolt.fill", title: "Hızlı Tanış", subtitle: "3 dk", accentColor: .orange, isHot: true, action: onSpeedDate)
                LiquidGlassPill(icon: "theatermasks.fill", title: "Kör Randevu", subtitle: "Fotoğrafsız", accentColor: .purple, isHot: false, action: onBlindDate)
                LiquidGlassPill(icon: "mic.fill", title: "Ses Tanış", subtitle: "30 sn", accentColor: .cyan, isHot: false, action: onVoiceMatch)
                LiquidGlassPill(icon: "moon.stars.fill", title: "Burç Eşleş", subtitle: "Astroloji", accentColor: .pink, isHot: true, action: onAstroMatch)
            }
            .padding(.horizontal, 16)
        }
    }
}

struct LiquidGlassPill: View {
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
    let isHot: Bool
    let action: () -> Void
    @State private var isPressed = false
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
    private let pillShape = Capsule()
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                // SF Symbol Icon
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(accentColor)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(colors.primaryText)
                        if isHot {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.orange)
                        }
                    }
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(colors.secondaryText)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(colors.cardBackground, in: pillShape)
            .overlay(pillShape.stroke(colors.border, lineWidth: 0.5))
            .scaleEffect(isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { p in isPressed = p }, perform: {})
    }
}

// MARK: - Glass Mood Carousel (Premium Minimal Design)
// =====================================================
// DESIGN: Premium minimal mood cards
// - Clean dark glass background
// - Large emoji, minimal text
// - Subtle colored accent line at bottom
// - No gradients, no glow - pure elegance
// =====================================================
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
    
    let moods = [
        ("adventure", "figure.hiking", "Macera", Color.orange),
        ("romantic", "heart.fill", "Romantik", Color.pink),
        ("chill", "moon.fill", "Sakin", Color.cyan),
        ("party", "party.popper.fill", "Parti", Color.purple),
        ("deep", "water.waves", "Derin", Color.blue)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Bugün Nasıl Hissediyorsun?")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                Spacer()
            }
            .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(moods, id: \.0) { mood in
                        PremiumMoodCard(
                            id: mood.0,
                            icon: mood.1,
                            title: mood.2,
                            accentColor: mood.3
                        ) {
                            selectedMood = mood.0
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct PremiumMoodCard: View {
    let id: String
    let icon: String
    let title: String
    let accentColor: Color
    let action: () -> Void
    @State private var isPressed = false
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
    private let cardShape = RoundedRectangle(cornerRadius: 20, style: .continuous)
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Main content area
                VStack(spacing: 12) {
                    Spacer()
                    
                    // SF Symbol Icon
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: icon)
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(accentColor)
                    }
                    
                    // Title
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                    
                    Spacer()
                }
                .frame(width: 110, height: 130)
                
                // Accent line at bottom
                Rectangle()
                    .fill(accentColor)
                    .frame(height: 3)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
            }
            .background(colors.cardBackground, in: cardShape)
            .overlay(cardShape.stroke(colors.border, lineWidth: 0.5))
            .scaleEffect(isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { p in isPressed = p }, perform: {})
    }
}


// MARK: - Experience Glass Grid
struct ExperienceGlassGrid: View {
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Clean header with subtle gold accent
            HStack(spacing: 6) {
                Text("Özel Deneyimler")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(red: 0.85, green: 0.65, blue: 0.3))
            }
            
            // 2x2 + 1 layout
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    PremiumExperienceCard(
                        icon: "gamecontroller.fill",
                        title: "Oyun Arkadaşı",
                        subtitle: "Birlikte oyna",
                        accentColor: .purple,
                        isLarge: false,
                        action: onGameMatch
                    )
                    PremiumExperienceCard(
                        icon: "music.note",
                        title: "Müzik Eşleş",
                        subtitle: "Aynı zevk",
                        accentColor: .pink,
                        isLarge: false,
                        action: onMusicMatch
                    )
                }
                
                HStack(spacing: 12) {
                    PremiumExperienceCard(
                        icon: "fork.knife",
                        title: "Gurme",
                        subtitle: "Yemek keşfi",
                        accentColor: .green,
                        isLarge: false,
                        action: onFoodieDate
                    )
                    PremiumExperienceCard(
                        icon: "book.fill",
                        title: "Kitap Kulübü",
                        subtitle: "Aynı kitap",
                        accentColor: .orange,
                        isLarge: false,
                        action: onBookClub
                    )
                }
                
                // Wide card
                PremiumExperienceCard(
                    icon: "airplane",
                    title: "Seyahat Arkadaşı",
                    subtitle: "Dünyayı birlikte keşfet",
                    accentColor: .cyan,
                    isLarge: true,
                    action: onTravelBuddy
                )
            }
        }
    }
}

// MARK: - Premium Experience Card (iOS Style - Clean & Minimal)
struct PremiumExperienceCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
    let isLarge: Bool
    let action: () -> Void
    @State private var isPressed = false
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
    
    // Subtle gold color
    private let goldColor = Color(red: 0.85, green: 0.65, blue: 0.3)
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                // Clean glass background
                RoundedRectangle(cornerRadius: 16)
                    .fill(colors.cardBackground)
                
                // Subtle accent tint
                RoundedRectangle(cornerRadius: 16)
                    .fill(accentColor.opacity(0.1))
                
                // Thin border
                RoundedRectangle(cornerRadius: 16)
                    .stroke(colors.border, lineWidth: 0.5)
                
                // Content
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: isLarge ? 17 : 15, weight: .semibold))
                            .foregroundStyle(colors.primaryText)
                        Text(subtitle)
                            .font(.system(size: isLarge ? 13 : 11))
                            .foregroundStyle(colors.secondaryText)
                    }
                    
                    Spacer()
                    
                    // SF Symbol Icon
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(0.2))
                            .frame(width: isLarge ? 50 : 44, height: isLarge ? 50 : 44)
                        
                        Image(systemName: icon)
                            .font(.system(size: isLarge ? 22 : 18, weight: .medium))
                            .foregroundStyle(accentColor)
                    }
                }
                .padding(14)
            }
            .frame(height: isLarge ? 80 : 90)
            .scaleEffect(isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { p in isPressed = p }, perform: {})
    }
}

// MARK: - Old Experience Card (keeping for compatibility)
struct ExperienceGlassCard: View {
    let emoji: String
    let title: String
    let subtitle: String
    let gradient: [Color]
    let isLarge: Bool
    let action: () -> Void
    @State private var isPressed = false
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
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(gradient[0].opacity(0.1))
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.1), lineWidth: 0.5)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: isLarge ? 17 : 15, weight: .semibold))
                            .foregroundStyle(colors.primaryText)
                        Text(subtitle)
                            .font(.system(size: isLarge ? 13 : 11))
                            .foregroundStyle(colors.secondaryText)
                    }
                    
                    Spacer()
                    
                    Text(emoji)
                        .font(.system(size: isLarge ? 40 : 30))
                }
                .padding(14)
            }
            .frame(height: isLarge ? 80 : 90)
            .scaleEffect(isPressed ? 0.98 : 1)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { p in isPressed = p }, perform: {})
    }
}


// MARK: - Live Events Section
struct LiveEventsSection: View {
    let onEventTap: () -> Void
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
    
    let events = [
        ("Canlı Müzik", "Kadıköy", "Cuma 21:00", 48, "guitars.fill"),
        ("Kahve Buluşması", "Beşiktaş", "Cmt 15:00", 23, "cup.and.saucer.fill"),
        ("Yoga & Tanışma", "Caddebostan", "Paz 10:00", 31, "figure.yoga")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Yaklaşan Etkinlikler")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                Spacer()
                HStack(spacing: 4) {
                    Circle().fill(.red).frame(width: 6, height: 6)
                    Text("CANLI")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.red)
                }
            }
            
            VStack(spacing: 10) {
                ForEach(events, id: \.0) { event in
                    EventGlassRow(
                        title: event.0,
                        location: event.1,
                        time: event.2,
                        attendees: event.3,
                        icon: event.4,
                        action: onEventTap
                    )
                }
            }
        }
    }
}

struct EventGlassRow: View {
    let title: String
    let location: String
    let time: String
    let attendees: Int
    let icon: String
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
                // Icon container
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(colors.secondaryBackground)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                    HStack(spacing: 8) {
                        HStack(spacing: 3) {
                            Image(systemName: "mappin")
                                .font(.system(size: 10))
                            Text(location)
                        }
                        HStack(spacing: 3) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                            Text(time)
                        }
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(colors.secondaryText)
                }
                
                Spacer()
                
                // Attendees
                VStack(spacing: 2) {
                    HStack(spacing: -6) {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(colors.secondaryBackground)
                                .frame(width: 22, height: 22)
                                .overlay(Circle().stroke(colors.background, lineWidth: 1))
                        }
                    }
                    Text("+\(attendees)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(colors.secondaryText)
                }
            }
            .padding(12)
            .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(colors.border, lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Daily Streak Glass
struct DailyStreakGlass: View {
    @State private var currentStreak = 5
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
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(colors.cardBackground)
            
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [.orange.opacity(isDark ? 0.2 : 0.1), .yellow.opacity(isDark ? 0.1 : 0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            RoundedRectangle(cornerRadius: 24)
                .stroke(colors.border, lineWidth: 1)
            
            HStack(spacing: 16) {
                // Flame icon
                ZStack {
                    Circle()
                        .fill(.orange.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .blur(radius: 10)
                    
                    Image(systemName: "flame.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(currentStreak) Günlük Seri!")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(colors.primaryText)
                    Text("Her gün giriş yap, ödül kazan")
                        .font(.system(size: 12))
                        .foregroundStyle(colors.secondaryText)
                    
                    // Progress dots
                    HStack(spacing: 6) {
                        ForEach(0..<7, id: \.self) { i in
                            Circle()
                                .fill(i < currentStreak ? .orange : colors.secondaryBackground)
                                .frame(width: 10, height: 10)
                        }
                    }
                }
                
                Spacer()
                
                // Reward
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(.yellow.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "gift.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.yellow)
                    }
                    Text("2 gün")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.orange)
                }
            }
            .padding(20)
        }
        .frame(height: 110)
    }
}


// MARK: - ============================================
// MARK: - FULL SCREEN GLASS VIEWS
// MARK: - ============================================

// MARK: - Vibe Quiz Glass View
struct VibeQuizGlassView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var currentQ = 0
    @State private var answers: [Int] = []
    @State private var showResult = false
    @State private var selectedAnswer: Int?
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    
    let questions = [
        ("Hafta sonu planın ne?", ["🏠 Evde film", "🎉 Dışarı çıkmak", "🏔️ Doğa yürüyüşü", "🎨 Yeni hobi"], "weekend"),
        ("İlk buluşma nerede olsun?", ["🍽️ Şık restoran", "☕ Rahat kafe", "🌳 Açık hava", "🎭 Müze/Sergi"], "date"),
        ("Seni en iyi tanımlayan?", ["🚀 Maceracı", "💕 Romantik", "😄 Eğlenceli", "🤔 Düşünceli"], "personality"),
        ("Müzik zevkin?", ["🎤 Pop", "🎸 Rock", "🎷 Jazz", "🎧 Hip-Hop"], "music"),
        ("İlişkide en önemli?", ["🤝 Güven", "💬 İletişim", "🎊 Eğlence", "❤️‍🔥 Tutku"], "relationship")
    ]
    
    var body: some View {
        ZStack {
            // Theme-aware background
            colors.background
                .ignoresSafeArea()
            
            if showResult {
                QuizResultView(dismiss: dismiss)
            } else {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(colors.primaryText)
                                .frame(width: 40, height: 40)
                                .background(colors.cardBackground, in: Circle())
                        }
                        Spacer()
                        Text("\(currentQ + 1) / \(questions.count)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(colors.secondaryText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(colors.cardBackground, in: Capsule())
                        Spacer()
                        Color.clear.frame(width: 40, height: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(colors.tertiaryText.opacity(0.3))
                                .frame(height: 4)
                            Capsule()
                                .fill(colors.accent)
                                .frame(width: geo.size.width * CGFloat(currentQ + 1) / CGFloat(questions.count), height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Question
                    VStack(spacing: 20) {
                        Text("💭")
                            .font(.system(size: 60))
                        
                        Text(questions[currentQ].0)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    Spacer()
                    
                    // Options
                    VStack(spacing: 12) {
                        ForEach(0..<4, id: \.self) { i in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedAnswer = i
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    answers.append(i)
                                    selectedAnswer = nil
                                    if currentQ < questions.count - 1 {
                                        withAnimation { currentQ += 1 }
                                    } else {
                                        withAnimation { showResult = true }
                                    }
                                }
                            } label: {
                                Text(questions[currentQ].1[i])
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(colors.primaryText)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(selectedAnswer == i ? colors.accent : colors.border, lineWidth: selectedAnswer == i ? 2 : 1)
                                    )
                                    .scaleEffect(selectedAnswer == i ? 1.02 : 1)
                            }
                            .disabled(selectedAnswer != nil)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

struct QuizResultView: View {
    let dismiss: DismissAction
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var showContent = false
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    @State private var showMatches = false
    
    var body: some View {
        ZStack {
            // Result content
            VStack(spacing: 24) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 140, height: 140)
                        .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 2))
                    
                    Text("🎉")
                        .font(.system(size: 70))
                        .scaleEffect(showContent ? 1 : 0)
                }
                
                VStack(spacing: 12) {
                    Text("Tamamlandı!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(colors.primaryText)
                    
                    Text("Kişilik profilin oluşturuldu\nEşleşmelerin hazırlanıyor...")
                        .font(.system(size: 15))
                        .foregroundStyle(colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                // Personality traits
                HStack(spacing: 12) {
                    TraitBadge(icon: "heart.fill", title: "Romantik", color: .pink)
                    TraitBadge(icon: "paintpalette.fill", title: "Yaratıcı", color: .purple)
                    TraitBadge(icon: "star.fill", title: "Sosyal", color: .yellow)
                }
                .opacity(showContent ? 1 : 0)
                
                Spacer()
                
                Button { 
                    withAnimation(.spring(response: 0.4)) {
                        showMatches = true
                    }
                } label: {
                    Text("Eşleşmeleri Gör")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.white, in: Capsule())
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
            }
            .opacity(showMatches ? 0 : 1)
            
            // Matches selection view
            if showMatches {
                MatchesSelectionView(dismiss: dismiss)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6).delay(0.2)) {
                showContent = true
            }
        }
    }
}

// MARK: - Matches Selection View
struct MatchesSelectionView: View {
    let dismiss: DismissAction
    @State private var selectedProfile: Int?
    @State private var showContent = false
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
    
    let profiles = [
        ("Ayşe", 24, "İstanbul", 94, "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400"),
        ("Zeynep", 26, "Ankara", 91, "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400"),
        ("Elif", 23, "İzmir", 88, "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400"),
        ("Selin", 25, "İstanbul", 85, "https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=400"),
        ("Deniz", 27, "Bursa", 82, "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400")
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 8) {
                Text("Senin İçin Seçtik")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                
                Text("En uyumlu 5 profil")
                    .font(.system(size: 14))
                    .foregroundStyle(colors.secondaryText)
            }
            .padding(.top, 30)
            .opacity(showContent ? 1 : 0)
            
            // Horizontal scroll profiles
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<profiles.count, id: \.self) { index in
                        MatchPhotoCard(
                            name: profiles[index].0,
                            age: profiles[index].1,
                            city: profiles[index].2,
                            compatibility: profiles[index].3,
                            photoURL: profiles[index].4,
                            isSelected: selectedProfile == index,
                            rank: index + 1
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedProfile = index
                            }
                        }
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 30)
                        .animation(.spring(response: 0.5).delay(Double(index) * 0.1), value: showContent)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            
            Spacer()
            
            // Selected profile info
            if let selected = selectedProfile {
                VStack(spacing: 8) {
                    Text("\(profiles[selected].0), \(profiles[selected].1)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(colors.primaryText)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                        Text("%\(profiles[selected].3) Uyum")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.purple)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
            
            // CTA Button
            Button {
                if let selected = selectedProfile {
                    let profile = profiles[selected]
                    appState.createConversationFromMatch(
                        name: profile.0,
                        age: profile.1,
                        city: profile.2,
                        photoURL: profile.4,
                        compatibility: profile.3
                    )
                    dismiss()
                }
            } label: {
                Text(selectedProfile != nil ? "Sohbete Başla" : "Profil Seç")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(selectedProfile != nil ? colors.primaryText : colors.tertiaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        selectedProfile != nil ? 
                        AnyShapeStyle(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)) : 
                        AnyShapeStyle(Color.white.opacity(0.2)),
                        in: Capsule()
                    )
            }
            .disabled(selectedProfile == nil)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5)) {
                showContent = true
            }
        }
    }
}

// MARK: - Match Photo Card
struct MatchPhotoCard: View {
    let name: String
    let age: Int
    let city: String
    let compatibility: Int
    let photoURL: String
    let isSelected: Bool
    let rank: Int
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
            ZStack(alignment: .bottom) {
                // Photo from URL
                AsyncImage(url: URL(string: photoURL)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                ProgressView()
                                    .tint(.white)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(colors.tertiaryText)
                            )
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                }
                .frame(width: 200, height: 280)
                
                // Gradient overlay at bottom
                LinearGradient(
                    colors: [.clear, .black.opacity(0.8)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                // Info overlay
                VStack(alignment: .leading, spacing: 6) {
                    // Compatibility badge
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 10))
                        Text("%\(compatibility)")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundStyle(colors.primaryText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.purple, in: Capsule())
                    
                    // Name & Age
                    HStack(spacing: 6) {
                        Text(name)
                            .font(.system(size: 20, weight: .bold))
                        Text("\(age)")
                            .font(.system(size: 18))
                    }
                    .foregroundStyle(colors.primaryText)
                    
                    // Location
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 11))
                        Text(city)
                            .font(.system(size: 13))
                    }
                    .foregroundStyle(colors.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                
                // Rank badge
                VStack {
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(rankColor)
                                .frame(width: 32, height: 32)
                            Text("\(rank)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(colors.primaryText)
                        }
                        .padding(12)
                    }
                    Spacer()
                }
            }
            .frame(width: 200, height: 280)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(isSelected ? .white : .clear, lineWidth: 3)
            )
            .shadow(color: isSelected ? .purple.opacity(0.5) : .clear, radius: 15)
            .scaleEffect(isSelected ? 1.05 : 1)
        }
        .buttonStyle(.plain)
    }
    
    var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(white: 0.7)
        case 3: return .orange
        default: return .purple.opacity(0.8)
        }
    }
}

struct TraitBadge: View {
    let icon: String
    let title: String
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
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(color)
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(colors.primaryText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(colors.cardBackground, in: Capsule())
    }
}


// MARK: - Blind Date Glass View
// =====================================================
// MVP FEATURES:
// - Anonymous chat without photos
// - Profile revealed after 10 messages
// - All UI elements use .glassEffect API
// =====================================================
struct BlindDateGlassView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var phase: BlindDatePhase = .intro
    @State private var messages: [(String, Bool, Date)] = []
    @State private var newMessage = ""
    @State private var messageCount = 0
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    
    enum BlindDatePhase {
        case intro, searching, chatting, revealed
    }
    
    var body: some View {
        ZStack {
            colors.background
                .ignoresSafeArea()
            
            switch phase {
            case .intro:
                BlindDateIntroLiquid(
                    onStart: {
                        withAnimation { phase = .searching }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation { phase = .chatting }
                        }
                    },
                    onDismiss: { dismiss() }
                )
            case .searching:
                BlindDateSearchingLiquid()
            case .chatting:
                BlindDateChatLiquid(
                    messages: $messages,
                    newMessage: $newMessage,
                    messageCount: $messageCount,
                    onReveal: { withAnimation { phase = .revealed } },
                    onDismiss: { dismiss() }
                )
            case .revealed:
                BlindDateRevealedLiquid(onDismiss: { dismiss() })
            }
        }
    }
}

// MARK: - Blind Date Intro (Liquid Glass)
struct BlindDateIntroLiquid: View {
    let onStart: () -> Void
    let onDismiss: () -> Void
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
    
    private let buttonShape = Capsule()
    private let circleShape = Circle()
    private let cardShape = RoundedRectangle(cornerRadius: 16, style: .continuous)
    
    var body: some View {
        VStack(spacing: 24) {
            // Close button
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: circleShape)
                        .glassEffect(.regular.interactive(), in: circleShape)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            Spacer()
            
            // Icon
            Text("🎭")
                .font(.system(size: 80))
                .frame(width: 140, height: 140)
                .background(.ultraThinMaterial, in: circleShape)
                .glassEffect(.regular.interactive(), in: circleShape)
            
            // Title
            VStack(spacing: 12) {
                Text("Kör Randevu")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                
                Text("Fotoğraf yok, sadece sohbet")
                    .font(.system(size: 15))
                    .foregroundStyle(colors.secondaryText)
            }
            
            // Features
            VStack(spacing: 12) {
                FeatureLiquidRow(icon: "eye.slash", text: "Fotoğraflar gizli")
                FeatureLiquidRow(icon: "message", text: "Sadece sohbet")
                FeatureLiquidRow(icon: "sparkles", text: "10 mesaj sonra açılır")
            }
            .padding(.top, 20)
            
            Spacer()
            
            // Start button
            Button(action: onStart) {
                Text("Eşleşme Ara")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(.ultraThinMaterial, in: buttonShape)
                    .glassEffect(.regular.interactive(), in: buttonShape)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

struct FeatureLiquidRow: View {
    let icon: String
    let text: String
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
    private let rowShape = RoundedRectangle(cornerRadius: 12, style: .continuous)
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.purple)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(colors.secondaryText)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(colors.cardBackground, in: rowShape)
        .glassEffect(.regular.interactive(), in: rowShape)
        .padding(.horizontal, 40)
    }
}

// MARK: - Blind Date Searching (Liquid Glass)
struct BlindDateSearchingLiquid: View {
    @State private var rotation: Double = 0
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
    private let circleShape = Circle()
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.2), lineWidth: 4)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(.purple, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(rotation))
                
                Text("🔍")
                    .font(.system(size: 50))
                    .frame(width: 80, height: 80)
                    .background(.ultraThinMaterial, in: circleShape)
                    .glassEffect(.regular.interactive(), in: circleShape)
            }
            
            Text("Eşleşme aranıyor...")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(colors.primaryText)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Blind Date Chat (Liquid Glass)
struct BlindDateChatLiquid: View {
    @Binding var messages: [(String, Bool, Date)]
    @Binding var newMessage: String
    @Binding var messageCount: Int
    let onReveal: () -> Void
    let onDismiss: () -> Void
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
    
    private let buttonShape = Capsule()
    private let circleShape = Circle()
    
    let autoReplies = ["Merhaba! 👋", "Nasılsın?", "İlginç!", "Anlat bakalım 😊", "Harika!", "Devam et", "Çok güzel", "Ben de öyle düşünüyorum", "Vay be!", "Süper 🎉"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .frame(width: 36, height: 36)
                        .background(colors.cardBackground, in: circleShape)
                        .glassEffect(.regular.interactive(), in: circleShape)
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("🎭")
                        .font(.system(size: 24))
                    Text("Gizemli Eşleşme")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                }
                
                Spacer()
                
                // Progress
                Text("\(10 - messageCount)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.purple)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial, in: circleShape)
                    .glassEffect(.regular.interactive(), in: circleShape)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(Array(messages.enumerated()), id: \.offset) { index, msg in
                            BlindDateBubble(text: msg.0, isMe: msg.1)
                                .id(index)
                        }
                    }
                    .padding(16)
                }
                .onChange(of: messages.count) { _, _ in
                    withAnimation {
                        proxy.scrollTo(messages.count - 1, anchor: .bottom)
                    }
                }
            }
            
            // Input
            HStack(spacing: 12) {
                TextField("Mesaj yaz...", text: $newMessage)
                    .font(.system(size: 15))
                    .foregroundStyle(colors.primaryText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: buttonShape)
                    .glassEffect(.regular.interactive(), in: buttonShape)
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(colors.primaryText)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: circleShape)
                        .glassEffect(.regular.interactive(), in: circleShape)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
    
    func sendMessage() {
        guard !newMessage.isEmpty else { return }
        messages.append((newMessage, true, Date()))
        messageCount += 1
        newMessage = ""
        
        // Auto reply
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            messages.append((autoReplies.randomElement()!, false, Date()))
            messageCount += 1
            
            if messageCount >= 10 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onReveal()
                }
            }
        }
    }
}

struct BlindDateBubble: View {
    let text: String
    let isMe: Bool
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
    private let bubbleShape = RoundedRectangle(cornerRadius: 18, style: .continuous)
    
    var body: some View {
        HStack {
            if isMe { Spacer() }
            
            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(colors.primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(colors.cardBackground, in: bubbleShape)
                .glassEffect(isMe ? .regular : .regular.tint(Color.purple.opacity(0.3)), in: bubbleShape)
            
            if !isMe { Spacer() }
        }
    }
}

// MARK: - Blind Date Revealed (Liquid Glass)
struct BlindDateRevealedLiquid: View {
    let onDismiss: () -> Void
    @State private var revealed = false
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
    
    private let buttonShape = Capsule()
    private let circleShape = Circle()
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Avatar
            ZStack {
                if revealed {
                    AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Text("👤")
                            .font(.system(size: 70))
                    }
                    .frame(width: 160, height: 160)
                    .clipShape(Circle())
                } else {
                    Text("🎭")
                        .font(.system(size: 80))
                        .frame(width: 160, height: 160)
                        .background(.ultraThinMaterial, in: circleShape)
                        .glassEffect(.regular.interactive(), in: circleShape)
                }
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.5)) {
                    revealed = true
                }
            }
            
            VStack(spacing: 12) {
                Text(revealed ? "Ayşe, 24" : "10 Mesaj Tamamlandı!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                
                Text(revealed ? "İstanbul • %92 Uyum" : "Profili görmek için dokun")
                    .font(.system(size: 15))
                    .foregroundStyle(revealed ? .purple : colors.secondaryText)
            }
            
            Spacer()
            
            // CTA Button
            Button {
                if revealed {
                    // Create conversation and navigate to chat
                    appState.createConversationFromMatch(
                        name: "Ayşe",
                        age: 24,
                        city: "İstanbul",
                        photoURL: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400",
                        compatibility: 92
                    )
                }
                onDismiss()
            } label: {
                Text(revealed ? "Sohbete Devam Et" : "Profili Aç")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(.ultraThinMaterial, in: buttonShape)
                    .glassEffect(.regular.interactive(), in: buttonShape)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}


// MARK: - Voice Match Glass View
// =====================================================
// MVP FEATURES:
// - 30 second voice recording
// - Waveform visualization
// - Playback and match finding
// - All UI elements use .glassEffect API
// =====================================================
struct VoiceMatchGlassView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var isRecording = false
    @State private var hasRecorded = false
    @State private var progress: CGFloat = 0
    @State private var waveAmplitudes: [CGFloat] = Array(repeating: 0.3, count: 30)
    @State private var isPlaying = false
    @State private var showMatches = false
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    
    private let buttonShape = Capsule()
    private let circleShape = Circle()
    
    var body: some View {
        ZStack {
            colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(colors.primaryText)
                            .frame(width: 44, height: 44)
                            .background(colors.cardBackground, in: circleShape)
                            .glassEffect(.regular.interactive(), in: circleShape)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Spacer()
                
                // Title
                VStack(spacing: 12) {
                    Text("🎙️")
                        .font(.system(size: 70))
                        .frame(width: 120, height: 120)
                        .background(.ultraThinMaterial, in: circleShape)
                        .glassEffect(.regular.interactive(), in: circleShape)
                    
                    Text("Ses Tanışması")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(colors.primaryText)
                    Text("30 saniyelik ses kaydı oluştur")
                        .font(.system(size: 15))
                        .foregroundStyle(colors.secondaryText)
                }
                
                // Waveform
                WaveformLiquidView(amplitudes: waveAmplitudes, isActive: isRecording || isPlaying)
                    .padding(.vertical, 20)
                
                // Record button
                ZStack {
                    // Progress ring
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 6)
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(isRecording ? Color.red : Color.cyan, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))
                    
                    // Button
                    Button {
                        if isRecording {
                            stopRecording()
                        } else {
                            startRecording()
                        }
                    } label: {
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(isRecording ? .red : colors.primaryText)
                            .frame(width: 100, height: 100)
                            .background(colors.cardBackground, in: circleShape)
                            .glassEffect(.regular.interactive(), in: circleShape)
                    }
                }
                
                Text(isRecording ? "Kayıt yapılıyor..." : (hasRecorded ? "Kayıt tamamlandı! ✓" : "Kaydetmek için dokun"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(colors.secondaryText)
                
                Spacer()
                
                if hasRecorded {
                    VStack(spacing: 12) {
                        // Play button
                        Button {
                            playRecording()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                Text(isPlaying ? "Durdur" : "Dinle")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(colors.primaryText)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(.ultraThinMaterial, in: buttonShape)
                            .glassEffect(.regular.interactive(), in: buttonShape)
                        }
                        
                        // Find matches button
                        Button {
                            // Create conversation and navigate to chat
                            appState.createConversationFromMatch(
                                name: "Ses Eşleşmesi",
                                age: 24,
                                city: "İstanbul",
                                photoURL: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400",
                                compatibility: 88
                            )
                            dismiss()
                        } label: {
                            Text("Eşleşmeleri Bul")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(colors.primaryText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(.ultraThinMaterial, in: buttonShape)
                                .glassEffect(.regular.interactive(), in: buttonShape)
                        }
                        .padding(.horizontal, 24)
                    }
                }
                
                Spacer().frame(height: 40)
            }
        }
    }
    
    func startRecording() {
        isRecording = true
        progress = 0
        
        // Animate waveform
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if !isRecording {
                timer.invalidate()
                return
            }
            waveAmplitudes = waveAmplitudes.map { _ in CGFloat.random(in: 0.2...1.0) }
        }
        
        // Progress timer
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if progress >= 1 || !isRecording {
                timer.invalidate()
                if progress >= 1 {
                    stopRecording()
                }
                return
            }
            withAnimation(.linear(duration: 0.1)) {
                progress += 0.1 / 30
            }
        }
    }
    
    func stopRecording() {
        isRecording = false
        hasRecorded = true
        waveAmplitudes = Array(repeating: 0.3, count: 30)
    }
    
    func playRecording() {
        isPlaying.toggle()
        if isPlaying {
            // Simulate playback
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                if !isPlaying {
                    timer.invalidate()
                    waveAmplitudes = Array(repeating: 0.3, count: 30)
                    return
                }
                waveAmplitudes = waveAmplitudes.map { _ in CGFloat.random(in: 0.2...0.8) }
            }
            
            // Auto stop after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isPlaying = false
                waveAmplitudes = Array(repeating: 0.3, count: 30)
            }
        }
    }
}

struct WaveformLiquidView: View {
    let amplitudes: [CGFloat]
    let isActive: Bool
    private let barShape = RoundedRectangle(cornerRadius: 2, style: .continuous)
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<30, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(isActive ? Color.cyan : Color.white.opacity(0.3))
                    .frame(width: 4, height: 20 + amplitudes[i] * 40)
                    .animation(.easeInOut(duration: 0.1), value: amplitudes[i])
            }
        }
        .frame(height: 80)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 20)
    }
}


// MARK: - Game Match Glass View
struct GameMatchGlassView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var selectedGames: Set<String> = []
    @State private var phase: GameMatchPhase = .selectGames
    @State private var searchingProgress: CGFloat = 0
    @State private var foundPlayers: [GamePlayer] = []
    @State private var selectedPlayer: GamePlayer?
    @State private var showLobby = false
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    
    enum GameMatchPhase {
        case selectGames, searching, results, lobby
    }
    
    struct GamePlayer: Identifiable {
        let id = UUID()
        let name: String
        let age: Int
        let photo: String
        let game: String
        let rank: String
        let rankColor: Color
        let isOnline: Bool
        let winRate: Int
    }
    
    let games = [
        ("Valorant", "🎯", Color.red, "FPS"),
        ("League of Legends", "⚔️", Color.blue, "MOBA"),
        ("CS2", "🔫", Color.orange, "FPS"),
        ("Fortnite", "🏗️", Color.purple, "Battle Royale"),
        ("Minecraft", "⛏️", Color.green, "Sandbox"),
        ("GTA V", "🚗", Color.cyan, "Open World")
    ]
    
    let mockPlayers: [GamePlayer] = [
        GamePlayer(name: "Ece", age: 22, photo: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800", game: "Valorant", rank: "Diamond II", rankColor: .cyan, isOnline: true, winRate: 58),
        GamePlayer(name: "Selin", age: 21, photo: "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=800", game: "League of Legends", rank: "Platinum I", rankColor: .green, isOnline: true, winRate: 52),
        GamePlayer(name: "Deniz", age: 23, photo: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800", game: "Valorant", rank: "Immortal", rankColor: .red, isOnline: false, winRate: 64),
        GamePlayer(name: "Ayşe", age: 20, photo: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800", game: "Fortnite", rank: "Champion", rankColor: .purple, isOnline: true, winRate: 45)
    ]
    
    var body: some View {
        ZStack {
            colors.background.ignoresSafeArea()
            
            switch phase {
            case .selectGames:
                selectGamesView
            case .searching:
                searchingView
            case .results:
                resultsView
            case .lobby:
                lobbyView
            }
        }
    }
    
    // MARK: - Select Games
    private var selectGamesView: some View {
        VStack(spacing: 20) {
            header
            
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.purple.opacity(0.3), .blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(LinearGradient(colors: [.purple, .blue], startPoint: .top, endPoint: .bottom))
                }
                Text("Ne oynuyorsun?").font(.system(size: 26, weight: .bold)).foregroundStyle(colors.primaryText)
                Text("Oyun arkadaşı bulmak için oyunlarını seç").font(.system(size: 14)).foregroundStyle(colors.secondaryText)
            }
            
            // Games as selectable chips
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(games, id: \.0) { game in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            if selectedGames.contains(game.0) { selectedGames.remove(game.0) }
                            else { selectedGames.insert(game.0) }
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Text(game.1).font(.system(size: 28))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(game.0).font(.system(size: 14, weight: .semibold)).foregroundStyle(colors.primaryText)
                                Text(game.3).font(.system(size: 11)).foregroundStyle(colors.secondaryText)
                            }
                            Spacer()
                            if selectedGames.contains(game.0) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(game.2)
                            }
                        }
                        .padding(14)
                        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selectedGames.contains(game.0) ? game.2 : colors.border, lineWidth: selectedGames.contains(game.0) ? 2 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button {
                phase = .searching
                startSearching()
            } label: {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Oyuncu Ara")
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(selectedGames.isEmpty ? colors.tertiaryText : (isDark ? .black : .white))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(selectedGames.isEmpty ? colors.border : colors.accent, in: Capsule())
            }
            .disabled(selectedGames.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Searching Animation
    private var searchingView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                // Pulsing circles
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(.purple.opacity(0.3), lineWidth: 2)
                        .frame(width: 150 + CGFloat(i * 50), height: 150 + CGFloat(i * 50))
                        .scaleEffect(searchingProgress)
                        .opacity(1 - searchingProgress)
                }
                
                // Center icon
                ZStack {
                    Circle()
                        .fill(colors.cardBackground)
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(LinearGradient(colors: [.purple, .blue], startPoint: .top, endPoint: .bottom))
                }
            }
            
            VStack(spacing: 8) {
                Text("Oyuncu Aranıyor...")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                
                Text(selectedGames.joined(separator: ", "))
                    .font(.system(size: 14))
                    .foregroundStyle(.purple)
            }
            
            // Progress dots
            HStack(spacing: 8) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(colors.secondaryText.opacity(Double(i) * 0.3 + 0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            Spacer()
            
            Button { phase = .selectGames } label: {
                Text("İptal")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(colors.secondaryText)
            }
            .padding(.bottom, 40)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                searchingProgress = 1
            }
        }
    }
    
    // MARK: - Results (Player Cards)
    private var resultsView: some View {
        VStack(spacing: 0) {
            HStack {
                Button { phase = .selectGames } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .frame(width: 40, height: 40)
                        .background(colors.cardBackground, in: Circle())
                }
                Spacer()
                Text("\(foundPlayers.count) Oyuncu Bulundu")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                Spacer()
                Color.clear.frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(foundPlayers) { player in
                        PlayerCard(player: player) {
                            selectedPlayer = player
                            phase = .lobby
                        }
                    }
                }
                .padding(20)
            }
        }
    }
    
    // MARK: - Game Lobby
    private var lobbyView: some View {
        VStack(spacing: 20) {
            HStack {
                Button { phase = .results } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .frame(width: 40, height: 40)
                        .background(colors.cardBackground, in: Circle())
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            if let player = selectedPlayer {
                VStack(spacing: 16) {
                    // Player photo
                    AsyncImage(url: URL(string: player.photo)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: { Color.gray.opacity(0.3) }
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(player.isOnline ? .green : .gray, lineWidth: 3)
                    )
                    
                    VStack(spacing: 4) {
                        Text(player.name).font(.system(size: 24, weight: .bold)).foregroundStyle(colors.primaryText)
                        HStack(spacing: 8) {
                            Text(player.rank)
                                .font(.system(size: 12, weight: .bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(player.rankColor, in: Capsule())
                            Text("\(player.winRate)% Win")
                                .font(.system(size: 12))
                                .foregroundStyle(colors.secondaryText)
                        }
                    }
                    
                    // Game info
                    HStack(spacing: 20) {
                        VStack {
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(.purple)
                            Text(player.game).font(.system(size: 12, weight: .medium)).foregroundStyle(colors.primaryText)
                        }
                        .frame(width: 100, height: 80)
                        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
                        
                        VStack {
                            Circle()
                                .fill(player.isOnline ? .green : .red)
                                .frame(width: 24, height: 24)
                            Text(player.isOnline ? "Çevrimiçi" : "Çevrimdışı").font(.system(size: 12, weight: .medium)).foregroundStyle(colors.primaryText)
                        }
                        .frame(width: 100, height: 80)
                        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
                    }
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        // Send game invite
                        appState.createConversationFromMatch(
                            name: player.name,
                            age: player.age,
                            city: "Online",
                            photoURL: player.photo,
                            compatibility: player.winRate
                        )
                        dismiss()
                        appState.selectedTab = 3
                    } label: {
                        HStack {
                            Image(systemName: "gamecontroller.fill")
                            Text("Oyuna Davet Et")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.green, in: Capsule())
                    }
                    
                    Button {
                        appState.createConversationFromMatch(
                            name: player.name,
                            age: player.age,
                            city: "Online",
                            photoURL: player.photo,
                            compatibility: player.winRate
                        )
                        dismiss()
                        appState.selectedTab = 3
                    } label: {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("Mesaj Gönder")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(colors.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(colors.cardBackground, in: Capsule())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(colors.primaryText)
                    .frame(width: 40, height: 40)
                    .background(colors.cardBackground, in: Circle())
            }
            Spacer()
            if !selectedGames.isEmpty {
                Text("\(selectedGames.count) oyun")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.purple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.purple.opacity(0.2), in: Capsule())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private func startSearching() {
        // Filter players by selected games
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            foundPlayers = mockPlayers.filter { selectedGames.contains($0.game) }
            if foundPlayers.isEmpty {
                foundPlayers = Array(mockPlayers.prefix(2)) // Show some anyway
            }
            withAnimation { phase = .results }
        }
    }
}

// MARK: - Player Card
struct PlayerCard: View {
    let player: GameMatchGlassView.GamePlayer
    let onTap: () -> Void
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
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Photo with online indicator
                ZStack(alignment: .bottomTrailing) {
                    AsyncImage(url: URL(string: player.photo)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: { Color.gray.opacity(0.3) }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    
                    Circle()
                        .fill(player.isOnline ? .green : .gray)
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(colors.background, lineWidth: 2))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(player.name).font(.system(size: 16, weight: .semibold)).foregroundStyle(colors.primaryText)
                        Text("\(player.age)").font(.system(size: 14)).foregroundStyle(colors.secondaryText)
                    }
                    HStack(spacing: 8) {
                        Text(player.game)
                            .font(.system(size: 11, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.purple.opacity(0.3), in: Capsule())
                        Text(player.rank)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(player.rankColor)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(player.winRate)%")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.green)
                    Text("Win Rate")
                        .font(.system(size: 10))
                        .foregroundStyle(colors.tertiaryText)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(colors.tertiaryText)
            }
            .padding(14)
            .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

struct GameSelectCard: View {
    let name: String
    let emoji: String
    let color: Color
    let isSelected: Bool
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
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colors.cardBackground)
                        .frame(height: 70)
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(color.opacity(0.3))
                    }
                    
                    Text(emoji)
                        .font(.system(size: 32))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? color : colors.border, lineWidth: isSelected ? 2 : 1)
                )
                
                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(colors.secondaryText)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Music Match Glass View (Spotify Style)
struct MusicMatchGlassView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var phase: MusicPhase = .selectGenres
    @State private var selectedGenres: Set<String> = []
    @State private var currentlyPlaying: String?
    @State private var matchedPerson: MusicPerson?
    @State private var compatibilityScore: Int = 0
    @State private var isPlaying = false
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    
    enum MusicPhase {
        case selectGenres, listening, matched
    }
    
    struct MusicPerson: Identifiable {
        let id = UUID()
        let name: String
        let age: Int
        let photo: String
        let topArtist: String
        let topSong: String
        let genres: [String]
    }
    
    let genres = [
        ("Pop", "🎤", Color.pink, ["Dua Lipa", "The Weeknd", "Taylor Swift"]),
        ("Rock", "🎸", Color.red, ["Arctic Monkeys", "Nirvana", "Queen"]),
        ("Hip-Hop", "🎧", Color.purple, ["Travis Scott", "Kendrick", "Drake"]),
        ("Elektronik", "🎹", Color.cyan, ["Calvin Harris", "Avicii", "Marshmello"]),
        ("R&B", "🎵", Color.blue, ["Frank Ocean", "SZA", "Daniel Caesar"]),
        ("Jazz", "🎷", Color.orange, ["Norah Jones", "Miles Davis", "Chet Baker"])
    ]
    
    let musicPeople: [MusicPerson] = [
        MusicPerson(name: "Melis", age: 23, photo: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800", topArtist: "Dua Lipa", topSong: "Levitating", genres: ["Pop", "Elektronik"]),
        MusicPerson(name: "Ceren", age: 22, photo: "https://images.unsplash.com/photo-1502823403499-6ccfcf4fb453?w=800", topArtist: "Arctic Monkeys", topSong: "Do I Wanna Know?", genres: ["Rock"]),
        MusicPerson(name: "Buse", age: 21, photo: "https://images.unsplash.com/photo-1524638431109-93d95c968f03?w=800", topArtist: "Travis Scott", topSong: "SICKO MODE", genres: ["Hip-Hop", "R&B"])
    ]
    
    var body: some View {
        ZStack {
            // Animated gradient background
            colors.background.ignoresSafeArea()
            
            switch phase {
            case .selectGenres:
                selectGenresView
            case .listening:
                listeningView
            case .matched:
                matchedView
            }
        }
    }
    
    // MARK: - Select Genres
    private var selectGenresView: some View {
        VStack(spacing: 20) {
            header
            
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.pink.opacity(0.3), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "music.note")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(LinearGradient(colors: [.pink, .purple], startPoint: .top, endPoint: .bottom))
                }
                Text("Müzik Zevkin Ne?").font(.system(size: 26, weight: .bold)).foregroundStyle(colors.primaryText)
                Text("Aynı şarkıları dinleyenlerle eşleş").font(.system(size: 14)).foregroundStyle(colors.secondaryText)
            }
            
            // Genre cards with artists
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(genres, id: \.0) { genre in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                if selectedGenres.contains(genre.0) { selectedGenres.remove(genre.0) }
                                else { selectedGenres.insert(genre.0) }
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Text(genre.1)
                                    .font(.system(size: 36))
                                    .frame(width: 60, height: 60)
                                    .background(genre.2.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(genre.0)
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundStyle(colors.primaryText)
                                    Text(genre.3.joined(separator: " • "))
                                        .font(.system(size: 12))
                                        .foregroundStyle(colors.secondaryText)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                if selectedGenres.contains(genre.0) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(genre.2)
                                }
                            }
                            .padding(14)
                            .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedGenres.contains(genre.0) ? genre.2 : .clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Button {
                phase = .listening
                startListening()
            } label: {
                HStack {
                    Image(systemName: "waveform")
                    Text("Eşleşmeyi Başlat")
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(selectedGenres.isEmpty ? colors.tertiaryText : (isDark ? .black : .white))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(selectedGenres.isEmpty ? colors.border : .green, in: Capsule())
            }
            .disabled(selectedGenres.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Listening/Matching Animation
    private var listeningView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Vinyl record animation
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .fill(
                        RadialGradient(colors: [.gray.opacity(0.3), .black], center: .center, startRadius: 20, endRadius: 100)
                    )
                    .frame(width: 200, height: 200)
                
                // Grooves
                ForEach(0..<5) { i in
                    Circle()
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                        .frame(width: CGFloat(40 + i * 30), height: CGFloat(40 + i * 30))
                }
                
                // Center label
                Circle()
                    .fill(.green)
                    .frame(width: 60, height: 60)
                
                Image(systemName: "music.note")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(colors.primaryText)
            }
            .rotationEffect(.degrees(isPlaying ? 360 : 0))
            .animation(.linear(duration: 3).repeatForever(autoreverses: false), value: isPlaying)
            
            VStack(spacing: 8) {
                Text("Müzik Zevkini Analiz Ediyoruz...")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                
                if let song = currentlyPlaying {
                    Text("♫ \(song)")
                        .font(.system(size: 14))
                        .foregroundStyle(.green)
                }
            }
            
            // Sound wave
            HStack(spacing: 4) {
                ForEach(0..<20) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.green)
                        .frame(width: 4, height: CGFloat.random(in: 10...40))
                        .animation(.easeInOut(duration: 0.3).repeatForever().delay(Double(i) * 0.05), value: isPlaying)
                }
            }
            .frame(height: 50)
            
            Spacer()
            
            Button { phase = .selectGenres; isPlaying = false } label: {
                Text("İptal")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(colors.secondaryText)
            }
            .padding(.bottom, 40)
        }
        .onAppear { isPlaying = true }
    }
    
    // MARK: - Matched View
    private var matchedView: some View {
        VStack(spacing: 20) {
            header
            
            if let person = matchedPerson {
                Spacer()
                
                // Match animation
                VStack(spacing: 20) {
                    // Photos side by side
                    HStack(spacing: -20) {
                        AsyncImage(url: URL(string: person.photo)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: { Color.gray }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.green, lineWidth: 3))
                        
                        ZStack {
                            Circle()
                                .fill(.green)
                                .frame(width: 50, height: 50)
                            Image(systemName: "music.note")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(colors.primaryText)
                        }
                        
                        Circle()
                            .fill(.gray.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(colors.secondaryText)
                            )
                    }
                    
                    VStack(spacing: 8) {
                        Text("Müzik Eşleşmesi!")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        
                        Text("\(person.name), \(person.age)")
                            .font(.system(size: 18))
                            .foregroundStyle(colors.secondaryText)
                    }
                    
                    // Compatibility
                    VStack(spacing: 8) {
                        Text("\(compatibilityScore)%")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(.green)
                        Text("Müzik Uyumu")
                            .font(.system(size: 14))
                            .foregroundStyle(colors.secondaryText)
                    }
                    .padding(.vertical, 20)
                    
                    // Common music
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "music.note")
                            Text("Ortak Zevkler")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(colors.secondaryText)
                        
                        HStack(spacing: 8) {
                            ForEach(person.genres, id: \.self) { genre in
                                Text(genre)
                                    .font(.system(size: 12, weight: .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.green.opacity(0.3), in: Capsule())
                                    .foregroundStyle(colors.primaryText)
                            }
                        }
                        
                        Text("♫ \(person.topArtist) - \(person.topSong)")
                            .font(.system(size: 13))
                            .foregroundStyle(colors.secondaryText)
                    }
                }
                
                Spacer()
                
                // Actions
                VStack(spacing: 12) {
                    Button {
                        appState.createConversationFromMatch(
                            name: person.name,
                            age: person.age,
                            city: "Müzik Eşleşmesi",
                            photoURL: person.photo,
                            compatibility: compatibilityScore
                        )
                        dismiss()
                        appState.selectedTab = 3
                    } label: {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("Mesaj Gönder")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.green, in: Capsule())
                    }
                    
                    Button {
                        phase = .selectGenres
                        matchedPerson = nil
                    } label: {
                        Text("Başka Birini Bul")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(colors.secondaryText)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(colors.primaryText)
                    .frame(width: 40, height: 40)
                    .background(colors.cardBackground, in: Circle())
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private func startListening() {
        let songs = ["Levitating - Dua Lipa", "Blinding Lights - The Weeknd", "SICKO MODE - Travis Scott"]
        var index = 0
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if index < songs.count {
                currentlyPlaying = songs[index]
                index += 1
            } else {
                timer.invalidate()
                // Find match
                if let person = musicPeople.first(where: { !selectedGenres.isDisjoint(with: Set($0.genres)) }) {
                    matchedPerson = person
                    compatibilityScore = Int.random(in: 75...95)
                } else {
                    matchedPerson = musicPeople.first
                    compatibilityScore = Int.random(in: 60...80)
                }
                withAnimation { phase = .matched }
            }
        }
    }
}


// MARK: - =====================================================
// MARK: - FOODIE DATE GLASS VIEW - ULTIMATE RESTAURANT DISCOVERY
// MARK: - =====================================================
// COMPREHENSIVE FOOD & DINING EXPERIENCE:
// Phase 1: Select cuisine preferences with beautiful food imagery
// Phase 2: Browse curated restaurants with ratings, photos, menus
// Phase 3: Find dining partners who want to try the same place
// Phase 4: Create a dinner date with reservation & menu planning
// Phase 5: Post-dinner review and photo sharing
// =====================================================

struct FoodieDateGlassView: View {
    @Environment(\.dismiss) var dismiss
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
    
    // Flow phases
    enum FoodiePhase {
        case selectCuisine      // Pick favorite cuisines
        case browseRestaurants  // See restaurant recommendations
        case findPartners       // Find people who want to go
        case planDate           // Plan the dinner date
        case confirmation       // Booking confirmed
    }
    
    @State private var phase: FoodiePhase = .selectCuisine
    @State private var selectedCuisines: Set<String> = []
    @State private var selectedRestaurant: FoodieRestaurant?
    @State private var selectedPartner: FoodiePerson?
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: String = "20:00"
    @State private var guestCount: Int = 2
    @State private var specialRequests: String = ""
    @State private var searchingAnimation = false
    
    // Cuisine data with images
    let cuisines: [(name: String, emoji: String, color: Color, dishes: [String])] = [
        ("Türk", "🥙", .orange, ["Kebap", "Lahmacun", "Pide", "Meze"]),
        ("İtalyan", "🍝", .red, ["Pizza", "Pasta", "Risotto", "Tiramisu"]),
        ("Japon", "🍣", .pink, ["Sushi", "Ramen", "Tempura", "Sashimi"]),
        ("Meksika", "🌮", .yellow, ["Taco", "Burrito", "Nachos", "Guacamole"]),
        ("Hint", "🍛", .orange, ["Curry", "Tandoori", "Naan", "Biryani"]),
        ("Çin", "🥡", .red, ["Dim Sum", "Pekin Ördeği", "Kung Pao", "Wonton"]),
        ("Fransız", "🥐", .purple, ["Croissant", "Escargot", "Ratatouille", "Crème Brûlée"]),
        ("Kore", "🍜", .green, ["Bibimbap", "Korean BBQ", "Kimchi", "Tteokbokki"]),
        ("Deniz Ürünleri", "🦞", .cyan, ["Istakoz", "Karides", "Midye", "Levrek"])
    ]
    
    // Restaurant data
    let restaurants: [FoodieRestaurant] = [
        FoodieRestaurant(name: "Mikla", cuisine: "Türk-Nordic Fusion", rating: 4.9, priceRange: "₺₺₺₺", location: "Beyoğlu", distance: 2.3, image: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800", specialties: ["Tasting Menu", "Rooftop View", "Michelin Star"], availableTimes: ["19:00", "20:00", "21:00"]),
        FoodieRestaurant(name: "Zuma", cuisine: "Japon", rating: 4.8, priceRange: "₺₺₺₺", location: "Zorlu Center", distance: 5.1, image: "https://images.unsplash.com/photo-1579027989536-b7b1f875659b?w=800", specialties: ["Sushi", "Robata", "Sake Bar"], availableTimes: ["18:30", "20:00", "21:30"]),
        FoodieRestaurant(name: "Nusr-Et", cuisine: "Türk Steakhouse", rating: 4.7, priceRange: "₺₺₺₺", location: "Etiler", distance: 4.2, image: "https://images.unsplash.com/photo-1544025162-d76694265947?w=800", specialties: ["Dry Aged Steak", "Salt Bae", "Premium Meat"], availableTimes: ["19:30", "20:30", "21:30"]),
        FoodieRestaurant(name: "Sunset Grill", cuisine: "Akdeniz", rating: 4.6, priceRange: "₺₺₺", location: "Ulus", distance: 6.8, image: "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800", specialties: ["Boğaz Manzarası", "Seafood", "Wine Selection"], availableTimes: ["18:00", "19:30", "21:00"]),
        FoodieRestaurant(name: "Çiya Sofrası", cuisine: "Anadolu", rating: 4.8, priceRange: "₺₺", location: "Kadıköy", distance: 3.5, image: "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800", specialties: ["Kebap Çeşitleri", "Ev Yemekleri", "Otantik"], availableTimes: ["12:00", "13:00", "19:00", "20:00"])
    ]
    
    // Foodie partners data
    let foodiePartners: [FoodiePerson] = [
        FoodiePerson(name: "Yağmur", age: 24, photo: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800", favCuisines: ["Japon", "İtalyan"], favRestaurant: "Zuma", foodieLevel: "Gurme", reviews: 47, bio: "Yeni tatlar keşfetmeyi seviyorum"),
        FoodiePerson(name: "Ece", age: 23, photo: "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=800", favCuisines: ["Türk", "Fransız"], favRestaurant: "Mikla", foodieLevel: "Food Blogger", reviews: 128, bio: "Her yemeğin bir hikayesi var"),
        FoodiePerson(name: "Nehir", age: 22, photo: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800", favCuisines: ["Meksika", "Kore"], favRestaurant: "Çiya", foodieLevel: "Maceraperest", reviews: 34, bio: "Sokak lezzetleri favorim"),
        FoodiePerson(name: "Dilan", age: 25, photo: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800", favCuisines: ["Hint", "Çin"], favRestaurant: "Spice Market", foodieLevel: "Şef Adayı", reviews: 89, bio: "Baharatlı yemekler benim işim")
    ]
    
    var filteredRestaurants: [FoodieRestaurant] {
        restaurants.filter { restaurant in
            selectedCuisines.isEmpty || selectedCuisines.contains(where: { restaurant.cuisine.contains($0) })
        }
    }
    
    var filteredPartners: [FoodiePerson] {
        foodiePartners.filter { person in
            !selectedCuisines.isDisjoint(with: Set(person.favCuisines))
        }
    }
    
    var body: some View {
        ZStack {
            colors.background.ignoresSafeArea()
            
            switch phase {
            case .selectCuisine:
                FoodieCuisineSelectionView(
                    cuisines: cuisines,
                    selectedCuisines: $selectedCuisines,
                    onContinue: {
                        withAnimation(.spring(response: 0.4)) {
                            searchingAnimation = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.spring(response: 0.4)) {
                                searchingAnimation = false
                                phase = .browseRestaurants
                            }
                        }
                    },
                    onDismiss: { dismiss() }
                )
                
            case .browseRestaurants:
                FoodieRestaurantBrowseView(
                    restaurants: filteredRestaurants,
                    selectedRestaurant: $selectedRestaurant,
                    onSelectRestaurant: { restaurant in
                        selectedRestaurant = restaurant
                        withAnimation(.spring(response: 0.4)) {
                            phase = .findPartners
                        }
                    },
                    onBack: { withAnimation { phase = .selectCuisine } },
                    onDismiss: { dismiss() }
                )
                
            case .findPartners:
                FoodiePartnerFinderView(
                    partners: filteredPartners,
                    restaurant: selectedRestaurant,
                    selectedPartner: $selectedPartner,
                    onSelectPartner: { partner in
                        selectedPartner = partner
                        withAnimation(.spring(response: 0.4)) {
                            phase = .planDate
                        }
                    },
                    onBack: { withAnimation { phase = .browseRestaurants } },
                    onDismiss: { dismiss() }
                )
                
            case .planDate:
                FoodieDatePlannerView(
                    restaurant: selectedRestaurant,
                    partner: selectedPartner,
                    selectedDate: $selectedDate,
                    selectedTime: $selectedTime,
                    guestCount: $guestCount,
                    specialRequests: $specialRequests,
                    onConfirm: {
                        withAnimation(.spring(response: 0.4)) {
                            phase = .confirmation
                        }
                    },
                    onBack: { withAnimation { phase = .findPartners } },
                    onDismiss: { dismiss() }
                )
                
            case .confirmation:
                FoodieConfirmationView(
                    restaurant: selectedRestaurant,
                    partner: selectedPartner,
                    date: selectedDate,
                    time: selectedTime,
                    guestCount: guestCount,
                    onStartChat: {
                        if let partner = selectedPartner {
                            appState.createConversationFromMatch(
                                name: partner.name,
                                age: partner.age,
                                city: "İstanbul",
                                photoURL: partner.photo,
                                compatibility: 92
                            )
                        }
                        dismiss()
                        appState.selectedTab = 3
                    },
                    onDismiss: { dismiss() }
                )
            }
            
            // Searching overlay animation
            if searchingAnimation {
                FoodieSearchingOverlay()
            }
        }
    }
}

// MARK: - Foodie Data Models
struct FoodieRestaurant: Identifiable {
    let id = UUID()
    let name: String
    let cuisine: String
    let rating: Double
    let priceRange: String
    let location: String
    let distance: Double
    let image: String
    let specialties: [String]
    let availableTimes: [String]
}

struct FoodiePerson: Identifiable {
    let id = UUID()
    let name: String
    let age: Int
    let photo: String
    let favCuisines: [String]
    let favRestaurant: String
    let foodieLevel: String
    let reviews: Int
    let bio: String
}

// MARK: - Phase 1: Cuisine Selection
struct FoodieCuisineSelectionView: View {
    let cuisines: [(name: String, emoji: String, color: Color, dishes: [String])]
    @Binding var selectedCuisines: Set<String>
    let onContinue: () -> Void
    let onDismiss: () -> Void
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
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                }
                Spacer()
                VStack(spacing: 2) {
                    Text("🍽️ Gurme Keşfi")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(colors.primaryText)
                    Text("Adım 1/4")
                        .font(.system(size: 11))
                        .foregroundStyle(colors.secondaryText)
                }
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Title
            VStack(spacing: 8) {
                Text("Hangi mutfakları seviyorsun?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                Text("En az 1 mutfak seç")
                    .font(.system(size: 14))
                    .foregroundStyle(colors.secondaryText)
            }
            .padding(.top, 24)
            
            // Cuisine Grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(cuisines, id: \.name) { cuisine in
                        FoodieCuisineCard(
                            name: cuisine.name,
                            emoji: cuisine.emoji,
                            color: cuisine.color,
                            dishes: cuisine.dishes,
                            isSelected: selectedCuisines.contains(cuisine.name)
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                if selectedCuisines.contains(cuisine.name) {
                                    selectedCuisines.remove(cuisine.name)
                                } else {
                                    selectedCuisines.insert(cuisine.name)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
            
            Spacer()
            
            // Continue Button
            Button(action: onContinue) {
                HStack(spacing: 8) {
                    Text("Restoranları Gör")
                        .font(.system(size: 16, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(selectedCuisines.isEmpty ? .white.opacity(0.5) : .black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(selectedCuisines.isEmpty ? .white.opacity(0.2) : .white, in: Capsule())
            }
            .disabled(selectedCuisines.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

struct FoodieCuisineCard: View {
    let name: String
    let emoji: String
    let color: Color
    let dishes: [String]
    let isSelected: Bool
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
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(emoji)
                        .font(.system(size: 36))
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.green)
                    }
                }
                
                Text(name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                
                Text(dishes.prefix(2).joined(separator: " • "))
                    .font(.system(size: 11))
                    .foregroundStyle(colors.secondaryText)
                    .lineLimit(1)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? color : .white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(isSelected ? 0.15 : 0))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Phase 2: Restaurant Browse
struct FoodieRestaurantBrowseView: View {
    let restaurants: [FoodieRestaurant]
    @Binding var selectedRestaurant: FoodieRestaurant?
    let onSelectRestaurant: (FoodieRestaurant) -> Void
    let onBack: () -> Void
    let onDismiss: () -> Void
    
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
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                }
                Spacer()
                VStack(spacing: 2) {
                    Text("🍴 Restoranlar")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(colors.primaryText)
                    Text("Adım 2/4")
                        .font(.system(size: 11))
                        .foregroundStyle(colors.secondaryText)
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(colors.secondaryText)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Restaurant List
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(restaurants) { restaurant in
                        FoodieRestaurantCard(restaurant: restaurant) {
                            onSelectRestaurant(restaurant)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

struct FoodieRestaurantCard: View {
    let restaurant: FoodieRestaurant
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
                // Restaurant Image
                AsyncImage(url: URL(string: restaurant.image)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.3))
                }
                .frame(height: 140)
                .clipped()
                
                // Info
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(restaurant.name)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(.yellow)
                            Text(String(format: "%.1f", restaurant.rating))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(colors.primaryText)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Text(restaurant.cuisine)
                            .font(.system(size: 12))
                            .foregroundStyle(colors.secondaryText)
                        Text("•")
                            .foregroundStyle(colors.tertiaryText)
                        Text(restaurant.priceRange)
                            .font(.system(size: 12))
                            .foregroundStyle(.green)
                        Text("•")
                            .foregroundStyle(colors.tertiaryText)
                        HStack(spacing: 3) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 10))
                            Text(String(format: "%.1f km", restaurant.distance))
                        }
                        .font(.system(size: 11))
                        .foregroundStyle(colors.secondaryText)
                    }
                    
                    // Specialties
                    HStack(spacing: 6) {
                        ForEach(restaurant.specialties.prefix(3), id: \.self) { specialty in
                            Text(specialty)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(colors.tertiaryText)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.white.opacity(0.1), in: Capsule())
                        }
                    }
                }
                .padding(14)
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Phase 3: Partner Finder
struct FoodiePartnerFinderView: View {
    let partners: [FoodiePerson]
    let restaurant: FoodieRestaurant?
    @Binding var selectedPartner: FoodiePerson?
    let onSelectPartner: (FoodiePerson) -> Void
    let onBack: () -> Void
    let onDismiss: () -> Void
    
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
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                }
                Spacer()
                VStack(spacing: 2) {
                    Text("👥 Yemek Arkadaşı")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(colors.primaryText)
                    Text("Adım 3/4")
                        .font(.system(size: 11))
                        .foregroundStyle(colors.secondaryText)
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(colors.secondaryText)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Restaurant info
            if let restaurant = restaurant {
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: restaurant.image)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Rectangle().fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(restaurant.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(colors.primaryText)
                        Text(restaurant.location)
                            .font(.system(size: 12))
                            .foregroundStyle(colors.secondaryText)
                    }
                    Spacer()
                }
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            
            Text("Bu restorana gitmek isteyen kişiler")
                .font(.system(size: 14))
                .foregroundStyle(colors.secondaryText)
                .padding(.top, 16)
            
            // Partners List
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(partners) { partner in
                        FoodiePartnerCard(partner: partner) {
                            onSelectPartner(partner)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
    }
}

struct FoodiePartnerCard: View {
    let partner: FoodiePerson
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
                // Photo
                AsyncImage(url: URL(string: partner.photo)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Circle().fill(Color.gray.opacity(0.3))
                }
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("\(partner.name), \(partner.age)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        
                        Text(partner.foodieLevel)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.green.opacity(0.2), in: Capsule())
                    }
                    
                    Text(partner.bio)
                        .font(.system(size: 12))
                        .foregroundStyle(colors.secondaryText)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.yellow)
                            Text("\(partner.reviews) değerlendirme")
                                .font(.system(size: 10))
                                .foregroundStyle(colors.secondaryText)
                        }
                        
                        Text("❤️ \(partner.favRestaurant)")
                            .font(.system(size: 10))
                            .foregroundStyle(colors.secondaryText)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(colors.tertiaryText)
            }
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Phase 4: Date Planner
struct FoodieDatePlannerView: View {
    let restaurant: FoodieRestaurant?
    let partner: FoodiePerson?
    @Binding var selectedDate: Date
    @Binding var selectedTime: String
    @Binding var guestCount: Int
    @Binding var specialRequests: String
    let onConfirm: () -> Void
    let onBack: () -> Void
    let onDismiss: () -> Void
    
    let timeSlots = ["18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30"]
    
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
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                }
                Spacer()
                VStack(spacing: 2) {
                    Text("📅 Rezervasyon")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(colors.primaryText)
                    Text("Adım 4/4")
                        .font(.system(size: 11))
                        .foregroundStyle(colors.secondaryText)
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(colors.secondaryText)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Restaurant & Partner Summary
                    HStack(spacing: 12) {
                        if let restaurant = restaurant {
                            AsyncImage(url: URL(string: restaurant.image)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Rectangle().fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(restaurant?.name ?? "")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(colors.primaryText)
                            if let partner = partner {
                                Text("ile \(partner.name)")
                                    .font(.system(size: 13))
                                    .foregroundStyle(colors.secondaryText)
                            }
                        }
                        
                        Spacer()
                        
                        if let partner = partner {
                            AsyncImage(url: URL(string: partner.photo)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Circle().fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(.green, lineWidth: 2))
                        }
                    }
                    .padding(14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    
                    // Date Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tarih Seç")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(colors.primaryText)
                        
                        DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .tint(.green)
                            .colorScheme(.dark)
                    }
                    .padding(14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    
                    // Time Slots
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Saat Seç")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(colors.primaryText)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(timeSlots, id: \.self) { time in
                                Button {
                                    selectedTime = time
                                } label: {
                                    Text(time)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(selectedTime == time ? .black : .white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(selectedTime == time ? .white : .white.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                    .padding(14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    
                    // Guest Count
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Kişi Sayısı")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(colors.primaryText)
                        
                        HStack {
                            Button {
                                if guestCount > 1 { guestCount -= 1 }
                            } label: {
                                Image(systemName: "minus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(colors.primaryText)
                                    .frame(width: 44, height: 44)
                                    .background(.white.opacity(0.1), in: Circle())
                            }
                            
                            Spacer()
                            
                            Text("\(guestCount)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(colors.primaryText)
                            
                            Text("kişi")
                                .font(.system(size: 14))
                                .foregroundStyle(colors.secondaryText)
                            
                            Spacer()
                            
                            Button {
                                if guestCount < 10 { guestCount += 1 }
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(colors.primaryText)
                                    .frame(width: 44, height: 44)
                                    .background(.white.opacity(0.1), in: Circle())
                            }
                        }
                    }
                    .padding(14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
            
            // Confirm Button
            Button(action: onConfirm) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                    Text("Rezervasyonu Onayla")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(.white, in: Capsule())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Phase 5: Confirmation
struct FoodieConfirmationView: View {
    let restaurant: FoodieRestaurant?
    let partner: FoodiePerson?
    let date: Date
    let time: String
    let guestCount: Int
    let onStartChat: () -> Void
    let onDismiss: () -> Void
    
    @State private var showConfetti = false
    
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
        VStack(spacing: 24) {
            Spacer()
            
            // Success Icon
            ZStack {
                Circle()
                    .fill(.green.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(.green)
            }
            .scaleEffect(showConfetti ? 1 : 0.5)
            .opacity(showConfetti ? 1 : 0)
            
            VStack(spacing: 8) {
                Text("Rezervasyon Onaylandı! 🎉")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                
                Text("Harika bir akşam yemeği sizi bekliyor")
                    .font(.system(size: 14))
                    .foregroundStyle(colors.secondaryText)
            }
            
            // Reservation Details
            VStack(spacing: 16) {
                if let restaurant = restaurant {
                    HStack {
                        Image(systemName: "fork.knife")
                            .foregroundStyle(.green)
                        Text(restaurant.name)
                            .foregroundStyle(colors.primaryText)
                        Spacer()
                    }
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.green)
                    Text(date.formatted(date: .long, time: .omitted))
                        .foregroundStyle(colors.primaryText)
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundStyle(.green)
                    Text(time)
                        .foregroundStyle(colors.primaryText)
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "person.2")
                        .foregroundStyle(.green)
                    Text("\(guestCount) kişi")
                        .foregroundStyle(colors.primaryText)
                    Spacer()
                }
                
                if let partner = partner {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.pink)
                        Text("\(partner.name) ile")
                            .foregroundStyle(colors.primaryText)
                        Spacer()
                    }
                }
            }
            .font(.system(size: 15))
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: onStartChat) {
                    HStack(spacing: 8) {
                        Image(systemName: "message.fill")
                        Text("Sohbete Başla")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(.white, in: Capsule())
                }
                
                Button(action: onDismiss) {
                    Text("Kapat")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(colors.secondaryText)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                showConfetti = true
            }
        }
    }
}

// MARK: - Searching Overlay
struct FoodieSearchingOverlay: View {
    @State private var rotation: Double = 0
    
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
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 4)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: 0.3)
                        .stroke(.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(rotation))
                    
                    Text("🍽️")
                        .font(.system(size: 32))
                }
                
                Text("Restoranlar aranıyor...")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(colors.primaryText)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}



// MARK: - =====================================================
// MARK: - BOOK CLUB GLASS VIEW - ULTIMATE READING EXPERIENCE
// MARK: - =====================================================
// COMPREHENSIVE BOOK CLUB FEATURES:
// Phase 1: Browse book categories and trending books
// Phase 2: Select a book and see reading challenge
// Phase 3: Join discussion rooms with other readers
// Phase 4: Find reading buddies and schedule book dates
// Phase 5: Track progress and share reviews
// =====================================================

struct BookClubGlassView: View {
    @Environment(\.dismiss) var dismiss
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
    
    enum BookPhase {
        case browseBooks
        case bookDetail
        case discussionRooms
        case findBuddies
        case scheduleDate
    }
    
    @State private var phase: BookPhase = .browseBooks
    @State private var selectedCategory: String = "Tümü"
    @State private var selectedBook: BookClubBook?
    @State private var selectedRoom: DiscussionRoom?
    @State private var selectedBuddy: ReadingBuddy?
    @State private var readingProgress: Double = 0
    @State private var searchText: String = ""
    
    let categories = ["Tümü", "Klasik", "Roman", "Bilim Kurgu", "Felsefe", "Psikoloji", "Şiir"]
    
    let books: [BookClubBook] = [
        BookClubBook(title: "Suç ve Ceza", author: "Dostoyevski", cover: "https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1382846449i/7144.jpg", category: "Klasik", rating: 4.8, readers: 1247, pages: 671, description: "Raskolnikov'un iç dünyasına yolculuk", discussionCount: 23, currentlyReading: 89),
        BookClubBook(title: "1984", author: "George Orwell", cover: "https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1657781256i/61439040.jpg", category: "Bilim Kurgu", rating: 4.9, readers: 2341, pages: 328, description: "Distopik bir gelecek tasviri", discussionCount: 45, currentlyReading: 156),
        BookClubBook(title: "Küçük Prens", author: "Saint-Exupéry", cover: "https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1367545443i/157993.jpg", category: "Roman", rating: 4.7, readers: 3421, pages: 96, description: "Büyüklerin anlayamadığı hikaye", discussionCount: 67, currentlyReading: 234),
        BookClubBook(title: "Simyacı", author: "Paulo Coelho", cover: "https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1483412266i/865.jpg", category: "Felsefe", rating: 4.5, readers: 1876, pages: 208, description: "Kişisel efsanenin peşinde", discussionCount: 34, currentlyReading: 123),
        BookClubBook(title: "Dönüşüm", author: "Franz Kafka", cover: "https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1359061917i/485894.jpg", category: "Klasik", rating: 4.6, readers: 987, pages: 128, description: "Absürt bir sabah", discussionCount: 19, currentlyReading: 67),
        BookClubBook(title: "Sefiller", author: "Victor Hugo", cover: "https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1411852091i/24280.jpg", category: "Klasik", rating: 4.8, readers: 765, pages: 1463, description: "Jean Valjean'ın destanı", discussionCount: 28, currentlyReading: 45)
    ]
    
    let discussionRooms: [DiscussionRoom] = [
        DiscussionRoom(name: "Raskolnikov Tartışması", book: "Suç ve Ceza", members: 12, isLive: true, nextSession: "Bugün 21:00", topic: "Ahlaki ikilem"),
        DiscussionRoom(name: "Distopya Severler", book: "1984", members: 23, isLive: false, nextSession: "Yarın 20:00", topic: "Big Brother kavramı"),
        DiscussionRoom(name: "Küçük Prens Kulübü", book: "Küçük Prens", members: 34, isLive: true, nextSession: "Şimdi", topic: "Gül ve tilki")
    ]
    
    let readingBuddies: [ReadingBuddy] = [
        ReadingBuddy(name: "Pelin", age: 24, photo: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800", currentBook: "Suç ve Ceza", booksRead: 47, favGenre: "Klasik", quote: "Kitaplar en iyi arkadaş"),
        ReadingBuddy(name: "Sude", age: 23, photo: "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=800", currentBook: "1984", booksRead: 62, favGenre: "Bilim Kurgu", quote: "Distopya bağımlısıyım"),
        ReadingBuddy(name: "Elif", age: 22, photo: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800", currentBook: "Küçük Prens", booksRead: 38, favGenre: "Roman", quote: "Her kitap yeni bir dünya"),
        ReadingBuddy(name: "Zeynep", age: 25, photo: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800", currentBook: "Simyacı", booksRead: 89, favGenre: "Felsefe", quote: "Okumak yaşamaktır")
    ]
    
    var filteredBooks: [BookClubBook] {
        books.filter { book in
            (selectedCategory == "Tümü" || book.category == selectedCategory) &&
            (searchText.isEmpty || book.title.localizedCaseInsensitiveContains(searchText) || book.author.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    var body: some View {
        ZStack {
            colors.background.ignoresSafeArea()
            
            switch phase {
            case .browseBooks:
                BookBrowseView(
                    categories: categories,
                    selectedCategory: $selectedCategory,
                    searchText: $searchText,
                    books: filteredBooks,
                    onSelectBook: { book in
                        selectedBook = book
                        withAnimation(.spring(response: 0.4)) { phase = .bookDetail }
                    },
                    onDismiss: { dismiss() }
                )
                
            case .bookDetail:
                if let book = selectedBook {
                    BookDetailView(
                        book: book,
                        readingProgress: $readingProgress,
                        onJoinDiscussion: { withAnimation(.spring(response: 0.4)) { phase = .discussionRooms } },
                        onFindBuddies: { withAnimation(.spring(response: 0.4)) { phase = .findBuddies } },
                        onBack: { withAnimation(.spring(response: 0.4)) { phase = .browseBooks } },
                        onDismiss: { dismiss() }
                    )
                }
                
            case .discussionRooms:
                DiscussionRoomsView(
                    rooms: discussionRooms,
                    book: selectedBook,
                    onSelectRoom: { room in
                        selectedRoom = room
                    },
                    onBack: { withAnimation(.spring(response: 0.4)) { phase = .bookDetail } },
                    onDismiss: { dismiss() }
                )
                
            case .findBuddies:
                ReadingBuddiesView(
                    buddies: readingBuddies,
                    book: selectedBook,
                    onSelectBuddy: { buddy in
                        selectedBuddy = buddy
                        withAnimation(.spring(response: 0.4)) { phase = .scheduleDate }
                    },
                    onBack: { withAnimation(.spring(response: 0.4)) { phase = .bookDetail } },
                    onDismiss: { dismiss() }
                )
                
            case .scheduleDate:
                if let buddy = selectedBuddy {
                    BookDateScheduleView(
                        buddy: buddy,
                        book: selectedBook,
                        onConfirm: {
                            appState.createConversationFromMatch(
                                name: buddy.name,
                                age: buddy.age,
                                city: "İstanbul",
                                photoURL: buddy.photo,
                                compatibility: 88
                            )
                            dismiss()
                            appState.selectedTab = 3
                        },
                        onBack: { withAnimation(.spring(response: 0.4)) { phase = .findBuddies } },
                        onDismiss: { dismiss() }
                    )
                }
            }
        }
    }
}

// MARK: - Book Club Data Models
struct BookClubBook: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let cover: String
    let category: String
    let rating: Double
    let readers: Int
    let pages: Int
    let description: String
    let discussionCount: Int
    let currentlyReading: Int
}

struct DiscussionRoom: Identifiable {
    let id = UUID()
    let name: String
    let book: String
    let members: Int
    let isLive: Bool
    let nextSession: String
    let topic: String
}

struct ReadingBuddy: Identifiable {
    let id = UUID()
    let name: String
    let age: Int
    let photo: String
    let currentBook: String
    let booksRead: Int
    let favGenre: String
    let quote: String
}

// MARK: - Book Browse View
struct BookBrowseView: View {
    let categories: [String]
    @Binding var selectedCategory: String
    @Binding var searchText: String
    let books: [BookClubBook]
    let onSelectBook: (BookClubBook) -> Void
    let onDismiss: () -> Void
    
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
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                }
                Spacer()
                Text("📚 Kitap Kulübü")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Search
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(colors.secondaryText)
                TextField("Kitap veya yazar ara...", text: $searchText)
                    .foregroundStyle(colors.primaryText)
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Categories
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(categories, id: \.self) { category in
                        Button {
                            withAnimation { selectedCategory = category }
                        } label: {
                            Text(category)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(selectedCategory == category ? .black : .white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? .white : .white.opacity(0.1), in: Capsule())
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 16)
            
            // Books Grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(books) { book in
                        BookCardView(book: book) { onSelectBook(book) }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

struct BookCardView: View {
    let book: BookClubBook
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
            VStack(alignment: .leading, spacing: 10) {
                // Cover - Display actual book cover image
                AsyncImage(url: URL(string: book.cover)) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(colors: [.orange.opacity(0.3), .orange.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .overlay(
                                ProgressView()
                                    .tint(.orange)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    case .failure:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(colors: [.orange.opacity(0.3), .orange.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .overlay(
                                Image(systemName: "book.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.orange.opacity(0.5))
                            )
                    @unknown default:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(colors: [.orange.opacity(0.3), .orange.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                }
                .frame(height: 120)
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(colors.primaryText)
                        .lineLimit(1)
                    
                    Text(book.author)
                        .font(.system(size: 11))
                        .foregroundStyle(colors.secondaryText)
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(.yellow)
                            Text(String(format: "%.1f", book.rating))
                                .font(.system(size: 10))
                                .foregroundStyle(colors.secondaryText)
                        }
                        
                        HStack(spacing: 2) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(.orange)
                            Text("\(book.currentlyReading)")
                                .font(.system(size: 10))
                                .foregroundStyle(colors.secondaryText)
                        }
                    }
                }
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Book Detail View
struct BookDetailView: View {
    let book: BookClubBook
    @Binding var readingProgress: Double
    let onJoinDiscussion: () -> Void
    let onFindBuddies: () -> Void
    let onBack: () -> Void
    let onDismiss: () -> Void
    
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
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(colors.secondaryText)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Book Cover & Info
                    HStack(spacing: 20) {
                        // Display actual book cover image
                        AsyncImage(url: URL(string: book.cover)) { phase in
                            switch phase {
                            case .empty:
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(LinearGradient(colors: [.orange.opacity(0.4), .orange.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .overlay(
                                        ProgressView()
                                            .tint(.orange)
                                    )
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            case .failure:
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(LinearGradient(colors: [.orange.opacity(0.4), .orange.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .overlay(
                                        Image(systemName: "book.fill")
                                            .font(.system(size: 50))
                                            .foregroundStyle(.orange.opacity(0.5))
                                    )
                            @unknown default:
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(LinearGradient(colors: [.orange.opacity(0.4), .orange.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            }
                        }
                        .frame(width: 120, height: 160)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(book.title)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(colors.primaryText)
                            
                            Text(book.author)
                                .font(.system(size: 15))
                                .foregroundStyle(colors.secondaryText)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                Text(String(format: "%.1f", book.rating))
                                    .foregroundStyle(colors.primaryText)
                                Text("(\(book.readers))")
                                    .foregroundStyle(colors.secondaryText)
                            }
                            .font(.system(size: 13))
                            
                            Text("\(book.pages) sayfa")
                                .font(.system(size: 12))
                                .foregroundStyle(colors.secondaryText)
                            
                            Text(book.category)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.orange)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.orange.opacity(0.2), in: Capsule())
                        }
                    }
                    .padding(20)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hakkında")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(colors.primaryText)
                        Text(book.description)
                            .font(.system(size: 13))
                            .foregroundStyle(colors.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    
                    // Reading Progress
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Okuma İlerlemen")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(colors.primaryText)
                            Spacer()
                            Text("\(Int(readingProgress * 100))%")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.orange)
                        }
                        
                        Slider(value: $readingProgress, in: 0...1)
                            .tint(.orange)
                        
                        Text("\(Int(Double(book.pages) * readingProgress))/\(book.pages) sayfa")
                            .font(.system(size: 11))
                            .foregroundStyle(colors.secondaryText)
                    }
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    
                    // Stats
                    HStack(spacing: 12) {
                        StatCard(icon: "person.2.fill", value: "\(book.currentlyReading)", label: "Okuyor", color: .green)
                        StatCard(icon: "bubble.left.and.bubble.right.fill", value: "\(book.discussionCount)", label: "Tartışma", color: .purple)
                        StatCard(icon: "heart.fill", value: "\(book.readers)", label: "Okudu", color: .pink)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 120)
            }
            
            // Action Buttons
            VStack(spacing: 10) {
                Button(action: onJoinDiscussion) {
                    HStack(spacing: 8) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                        Text("Tartışmalara Katıl")
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.white, in: Capsule())
                }
                
                Button(action: onFindBuddies) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.2.fill")
                        Text("Okuma Arkadaşı Bul")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(colors.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.ultraThinMaterial, in: Capsule())
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
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
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(colors.primaryText)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Discussion Rooms View
struct DiscussionRoomsView: View {
    let rooms: [DiscussionRoom]
    let book: BookClubBook?
    let onSelectRoom: (DiscussionRoom) -> Void
    let onBack: () -> Void
    let onDismiss: () -> Void
    
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
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                }
                Spacer()
                Text("💬 Tartışma Odaları")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(colors.secondaryText)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(rooms) { room in
                        DiscussionRoomCard(room: room) { onSelectRoom(room) }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
    }
}

struct DiscussionRoomCard: View {
    let room: DiscussionRoom
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
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(room.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(colors.primaryText)
                    Spacer()
                    if room.isLive {
                        HStack(spacing: 4) {
                            Circle().fill(.red).frame(width: 6, height: 6)
                            Text("CANLI")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.red)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.red.opacity(0.2), in: Capsule())
                    }
                }
                
                Text("📖 \(room.book)")
                    .font(.system(size: 12))
                    .foregroundStyle(colors.secondaryText)
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 11))
                        Text("\(room.members) üye")
                    }
                    .foregroundStyle(colors.secondaryText)
                    
                    Spacer()
                    
                    Text("🕐 \(room.nextSession)")
                        .font(.system(size: 11))
                        .foregroundStyle(.orange)
                }
                .font(.system(size: 11))
                
                Text("Konu: \(room.topic)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.purple)
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Reading Buddies View
struct ReadingBuddiesView: View {
    let buddies: [ReadingBuddy]
    let book: BookClubBook?
    let onSelectBuddy: (ReadingBuddy) -> Void
    let onBack: () -> Void
    let onDismiss: () -> Void
    
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
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                }
                Spacer()
                Text("👥 Okuma Arkadaşları")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(colors.secondaryText)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(buddies) { buddy in
                        ReadingBuddyCard(buddy: buddy) { onSelectBuddy(buddy) }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
    }
}

struct ReadingBuddyCard: View {
    let buddy: ReadingBuddy
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
                AsyncImage(url: URL(string: buddy.photo)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Circle().fill(Color.gray.opacity(0.3))
                }
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("\(buddy.name), \(buddy.age)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        
                        Text("📚 \(buddy.booksRead)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.orange.opacity(0.2), in: Capsule())
                    }
                    
                    Text("Şu an: \(buddy.currentBook)")
                        .font(.system(size: 12))
                        .foregroundStyle(colors.secondaryText)
                    
                    Text("\"\(buddy.quote)\"")
                        .font(.system(size: 11))
                        .foregroundStyle(colors.secondaryText)
                        .italic()
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(colors.tertiaryText)
            }
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Book Date Schedule View
struct BookDateScheduleView: View {

    let buddy: ReadingBuddy
    let book: BookClubBook?
    let onConfirm: () -> Void
    let onBack: () -> Void
    let onDismiss: () -> Void
    
    @State private var selectedDate = Date()
    @State private var selectedActivity = "Kahve & Kitap"
    
    let activities = ["Kahve & Kitap", "Kütüphane Buluşması", "Park Okuma", "Online Tartışma"]
    
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
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                }
                Spacer()
                Text("📅 Buluşma Planla")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(colors.secondaryText)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Buddy Info
                    HStack(spacing: 14) {
                        AsyncImage(url: URL(string: buddy.photo)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Circle().fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(buddy.name)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(colors.primaryText)
                            Text("ile kitap buluşması")
                                .font(.system(size: 13))
                                .foregroundStyle(colors.secondaryText)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    
                    // Activity Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Aktivite Seç")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(colors.primaryText)
                        
                        ForEach(activities, id: \.self) { activity in
                            Button {
                                selectedActivity = activity
                            } label: {
                                HStack {
                                    Text(activity)
                                        .font(.system(size: 14))
                                        .foregroundStyle(colors.primaryText)
                                    Spacer()
                                    if selectedActivity == activity {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.orange)
                                    }
                                }
                                .padding(12)
                                .background(selectedActivity == activity ? .orange.opacity(0.2) : .white.opacity(0.05), in: RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    
                    // Date Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tarih Seç")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(colors.primaryText)
                        
                        DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                            .tint(.orange)
                            .colorScheme(.dark)
                    }
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
            
            Button(action: onConfirm) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Buluşmayı Onayla")
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(.white, in: Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
}


// MARK: - Speed Date Glass View
// =====================================================
// MVP FEATURES:
// - 3 minute speed dating with timer
// - 5 ice-breaker questions
// - Match/Pass decision at end
// - All UI elements use .glassEffect API
// =====================================================
struct SpeedDateGlassView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var phase: SpeedDatePhase = .intro
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    @State private var timeRemaining = 180
    @State private var currentQuestion = 0
    @State private var messages: [(String, Bool)] = []
    @State private var newMessage = ""
    
    enum SpeedDatePhase {
        case intro, matching, chatting, ended
    }
    
    let questions = [
        "Kendini 3 kelimeyle tanımla",
        "Hayalindeki tatil nerede?",
        "En sevdiğin film?",
        "Süper gücün ne olurdu?",
        "Hayatta en çok neye değer verirsin?"
    ]
    
    var body: some View {
        ZStack {
            colors.background
                .ignoresSafeArea()
            
            switch phase {
            case .intro:
                SpeedDateIntroLiquid(
                    onStart: {
                        withAnimation { phase = .matching }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { phase = .chatting }
                            startTimer()
                        }
                    },
                    onDismiss: { dismiss() }
                )
            case .matching:
                SpeedDateMatchingLiquid()
            case .chatting:
                SpeedDateChatLiquid(
                    timeRemaining: timeRemaining,
                    currentQuestion: questions[currentQuestion],
                    messages: $messages,
                    newMessage: $newMessage,
                    onNextQuestion: {
                        if currentQuestion < questions.count - 1 {
                            currentQuestion += 1
                        }
                    },
                    onSendMessage: { sendMessage() },
                    onEnd: { withAnimation { phase = .ended } },
                    onDismiss: { dismiss() }
                )
            case .ended:
                SpeedDateEndedLiquid(onDismiss: { dismiss() })
            }
        }
    }
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 && phase == .chatting {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                if phase == .chatting {
                    withAnimation { phase = .ended }
                }
            }
        }
    }
    
    func sendMessage() {
        guard !newMessage.isEmpty else { return }
        messages.append((newMessage, true))
        let sent = newMessage
        newMessage = ""
        
        // Auto reply
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let replies = ["İlginç! 😊", "Ben de öyle düşünüyorum", "Harika cevap!", "Anlat daha fazla", "Vay be! 🎉"]
            messages.append((replies.randomElement()!, false))
        }
    }
}

// MARK: - Speed Date Intro (Liquid Glass)
struct SpeedDateIntroLiquid: View {
    let onStart: () -> Void
    let onDismiss: () -> Void
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
    private let buttonShape = Capsule()
    private let cardShape = RoundedRectangle(cornerRadius: 20, style: .continuous)
    private let circleShape = Circle()
    
    var body: some View {
        VStack(spacing: 24) {
            // Close button
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: circleShape)
                        .glassEffect(.regular.interactive(), in: circleShape)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            Spacer()
            
            // Icon
            Text("⚡")
                .font(.system(size: 80))
                .frame(width: 140, height: 140)
                .background(.ultraThinMaterial, in: circleShape)
                .glassEffect(.regular.interactive(), in: circleShape)
            
            // Title
            VStack(spacing: 12) {
                Text("Hızlı Tanışma")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                
                Text("3 dakikada tanış, sorulara cevap ver")
                    .font(.system(size: 15))
                    .foregroundStyle(colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            // Rules in glass cards
            HStack(spacing: 14) {
                RuleLiquidCard(icon: "clock", text: "3 dk", color: .orange)
                RuleLiquidCard(icon: "questionmark.bubble", text: "5 soru", color: .purple)
                RuleLiquidCard(icon: "heart", text: "Karar", color: .pink)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Spacer()
            
            // Start button
            Button(action: onStart) {
                Text("Başla")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(.ultraThinMaterial, in: buttonShape)
                    .glassEffect(.regular.interactive(), in: buttonShape)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

struct RuleLiquidCard: View {
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
    private let cardShape = RoundedRectangle(cornerRadius: 16, style: .continuous)
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(color)
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(colors.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(.ultraThinMaterial, in: cardShape)
        .glassEffect(.regular.interactive(), in: cardShape)
    }
}

// MARK: - Speed Date Matching (Liquid Glass)
struct SpeedDateMatchingLiquid: View {
    @State private var rotation: Double = 0
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
    private let circleShape = Circle()
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                // Outer ring
                Circle()
                    .stroke(.white.opacity(0.2), lineWidth: 4)
                    .frame(width: 120, height: 120)
                
                // Spinning arc
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(rotation))
                
                // Center icon
                Text("🔍")
                    .font(.system(size: 50))
                    .frame(width: 80, height: 80)
                    .background(.ultraThinMaterial, in: circleShape)
                    .glassEffect(.regular.interactive(), in: circleShape)
            }
            
            Text("Eşleşme bulunuyor...")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(colors.primaryText)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Speed Date Chat (Liquid Glass)
struct SpeedDateChatLiquid: View {
    let timeRemaining: Int
    let currentQuestion: String
    @Binding var messages: [(String, Bool)]
    @Binding var newMessage: String
    let onNextQuestion: () -> Void
    let onSendMessage: () -> Void
    let onEnd: () -> Void
    let onDismiss: () -> Void
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
    private let buttonShape = Capsule()
    private let inputShape = RoundedRectangle(cornerRadius: 20, style: .continuous)
    private let circleShape = Circle()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .frame(width: 36, height: 36)
                        .background(.ultraThinMaterial, in: circleShape)
                        .glassEffect(.regular.interactive(), in: circleShape)
                }
                
                Spacer()
                
                // Timer
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text(String(format: "%d:%02d", timeRemaining / 60, timeRemaining % 60))
                        .font(.system(size: 16, weight: .bold))
                        .monospacedDigit()
                }
                .foregroundStyle(timeRemaining < 30 ? .red : .white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: buttonShape)
                .glassEffect(.regular.interactive(), in: buttonShape)
                
                Spacer()
                
                Button(action: onEnd) {
                    Text("Bitir")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: buttonShape)
                        .glassEffect(.regular.interactive(), in: buttonShape)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // Current question card
            VStack(spacing: 12) {
                Text("💬")
                    .font(.system(size: 32))
                Text(currentQuestion)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(colors.primaryText)
                    .multilineTextAlignment(.center)
                
                Button(action: onNextQuestion) {
                    HStack(spacing: 6) {
                        Text("Sonraki")
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(colors.secondaryText)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: inputShape)
            .glassEffect(.regular.interactive(), in: inputShape)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(Array(messages.enumerated()), id: \.offset) { index, msg in
                            SpeedDateBubble(text: msg.0, isMe: msg.1)
                                .id(index)
                        }
                    }
                    .padding(16)
                }
                .onChange(of: messages.count) { _, _ in
                    withAnimation {
                        proxy.scrollTo(messages.count - 1, anchor: .bottom)
                    }
                }
            }
            
            // Input
            HStack(spacing: 12) {
                TextField("Mesaj yaz...", text: $newMessage)
                    .font(.system(size: 15))
                    .foregroundStyle(colors.primaryText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: buttonShape)
                    .glassEffect(.regular.interactive(), in: buttonShape)
                
                Button(action: onSendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(colors.primaryText)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: circleShape)
                        .glassEffect(.regular.interactive(), in: circleShape)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

struct SpeedDateBubble: View {

    let text: String
    let isMe: Bool
    private let bubbleShape = RoundedRectangle(cornerRadius: 18, style: .continuous)
    
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
        HStack {
            if isMe { Spacer() }
            
            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(colors.primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: bubbleShape)
                .glassEffect(isMe ? .regular : .regular.tint(Color.purple.opacity(0.3)), in: bubbleShape)
            
            if !isMe { Spacer() }
        }
    }
}

// MARK: - Speed Date Ended (Liquid Glass)
struct SpeedDateEndedLiquid: View {
    let onDismiss: () -> Void
    @State private var decision: String?
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
    private let buttonShape = Capsule()
    private let cardShape = RoundedRectangle(cornerRadius: 24, style: .continuous)
    private let circleShape = Circle()
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Timer icon
            Text("⏰")
                .font(.system(size: 70))
                .frame(width: 130, height: 130)
                .background(.ultraThinMaterial, in: circleShape)
                .glassEffect(.regular.interactive(), in: circleShape)
            
            VStack(spacing: 12) {
                Text("Süre Doldu!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                
                Text("Bu kişiyle devam etmek ister misin?")
                    .font(.system(size: 15))
                    .foregroundStyle(colors.secondaryText)
            }
            
            // Decision buttons
            HStack(spacing: 20) {
                // No button
                Button {
                    withAnimation(.spring(response: 0.3)) { decision = "no" }
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "xmark")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(decision == "no" ? .red : .white)
                        Text("Hayır")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(colors.primaryText)
                    }
                    .frame(width: 110, height: 90)
                    .background(.ultraThinMaterial, in: cardShape)
                    .glassEffect(decision == "no" ? .regular.tint(Color.red.opacity(0.3)) : .regular.interactive(), in: cardShape)
                }
                
                // Yes button
                Button {
                    withAnimation(.spring(response: 0.3)) { decision = "yes" }
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(decision == "yes" ? .green : .white)
                        Text("Evet")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(colors.primaryText)
                    }
                    .frame(width: 110, height: 90)
                    .background(.ultraThinMaterial, in: cardShape)
                    .glassEffect(decision == "yes" ? .regular.tint(Color.green.opacity(0.3)) : .regular.interactive(), in: cardShape)
                }
            }
            
            Spacer()
            
            // Confirm button
            if decision != nil {
                Button {
                    if decision == "yes" {
                        // Create conversation and navigate to chat
                        appState.createConversationFromMatch(
                            name: "Hızlı Tanışma",
                            age: 25,
                            city: "İstanbul",
                            photoURL: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400",
                            compatibility: 85
                        )
                    }
                    onDismiss()
                } label: {
                    Text(decision == "yes" ? "Sohbete Devam Et" : "Tamam")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(colors.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.ultraThinMaterial, in: buttonShape)
                        .glassEffect(.regular.interactive(), in: buttonShape)
                }
                .padding(.horizontal, 24)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            
            Spacer().frame(height: 40)
        }
    }
}


// MARK: - Astro Match Glass View
// =====================================================
// MVP FEATURES:
// - Select zodiac sign
// - Find compatible matches
// - Navigate to chat on completion
// - All UI elements use .glassEffect API
// =====================================================
struct AstroMatchGlassView: View {
    @Environment(\.dismiss) var dismiss
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
    @State private var selectedSign: String?
    @State private var showResult = false
    
    private let buttonShape = Capsule()
    private let circleShape = Circle()
    
    let signs = [
        ("Koç", "♈", "21 Mar - 19 Nis"),
        ("Boğa", "♉", "20 Nis - 20 May"),
        ("İkizler", "♊", "21 May - 20 Haz"),
        ("Yengeç", "♋", "21 Haz - 22 Tem"),
        ("Aslan", "♌", "23 Tem - 22 Ağu"),
        ("Başak", "♍", "23 Ağu - 22 Eyl"),
        ("Terazi", "♎", "23 Eyl - 22 Eki"),
        ("Akrep", "♏", "23 Eki - 21 Kas"),
        ("Yay", "♐", "22 Kas - 21 Ara"),
        ("Oğlak", "♑", "22 Ara - 19 Oca"),
        ("Kova", "♒", "20 Oca - 18 Şub"),
        ("Balık", "♓", "19 Şub - 20 Mar")
    ]
    
    var body: some View {
        ZStack {
            colors.background
                .ignoresSafeArea()
            
            if showResult {
                AstroResultView(sign: selectedSign ?? "Koç", dismiss: dismiss)
            } else {
                VStack(spacing: 16) {
                    // Header
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(colors.primaryText)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial, in: circleShape)
                                .glassEffect(.regular.interactive(), in: circleShape)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Title
                    VStack(spacing: 8) {
                        Text("🔮")
                            .font(.system(size: 60))
                            .frame(width: 100, height: 100)
                            .background(.ultraThinMaterial, in: circleShape)
                            .glassEffect(.regular.interactive(), in: circleShape)
                        
                        Text("Burç Eşleşmesi")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        Text("Burcunu seç, uyumlu eşleşmeleri bul")
                            .font(.system(size: 14))
                            .foregroundStyle(colors.secondaryText)
                    }
                    
                    // Signs grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(signs, id: \.0) { sign in
                            ZodiacLiquidCard(
                                name: sign.0,
                                symbol: sign.1,
                                isSelected: selectedSign == sign.0
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedSign = sign.0
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    // CTA
                    if selectedSign != nil {
                        Button {
                            withAnimation(.spring(response: 0.4)) {
                                showResult = true
                            }
                        } label: {
                            Text("Uyumlu Eşleşmeleri Gör")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(colors.primaryText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(.ultraThinMaterial, in: buttonShape)
                                .glassEffect(.regular.interactive(), in: buttonShape)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
            }
        }
    }
}

struct ZodiacLiquidCard: View {

    let name: String
    let symbol: String
    let isSelected: Bool
    let action: () -> Void
    
    private let cardShape = RoundedRectangle(cornerRadius: 14, style: .continuous)
    
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
            VStack(spacing: 4) {
                Text(symbol)
                    .font(.system(size: 28))
                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(colors.primaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial, in: cardShape)
            .glassEffect(isSelected ? .regular.tint(Color.purple.opacity(0.4)) : .regular.interactive(), in: cardShape)
        }
        .buttonStyle(.plain)
    }
}

struct AstroResultView: View {
    let sign: String
    let dismiss: DismissAction
    @State private var showContent = false
    
    private let buttonShape = Capsule()
    private let circleShape = Circle()
    
    let compatibleProfiles = [
        ("Selin", 25, "İstanbul", 96, "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400"),
        ("Ayşe", 24, "Ankara", 92, "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400"),
        ("Zeynep", 26, "İzmir", 88, "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400")
    ]
    
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
        VStack(spacing: 20) {
            Spacer()
            
            // Result icon
            Text("✨")
                .font(.system(size: 70))
                .frame(width: 120, height: 120)
                .background(.ultraThinMaterial, in: circleShape)
                .glassEffect(.regular.interactive(), in: circleShape)
                .scaleEffect(showContent ? 1 : 0.5)
                .opacity(showContent ? 1 : 0)
            
            VStack(spacing: 8) {
                Text("\(sign) Burcu İçin")
                    .font(.system(size: 16))
                    .foregroundStyle(.purple)
                Text("3 Uyumlu Eşleşme!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(colors.primaryText)
            }
            .opacity(showContent ? 1 : 0)
            
            // Compatible profiles
            VStack(spacing: 12) {
                ForEach(Array(compatibleProfiles.enumerated()), id: \.offset) { index, profile in
                    AstroProfileRow(
                        name: profile.0,
                        age: profile.1,
                        city: profile.2,
                        compatibility: profile.3,
                        photoURL: profile.4
                    ) {
                        // Start chat
                        appState.createConversationFromMatch(
                            name: profile.0,
                            age: profile.1,
                            city: profile.2,
                            photoURL: profile.4,
                            compatibility: profile.3
                        )
                        dismiss()
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.5).delay(Double(index) * 0.1), value: showContent)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button { dismiss() } label: {
                Text("Kapat")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(colors.secondaryText)
            }
            .padding(.bottom, 30)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6).delay(0.2)) {
                showContent = true
            }
        }
    }
}

struct AstroProfileRow: View {

    let name: String
    let age: Int
    let city: String
    let compatibility: Int
    let photoURL: String
    let onChat: () -> Void
    
    private let rowShape = RoundedRectangle(cornerRadius: 16, style: .continuous)
    private let buttonShape = Capsule()
    
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
        HStack(spacing: 14) {
            // Photo
            AsyncImage(url: URL(string: photoURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Circle()
                    .fill(Color.purple.opacity(0.3))
            }
            .frame(width: 56, height: 56)
            .clipShape(Circle())
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text("\(name), \(age)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(colors.primaryText)
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                        .font(.system(size: 10))
                    Text(city)
                        .font(.system(size: 12))
                }
                .foregroundStyle(colors.secondaryText)
            }
            
            Spacer()
            
            // Compatibility & Chat button
            VStack(alignment: .trailing, spacing: 6) {
                Text("%\(compatibility)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.purple)
                
                Button(action: onChat) {
                    Text("Sohbet")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: buttonShape)
                        .glassEffect(.regular.interactive(), in: buttonShape)
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: rowShape)
        .glassEffect(.regular.interactive(), in: rowShape)
    }
}

// MARK: - Travel Data Models
struct TravelDestination: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let country: String
}

struct TravelBuddyPerson: Identifiable {
    let id = UUID()
    let name: String
    let age: Int
    let photo: String
    let style: String
    let destinations: [String]
    let bio: String
}

// MARK: - =====================================================
// MARK: - TRAVEL BUDDY GLASS VIEW - MULTI-PHASE TRAVEL PLANNING
// MARK: - =====================================================

struct TravelBuddyGlassView: View {
    @Environment(\.dismiss) var dismiss
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
    
    @State private var selectedDestinations: Set<String> = []
    @State private var showMatches = false
    @State private var currentMatchIndex = 0
    @State private var cardOffset: CGSize = .zero
    
    let destinations: [(String, String, String)] = [
        ("Paris", "🗼", "Fransa"),
        ("Tokyo", "🗾", "Japonya"),
        ("Bali", "🏝️", "Endonezya"),
        ("Roma", "🏛️", "İtalya"),
        ("Santorini", "🏖️", "Yunanistan"),
        ("New York", "🗽", "ABD"),
        ("Dubai", "🏙️", "BAE"),
        ("Maldivler", "🌊", "Maldivler"),
        ("Barcelona", "🏰", "İspanya")
    ]
    
    let travelers: [TravelBuddyPerson] = [
        TravelBuddyPerson(name: "Elif", age: 26, photo: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800", style: "Macera", destinations: ["Paris", "Tokyo"], bio: "Yeni yerler keşfetmeyi seviyorum"),
        TravelBuddyPerson(name: "Ahmet", age: 28, photo: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800", style: "Kültür", destinations: ["Roma", "Barcelona"], bio: "Tarih ve sanat meraklısı"),
        TravelBuddyPerson(name: "Zeynep", age: 24, photo: "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800", style: "Plaj", destinations: ["Bali", "Maldivler"], bio: "Deniz ve güneş aşığı"),
        TravelBuddyPerson(name: "Can", age: 30, photo: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800", style: "Şehir", destinations: ["New York", "Dubai"], bio: "Büyük şehirleri keşfetmeyi seviyorum")
    ]
    
    var filteredTravelers: [TravelBuddyPerson] {
        travelers.filter { person in
            !selectedDestinations.isDisjoint(with: Set(person.destinations))
        }
    }
    
    var body: some View {
        ZStack {
            colors.background
                .ignoresSafeArea()
            
            if showMatches {
                matchesView
            } else {
                destinationSelectionView
            }
        }
    }
    
    private var destinationSelectionView: some View {
        VStack(spacing: 20) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.cyan.opacity(0.3), .blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "airplane")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom))
                }
                Text("Seyahat Arkadaşı").font(.system(size: 28, weight: .bold)).foregroundStyle(colors.primaryText)
                Text("Gitmek istediğin yerleri seç").font(.system(size: 14)).foregroundStyle(colors.secondaryText)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(destinations, id: \.0) { dest in
                    TravelDestinationCard(city: dest.0, emoji: dest.1, country: dest.2, isSelected: selectedDestinations.contains(dest.0)) {
                        if selectedDestinations.contains(dest.0) { selectedDestinations.remove(dest.0) }
                        else { selectedDestinations.insert(dest.0) }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button { showMatches = true } label: {
                Text(selectedDestinations.isEmpty ? "Destinasyon Seç" : "Gezgin Bul (\(filteredTravelers.count))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(selectedDestinations.isEmpty ? .white.opacity(0.5) : .black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(selectedDestinations.isEmpty ? .white.opacity(0.2) : .white, in: Capsule())
            }
            .disabled(selectedDestinations.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    private var matchesView: some View {
        VStack(spacing: 0) {
            HStack {
                Button { showMatches = false; currentMatchIndex = 0 } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                }
                Spacer()
                Text("✈️ Gezginler")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                Spacer()
                Color.clear.frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            if currentMatchIndex < filteredTravelers.count {
                let person = filteredTravelers[currentMatchIndex]
                
                GeometryReader { geo in
                    ZStack {
                        AsyncImage(url: URL(string: person.photo)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: { Color.gray.opacity(0.3) }
                        .frame(width: geo.size.width - 32, height: geo.size.height - 20)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        VStack {
                            Spacer()
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("\(person.name), \(person.age)")
                                        .font(.system(size: 26, weight: .bold))
                                    Spacer()
                                    Text(person.style)
                                        .font(.system(size: 12, weight: .bold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(.cyan, in: Capsule())
                                }
                                Text(person.bio)
                                    .font(.system(size: 14))
                                    .foregroundStyle(colors.tertiaryText)
                                HStack(spacing: 8) {
                                    ForEach(person.destinations, id: \.self) { dest in
                                        Text(dest)
                                            .font(.system(size: 12, weight: .medium))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(.ultraThinMaterial, in: Capsule())
                                    }
                                }
                            }
                            .foregroundStyle(colors.primaryText)
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                        }
                        .frame(width: geo.size.width - 32, height: geo.size.height - 20)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(cardOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { cardOffset = $0.translation }
                            .onEnded { value in
                                if abs(value.translation.width) > 100 {
                                    withAnimation { cardOffset = CGSize(width: value.translation.width > 0 ? 500 : -500, height: 0) }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        currentMatchIndex += 1
                                        cardOffset = .zero
                                    }
                                } else {
                                    withAnimation { cardOffset = .zero }
                                }
                            }
                    )
                }
                
                HStack(spacing: 20) {
                    Button {
                        withAnimation { cardOffset = CGSize(width: -500, height: 0) }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { currentMatchIndex += 1; cardOffset = .zero }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                            .frame(width: 60, height: 60)
                            .background(.red.opacity(0.8), in: Circle())
                    }
                    Button {
                        withAnimation { cardOffset = CGSize(width: 500, height: 0) }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { currentMatchIndex += 1; cardOffset = .zero }
                    } label: {
                        Image(systemName: "airplane")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                            .frame(width: 60, height: 60)
                            .background(.cyan.opacity(0.8), in: Circle())
                    }
                }
                .padding(.bottom, 40)
            } else {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.cyan.opacity(0.3), .blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "airplane")
                            .font(.system(size: 44, weight: .medium))
                            .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom))
                    }
                    Text("Tüm gezginleri gördün!").font(.system(size: 20, weight: .bold)).foregroundStyle(colors.primaryText)
                    Button { dismiss() } label: {
                        Text("Kapat").font(.system(size: 16, weight: .semibold)).foregroundStyle(.black)
                            .padding(.horizontal, 40).padding(.vertical, 14).background(.white, in: Capsule())
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct TravelDestinationCard: View {
    let city: String
    let emoji: String
    let country: String
    let isSelected: Bool
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
            VStack(spacing: 6) {
                Text(emoji)
                    .font(.system(size: 30))
                Text(city)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(colors.primaryText)
                Text(country)
                    .font(.system(size: 9))
                    .foregroundStyle(colors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? .cyan : .white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Mood Explore Glass View (Tinder-Style with Liquid Glass)
struct MoodExploreGlassView: View {
    let mood: String
    @Environment(\.dismiss) var dismiss
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
    
    // Card state
    @State private var currentIndex = 0
    @State private var cardOffset: CGSize = .zero
    @State private var cardRotation: Double = 0
    @State private var currentPhotoIndex = 0
    
    // Animation state
    @State private var cardScale: CGFloat = 1.0
    @State private var cardOpacity: Double = 1.0
    @State private var isAnimating = false  // Animasyon kilidi
    
    // UI state
    @State private var showFilters = false
    @State private var showMatchAlert = false
    @State private var matchedUser: DiscoverUser?
    
    // Mock users for mood - @State ile sabit tutuyoruz
    @State private var users: [DiscoverUser] = DiscoverUser.mockUsers.shuffled()
    
    var currentUser: DiscoverUser? {
        guard currentIndex < users.count else { return nil }
        return users[currentIndex]
    }
    
    var moodConfig: (emoji: String, title: String, accentColor: Color) {
        switch mood {
        case "adventure": return ("🎢", "Macera Arayanlar", .orange)
        case "romantic": return ("💕", "Romantik Ruhlar", .pink)
        case "chill": return ("🌙", "Sakin Akşam", .cyan)
        case "party": return ("🎉", "Parti Severler", .purple)
        case "deep": return ("🌊", "Derin Sohbet", .blue)
        default: return ("✨", "Keşfet", .purple)
        }
    }
    
    private let cardShape = RoundedRectangle(cornerRadius: 20)
    
    var body: some View {
        ZStack {
            colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with liquid glass
                moodHeader
                
                // Main Card Area
                GeometryReader { geo in
                    ZStack {
                        if let user = currentUser {
                            MoodSwipeCard(
                                user: user,
                                currentPhotoIndex: $currentPhotoIndex,
                                cardOffset: cardOffset,
                                accentColor: moodConfig.accentColor
                            )
                            .frame(width: geo.size.width - 24, height: geo.size.height + 20)
                            .offset(cardOffset)
                            .rotationEffect(.degrees(cardRotation))
                            .scaleEffect(cardScale)
                            .opacity(cardOpacity)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        guard !isAnimating else { return }
                                        cardOffset = value.translation
                                        cardRotation = Double(value.translation.width / 20)
                                    }
                                    .onEnded { value in
                                        guard !isAnimating else { return }
                                        if value.translation.width > 100 {
                                            likeUser()
                                        } else if value.translation.width < -100 {
                                            skipUser()
                                        } else if value.translation.height < -100 {
                                            superLikeUser()
                                        } else {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                cardOffset = .zero
                                                cardRotation = 0
                                            }
                                        }
                                    }
                            )
                            .allowsHitTesting(!isAnimating)
                        } else {
                            // Empty state
                            MoodEmptyCard(mood: moodConfig)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Action Buttons with liquid glass
                MoodActionBar(
                    onRewind: rewindUser,
                    onSkip: skipUser,
                    onSuperLike: superLikeUser,
                    onLike: likeUser,
                    cardOffset: cardOffset,
                    accentColor: moodConfig.accentColor
                )
                .padding(.bottom, 8)
                .padding(.top, -30)
            }
        }
        .sheet(isPresented: $showFilters) {
            MoodFilterSheet(mood: mood)
        }
        .alert("Eşleşme! 🎉", isPresented: $showMatchAlert) {
            Button("Sohbete Git") {
                if let user = matchedUser {
                    appState.createConversationFromMatch(
                        name: user.displayName,
                        age: user.age,
                        city: user.city,
                        photoURL: user.profilePhotoURL,
                        compatibility: 85
                    )
                    dismiss()
                    appState.selectedTab = 3
                }
            }
            Button("Devam Et", role: .cancel) { }
        } message: {
            if let user = matchedUser {
                Text("\(user.displayName) ile eşleştin!")
            }
        }
    }
    
    // MARK: - Header
    private var moodHeader: some View {
        HStack(spacing: 16) {
            // Close button
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(colors.primaryText)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
                    .glassEffect(.regular.interactive(), in: Circle())
            }
            
            Spacer()
            
            // Title
            HStack(spacing: 8) {
                Text(moodConfig.emoji)
                    .font(.system(size: 22))
                Text(moodConfig.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(colors.primaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .glassEffect(.regular.interactive(), in: Capsule())
            
            Spacer()
            
            // Filter button
            Button { showFilters = true } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(colors.primaryText)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
                    .glassEffect(.regular.interactive(), in: Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Actions
    private func likeUser() {
        guard !isAnimating else { return }
        isAnimating = true
        
        withAnimation(.easeOut(duration: 0.3)) {
            cardOffset = CGSize(width: 500, height: 0)
            cardRotation = 15
        }
        
        // Random match chance (30%)
        if let user = currentUser, Bool.random() && Bool.random() {
            matchedUser = user
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showMatchAlert = true
            }
        }
        
        moveToNextUser()
    }
    
    private func skipUser() {
        guard !isAnimating else { return }
        isAnimating = true
        
        withAnimation(.easeOut(duration: 0.3)) {
            cardOffset = CGSize(width: -500, height: 0)
            cardRotation = -15
        }
        moveToNextUser()
    }
    
    private func superLikeUser() {
        guard !isAnimating else { return }
        isAnimating = true
        
        withAnimation(.easeOut(duration: 0.3)) {
            cardOffset = CGSize(width: 0, height: -500)
        }
        
        // Super like always matches
        if let user = currentUser {
            matchedUser = user
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showMatchAlert = true
            }
        }
        
        moveToNextUser()
    }
    
    private func rewindUser() {
        guard currentIndex > 0, !isAnimating else { return }
        isAnimating = true
        
        cardScale = 1.15
        cardOpacity = 0
        currentIndex -= 1
        cardOffset = .zero
        cardRotation = 0
        currentPhotoIndex = 0
        withAnimation(.easeOut(duration: 0.3)) {
            cardScale = 1.0
            cardOpacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            isAnimating = false
        }
    }
    
    private func moveToNextUser() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            cardScale = 1.15
            cardOpacity = 0
            currentIndex += 1
            cardOffset = .zero
            cardRotation = 0
            currentPhotoIndex = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeOut(duration: 0.35)) {
                    cardScale = 1.0
                    cardOpacity = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    isAnimating = false
                }
            }
        }
    }
}

// MARK: - Mood Swipe Card (Liquid Glass)
struct MoodSwipeCard: View {

    let user: DiscoverUser
    @Binding var currentPhotoIndex: Int
    let cardOffset: CGSize
    let accentColor: Color
    
    private var photos: [String] {
        if user.photos.isEmpty {
            return [user.profilePhotoURL]
        }
        return user.photos.map { $0.url }
    }
    
    private let cardShape = RoundedRectangle(cornerRadius: 20)
    
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
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // Photo
                AsyncImage(url: URL(string: photos[currentPhotoIndex])) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Rectangle()
                            .fill(Color(white: 0.12))
                            .overlay {
                                ProgressView()
                                    .tint(.white)
                            }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
                
                // Photo indicators
                VStack {
                    HStack(spacing: 4) {
                        ForEach(0..<photos.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPhotoIndex ? .white : .white.opacity(0.4))
                                .frame(height: 3)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    
                    Spacer()
                }
                
                // Tap areas for photo navigation
                HStack(spacing: 0) {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if currentPhotoIndex > 0 {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    currentPhotoIndex -= 1
                                }
                            }
                        }
                    
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if currentPhotoIndex < photos.count - 1 {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    currentPhotoIndex += 1
                                }
                            }
                        }
                }
                
                // Bottom info with glass effect
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Gradient fade
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.6), .black.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 180)
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 10) {
                            // Active badge
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 8, height: 8)
                                Text("Aktif")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundStyle(colors.primaryText)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                            .glassEffect(.regular.interactive(), in: Capsule())
                            
                            // Name + Age
                            HStack(spacing: 8) {
                                Text(user.displayName)
                                    .font(.system(size: 28, weight: .bold))
                                Text("\(user.age)")
                                    .font(.system(size: 26, weight: .regular))
                                if user.isBoosted {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 22))
                                        .foregroundStyle(.blue)
                                }
                            }
                            .foregroundStyle(colors.primaryText)
                            
                            // Location + Tags
                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 12))
                                    Text("\(Int(user.distanceKm ?? 0)) km")
                                }
                                
                                Text("•")
                                
                                Text(user.city)
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(colors.tertiaryText)
                            
                            // Interest tags
                            HStack(spacing: 8) {
                                ForEach(user.tags.prefix(3), id: \.self) { tag in
                                    Text(tag)
                                        .font(.system(size: 18))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
                
                // Like/Nope/SuperLike indicators
                if cardOffset.width > 50 {
                    moodLikeIndicator
                }
                if cardOffset.width < -50 {
                    moodNopeIndicator
                }
                if cardOffset.height < -50 {
                    moodSuperLikeIndicator(accentColor: accentColor)
                }
            }
            .clipShape(cardShape)
        }
    }
    
    private var moodLikeIndicator: some View {
        VStack {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.4, green: 1.0, blue: 0.4))
                        .frame(width: 70, height: 70)
                    Image(systemName: "heart.fill")
                        .font(.system(size: 35, weight: .bold))
                        .foregroundStyle(colors.primaryText)
                }
                .shadow(color: .green.opacity(0.5), radius: 12)
                .rotationEffect(.degrees(-15))
                .padding(.leading, 30)
                .padding(.top, 60)
                Spacer()
            }
            Spacer()
        }
    }
    
    private var moodNopeIndicator: some View {
        VStack {
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.3, blue: 0.4))
                        .frame(width: 70, height: 70)
                    Image(systemName: "xmark")
                        .font(.system(size: 35, weight: .bold))
                        .foregroundStyle(colors.primaryText)
                }
                .shadow(color: .red.opacity(0.5), radius: 12)
                .rotationEffect(.degrees(15))
                .padding(.trailing, 30)
                .padding(.top, 60)
            }
            Spacer()
        }
    }
    
    private func moodSuperLikeIndicator(accentColor: Color) -> some View {
        VStack {
            Spacer()
            ZStack {
                Circle()
                    .fill(accentColor)
                    .frame(width: 70, height: 70)
                Image(systemName: "star.fill")
                    .font(.system(size: 35, weight: .bold))
                    .foregroundStyle(colors.primaryText)
            }
            .shadow(color: accentColor.opacity(0.5), radius: 12)
            .padding(.bottom, 120)
        }
    }
}

// MARK: - Mood Action Bar (Liquid Glass)
struct MoodActionBar: View {
    let onRewind: () -> Void
    let onSkip: () -> Void
    let onSuperLike: () -> Void
    let onLike: () -> Void
    var cardOffset: CGSize = .zero
    let accentColor: Color
    
    private var highlightSkip: Bool { cardOffset.width < -50 }
    private var highlightLike: Bool { cardOffset.width > 50 }
    private var highlightSuperLike: Bool { cardOffset.height < -50 }
    
    var body: some View {
        HStack(spacing: 16) {
            // Rewind
            MoodGlassButton(
                icon: "arrow.uturn.backward",
                size: 52,
                iconSize: 22,
                normalColor: .orange,
                action: onRewind
            )
            
            // Skip
            MoodGlassButton(
                icon: "xmark",
                size: 62,
                iconSize: 28,
                normalColor: Color(red: 1.0, green: 0.3, blue: 0.5),
                action: onSkip,
                isHighlighted: highlightSkip
            )
            
            // Super Like
            MoodGlassButton(
                icon: "star.fill",
                size: 52,
                iconSize: 24,
                normalColor: accentColor,
                action: onSuperLike,
                isHighlighted: highlightSuperLike
            )
            
            // Like
            MoodGlassButton(
                icon: "heart.fill",
                size: 62,
                iconSize: 28,
                normalColor: Color(red: 0.4, green: 1.0, blue: 0.4),
                action: onLike,
                isHighlighted: highlightLike
            )
            
            // Message
            MoodGlassButton(
                icon: "paperplane.fill",
                size: 52,
                iconSize: 22,
                normalColor: .blue,
                action: { }
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Mood Glass Button
struct MoodGlassButton: View {
    let icon: String
    let size: CGFloat
    let iconSize: CGFloat
    let normalColor: Color
    let action: () -> Void
    var isHighlighted: Bool = false
    
    @State private var isPressed = false
    
    private var isActive: Bool { isPressed || isHighlighted }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isActive ? normalColor : Color(white: 0.12))
                    .overlay {
                        Circle()
                            .fill(.ultraThinMaterial.opacity(isActive ? 0 : 0.5))
                    }
                
                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .bold))
                    .foregroundStyle(isActive ? .white : normalColor)
            }
            .frame(width: size, height: size)
            .glassEffect(isActive ? .regular : .regular.interactive(), in: Circle())
            .scaleEffect(isActive ? 1.1 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isActive)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Mood Empty Card
struct MoodEmptyCard: View {

    let mood: (emoji: String, title: String, accentColor: Color)
    
    private let cardShape = RoundedRectangle(cornerRadius: 20)
    
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
        VStack(spacing: 20) {
            Text(mood.emoji)
                .font(.system(size: 60))
            
            Text("Şimdilik bu kadar!")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(colors.primaryText)
            
            Text("Daha sonra tekrar gel,\nyeni kişiler eklenecek")
                .font(.system(size: 15))
                .foregroundStyle(colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial, in: cardShape)
        .glassEffect(.regular.interactive(), in: cardShape)
        .padding(.horizontal, 12)
    }
}

// MARK: - Mood Filter Sheet
struct MoodFilterSheet: View {
    let mood: String
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
    
    @State private var minAge: Double = 18
    @State private var maxAge: Double = 35
    @State private var maxDistance: Double = 50
    @State private var showOnlineOnly = false
    @State private var showVerifiedOnly = false
    
    private let sheetShape = RoundedRectangle(cornerRadius: 32)
    private let sectionShape = RoundedRectangle(cornerRadius: 16)
    
    var body: some View {
        NavigationStack {
            ZStack {
                colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Age Range
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Yaş Aralığı")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(colors.secondaryText)
                            
                            HStack {
                                Text("\(Int(minAge))")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(colors.primaryText)
                                Spacer()
                                Text("-")
                                    .foregroundStyle(colors.secondaryText)
                                Spacer()
                                Text("\(Int(maxAge))")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(colors.primaryText)
                            }
                            .padding(.horizontal, 40)
                            
                            // Sliders
                            VStack(spacing: 8) {
                                Slider(value: $minAge, in: 18...99)
                                    .tint(.purple)
                                Slider(value: $maxAge, in: 18...99)
                                    .tint(.purple)
                            }
                        }
                        .padding(20)
                        .background(.ultraThinMaterial, in: sectionShape)
                        .glassEffect(.regular.interactive(), in: sectionShape)
                        
                        // Distance
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Maksimum Mesafe")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(colors.secondaryText)
                            
                            HStack {
                                Text("\(Int(maxDistance)) km")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(colors.primaryText)
                                Spacer()
                                if maxDistance >= 100 {
                                    Text("Tüm Dünya")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.purple)
                                }
                            }
                            
                            Slider(value: $maxDistance, in: 1...100)
                                .tint(.purple)
                        }
                        .padding(20)
                        .background(.ultraThinMaterial, in: sectionShape)
                        .glassEffect(.regular.interactive(), in: sectionShape)
                        
                        // Quick Filters
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Hızlı Filtreler")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(colors.secondaryText)
                            
                            Toggle(isOn: $showOnlineOnly) {
                                HStack(spacing: 10) {
                                    Circle()
                                        .fill(.green)
                                        .frame(width: 10, height: 10)
                                    Text("Sadece Çevrimiçi")
                                        .font(.system(size: 15))
                                        .foregroundStyle(colors.primaryText)
                                }
                            }
                            .tint(.purple)
                            
                            Toggle(isOn: $showVerifiedOnly) {
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundStyle(.blue)
                                    Text("Sadece Doğrulanmış")
                                        .font(.system(size: 15))
                                        .foregroundStyle(colors.primaryText)
                                }
                            }
                            .tint(.purple)
                        }
                        .padding(20)
                        .background(.ultraThinMaterial, in: sectionShape)
                        .glassEffect(.regular.interactive(), in: sectionShape)
                        
                        // Apply Button
                        Button {
                            dismiss()
                        } label: {
                            Text("Uygula")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(.white, in: Capsule())
                        }
                        .padding(.top, 10)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Filtreler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sıfırla") {
                        minAge = 18
                        maxAge = 35
                        maxDistance = 50
                        showOnlineOnly = false
                        showVerifiedOnly = false
                    }
                    .foregroundStyle(.purple)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}



// MARK: - Event Detail Glass View
struct EventDetailGlassView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var isJoined = false
    
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
            colors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Hero image placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [.pink, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 200)
                        
                        VStack(spacing: 12) {
                            Text("🎸")
                                .font(.system(size: 60))
                            Text("Canlı Müzik Gecesi")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(colors.primaryText)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Details
                    VStack(alignment: .leading, spacing: 20) {
                        // Date & Time
                        HStack(spacing: 16) {
                            DetailBox(icon: "calendar", title: "Tarih", value: "Cuma, 15 Ocak")
                            DetailBox(icon: "clock", title: "Saat", value: "21:00")
                        }
                        
                        // Location
                        HStack(spacing: 12) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(.pink)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Kadıköy, İstanbul")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(colors.primaryText)
                                Text("Moda Sahili yakını")
                                    .font(.system(size: 12))
                                    .foregroundStyle(colors.secondaryText)
                            }
                            
                            Spacer()
                            
                            Button {
                                // Open maps
                            } label: {
                                Text("Harita")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(colors.primaryText)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.ultraThinMaterial, in: Capsule())
                            }
                        }
                        .padding(14)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        
                        // About
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Hakkında")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(colors.primaryText)
                            
                            Text("Akustik performanslar eşliğinde yeni insanlarla tanışma fırsatı. Rahat bir ortamda müzik dinleyip sohbet edebilirsiniz.")
                                .font(.system(size: 14))
                                .foregroundStyle(colors.secondaryText)
                                .lineSpacing(4)
                        }
                        
                        // Attendees
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Katılımcılar")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(colors.primaryText)
                                Spacer()
                                Text("48/60")
                                    .font(.system(size: 14))
                                    .foregroundStyle(colors.secondaryText)
                            }
                            
                            HStack(spacing: -8) {
                                ForEach(0..<6, id: \.self) { i in
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Circle()
                                                .stroke(Color(red: 0.04, green: 0.02, blue: 0.08), lineWidth: 2)
                                        )
                                        .overlay(
                                            Text(i < 5 ? "👤" : "+43")
                                                .font(.system(size: i < 5 ? 20 : 11, weight: .semibold))
                                                .foregroundStyle(colors.primaryText)
                                        )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Join button
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            isJoined.toggle()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if isJoined {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            Text(isJoined ? "Katıldın" : "Etkinliğe Katıl")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(isJoined ? .green : .black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(isJoined ? .green.opacity(0.2) : .white, in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(isJoined ? .green : .clear, lineWidth: 2)
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 30)
                }
                .padding(.top, 20)
            }
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(colors.primaryText)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 16)
                }
                Spacer()
            }
        }
    }
}

struct DetailBox: View {

    let icon: String
    let title: String
    let value: String
    
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
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.pink)
                .frame(width: 36, height: 36)
                .background(.ultraThinMaterial, in: Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11))
                    .foregroundStyle(colors.secondaryText)
                Text(value)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(colors.primaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

#Preview {
    ExploreViewNew()
        .environment(AppState())
}
