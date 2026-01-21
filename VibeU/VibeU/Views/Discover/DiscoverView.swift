import SwiftUI

// MARK: - Mock Data

extension DiscoverUser {
    static var mockUsers: [DiscoverUser] {
        let maleNames = ["Kaan", "Efe", "Berk", "Emre", "Arda", "Mert", "Yiğit", "Barış", "Can", "Deniz", "Ozan", "Alp", "Cem", "Onur", "Burak", "Tolga", "Serkan", "Kerem", "Koray", "Batuhan", "Ahmet", "Mehmet", "Mustafa", "Ali", "Hüseyin", "İbrahim", "Ömer", "Yusuf", "Murat", "Hakan"]
        let femaleNames = ["Elif", "Zeynep", "Ayşe", "Defne", "Ecrin", "Melis", "İrem", "Selin", "Ceren", "Derya", "Pelin", "Buse", "Gizem", "Cansu", "Burcu", "Özge", "Şeyma", "Aslı", "Esra", "Gamze", "Nazlı", "Merve", "Dilan", "Ebru", "Fatma", "Aylin", "Büşra", "Dilara", "Eylül", "Hande", "Aleyna", "Nilay", "Sibel", "Tuğba", "Yonca", "Eda", "Seda", "Beren", "Ceyda", "Damla", "Ezgi", "Funda", "Gözde", "Hale", "Işık", "Jale", "Lale", "Mine", "Nalan", "Oya", "Pınar", "Rana", "Simge", "Yeliz", "Zehra", "Berna", "Duygu", "Ece", "Filiz", "Gül", "Hazal", "İpek", "Jülide", "Kübra", "Leyla", "Melek", "Nur", "Pırıl", "Reyhan", "Saadet", "Tülay", "Ülkü", "Vildan", "Yasemin", "Zümrüt", "Bahar", "Cansel", "Demet", "Fulya", "Gonca", "Hülya", "İlknur", "Menekşe", "Nergis", "Perihan", "Rüya", "Sanem", "Tansu", "Umay", "Veda", "Yeşim", "Zuhal"]
        let cities = ["Istanbul", "Ankara", "Izmir", "Antalya", "Bursa", "Adana", "Konya", "Gaziantep", "Mersin", "Kayseri", "Eskişehir", "Samsun", "Trabzon", "Bodrum", "Muğla", "Denizli", "Kocaeli", "Diyarbakır", "Hatay", "Malatya"]
        
        // High Quality 4K Unsplash Photos (Sexy/Bikini/Summer/Model Vibe) - OPTIMIZED w=800
        // Strictly verified female IDs to strictly avoid male photos
        let highQualityFemalePhotos = [
            "https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1524638431109-93d95c968f03?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1589156229687-496a31ad1d1f?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1564485377539-4af72d1f6a2f?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1502823403499-6ccfcf4fb453?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1546539782-d937163cb434?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1519699047748-de8e457a634e?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1526510747491-58f928ec870f?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1500917293891-ef795e70e1f6?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1485290334039-a3c69043e517?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1514315384763-ba401779410f?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1469334031218-e382a71b716b?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1532910404247-7ee9488d7292?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1523950704592-7e477647242d?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1523264939339-c89f9dadde2e?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1504703395950-b89145a5425b?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1512316609839-ce289d3eba0a?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1517365830460-955ce3ccd263?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1520813792240-56fc4a3765a7?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1496747611176-843222e1e57c?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1509967419530-da38b4704bc6?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1534751516642-a1af1ef26a56?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1516467508483-a7212febe31a?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1548142813-c348350df52b?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1485206412256-701ccc5b93ca?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1520155707862-5b32817388d6?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1529139574466-a302d2d3f524?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1518977822534-7049a61ee0c2?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1518384401463-d3876163c195?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1507537297725-24a1c029d3ca?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1532384748853-8f54a8f476e2?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1621784563330-caee0b138a00?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1520261073836-bdd3147814b7?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1524250502761-1ac6f2e30d43?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1525186402429-b4ff38bedec6?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1563178406-4cdc2923acbc?q=80&w=800&auto=format&fit=crop"
        ]
        
        let malePhotos = [
            "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1200",
            "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1200",
            "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?q=80&w=1200",
            "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?q=80&w=1200",
            "https://images.unsplash.com/photo-1504257432389-52343af06ae3?q=80&w=1200",
        ]
        
        let tags = ["Müzik", "Spor", "Seyahat", "Yemek", "Film", "Dans", "Yoga", "Fotoğraf", "Doğa", "Fitness", "Kahve", "Moda", "Alışveriş", "Yüzme", "Parti", "Sanat", "Netflix", "Kedi", "Köpek", "Sahil", "Kamp", "Makyaj", "Astnoloji", "Konser"]
        
        var users: [DiscoverUser] = []
        var idCounter = 1
        
        func createUser(name: String, photoUrl: String, city: String, isFemale: Bool) -> DiscoverUser {
            let age = Int.random(in: 19...28)
            let userTags = Array(tags.shuffled().prefix(Int.random(in: 3...6)))
            let id = "mock_u_\(idCounter)"
            idCounter += 1
            
            return DiscoverUser(
                id: id,
                displayName: name,
                age: age,
                city: city,
                country: "Turkey",
                countryFlag: "🇹🇷",
                distanceKm: Double.random(in: 1...30),
                profilePhotoURL: photoUrl,
                photos: [
                    UserPhoto(id: "p_\(id)_1", url: photoUrl, thumbnailURL: nil, orderIndex: 0, isPrimary: true)
                ],
                tags: userTags,
                commonInterests: Array(userTags.prefix(2)),
                score: Double.random(in: 75...100),
                isBoosted: idCounter % 10 == 0,
                tiktokUsername: idCounter % 3 == 0 ? "@\(name.lowercased())" : nil,
                instagramUsername: idCounter % 2 == 0 ? name.lowercased() : nil,
                snapchatUsername: idCounter % 4 == 0 ? name.lowercased() : nil,
                isFriend: false
            )
        }
        
        // 1. Generate 70 Female Users from High Quality List (Unique)
        for (index, photoUrl) in highQualityFemalePhotos.enumerated() {
            let name = femaleNames[index % femaleNames.count]
            let city = cities.randomElement()!
            users.append(createUser(name: name, photoUrl: photoUrl, city: city, isFemale: true))
        }
        
        // 2. Generate Only 3 Male Users (Strictly limited)
        for i in 0..<3 {
            let name = maleNames.randomElement()!
            let city = cities.randomElement()!
            let photoUrl = malePhotos[i % malePhotos.count]
            users.append(createUser(name: name, photoUrl: photoUrl, city: city, isFemale: false))
        }
        
        return users.shuffled()
    }

    // Seni beğenenler (Premium) - High Quality Dynamic
    static var likedYouUsers: [DiscoverUser] {
        // Use a consistent subset of mockUsers or generate specific ones
        // For simplicity and quality consistency, we generate a fresh batch using the same high quality logic
        return Array(mockUsers.prefix(6))
    }
    
    // Yeni üyeler - High Quality Dynamic
    static var newUsers: [DiscoverUser] {
        return Array(mockUsers.suffix(6))
    }


}



// MARK: - Main Discover View (Tinder Style)

struct DiscoverView: View {
    @State private var currentIndex = 0
    @State private var cardOffset: CGSize = .zero
    @State private var cardRotation: Double = 0
    @State private var currentPhotoIndex = 0
    @State private var selectedUser: DiscoverUser?
    @State private var selectedMode: DiscoverMode = .forYou
    @State private var showDiamond = false
    @State private var showFilters = false
    @State private var showDoubleDateSheet = false
    @State private var showPremiumSheet = false
    @State private var showProfileSummary = false
    @State private var isGlobalMode = false // false = Kendi Ülkem, true = Global
    
    // Geçiş animasyonu için
    @State private var cardScale: CGFloat = 1.0
    @State private var cardBlur: CGFloat = 0
    @State private var cardOpacity: Double = 1.0
    
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    
    private let users = DiscoverUser.mockUsers
    
    var currentUser: DiscoverUser? {
        guard currentIndex < users.count else { return nil }
        return users[currentIndex]
    }
    
    var body: some View {
        ZStack {
            // Background - Dynamic color for light/dark mode
            (colorScheme == .dark ? Color(red: 0.04, green: 0.02, blue: 0.08) : Color.white).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar (Tinder Style)
                topBar
                
                // Main Card Area - Butonların üst çizgisine kadar
                GeometryReader { geo in
                    ZStack {
                        if let user = currentUser {
                            TinderStyleCard(
                                user: user,
                                currentPhotoIndex: $currentPhotoIndex,
                                cardOffset: $cardOffset,
                                cardRotation: $cardRotation,
                                onLike: likeCurrentUser,
                                onSkip: skipCurrentUser,
                                onTap: { selectedUser = user },
                                onOpenProfile: { selectedUser = user }
                            )
                            .frame(width: geo.size.width - 24, height: geo.size.height + 30)
                            .offset(cardOffset)
                            .rotationEffect(.degrees(cardRotation))
                            .scaleEffect(cardScale)
                            .blur(radius: cardBlur)
                            .opacity(cardOpacity)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        cardOffset = value.translation
                                        cardRotation = Double(value.translation.width / 20)
                                    }
                                    .onEnded { value in
                                        if value.translation.width > 100 {
                                            likeCurrentUser()
                                        } else if value.translation.width < -100 {
                                            skipCurrentUser()
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
                        } else {
                            EmptyDiscoverCard()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Action Bar (Tinder Style) - Kartın üzerine binecek
                TinderActionBar(
                    onRewind: rewindUser,
                    onSkip: skipCurrentUser,
                    onSuperLike: { superLikeUser() },
                    onLike: likeCurrentUser,
                    onAddFriend: { showProfileSummary = true },
                    cardOffset: cardOffset
                )
                .padding(.bottom, 8)
                .padding(.top, -35)
            }
        }
        .navigationDestination(item: $selectedUser) { user in
            ProfileDetailView(user: user)
        }
        .sheet(isPresented: $showDiamond) {
            DiamondScreen()
        }
        .sheet(isPresented: $showFilters) {
            FilterSheet(isGlobalMode: $isGlobalMode)
        }
        .sheet(isPresented: $showDoubleDateSheet) {
            DoubleDateSheet()
        }
        .sheet(isPresented: $showPremiumSheet) {
            SubscriptionSheet()
        }
        .sheet(isPresented: $showProfileSummary) {
            if let user = currentUser {
                ProfileSummarySheet(user: user)
            }
        }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack(spacing: 16) {
            // Filter Button
            Button {
                showFilters = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8))
            }
            
            Spacer()
            
            // Mode Selector (Sana Özel | Çifte Randevu) - Blob animasyonlu
            ModeSelectorView(selectedMode: $selectedMode, showDoubleDateSheet: $showDoubleDateSheet)
            
            Spacer()
            
            // Premium & Diamond Menu (top right)
            Menu {
                Button {
                    showPremiumSheet = true
                } label: {
                    Label("VibeU Gold", systemImage: "flame.fill")
                }
                
                Button {
                    showDiamond = true
                } label: {
                    Label("Elmaslarım", systemImage: "diamond.fill")
                }
            } label: {
                Image(systemName: "diamond.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.1)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Actions
    
    private func likeCurrentUser() {
        withAnimation(.easeOut(duration: 0.3)) {
            cardOffset = CGSize(width: 500, height: 0)
            cardRotation = 15
        }
        if let user = currentUser {
            Task {
                try? await ChatService.shared.likeUser(userId: user.id)
            }
        }
        moveToNextUser()
    }
    
    private func skipCurrentUser() {
        withAnimation(.easeOut(duration: 0.3)) {
            cardOffset = CGSize(width: -500, height: 0)
            cardRotation = -15
        }
        moveToNextUser()
    }
    
    private func superLikeUser() {
        withAnimation(.easeOut(duration: 0.3)) {
            cardOffset = CGSize(width: 0, height: -500)
        }
        moveToNextUser()
    }
    
    private func rewindUser() {
        guard currentIndex > 0 else { return }
        cardScale = 1.15
        cardBlur = 10
        cardOpacity = 0
        currentIndex -= 1
        cardOffset = .zero
        cardRotation = 0
        currentPhotoIndex = 0
        withAnimation(.easeOut(duration: 0.3)) {
            cardScale = 1.0
            cardBlur = 0
            cardOpacity = 1.0
        }
    }
    
    private func moveToNextUser() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            cardScale = 1.15
            cardBlur = 10
            cardOpacity = 0
            currentIndex += 1
            cardOffset = .zero
            cardRotation = 0
            currentPhotoIndex = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeOut(duration: 0.35)) {
                    cardScale = 1.0
                    cardBlur = 0
                    cardOpacity = 1.0
                }
            }
        }
    }
}

// MARK: - Mode Selector (Simple Working Version)
struct ModeSelectorView: View {
    @Binding var selectedMode: DiscoverMode
    @Binding var showDoubleDateSheet: Bool
    @Namespace private var namespace
    @Environment(\.colorScheme) private var colorScheme
    
    // Light modda siyah hover, dark modda beyaz hover
    private var hoverColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    // Light modda beyaz yazı (siyah hover'da), dark modda siyah yazı (beyaz hover'da)
    private var selectedTextColor: Color {
        colorScheme == .dark ? .black : .white
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Sana Özel
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    selectedMode = .forYou
                }
            } label: {
                Text("Sana Özel")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(selectedMode == .forYou ? selectedTextColor : (colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6)))
                    .fixedSize()
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background {
                        if selectedMode == .forYou {
                            Capsule()
                                .fill(hoverColor)
                                .matchedGeometryEffect(id: "blob", in: namespace)
                        }
                    }
            }
            .buttonStyle(.plain)
            
            // Çifte Randevu
            Button {
                // Önce hover geçsin
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    selectedMode = .doubleDate
                }
                // 0.3 saniye sonra sheet açılsın, hover yerinde kalsın
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showDoubleDateSheet = true
                }
            } label: {
                Text("Çifte Randevu")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(selectedMode == .doubleDate ? selectedTextColor : (colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6)))
                    .fixedSize()
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background {
                        if selectedMode == .doubleDate {
                            Capsule()
                                .fill(hoverColor)
                                .matchedGeometryEffect(id: "blob", in: namespace)
                        }
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(4)
        .background(Capsule().fill(colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.1)))
        // Sheet kapanınca Sana Özel'e dön
        .onChange(of: showDoubleDateSheet) { oldValue, newValue in
            if oldValue == true && newValue == false {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    selectedMode = .forYou
                }
            }
        }
    }
}

// MARK: - Mode Tab Item
struct ModeTabItem: View {
    let title: String
    let isSelected: Bool
    let isPressed: Bool
    
    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(isSelected ? .black : .white.opacity(0.6))
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: isPressed)
    }
}

// MARK: - Mode Button (Eski - artık kullanılmıyor)
struct ModeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isSelected ? .black : .white.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if isSelected {
                            Capsule().fill(.white)
                        }
                    }
                )
        }
    }
}

// MARK: - Tinder Style Card
struct TinderStyleCard: View {
    let user: DiscoverUser
    @Binding var currentPhotoIndex: Int
    @Binding var cardOffset: CGSize
    @Binding var cardRotation: Double
    let onLike: () -> Void
    let onSkip: () -> Void
    let onTap: () -> Void
    let onOpenProfile: () -> Void
    
    @State private var isInfoExpanded = false
    
    private var photos: [String] {
        if user.photos.isEmpty {
            return [user.profilePhotoURL]
        }
        return user.photos.map { $0.url }
    }
    
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
                            .fill(Color(white: 0.15))
                            .overlay {
                                ProgressView()
                                    .tint(.white)
                            }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
                
                // Photo Progress Indicators
                VStack {
                    HStack(spacing: 4) {
                        ForEach(0..<photos.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPhotoIndex ? .white : .white.opacity(0.4))
                                .frame(height: 3)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                    
                    Spacer()
                }
                
                // Tap Areas for Photo Navigation
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
                
                // Bottom Gradient + Info (Kapalı halde)
                if !isInfoExpanded {
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()
                        
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.5), .black.opacity(0.95)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 220)
                        .overlay(alignment: .bottomLeading) {
                            HStack(alignment: .bottom) {
                                // Sol taraf - Kullanıcı bilgileri
                                VStack(alignment: .leading, spacing: 8) {
                                    // Active Badge
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(.green)
                                            .frame(width: 8, height: 8)
                                        Text("Son Zamanlarda Aktif")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .foregroundStyle(.black)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(.white))
                                    
                                    // Name + Age + Verified
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
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                                    
                                    // University/School
                                    HStack(spacing: 6) {
                                        Image(systemName: "graduationcap.fill")
                                            .font(.system(size: 14))
                                        Text(user.city + " Üniversitesi")
                                            .font(.system(size: 15))
                                    }

                                    .foregroundStyle(.white.opacity(0.9))
                                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                                    
                                    // Social Icons (Moved to Left)
                                    HStack(spacing: 8) {
                                        if user.instagramUsername != nil {
                                            CardLockedSocialIcon(platform: "instagram")
                                        }
                                        if user.tiktokUsername != nil {
                                            CardLockedSocialIcon(platform: "tiktok")
                                        }
                                        if user.snapchatUsername != nil {
                                            CardLockedSocialIcon(platform: "snapchat")
                                        }
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 85) // Butonların üst hizasında bitsin
                        }
                    }
                }
                
                // Expand/Collapse Button (Sağ alt)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isInfoExpanded.toggle()
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(isInfoExpanded ? 
                                          LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                          LinearGradient(colors: [Color(white: 0.3), Color(white: 0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: isInfoExpanded ? "arrow.down" : "arrow.up")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, isInfoExpanded ? 16 : 80)
                    }
                }
                
                // Expanded Info Panel
                if isInfoExpanded {
                    ProfileInfoPanel(
                        user: user,
                        onClose: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isInfoExpanded = false
                            }
                        },
                        onSkip: onSkip,
                        onSuperLike: { },
                        onLike: onLike
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Like/Nope/SuperLike Indicators
                if cardOffset.width > 50 {
                    likeIndicator
                }
                if cardOffset.width < -50 {
                    nopeIndicator
                }
                if cardOffset.height < -50 {
                    superLikeIndicator
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var likeIndicator: some View {
        VStack {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.5, green: 1.0, blue: 0.3), Color(red: 0.2, green: 0.9, blue: 0.4)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay {
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        }
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 35, weight: .bold))
                        .foregroundStyle(Color(white: 0.12))
                }
                .shadow(color: Color(red: 0.3, green: 0.9, blue: 0.3).opacity(0.5), radius: 12, y: 0)
                .rotationEffect(.degrees(-15))
                .padding(.leading, 30)
                .padding(.top, 60)
                
                Spacer()
            }
            Spacer()
        }
    }
    
    private var nopeIndicator: some View {
        VStack {
            HStack {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.3, blue: 0.5), Color(red: 1.0, green: 0.15, blue: 0.4)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay {
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        }
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 35, weight: .bold))
                        .foregroundStyle(Color(white: 0.12))
                }
                .shadow(color: Color(red: 1.0, green: 0.3, blue: 0.5).opacity(0.5), radius: 12, y: 0)
                .rotationEffect(.degrees(15))
                .padding(.trailing, 30)
                .padding(.top, 60)
            }
            Spacer()
        }
    }
    
    private var superLikeIndicator: some View {
        VStack {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.3, green: 0.85, blue: 1.0), Color(red: 0.1, green: 0.5, blue: 1.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    }
                    .frame(width: 70, height: 70)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 35, weight: .bold))
                    .foregroundStyle(Color(white: 0.12))
            }
            .shadow(color: Color(red: 0.2, green: 0.7, blue: 1.0).opacity(0.5), radius: 12, y: 0)
            .padding(.bottom, 120)
        }
    }
}

// MARK: - Profile Info Panel (Açılan bilgi paneli)
struct ProfileInfoPanel: View {
    let user: DiscoverUser
    let onClose: () -> Void
    let onSkip: () -> Void
    let onSuperLike: () -> Void
    let onLike: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var primaryTextColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6)
    }
    
    private let panelShape = RoundedRectangle(cornerRadius: 24)
    private let sectionShape = RoundedRectangle(cornerRadius: 16)
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Text(user.displayName)
                        .font(.system(size: 24, weight: .bold))
                    Text("\(user.age)")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(secondaryTextColor)
                    if user.isBoosted {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.blue)
                    }
                }
                .foregroundStyle(primaryTextColor)
                
                Spacer()
                
                // Close Button (Turuncu aşağı ok)
                Button(action: onClose) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "arrow.down")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    // Fotoğraf (küçük)
                    AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            Rectangle().fill(Color(white: 0.15))
                        }
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)
                    
                    // Aradığım Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(secondaryTextColor)
                            Text("Aradığım")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(secondaryTextColor)
                        }
                        
                        HStack(spacing: 8) {
                            Text("🤔")
                                .font(.system(size: 20))
                            Text("Henüz karar vermedim")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(primaryTextColor)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.ultraThinMaterial, in: sectionShape)
                    .glassEffect(.regular.interactive(), in: sectionShape)
                    .padding(.horizontal, 16)
                    
                    // Temel Bilgiler Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: "person.text.rectangle")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(secondaryTextColor)
                                Text("Temel Bilgiler")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(secondaryTextColor)
                            }
                            
                            Spacer()
                            
                            Button { } label: {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(secondaryTextColor)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 10) {
                                Image(systemName: "location")
                                    .font(.system(size: 16))
                                    .foregroundStyle(secondaryTextColor)
                                Text("\(Int(user.distanceKm ?? 0)) kilometre uzaklıkta")
                                    .font(.system(size: 15))
                                    .foregroundStyle(primaryTextColor)
                            }
                            
                            HStack(spacing: 10) {
                                Image(systemName: "graduationcap")
                                    .font(.system(size: 16))
                                    .foregroundStyle(secondaryTextColor)
                                Text(user.city + " Üniversitesi")
                                    .font(.system(size: 15))
                                    .foregroundStyle(primaryTextColor)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.ultraThinMaterial, in: sectionShape)
                    .glassEffect(.regular.interactive(), in: sectionShape)
                    .padding(.horizontal, 16)
                    
                    // İlk İzlenim Section
                    FirstImpressionSection(user: user)
                    
                    // Action Buttons (X, Star, Heart)
                    HStack(spacing: 24) {
                        // Skip
                        PanelActionButton(
                            icon: "xmark",
                            normalColors: [Color(red: 1.0, green: 0.2, blue: 0.5), Color(red: 1.0, green: 0.4, blue: 0.6)],
                            action: onSkip
                        )
                        
                        // Super Like
                        PanelActionButton(
                            icon: "star.fill",
                            normalColors: [.cyan, .blue],
                            action: onSuperLike
                        )
                        
                        // Like
                        PanelActionButton(
                            icon: "heart.fill",
                            normalColors: [Color(red: 0.4, green: 1.0, blue: 0.4), Color(red: 0.2, green: 0.8, blue: 0.4)],
                            action: onLike
                        )
                    }
                    .padding(.vertical, 8)
                    
                    // Share Button
                    Button { } label: {
                        Text("\(user.displayName) adlı kişiyi paylaş")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(white: 0.15), in: RoundedRectangle(cornerRadius: 30))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(.ultraThinMaterial, in: panelShape)
        .glassEffect(.regular.interactive(), in: panelShape)
    }
}

// MARK: - Panel Action Button (Premium Glass + Hover)
struct PanelActionButton: View {
    let icon: String
    let normalColors: [Color]
    let action: () -> Void
    
    @State private var isPressed = false
    
    private var accentColor: Color {
        normalColors.first ?? .white
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Circle()
                .fill(isPressed ? accentColor : Color(white: 0.15))
                .overlay {
                    Circle()
                        .fill(.ultraThinMaterial.opacity(0.5))
                }
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                }
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(isPressed ? .white : accentColor)
                }
                .frame(width: 60, height: 60)
                .shadow(color: accentColor.opacity(isPressed ? 0.7 : 0), radius: isPressed ? 16 : 0)
                .scaleEffect(isPressed ? 1.2 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.5), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - First Impression Section (Premium Controlled)
struct FirstImpressionSection: View {
    let user: DiscoverUser
    @State private var messageText = ""
    @State private var showPremiumSheet = false
    @State private var showSentConfirmation = false
    @Environment(AppState.self) private var appState
    
    private let sectionShape = RoundedRectangle(cornerRadius: 16)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.blue)
                Text("İlk İzlenim ile öne çık")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                if !appState.isPremium {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 10))
                        Text("Premium")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(.yellow)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(.yellow.opacity(0.2)))
                }
            }
            
            Text("Eşleşmeden önce ona mesaj göndererek dikkatini çek. Ona profilinde hoşuna giden şeyin ne olduğunu söyleyebilir, iltifat edebilir veya onu güldürebilirsin.")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.7))
                .lineSpacing(4)
            
            // Message Input
            HStack(spacing: 12) {
                TextField("Mesajın...", text: $messageText)
                    .font(.system(size: 15))
                    .foregroundStyle(.white)
                    .padding(14)
                    .background(Color(white: 0.15), in: RoundedRectangle(cornerRadius: 12))
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(
                            messageText.isEmpty ? 
                            AnyShapeStyle(Color.white.opacity(0.3)) :
                            AnyShapeStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom))
                        )
                }
                .disabled(messageText.isEmpty)
            }
            
            // Sent Confirmation
            if showSentConfirmation {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Mesajın gönderildi!")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.green)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial, in: sectionShape)
        .glassEffect(.regular.interactive(), in: sectionShape)
        .padding(.horizontal, 16)
        .sheet(isPresented: $showPremiumSheet) {
            SubscriptionSheet()
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        // Premium kontrolü
        if !appState.isPremium {
            showPremiumSheet = true
            return
        }
        
        // Mesajı gönder
        Task {
            // API call would go here
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showSentConfirmation = true
            }
            messageText = ""
            
            // 2 saniye sonra confirmation'ı gizle
            try? await Task.sleep(for: .seconds(2))
            withAnimation {
                showSentConfirmation = false
            }
        }
    }
}

// MARK: - Tinder Action Bar
struct TinderActionBar: View {
    let onRewind: () -> Void
    let onSkip: () -> Void
    let onSuperLike: () -> Void
    let onLike: () -> Void
    let onAddFriend: () -> Void
    var cardOffset: CGSize = .zero // Kart kaydırma durumu
    
    // Hangi buton highlight olacak
    private var highlightSkip: Bool {
        cardOffset.width < -50
    }
    
    private var highlightLike: Bool {
        cardOffset.width > 50
    }
    
    private var highlightSuperLike: Bool {
        cardOffset.height < -50
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Rewind (Turuncu gradient)
            GlassActionButton(
                icon: "arrow.uturn.backward",
                size: 54,
                iconSize: 24,
                colors: [Color(red: 1.0, green: 0.8, blue: 0), Color(red: 1.0, green: 0.5, blue: 0)],
                action: onRewind
            )
            
            // Skip (X - Pembe gradient) - Sola kaydırınca highlight
            GlassActionButton(
                icon: "xmark",
                size: 64,
                iconSize: 32,
                colors: [Color(red: 1.0, green: 0.3, blue: 0.5), Color(red: 1.0, green: 0.15, blue: 0.4)],
                action: onSkip,
                isHighlighted: highlightSkip
            )
            
            // Super Like (Yıldız) - Yukarı kaydırınca highlight
            GlassActionButton(
                icon: "star.fill",
                size: 54,
                iconSize: 26,
                colors: [Color(red: 0.3, green: 0.85, blue: 1.0), Color(red: 0.1, green: 0.5, blue: 1.0)],
                action: onSuperLike,
                isHighlighted: highlightSuperLike
            )
            
            // Like (Kalp) - Sağa kaydırınca highlight
            GlassActionButton(
                icon: "heart.fill",
                size: 64,
                iconSize: 32,
                colors: [Color(red: 0.5, green: 1.0, blue: 0.3), Color(red: 0.2, green: 0.9, blue: 0.4)],
                action: onLike,
                isHighlighted: highlightLike
            )
            
            // Arkadaş Ekle (Mor gradient)
            GlassActionButton(
                icon: "plus",
                size: 54,
                iconSize: 28,
                colors: [Color(red: 0.6, green: 0.3, blue: 1.0), Color(red: 0.4, green: 0.2, blue: 0.8)],
                action: onAddFriend
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Glass Action Button (Gradient Icons with Hover Swap)
struct GlassActionButton: View {
    let icon: String
    let size: CGFloat
    let iconSize: CGFloat
    let colors: [Color]
    let action: () -> Void
    var isHighlighted: Bool = false
    
    @State private var isPressed = false
    @Environment(\.colorScheme) private var colorScheme
    
    private var isActive: Bool {
        isPressed || isHighlighted
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                // Daire - Normal: Light modda beyaz, Dark modda koyu gri; Basılı: Gradient
                Circle()
                    .fill(
                        isActive ?
                        AnyShapeStyle(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)) :
                        AnyShapeStyle(colorScheme == .dark ? Color(white: 0.15) : Color.white)
                    )
                    .overlay {
                        Circle()
                            .stroke(
                                colorScheme == .dark ? 
                                Color.white.opacity(isActive ? 0.3 : 0.08) :
                                Color.black.opacity(isActive ? 0.2 : 0.1),
                                lineWidth: 1
                            )
                    }
                    .shadow(color: colorScheme == .light ? Color.black.opacity(0.1) : Color.clear, radius: 8, x: 0, y: 2)
                
                // İkon - Normal: Gradient, Basılı: Koyu gri
                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .bold))
                    .foregroundStyle(
                        isActive ?
                        AnyShapeStyle(Color(white: 0.12)) :
                        AnyShapeStyle(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom))
                    )
            }
            .frame(width: size, height: size)
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

// MARK: - Filter Sheet
struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    // Country Toggle Binding
    @Binding var isGlobalMode: Bool
    
    // Filter States
    @State private var minAge: Double = 18
    @State private var maxAge: Double = 35
    @State private var maxDistance: Double = 50
    @State private var showVerifiedOnly: Bool = false
    @State private var showOnlineOnly: Bool = false
    @State private var showWithPhotoOnly: Bool = true
    @State private var showWithBioOnly: Bool = false
    
    // İlgi Alanları
    @State private var selectedInterests: Set<String> = []
    let allInterests = ["Müzik", "Spor", "Seyahat", "Yemek", "Film", "Kitap", "Oyun", "Sanat", "Dans", "Yoga", "Fotoğraf", "Doğa"]
    
    // Eğitim
    @State private var selectedEducation: String = "Hepsi"
    let educationOptions = ["Hepsi", "Lise", "Üniversite", "Yüksek Lisans", "Doktora"]
    
    // İlişki Amacı
    @State private var selectedRelationshipGoal: String = "Hepsi"
    let relationshipGoals = ["Hepsi", "Ciddi İlişki", "Arkadaşlık", "Belirsiz", "Evlilik"]
    
    // Burç
    @State private var selectedZodiac: String = "Hepsi"
    let zodiacSigns = ["Hepsi", "Koç", "Boğa", "İkizler", "Yengeç", "Aslan", "Başak", "Terazi", "Akrep", "Yay", "Oğlak", "Kova", "Balık"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - Keşif Modu (Kendi Ülkem / Global Toggle) (REAL GLASS STYLE)
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            isGlobalMode.toggle()
                        }
                    } label: {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: isGlobalMode ? [.cyan, .blue] : [.red, .orange], // Red Gradient for TR
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 48, height: 48) // Slightly larger icon container matches FilterSectionCard logic usually
                                    .shadow(color: (isGlobalMode ? Color.blue : Color.red).opacity(0.3), radius: 5, x: 0, y: 3)
                                
                                if isGlobalMode {
                                    Image(systemName: "globe.americas.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(.white)
                                } else {
                                    Text("🇹🇷")
                                        .font(.system(size: 24))
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Keşif Modu")
                                    .font(.system(size: 18, weight: .bold)) // Match FilterSectionCard Title
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                
                                Text(isGlobalMode ? "Global (Tüm Dünya)" : "Kendi Ülkem (Türkiye)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(isGlobalMode ? .cyan : .red.opacity(0.8))
                            }
                            .padding(.leading, 6)
                            
                            Spacer()
                            
                            // Status Indicator (Simplified)
                            Capsule()
                                .fill(isGlobalMode ? Color.cyan.opacity(0.1) : Color.red.opacity(0.1))
                                .frame(width: 70, height: 28)
                                .overlay(
                                    Text(isGlobalMode ? "Global" : "Türkiye")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(isGlobalMode ? .cyan : .red)
                                )
                        }
                        .padding(16) // Match FilterSectionCard padding
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.05)) // Match FilterSectionCard Background
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    // Remove external padding if FilterSectionCard doesn't rely on it, but FilterSectionCard usage usually needs horizontal padding if parent doesn't have it.
                    // Given the previous code had external padding, I will keep it consistent with the layout flow but ensure the BOX matches.
                    // If the box below is full width, this should be too. If the box below has offset, this should too.
                    // I will remove the extra .padding(.horizontal, 16) applied to the button itself in the previous version IF FilterSectionCard doesn't have it.
                    // BUT, based on the previous file view, FilterSectionCard is used directly in VStack. 
                    // If VStack(spacing: 20) is directly in ScrollView, items stretch.
                    // Let's assume we need to apply horizontal padding to key align with app margins.
                    .padding(.vertical, 8)
                    // MARK: - Yaş Aralığı
                    FilterSectionCard(title: "Yaş Aralığı", icon: "calendar") {
                        VStack(spacing: 16) {
                            HStack {
                                Text("\(Int(minAge))")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                
                                Spacer()
                                
                                Text("-")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5))
                                
                                Spacer()
                                
                                Text("\(Int(maxAge))")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                            }
                            .padding(.horizontal, 40)
                            
                            // Custom Range Slider
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    // Track
                                    Capsule()
                                        .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
                                        .frame(height: 6)
                                    
                                    // Active Track
                                    Capsule()
                                        .fill(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: CGFloat((maxAge - minAge) / 82) * geo.size.width, height: 6)
                                        .offset(x: CGFloat((minAge - 18) / 82) * geo.size.width)
                                    
                                    // Min Thumb
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 28, height: 28)
                                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                                        .offset(x: CGFloat((minAge - 18) / 82) * geo.size.width - 14)
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    let newValue = 18 + (value.location.x / geo.size.width) * 82
                                                    minAge = min(max(18, newValue), maxAge - 1)
                                                }
                                        )
                                    
                                    // Max Thumb
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 28, height: 28)
                                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                                        .offset(x: CGFloat((maxAge - 18) / 82) * geo.size.width - 14)
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    let newValue = 18 + (value.location.x / geo.size.width) * 82
                                                    maxAge = max(min(100, newValue), minAge + 1)
                                                }
                                        )
                                }
                            }
                            .frame(height: 28)
                            .padding(.horizontal, 8)
                        }
                    }
                    


// MARK: - Mesafe
FilterSectionCard(title: "Maksimum Mesafe", icon: "location") {
    VStack(spacing: 12) {
        HStack {
            Text("\(Int(maxDistance)) km")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(colorScheme == .dark ? .white : .black)
            
            Spacer()
            
            if maxDistance >= 100 {
                Text("Tüm Dünya")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.purple)
            }
        }
        
        Slider(value: $maxDistance, in: 1...100, step: 1)
            .tint(.purple)
    }
}

// MARK: - Hızlı Filtreler
FilterSectionCard(title: "Hızlı Filtreler", icon: "bolt.fill") {
    VStack(spacing: 12) {
        FilterToggleRow(title: "Sadece Doğrulanmış", icon: "checkmark.seal.fill", iconColor: .blue, isOn: $showVerifiedOnly)
        FilterToggleRow(title: "Sadece Çevrimiçi", icon: "circle.fill", iconColor: .green, isOn: $showOnlineOnly)
        FilterToggleRow(title: "Fotoğraflı Profiller", icon: "photo.fill", iconColor: .purple, isOn: $showWithPhotoOnly)
        FilterToggleRow(title: "Biyografili Profiller", icon: "text.alignleft", iconColor: .cyan, isOn: $showWithBioOnly)
    }
}

// MARK: - İlgi Alanları
FilterSectionCard(title: "İlgi Alanları", icon: "heart.fill") {
    FlowLayout(spacing: 10) {
        ForEach(allInterests, id: \.self) { interest in
            InterestChip(
                title: interest,
                isSelected: selectedInterests.contains(interest)
            ) {
                if selectedInterests.contains(interest) {
                    selectedInterests.remove(interest)
                } else {
                    selectedInterests.insert(interest)
                }
            }
        }
    }
}

// MARK: - Eğitim Durumu
FilterSectionCard(title: "Eğitim Durumu", icon: "graduationcap.fill") {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 10) {
            ForEach(educationOptions, id: \.self) { option in
                FilterOptionChip(
                    title: option,
                    isSelected: selectedEducation == option
                ) {
                    selectedEducation = option
                }
            }
        }
    }
}
                    
                    // MARK: - İlişki Amacı
                    FilterSectionCard(title: "İlişki Amacı", icon: "heart.circle.fill") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(relationshipGoals, id: \.self) { goal in
                                    FilterOptionChip(
                                        title: goal,
                                        isSelected: selectedRelationshipGoal == goal
                                    ) {
                                        selectedRelationshipGoal = goal
                                    }
                                }
                            }
                        }
                    }
                    
                    // MARK: - Burç
                    FilterSectionCard(title: "Burç", icon: "sparkles") {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                            ForEach(zodiacSigns, id: \.self) { sign in
                                FilterOptionChip(
                                    title: sign,
                                    isSelected: selectedZodiac == sign
                                ) {
                                    selectedZodiac = sign
                                }
                            }
                        }
                    }
                    
                    // MARK: - Filtreleri Sıfırla
                    Button {
                        resetFilters()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Filtreleri Sıfırla")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                                .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 16))
                        )
                    }
                    .padding(.top, 8)
                    
                }
                .padding(16)
            }
            .background((colorScheme == .dark ? Color(red: 0.04, green: 0.02, blue: 0.08) : Color(UIColor.systemBackground)).ignoresSafeArea())
            .navigationTitle("Filtreler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Sıfırla") {
                        resetFilters()
                        Task {
                            await LogService.shared.info("Filtreler sıfırlandı", category: "Filters")
                        }
                    }
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Uygula") {
                        applyFilters()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                }
            }
            .onAppear { loadFilters() }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    private func loadFilters() {
        minAge = UserDefaults.standard.double(forKey: "filter_minAge")
        if minAge < 18 { minAge = 18 }
        maxAge = UserDefaults.standard.double(forKey: "filter_maxAge")
        if maxAge < 18 { maxAge = 35 }
        maxDistance = UserDefaults.standard.double(forKey: "filter_maxDistance")
        if maxDistance < 1 { maxDistance = 50 }
        showVerifiedOnly = UserDefaults.standard.bool(forKey: "filter_verifiedOnly")
        showOnlineOnly = UserDefaults.standard.bool(forKey: "filter_onlineOnly")
        showWithPhotoOnly = UserDefaults.standard.bool(forKey: "filter_withPhoto")
        showWithBioOnly = UserDefaults.standard.bool(forKey: "filter_withBio")
    }
    
    private func applyFilters() {
        // Save to UserDefaults
        UserDefaults.standard.set(minAge, forKey: "filter_minAge")
        UserDefaults.standard.set(maxAge, forKey: "filter_maxAge")
        UserDefaults.standard.set(maxDistance, forKey: "filter_maxDistance")
        UserDefaults.standard.set(showVerifiedOnly, forKey: "filter_verifiedOnly")
        UserDefaults.standard.set(showOnlineOnly, forKey: "filter_onlineOnly")
        UserDefaults.standard.set(showWithPhotoOnly, forKey: "filter_withPhoto")
        UserDefaults.standard.set(showWithBioOnly, forKey: "filter_withBio")
        UserDefaults.standard.synchronize()
        
        // Log filter changes
        Task {
            await LogService.shared.info("Filtreler uygulandı", category: "Filters", metadata: [
                "minAge": "\(Int(minAge))",
                "maxAge": "\(Int(maxAge))",
                "maxDistance": "\(Int(maxDistance))",
                "verifiedOnly": "\(showVerifiedOnly)",
                "onlineOnly": "\(showOnlineOnly)",
                "withPhoto": "\(showWithPhotoOnly)",
                "withBio": "\(showWithBioOnly)",
                "interests": Array(selectedInterests).joined(separator: ","),
                "education": selectedEducation,
                "relationshipGoal": selectedRelationshipGoal,
                "zodiac": selectedZodiac
            ])
        }
    }
    
    private func resetFilters() {
        minAge = 18
        maxAge = 35
        maxDistance = 50
        showVerifiedOnly = false
        showOnlineOnly = false
        showWithPhotoOnly = true
        showWithBioOnly = false
        selectedInterests = []
        selectedEducation = "Hepsi"
        selectedRelationshipGoal = "Hepsi"
        selectedZodiac = "Hepsi"
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "filter_minAge")
        UserDefaults.standard.removeObject(forKey: "filter_maxAge")
        UserDefaults.standard.removeObject(forKey: "filter_maxDistance")
        UserDefaults.standard.removeObject(forKey: "filter_verifiedOnly")
        UserDefaults.standard.removeObject(forKey: "filter_onlineOnly")
        UserDefaults.standard.removeObject(forKey: "filter_withPhoto")
        UserDefaults.standard.removeObject(forKey: "filter_withBio")
        UserDefaults.standard.synchronize()
    }
}

// MARK: - Filter Section Card (Glass)
struct FilterSectionCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    @Environment(\.colorScheme) private var colorScheme
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.orange)
                
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
            }
            
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
        )
    }
}

// MARK: - Filter Toggle Row
struct FilterToggleRow: View {
    let title: String
    let icon: String
    let iconColor: Color
    @Binding var isOn: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(colorScheme == .dark ? .white : .black)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.purple)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Interest Chip
struct InterestChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isSelected ? .white : (colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7)))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? 
                              LinearGradient(colors: [.pink, .orange], startPoint: .leading, endPoint: .trailing) :
                              LinearGradient(colors: colorScheme == .dark ? [Color.white.opacity(0.1), Color.white.opacity(0.05)] : [Color.black.opacity(0.08), Color.black.opacity(0.04)], startPoint: .leading, endPoint: .trailing)
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : (colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1)), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Filter Option Chip
struct FilterOptionChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    // Light modda altın gradient, dark modda beyaz
    private var selectedBackground: AnyShapeStyle {
        if colorScheme == .dark {
            return AnyShapeStyle(Color.white)
        } else {
            return AnyShapeStyle(LinearGradient(colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 1.0, green: 0.6, blue: 0.0)], startPoint: .leading, endPoint: .trailing))
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isSelected ? .black : (colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7)))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? selectedBackground : AnyShapeStyle(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.08)))
                )
                // Hafif altın glow - sadece light modda ve seçili durumda
                .shadow(color: (isSelected && colorScheme == .light) ? Color(red: 1.0, green: 0.7, blue: 0.0).opacity(0.4) : .clear, radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Double Date Sheet
struct DoubleDateSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    // State
    @State private var team: DoubleDateTeam?
    @State private var friends: [Friendship] = []
    @State private var receivedInvites: [DoubleDateInvite] = []
    @State private var isLoading = true
    @State private var showFriendPicker = false
    @State private var showSettings = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Arkadaş Ekleme Bölümü
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Çifte Randevu arkadaşları")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                        
                        Spacer()
                        
                        Text("\(teamMemberCount)/3")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5))
                    }
                    
                    // Arkadaş Slotları
                    HStack(spacing: 20) {
                        ForEach(0..<3, id: \.self) { index in
                            FriendSlotView(
                                member: getMemberAtIndex(index),
                                onAdd: { showFriendPicker = true },
                                onRemove: { userId in
                                    Task { await removeMember(userId: userId) }
                                }
                            )
                        }
                    }
                }
                .padding(20)
                
                // Bilgi Metni
                VStack(alignment: .leading, spacing: 8) {
                    Text("Çifte Randevu'da en fazla 3 arkadaşınla çift olabilirsin.")
                        .font(.system(size: 14))
                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
                    
                    Button {
                        // Daha fazla bilgi
                    } label: {
                        Text("Daha fazla bilgi edin")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.purple)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                
                // Davetler Bölümü
                VStack(alignment: .leading, spacing: 16) {
                    Text("Arkadaşlardan gelen davetler")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    
                    if receivedInvites.isEmpty {
                        // Boş Durum
                        VStack(spacing: 12) {
                            Spacer()
                            
                            Image(systemName: "envelope")
                                .font(.system(size: 40))
                                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.3) : .black.opacity(0.3))
                            
                            Text("Çifte Randevu davetlerini burada göreceksin.")
                                .font(.system(size: 14))
                                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5))
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                    } else {
                        // Davet Listesi
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(receivedInvites) { invite in
                                    DoubleDateInviteRow(
                                        invite: invite,
                                        onAccept: { Task { await acceptInvite(invite) } },
                                        onReject: { Task { await rejectInvite(invite) } }
                                    )
                                }
                            }
                        }
                        .frame(height: 150)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Alt Buton
                Button {
                    showFriendPicker = true
                } label: {
                    Text("Arkadaşlarını Davet Et")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background((colorScheme == .dark ? Color(red: 0.04, green: 0.02, blue: 0.08) : Color(UIColor.systemBackground)).ignoresSafeArea())
            .navigationTitle("Arkadaşlar")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.1)))
                },
                trailing: Button("Ayarlar") {
                    showSettings = true
                }
                .foregroundStyle(Color.purple)
            )
            .sheet(isPresented: $showFriendPicker) {
                DoubleDateFriendPickerSheet(
                    friends: friends,
                    existingMemberIds: team?.members.map { $0.userId } ?? [],
                    onSelect: { friendId in
                        Task { await sendInvite(toFriendId: friendId) }
                    }
                )
            }
            .sheet(isPresented: $showSettings) {
                DoubleDateSettingsSheet(
                    team: team,
                    onLeaveTeam: {
                        Task { await leaveTeam() }
                    },
                    onDeactivateTeam: {
                        Task { await deactivateTeam() }
                    }
                )
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .task {
            await loadData()
        }
    }
    
    // MARK: - Team Actions
    
    private func leaveTeam() async {
        // Takımdan ayrıl (owner değilse)
        guard let team = team else { return }
        do {
            try await DoubleDateService.shared.leaveTeam()
            await loadData()
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func deactivateTeam() async {
        // Takımı deaktif et (owner ise)
        do {
            try await DoubleDateService.shared.deactivateTeam()
            await loadData()
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var teamMemberCount: Int {
        team?.members.count ?? 0
    }
    
    private func getMemberAtIndex(_ index: Int) -> DoubleDateMember? {
        guard let members = team?.members, index < members.count else { return nil }
        return members[index]
    }
    
    // MARK: - Data Loading
    
    private func loadData() async {
        isLoading = true
        
        do {
            async let teamTask = DoubleDateService.shared.getMyTeam()
            async let friendsTask = SocialService.shared.getFriends()
            async let invitesTask = DoubleDateService.shared.getReceivedInvites()
            
            let (loadedTeam, loadedFriends, loadedInvites) = try await (teamTask, friendsTask, invitesTask)
            
            await MainActor.run {
                self.team = loadedTeam
                self.friends = loadedFriends
                self.receivedInvites = loadedInvites
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Actions
    
    private func sendInvite(toFriendId: String) async {
        do {
            _ = try await DoubleDateService.shared.sendInvite(toFriendId: toFriendId)
            await loadData()
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func acceptInvite(_ invite: DoubleDateInvite) async {
        do {
            try await DoubleDateService.shared.acceptInvite(inviteId: invite.id)
            await loadData()
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func rejectInvite(_ invite: DoubleDateInvite) async {
        do {
            try await DoubleDateService.shared.rejectInvite(inviteId: invite.id)
            await loadData()
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func removeMember(userId: String) async {
        do {
            try await DoubleDateService.shared.removeTeamMember(userId: userId)
            await loadData()
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Double Date Invite Row
struct DoubleDateInviteRow: View {
    let invite: DoubleDateInvite
    let onAccept: () -> Void
    let onReject: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Profil Fotoğrafı
            AsyncImage(url: URL(string: invite.fromUser?.profilePhotoUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Circle().fill(colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.05))
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            
            // İsim ve Mesaj
            VStack(alignment: .leading, spacing: 2) {
                Text(invite.fromUser?.displayName ?? "Kullanıcı")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                
                if let message = invite.message, !message.isEmpty {
                    Text(message)
                        .font(.system(size: 12))
                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6))
                        .lineLimit(1)
                } else {
                    Text("Seni Çifte Randevu'ya davet etti")
                        .font(.system(size: 12))
                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6))
                }
            }
            
            Spacer()
            
            // Butonlar
            HStack(spacing: 8) {
                Button {
                    onReject()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(colorScheme == .dark ? .white : .black.opacity(0.7))
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(colorScheme == .dark ? .white.opacity(0.15) : .black.opacity(0.05)))
                }
                
                Button {
                    onAccept()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle().fill(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(colorScheme == .dark ? .white.opacity(0.05) : .black.opacity(0.03)))
    }
}

// MARK: - Friend Picker Sheet
struct DoubleDateFriendPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let friends: [Friendship]
    let existingMemberIds: [String]
    let onSelect: (String) -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    if availableFriends.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "person.2.slash")
                                .font(.system(size: 48))
                                .foregroundStyle(.white.opacity(0.3))
                            
                            Text("Davet edilecek arkadaş bulunamadı")
                                .font(.system(size: 16))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        ForEach(availableFriends, id: \.id) { friendship in
                            FriendPickerRow(friendship: friendship) {
                                onSelect(friendship.friend.id)
                                dismiss()
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Color(red: 0.04, green: 0.02, blue: 0.08).ignoresSafeArea())
            .navigationTitle("Arkadaş Seç")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            )
        }
        .presentationDetents([.medium, .large])
    }
    
    private var availableFriends: [Friendship] {
        friends.filter { !existingMemberIds.contains($0.friend.id) }
    }
}

// MARK: - Friend Picker Row
struct FriendPickerRow: View {
    let friendship: Friendship
    let onSelect: () -> Void
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: friendship.friend.profilePhotoURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Circle().fill(.white.opacity(0.2))
                            .overlay {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(friendship.friend.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    if friendship.friend.isOnline {
                        HStack(spacing: 4) {
                            Circle().fill(.green).frame(width: 6, height: 6)
                            Text("Çevrimiçi")
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(.white.opacity(0.05)))
        }
    }
}

// MARK: - Double Date Settings Sheet
struct DoubleDateSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    let team: DoubleDateTeam?
    let onLeaveTeam: () -> Void
    let onDeactivateTeam: () -> Void
    
    @State private var showLeaveConfirmation = false
    @State private var showDeactivateConfirmation = false
    @State private var notificationsEnabled = true
    @State private var showInDiscover = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Takım Bilgisi
                    if let team = team {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(
                                        LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                
                                Text("Takım Bilgisi")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                DDSettingsInfoRow(title: "Takım ID", value: String(team.id.prefix(8)) + "...")
                                DDSettingsInfoRow(title: "Üye Sayısı", value: "\(team.members.count)/3")
                                DDSettingsInfoRow(title: "Durum", value: team.isActive ? "Aktif" : "Pasif")
                            }
                            .padding(16)
                            .background(RoundedRectangle(cornerRadius: 16).fill(colorScheme == .dark ? .white.opacity(0.05) : .black.opacity(0.05)))
                        }
                    }
                    
                    // Bildirim Ayarları
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(
                                    LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                            
                            Text("Bildirimler")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 0) {
                            DDSettingsToggleRow(
                                title: "Eşleşme Bildirimleri",
                                subtitle: "Yeni eşleşmelerde bildirim al",
                                isOn: $notificationsEnabled
                            )
                            
                            Divider().background(.white.opacity(0.1))
                            
                            DDSettingsToggleRow(
                                title: "Davet Bildirimleri",
                                subtitle: "Yeni davetlerde bildirim al",
                                isOn: $notificationsEnabled
                            )
                        }
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 16).fill(colorScheme == .dark ? .white.opacity(0.05) : .black.opacity(0.05)))
                    }
                    
                    // Gizlilik Ayarları
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "eye.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(
                                    LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                            
                            Text("Gizlilik")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 0) {
                            DDSettingsToggleRow(
                                title: "Keşfette Görün",
                                subtitle: "Diğer takımlar sizi görebilir",
                                isOn: $showInDiscover
                            )
                        }
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 16).fill(colorScheme == .dark ? .white.opacity(0.05) : .black.opacity(0.05)))
                    }
                    
                    // Tehlikeli Bölge
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.red)
                            
                            Text("Tehlikeli Bölge")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            // Takımdan Ayrıl
                            Button {
                                showLeaveConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.system(size: 16))
                                    Text("Takımdan Ayrıl")
                                        .font(.system(size: 16, weight: .medium))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                }
                                .foregroundStyle(.orange)
                                .padding(16)
                                .background(RoundedRectangle(cornerRadius: 12).fill(.orange.opacity(0.1)))
                            }
                            
                            // Takımı Sil (sadece owner için)
                            if team?.ownerId == team?.members.first(where: { $0.role == "owner" })?.userId {
                                Button {
                                    showDeactivateConfirmation = true
                                } label: {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 16))
                                        Text("Takımı Sil")
                                            .font(.system(size: 16, weight: .medium))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                    }
                                    .foregroundStyle(.red)
                                    .padding(16)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(.red.opacity(0.1)))
                                }
                            }
                        }
                    }
                    
                    // Bilgi
                    VStack(spacing: 8) {
                        Text("Çifte Randevu Hakkında")
                            .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6))
                        
                        Text("Çifte Randevu, arkadaşlarınla birlikte diğer gruplarla tanışmanı sağlar. En fazla 3 arkadaşınla takım oluşturabilir ve diğer takımlarla eşleşebilirsin.")
                            .font(.system(size: 13))
                            .foregroundStyle(colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.4))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)
                }
                .padding(20)
            }
            .background((colorScheme == .dark ? Color(red: 0.04, green: 0.02, blue: 0.08) : Color(UIColor.systemBackground)).ignoresSafeArea())
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
            )
            .alert("Takımdan Ayrıl", isPresented: $showLeaveConfirmation) {
                Button("İptal", role: .cancel) { }
                Button("Ayrıl", role: .destructive) {
                    onLeaveTeam()
                    dismiss()
                }
            } message: {
                Text("Takımdan ayrılmak istediğine emin misin? Bu işlem geri alınamaz.")
            }
            .alert("Takımı Sil", isPresented: $showDeactivateConfirmation) {
                Button("İptal", role: .cancel) { }
                Button("Sil", role: .destructive) {
                    onDeactivateTeam()
                    dismiss()
                }
            } message: {
                Text("Takımı silmek istediğine emin misin? Tüm üyeler takımdan çıkarılacak ve eşleşmeler silinecek.")
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Settings Helper Views
// MARK: - Settings Helper Views
struct DDSettingsInfoRow: View {
    let title: String
    let value: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(colorScheme == .dark ? .white : .black)
        }
    }
}

struct DDSettingsToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5))
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .tint(Color.purple)
                .labelsHidden()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Friend Slot View
struct FriendSlotView: View {
    var member: DoubleDateMember?
    var onAdd: () -> Void = {}
    var onRemove: (String) -> Void = { _ in }
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            if let member = member, let user = member.user {
                // Dolu Slot
                VStack(spacing: 4) {
                    AsyncImage(url: URL(string: user.profilePhotoUrl ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Circle().fill(colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.05))
                                .overlay {
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.3))
                                }
                        }
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(
                            LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 2
                        )
                    )
                    .overlay(alignment: .topTrailing) {
                        if member.role != "owner" {
                            Button {
                                onRemove(member.userId)
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 20, height: 20)
                                    .background(Circle().fill(.red))
                            }
                            .offset(x: 4, y: -4)
                        }
                    }
                    
                    Text(user.displayName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .lineLimit(1)
                }
            } else {
                // Boş Slot
                Button {
                    onAdd()
                } label: {
                    ZStack {
                        Circle()
                            .stroke(
                                colorScheme == .dark ? Color.white.opacity(0.3) : Color.black.opacity(0.2),
                                style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                            )
                            .frame(width: 80, height: 80)
                        
                        VStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.3) : .black.opacity(0.2))
                            
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 24, height: 24)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .offset(y: 4)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Premium Background


// MARK: - User Profile Button (Sol Üst Geniş Buton)

struct UserProfileButton: View {
    @Environment(AppState.self) private var appState
    var isCompact: Bool = false
    
    var body: some View {
        NavigationLink {
            ProfileView()
        } label: {
            HStack(spacing: 8) {
                // Profil Fotoğrafı
                AsyncImage(url: URL(string: appState.currentUser?.profilePhotoURL ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Circle()
                            .fill(LinearGradient(colors: [.purple.opacity(0.5), .pink.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .overlay {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                    }
                }
                .frame(width: 28, height: 28)
                .clipShape(Circle())
                .overlay(Circle().stroke(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5))
                
                // Kullanıcı Bilgileri
                VStack(alignment: .leading, spacing: 2) {
                    Text(appState.currentUser?.displayName ?? "Kullanıcı")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(.green)
                            .frame(width: 5, height: 5)
                        Text("Çevrimiçi")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            .padding(.leading, 6)
            .padding(.trailing, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())
        }
    }
}

// MARK: - Logo View (Legacy)

struct LogoView: View {
    var body: some View {
        HStack(spacing: 2) {
            Text("Vibe")
                .font(.title2.weight(.bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.purple, Color.pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            Text("U")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Mode Selector Button (Fixed)

struct ModeSelectorButton: View {
    @Binding var mode: DiscoverMode
    var isCompact: Bool = false
    
    var body: some View {
        Button {
            mode = mode == .local ? .global : .local
        } label: {
            HStack(spacing: 5) {
                Text(mode == .local ? "🇹🇷" : "🌍")
                    .font(.system(size: 14))
                Text(mode == .local ? "Yerel" : "Global")
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
        }
    }
}

// MARK: - Notification Button (Fixed)

struct NotificationNavButton: View {
    var body: some View {
        NavigationLink {
            NotificationsView()
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial, in: Circle())
                
                Circle()
                    .fill(.red)
                    .frame(width: 8, height: 8)
                    .offset(x: 2, y: -1)
            }
        }
    }
}

// MARK: - Feature Card Button (Liquid Glass)

struct FeatureCardButton: View {
    let icon: String
    let title: String
    let gradient: [Color]
    let badge: String?
    let action: () -> Void
    
    private let buttonShape = Capsule()
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 10) {
                // Icon with liquid glass
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 30, height: 30)
                    .background(.regularMaterial, in: Circle())
                    .glassEffect(.regular.interactive(), in: Circle())
                
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 16, height: 16)
                        .background(
                            Circle().fill(
                                LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                        )
                }
            }
            .padding(.leading, 6)
            .padding(.trailing, 12)
            .padding(.vertical, 8)
            .background(.regularMaterial, in: buttonShape)
            .glassEffect(.regular.interactive(), in: buttonShape)
        }
        .buttonStyle(FeatureButtonStyle())
    }
}

struct FeatureButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Compact Feature Card

struct CompactFeatureCard: View {
    let icon: String
    let title: String
    let gradient: [Color]
    let badge: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 18, height: 18)
                        .background(Circle().fill(gradient[0]))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Feature Card (Legacy)

struct FeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradient: [Color]
    let badge: String?
    var isNew: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: icon)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    
                    Spacer()
                    
                    if let badge = badge {
                        Text(badge)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 16, height: 16)
                            .background(Circle().fill(gradient[0]))
                    }
                    
                    if isNew {
                        Text("YENİ")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing)))
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .frame(width: 85, height: 70)
            .padding(10)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Profile Card Back View (Next card - simplified, no interaction)

struct ProfileCardBackView: View {
    let user: DiscoverUser
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // Photo
                AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    default:
                        Rectangle()
                            .fill(Color(white: 0.15))
                            .frame(width: geo.size.width, height: geo.size.height)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.white.opacity(0.3))
                            }
                    }
                }
                
                // Gradient Overlay
                LinearGradient(
                    colors: [.clear, .black.opacity(0.3), .black.opacity(0.8)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                // User Info - Compact
                VStack(alignment: .leading, spacing: 6) {
                    if !user.tags.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(user.tags.prefix(3), id: \.self) { tag in
                                Text(tag).font(.subheadline)
                            }
                        }
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(user.displayName)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Text("\(user.age)")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                        
                        if user.isBoosted {
                            Image(systemName: "bolt.fill")
                                .font(.caption2)
                                .foregroundStyle(.yellow)
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.purple)
                        
                        Text(user.city)
                            .font(.caption.weight(.medium))
                        
                        if let flag = user.countryFlag {
                            Text(flag).font(.caption2)
                        }
                        
                        if let distance = user.distanceKm {
                            Text("•").foregroundStyle(.white.opacity(0.5))
                            Text("\(String(format: "%.1f", distance)) km")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .foregroundStyle(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
        }
    }
}

// MARK: - Profile Card View (Enhanced Animations)

struct ProfileCardView: View {
    let user: DiscoverUser
    @Binding var currentPhotoIndex: Int
    @Binding var cardOffset: CGSize
    @Binding var cardRotation: Double
    let onLike: () -> Void
    let onSkip: () -> Void
    let onTap: () -> Void
    
    // Swipe progress (0 to 1)
    private var swipeProgress: Double {
        min(abs(Double(cardOffset.width)) / 150.0, 1.0)
    }
    
    // Blur amount based on swipe
    private var blurAmount: Double {
        swipeProgress * 8
    }
    
    // Is swiping right (like)
    private var isSwipingRight: Bool {
        cardOffset.width > 0
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // Photo with blur effect
                AsyncImage(url: URL(string: !user.photos.isEmpty && currentPhotoIndex < user.photos.count ? user.photos[currentPhotoIndex].url : user.profilePhotoURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                            .blur(radius: blurAmount)
                    default:
                        placeholderView
                            .frame(width: geo.size.width, height: geo.size.height)
                    }
                }
                
                // Swipe overlay color
                if swipeProgress > 0.1 {
                    Rectangle()
                        .fill(
                            isSwipingRight 
                                ? Color.green.opacity(swipeProgress * 0.3)
                                : Color.red.opacity(swipeProgress * 0.3)
                        )
                        .allowsHitTesting(false)
                }
                
                // Photo Indicators
                if user.photos.count > 1 {
                    VStack {
                        HStack(spacing: 4) {
                            ForEach(0..<user.photos.count, id: \.self) { index in
                                Capsule()
                                    .fill(index == currentPhotoIndex ? .white : .white.opacity(0.4))
                                    .frame(height: 3)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        Spacer()
                    }
                }
                
                // Gradient Overlay
                LinearGradient(
                    colors: [.clear, .black.opacity(0.3), .black.opacity(0.8)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .opacity(1 - swipeProgress * 0.5)
                
                // Swipe Label Overlay (centered, on blur)
                SwipeIndicatorOverlay(offset: cardOffset, progress: swipeProgress)
                
                // User Info - Compact
                VStack(alignment: .leading, spacing: 6) {
                    if !user.tags.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(user.tags.prefix(3), id: \.self) { tag in
                                Text(tag).font(.subheadline)
                            }
                        }
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(user.displayName)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Text("\(user.age)")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                        
                        if user.isBoosted {
                            Image(systemName: "bolt.fill")
                                .font(.caption2)
                                .foregroundStyle(.yellow)
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.purple)
                        
                        Text(user.city)
                            .font(.caption.weight(.medium))
                        
                        if let flag = user.countryFlag {
                            Text(flag).font(.caption2)
                        }
                        
                        if let distance = user.distanceKm {
                            Text("•").foregroundStyle(.white.opacity(0.5))
                            Text("\(String(format: "%.1f", distance)) km")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .foregroundStyle(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .opacity(1 - swipeProgress * 0.7)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
        }
        .offset(cardOffset)
        .rotationEffect(.degrees(cardRotation))
        .gesture(
            DragGesture(minimumDistance: 20)
                .onChanged { value in
                    cardOffset = value.translation
                    cardRotation = Double(value.translation.width / 25)
                }
                .onEnded { value in
                    let threshold: CGFloat = 100
                    
                    if value.translation.width > threshold {
                        onLike()
                    } else if value.translation.width < -threshold {
                        onSkip()
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            cardOffset = .zero
                            cardRotation = 0
                        }
                    }
                }
        )
        .onTapGesture {
            onTap()
        }
    }
    
    private var placeholderView: some View {
        Rectangle()
            .fill(Color(white: 0.15))
            .overlay {
                Image(systemName: "person.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.white.opacity(0.3))
            }
    }
}

// MARK: - Swipe Indicator Overlay (Enhanced)

struct SwipeIndicatorOverlay: View {
    let offset: CGSize
    let progress: Double
    
    private var isSwipingRight: Bool {
        offset.width > 0
    }
    
    var body: some View {
        ZStack {
            // Like indicator
            if isSwipingRight && progress > 0.1 {
                VStack(spacing: 12) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundStyle(.green)
                        .scaleEffect(0.8 + progress * 0.4)
                    
                    Text("BEĞENDİN")
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(.white)
                }
                .opacity(progress)
                .scaleEffect(0.8 + progress * 0.2)
            }
            
            // Skip indicator
            if !isSwipingRight && progress > 0.1 {
                VStack(spacing: 12) {
                    Image(systemName: "xmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundStyle(.red)
                        .scaleEffect(0.8 + progress * 0.4)
                    
                    Text("GEÇ")
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(.white)
                }
                .opacity(progress)
                .scaleEffect(0.8 + progress * 0.2)
            }
        }
        .animation(.easeOut(duration: 0.15), value: progress)
    }
}

// MARK: - Discover Action Bar (New - Without Social Media)

struct DiscoverActionBarNew: View {
    let onRewind: () -> Void
    let onSkip: () -> Void
    let onLike: () -> Void
    let onFavorite: () -> Void
    let onSendRequest: () -> Void
    
    private let buttonSize: CGFloat = 54
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            
            // 1. Geri Al
            LiquidGlassButton(icon: "arrow.uturn.backward", color: .yellow, size: buttonSize, action: onRewind)
            
            Spacer()
            
            // 2. Geç (X)
            LiquidGlassButton(icon: "xmark", color: .red, size: buttonSize, action: onSkip)
            
            Spacer()
            
            // 3. Favorilere Ekle (Yıldız)
            LiquidGlassButton(icon: "star.fill", color: .yellow, size: buttonSize, action: onFavorite)
            
            Spacer()
            
            // 4. Beğen (Kalp)
            LiquidGlassButton(icon: "suit.heart.fill", color: .pink, size: buttonSize, action: onLike)
            
            Spacer()
            
            // 5. Arkadaş Ekle (Plus)
            LiquidGlassButton(icon: "person.badge.plus", color: .purple, size: buttonSize, action: onSendRequest)
            
            Spacer()
        }
    }
}

// MARK: - Liquid Glass Action Bar (Legacy - kept for compatibility)

struct LiquidGlassActionBar: View {
    let onRewind: () -> Void
    let onSkip: () -> Void
    let onInstagram: () -> Void
    let onLike: () -> Void
    let onSnapchat: () -> Void
    let instagramUsername: String?
    let snapchatUsername: String?
    
    private let buttonSize: CGFloat = 54
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            
            // 1. Geri Al
            LiquidGlassButton(icon: "arrow.uturn.backward", color: .yellow, size: buttonSize, action: onRewind)
            
            Spacer()
            
            // 2. Geç (X)
            LiquidGlassButton(icon: "xmark", color: .red, size: buttonSize, action: onSkip)
            
            Spacer()
            
            // 3. Beğen (Kalp)
            LiquidGlassButton(icon: "suit.heart.fill", color: .pink, size: buttonSize, action: onLike)
            
            Spacer()
            
            // 4. Instagram
            SocialMediaButton(
                platform: .instagram,
                size: buttonSize,
                isAvailable: instagramUsername != nil,
                action: onInstagram
            )
            
            Spacer()
            
            // 5. Snapchat
            SocialMediaButton(
                platform: .snapchat,
                size: buttonSize,
                isAvailable: snapchatUsername != nil,
                action: onSnapchat
            )
            
            Spacer()
        }
    }
}

// MARK: - Social Media Button

enum SocialPlatform {
    case instagram
    case snapchat
    
    var color: Color {
        switch self {
        case .instagram: return Color(red: 0.88, green: 0.19, blue: 0.42) // Instagram pink/purple
        case .snapchat: return Color(red: 1.0, green: 0.98, blue: 0.0) // Snapchat yellow
        }
    }
    
    var iconColor: Color {
        switch self {
        case .instagram: return .white
        case .snapchat: return .black
        }
    }
}

struct SocialMediaButton: View {
    let platform: SocialPlatform
    let size: CGFloat
    let isAvailable: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.regularMaterial)
                    .frame(width: size, height: size)
                    .glassEffect(.regular.interactive(), in: Circle())
                
                // Platform icon from Assets
                Image(platform == .instagram ? "InstagramIcon" : "SnapchatIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.75, height: size * 0.75)
                    .clipShape(Circle())
                    .opacity(isAvailable ? 1.0 : 0.4)
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(.plain)
        .opacity(isAvailable ? 1.0 : 0.5)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct LiquidGlassButton: View {
    let icon: String
    let color: Color
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.38, weight: .bold))
                .foregroundStyle(color)
                .frame(width: size, height: size)
                .background(.regularMaterial, in: Circle())
                .glassEffect(.regular.interactive(), in: Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Trending Section

struct DiscoverTrendingSection: View {
    let users: [DiscoverUser]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(.orange)
                Text("Trend Profiller")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Button("Tümü") {}
                    .font(.subheadline)
                    .foregroundStyle(.purple)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(users) { user in
                        DiscoverTrendingCard(user: user)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct DiscoverTrendingCard: View {
    let user: DiscoverUser
    
    var body: some View {
        VStack(spacing: 0) {
            AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Rectangle().fill(Color(white: 0.15))
                }
            }
            .frame(width: 110, height: 130)
            .clipped()
            
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(user.displayName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("\(user.age)")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.6))
                }
                
                HStack(spacing: 3) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 8))
                    Text(user.city)
                        .font(.caption2)
                }
                .foregroundStyle(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(.ultraThinMaterial)
        }
        .frame(width: 110)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}


// MARK: - Daily Missions Section

struct DailyMissionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "target")
                    .foregroundStyle(.green)
                Text("Günlük Görevler")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text("2/5")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.green)
            }
            
            VStack(spacing: 8) {
                MissionRow(icon: "hand.thumbsup.fill", title: "5 profil beğen", progress: 0.6, reward: "50 ⭐", color: .pink)
                MissionRow(icon: "message.fill", title: "3 kişiye istek gönder", progress: 0.33, reward: "30 ⭐", color: .purple)
                MissionRow(icon: "person.2.fill", title: "1 yeni arkadaş edin", progress: 1.0, reward: "100 ⭐", color: .green, isCompleted: true)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct MissionRow: View {
    let icon: String
    let title: String
    let progress: Double
    let reward: String
    let color: Color
    var isCompleted: Bool = false
    
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: isCompleted ? "checkmark" : icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(isCompleted ? .white.opacity(0.5) : .white)
                    .strikethrough(isCompleted)
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.white.opacity(0.1)).frame(height: 3)
                        Capsule().fill(color).frame(width: geo.size.width * progress, height: 3)
                    }
                }
                .frame(height: 3)
            }
            
            Text(reward)
                .font(.caption.weight(.bold))
                .foregroundStyle(isCompleted ? .green : .white.opacity(0.7))
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(isCompleted ? .green.opacity(0.1) : .white.opacity(0.03)))
    }
}

// MARK: - Nearby Section

struct NearbySection: View {
    let users: [DiscoverUser]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "location.circle.fill")
                    .foregroundStyle(.blue)
                Text("Yakınındakiler")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Button("Haritada Gör") {}
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(users) { user in
                        NearbyCard(user: user)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct NearbyCard: View {
    let user: DiscoverUser
    
    var body: some View {
        HStack(spacing: 10) {
            AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Circle().fill(Color(white: 0.15))
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .overlay(Circle().stroke(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2))
            
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(user.displayName)
                        .font(.subheadline.weight(.semibold))
                    if user.isBoosted {
                        Image(systemName: "bolt.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                }
                .foregroundStyle(.white)
                
                if let distance = user.distanceKm {
                    HStack(spacing: 3) {
                        Circle().fill(.green).frame(width: 5, height: 5)
                        Text("\(String(format: "%.1f", distance)) km")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            
            Spacer()
            
            Button {} label: {
                Image(systemName: "hand.thumbsup.fill")
                    .font(.caption)
                    .foregroundStyle(.pink)
                    .frame(width: 32, height: 32)
                    .background(.pink.opacity(0.2), in: Circle())
            }
        }
        .padding(12)
        .frame(width: 240)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Weekly Stats Card

struct WeeklyStatsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.cyan)
                Text("Bu Hafta")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text("📈 +23%")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.green)
            }
            
            HStack(spacing: 0) {
                DiscoverStatItem(value: "127", label: "Görüntülenme", icon: "eye.fill", color: .blue)
                DiscoverStatItem(value: "34", label: "Beğeni", icon: "heart.fill", color: .pink)
                DiscoverStatItem(value: "12", label: "Eşleşme", icon: "person.2.fill", color: .purple)
                DiscoverStatItem(value: "89%", label: "Uyum", icon: "sparkles", color: .orange)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct DiscoverStatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Empty Discover Card

struct EmptyDiscoverCard: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 50))
                .foregroundStyle(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
            
            VStack(spacing: 6) {
                Text("Şimdilik bu kadar")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                
                Text("Yeni profiller için daha sonra tekrar gel")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            
            Button {
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Yenile")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Capsule().fill(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Sheet Views

struct DailyChallengeSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom))
                        
                        Text("Günlük Görevler")
                            .font(.title.weight(.bold))
                        
                        Text("Görevleri tamamla, ödüller kazan!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)
                    
                    DailyMissionsSection()
                        .padding(.horizontal, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
    }
}

struct SpotlightSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundStyle(.yellow)
                
                Text("Spotlight")
                    .font(.title.weight(.bold))
                
                Text("Profilini öne çıkar ve daha fazla kişiye ulaş!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Button {
                } label: {
                    Text("Spotlight Aktifleştir")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 40)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
    }
}

struct VibeMatchSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 60))
                    .foregroundStyle(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                
                Text("Vibe Match")
                    .font(.title.weight(.bold))
                
                Text("Kişilik testini tamamla ve seninle uyumlu kişileri bul!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Button {
                } label: {
                    Text("Teste Başla")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 40)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
    }
}

struct TopPicksSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                
                Text("Top Picks")
                    .font(.title.weight(.bold))
                
                Text("Senin için özel seçilmiş en uyumlu profiller!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("Premium özellik")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Clamped Extension

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

// MARK: - Scroll Offset Preference Key

struct ScrollOffsetKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Hero Profile Card (Yeni Ana Kart)

struct HeroProfileCard: View {
    let user: DiscoverUser
    @Binding var currentPhotoIndex: Int
    let onLike: () -> Void
    let onSkip: () -> Void
    let onTap: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var showLikeIndicator = false
    @State private var showSkipIndicator = false
    
    var body: some View {
        ZStack {
            // Main Card
            Button(action: onTap) {
                ZStack(alignment: .bottom) {
                    // Photo
                    AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Rectangle().fill(Color(white: 0.12))
                                .overlay {
                                    ProgressView()
                                        .tint(.white.opacity(0.5))
                                }
                        }
                    }
                    .frame(height: 380)
                    .clipped()
                    
                    // Gradient
                    LinearGradient(
                        colors: [.clear, .clear, .black.opacity(0.4), .black.opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    // Like/Skip Indicators
                    HStack {
                        // Skip Indicator
                        if showSkipIndicator {
                            Text("GEÇÇ")
                                .font(.system(size: 28, weight: .black))
                                .foregroundStyle(.red)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(.red, lineWidth: 3)
                                )
                                .rotationEffect(.degrees(-15))
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        Spacer()
                        
                        // Like Indicator
                        if showLikeIndicator {
                            Text("BEĞENDİN")
                                .font(.system(size: 28, weight: .black))
                                .foregroundStyle(.green)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(.green, lineWidth: 3)
                                )
                                .rotationEffect(.degrees(15))
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(24)
                    .frame(maxHeight: .infinity, alignment: .top)
                    
                    // User Info
                    VStack(spacing: 12) {
                        // Top badges
                        HStack {
                            // Score Badge
                            HStack(spacing: 4) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 10))
                                Text("%\(Int(user.score))")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)))
                            
                            if user.isBoosted {
                                HStack(spacing: 4) {
                                    Image(systemName: "bolt.fill")
                                        .font(.system(size: 10))
                                    Text("Boost")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundStyle(.black)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(.yellow))
                            }
                            
                            Spacer()
                        }
                        
                        Spacer()
                        
                        // Bottom Info
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 10) {
                                Text(user.displayName)
                                    .font(.system(size: 26, weight: .bold))
                                Text("\(user.age)")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            
                            HStack(spacing: 8) {
                                HStack(spacing: 4) {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.purple)
                                    Text(user.city)
                                }
                                
                                if let distance = user.distanceKm {
                                    Text("•")
                                        .foregroundStyle(.white.opacity(0.4))
                                    Text("\(String(format: "%.1f", distance)) km")
                                }
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.7))
                            
                            // Tags
                            HStack(spacing: 8) {
                                ForEach(user.tags.prefix(4), id: \.self) { tag in
                                    Text(tag)
                                        .font(.system(size: 18))
                                }
                                
                                if !user.commonInterests.isEmpty {
                                    Text(user.commonInterests.first ?? "")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Capsule().fill(.white.opacity(0.15)))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(16)
                    .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .offset(dragOffset)
            .rotationEffect(.degrees(Double(dragOffset.width / 20)))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                        withAnimation(.easeInOut(duration: 0.1)) {
                            showLikeIndicator = value.translation.width > 50
                            showSkipIndicator = value.translation.width < -50
                        }
                    }
                    .onEnded { value in
                        if value.translation.width > 100 {
                            // Like
                            withAnimation(.easeOut(duration: 0.3)) {
                                dragOffset = CGSize(width: 500, height: 0)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onLike()
                                dragOffset = .zero
                                showLikeIndicator = false
                            }
                        } else if value.translation.width < -100 {
                            // Skip
                            withAnimation(.easeOut(duration: 0.3)) {
                                dragOffset = CGSize(width: -500, height: 0)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onSkip()
                                dragOffset = .zero
                                showSkipIndicator = false
                            }
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                dragOffset = .zero
                                showLikeIndicator = false
                                showSkipIndicator = false
                            }
                        }
                    }
            )
            
            // Action Buttons
            VStack {
                Spacer()
                
                HStack(spacing: 16) {
                    // Skip Button
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.3)) {
                            dragOffset = CGSize(width: -500, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSkip()
                            dragOffset = .zero
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.red)
                        }
                    }
                    
                    // Like Button
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.3)) {
                            dragOffset = CGSize(width: 500, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onLike()
                            dragOffset = .zero
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 64, height: 64)
                            
                            Image(systemName: "heart.fill")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .frame(height: 380)
    }
}

// MARK: - Quick Actions Bar

struct QuickActionsBar: View {
    let likedYouCount: Int
    let compatibilityCount: Int
    let isPremium: Bool
    let onLikedYouTap: () -> Void
    let onCompatibilityTap: () -> Void
    let onDailyTap: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            // Seni Beğenenler
            DiscoverQuickActionButton(
                icon: "heart.fill",
                title: "Beğenenler",
                count: likedYouCount,
                colors: [.pink, .red],
                isLocked: !isPremium,
                action: onLikedYouTap
            )
            
            // Yüksek Uyumluluk
            DiscoverQuickActionButton(
                icon: "sparkles",
                title: "Uyumlular",
                count: compatibilityCount,
                colors: [.purple, .blue],
                isLocked: false,
                action: onCompatibilityTap
            )
            
            // Günlük
            DiscoverQuickActionButton(
                icon: "calendar",
                title: "Günlük",
                count: 3,
                colors: [.orange, .yellow],
                isLocked: false,
                action: onDailyTap
            )
        }
    }
}

struct DiscoverQuickActionButton: View {
    let icon: String
    let title: String
    let count: Int
    let colors: [Color]
    let isLocked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        if isLocked {
                            Circle()
                                .fill(.black.opacity(0.5))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "lock.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(.yellow)
                        }
                    }
                    
                    // Count Badge
                    if count > 0 {
                        Text("\(count)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 18, height: 18)
                            .background(Circle().fill(.red))
                            .offset(x: 4, y: -4)
                    }
                }
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Expandable Users Section

struct ExpandableUsersSection: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColors: [Color]
    let users: [DiscoverUser]
    @Binding var isExpanded: Bool
    let onUserTap: (DiscoverUser) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header (Always visible - tappable)
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: iconColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    
                    // Title & Subtitle
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    // User Avatars Preview (when collapsed)
                    if !isExpanded {
                        HStack(spacing: -8) {
                            ForEach(Array(users.prefix(3).enumerated()), id: \.element.id) { _, user in
                                AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().scaledToFill()
                                    default:
                                        Circle().fill(Color(white: 0.2))
                                    }
                                }
                                .frame(width: 28, height: 28)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
                            }
                        }
                    }
                    
                    // Expand/Collapse Arrow
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.1))
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                }
                .padding(14)
            }
            .buttonStyle(.plain)
            
            // Expanded Content
            if isExpanded {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(users) { user in
                            ExpandableUserCard(user: user) {
                                onUserTap(user)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct ExpandableUserCard: View {
    let user: DiscoverUser
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack(alignment: .bottomTrailing) {
                    AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            RoundedRectangle(cornerRadius: 14).fill(Color(white: 0.15))
                        }
                    }
                    .frame(width: 90, height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                    // Score Badge
                    Text("%\(Int(user.score))")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)))
                        .offset(x: -6, y: -6)
                }
                
                VStack(spacing: 2) {
                    Text(user.displayName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Text("\(user.age), \(user.city)")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(1)
                }
            }
            .frame(width: 90)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Compact Premium Banner

struct CompactPremiumBanner: View {
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Premium'a Geç")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("Sınırsız beğeni, seni beğenenleri gör")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.yellow)
        }
        .padding(16)
        .background(
            LinearGradient(colors: [.yellow.opacity(0.15), .orange.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
        )
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(LinearGradient(colors: [.yellow.opacity(0.4), .orange.opacity(0.2)], startPoint: .leading, endPoint: .trailing), lineWidth: 1)
        )
    }
}

// MARK: - Expandable Glass Section (Premium Liquid Glass)

struct ExpandableGlassSection<Content: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColors: [Color]
    @Binding var isExpanded: Bool
    var isPremiumLocked: Bool = false
    @ViewBuilder let content: () -> Content
    
    private let containerShape = RoundedRectangle(cornerRadius: 24)
    
    var body: some View {
        VStack(spacing: 0) {
            // Header (Always visible)
            Button {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75, blendDuration: 0)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    // Icon with glass
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: iconColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .glassEffect(.regular.interactive(), in: Circle())
                    
                    // Title & Subtitle
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(title)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                            
                            if isPremiumLocked {
                                HStack(spacing: 3) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 9))
                                    Text("PRO")
                                        .font(.system(size: 9, weight: .bold))
                                }
                                .foregroundStyle(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)))
                            }
                        }
                        
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    // Expand/Collapse Arrow with glass
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.1))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7))
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                    .glassEffect(.regular.interactive(), in: Circle())
                }
                .padding(16)
            }
            .buttonStyle(.plain)
            
            // Expanded Content with smooth animation
            if isExpanded {
                content()
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                        removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
                    ))
            }
        }
        .background(.regularMaterial, in: containerShape)
        .glassEffect(.regular.interactive(), in: containerShape)
        .overlay(
            containerShape
                .stroke(.white.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Glass User Card

struct GlassUserCard: View {
    let user: DiscoverUser
    var isBlurred: Bool = false
    let onTap: () -> Void
    
    private let cardShape = RoundedRectangle(cornerRadius: 16)
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack(alignment: .bottomTrailing) {
                    AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            RoundedRectangle(cornerRadius: 14).fill(Color(white: 0.15))
                        }
                    }
                    .frame(width: 100, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .blur(radius: isBlurred ? 12 : 0)
                    
                    if isBlurred {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 100, height: 120)
                    }
                    
                    // Score Badge
                    if !isBlurred {
                        Text("%\(Int(user.score))")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)))
                            .offset(x: -6, y: -6)
                    }
                }
                
                VStack(spacing: 2) {
                    Text(isBlurred ? "???" : user.displayName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Text("\(user.age), \(user.city)")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(1)
                }
            }
            .frame(width: 100)
            .padding(8)
            .background(.regularMaterial, in: cardShape)
            .glassEffect(.regular.interactive(), in: cardShape)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Compatibility Glass Card

struct CompatibilityGlassCard: View {
    let user: DiscoverUser
    let onTap: () -> Void
    
    private let cardShape = RoundedRectangle(cornerRadius: 18)
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            RoundedRectangle(cornerRadius: 14).fill(Color(white: 0.15))
                        }
                    }
                    .frame(width: 110, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                    // Compatibility Ring
                    ZStack {
                        Circle()
                            .stroke(.white.opacity(0.2), lineWidth: 3)
                            .frame(width: 36, height: 36)
                        
                        Circle()
                            .trim(from: 0, to: user.score / 100)
                            .stroke(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: 36, height: 36)
                            .rotationEffect(.degrees(-90))
                        
                        Text("%\(Int(user.score))")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .background(.ultraThinMaterial, in: Circle())
                    .offset(x: 6, y: -6)
                }
                
                VStack(spacing: 3) {
                    Text(user.displayName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Text("\(user.age)")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.6))
                        
                        if let distance = user.distanceKm {
                            Text("•")
                                .font(.system(size: 8))
                                .foregroundStyle(.white.opacity(0.3))
                            Text("\(String(format: "%.1f", distance)) km")
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                    
                    // Common interests
                    if let interest = user.commonInterests.first {
                        Text(interest)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.purple)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(.purple.opacity(0.2)))
                    }
                }
            }
            .frame(width: 110)
            .padding(10)
            .background(.regularMaterial, in: cardShape)
            .glassEffect(.regular.interactive(), in: cardShape)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Premium Glass Section (Yeni Premium Tasarım)

struct PremiumGlassSection<Content: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColors: [Color]
    @Binding var isExpanded: Bool
    var isPremiumLocked: Bool = false
    @ViewBuilder let content: () -> Content
    
    private let containerShape = RoundedRectangle(cornerRadius: 28)
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 14) {
                    // Premium Icon with glow
                    ZStack {
                        // Glow effect
                        Circle()
                            .fill(LinearGradient(colors: iconColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 44, height: 44)
                            .blur(radius: 8)
                            .opacity(0.5)
                        
                        Circle()
                            .fill(LinearGradient(colors: iconColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    
                    // Title & Subtitle
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(title)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(.white)
                            
                            if isPremiumLocked {
                                HStack(spacing: 4) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 10))
                                    Text("PRO")
                                        .font(.system(size: 10, weight: .bold))
                                }
                                .foregroundStyle(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing))
                                )
                            }
                        }
                        
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    // Expand Arrow
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.08))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }
            .buttonStyle(PremiumSectionButtonStyle())
            
            // Expanded Content
            if isExpanded {
                content()
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.98, anchor: .top)),
                        removal: .opacity.combined(with: .scale(scale: 0.98, anchor: .top))
                    ))
            }
        }
        .background(.ultraThinMaterial, in: containerShape)
        .shadow(color: iconColors.first?.opacity(0.15) ?? .clear, radius: isExpanded ? 20 : 10, y: 5)
    }
}

struct PremiumSectionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Premium User Card

struct PremiumUserCard: View {
    let user: DiscoverUser
    var isBlurred: Bool = false
    let onTap: () -> Void
    
    private let cardShape = RoundedRectangle(cornerRadius: 20)
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                ZStack {
                    // Photo
                    AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            RoundedRectangle(cornerRadius: 16).fill(Color(white: 0.12))
                        }
                    }
                    .frame(width: 105, height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .blur(radius: isBlurred ? 14 : 0)
                    
                    if isBlurred {
                        VStack(spacing: 6) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.white)
                            Text("Premium")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.yellow)
                        }
                    }
                    
                    // Score Badge (top right)
                    if !isBlurred {
                        VStack {
                            HStack {
                                Spacer()
                                Text("%\(Int(user.score))")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing))
                                    )
                            }
                            Spacer()
                        }
                        .padding(8)
                    }
                }
                
                VStack(spacing: 3) {
                    Text(isBlurred ? "???" : user.displayName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Text("\(user.age)")
                        if let distance = user.distanceKm, !isBlurred {
                            Text("•")
                                .foregroundStyle(.white.opacity(0.3))
                            Text("\(String(format: "%.0f", distance)) km")
                        }
                    }
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.5))
                }
            }
            .frame(width: 105)
            .padding(10)
            .background(.ultraThinMaterial, in: cardShape)
        }
        .buttonStyle(PremiumCardButtonStyle())
    }
}

struct PremiumCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Compatibility Premium Card

struct CompatibilityPremiumCard: View {
    let user: DiscoverUser
    let onTap: () -> Void
    
    private let cardShape = RoundedRectangle(cornerRadius: 22)
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            RoundedRectangle(cornerRadius: 16).fill(Color(white: 0.12))
                        }
                    }
                    .frame(width: 115, height: 145)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Compatibility Ring
                    ZStack {
                        Circle()
                            .stroke(.white.opacity(0.15), lineWidth: 3)
                            .frame(width: 40, height: 40)
                        
                        Circle()
                            .trim(from: 0, to: user.score / 100)
                            .stroke(
                                LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(-90))
                        
                        Text("%\(Int(user.score))")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .background(.ultraThinMaterial, in: Circle())
                    .offset(x: 8, y: -8)
                }
                
                VStack(spacing: 4) {
                    Text(user.displayName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    HStack(spacing: 5) {
                        Text("\(user.age)")
                        if let distance = user.distanceKm {
                            Text("•")
                                .foregroundStyle(.white.opacity(0.3))
                            Text("\(String(format: "%.0f", distance)) km")
                        }
                    }
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.5))
                    
                    // Common interest tag
                    if let interest = user.commonInterests.first {
                        Text(interest)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.purple)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(.purple.opacity(0.15)))
                    }
                }
            }
            .frame(width: 115)
            .padding(12)
            .background(.ultraThinMaterial, in: cardShape)
        }
        .buttonStyle(PremiumCardButtonStyle())
    }
}

// MARK: - Daily Pick Expandable Card V2 (Düzeltilmiş)

struct DailyPickExpandableCardV2: View {
    let user: DiscoverUser
    @Binding var isExpanded: Bool
    let onTap: () -> Void
    
    private let containerShape = RoundedRectangle(cornerRadius: 28)
    
    var body: some View {
        VStack(spacing: 0) {
            if isExpanded {
                expandedContent
            } else {
                collapsedContent
            }
        }
        .background(.ultraThinMaterial, in: containerShape)
        .shadow(color: .purple.opacity(0.15), radius: isExpanded ? 20 : 10, y: 5)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: isExpanded)
    }
    
    // Collapsed - Capsule style
    private var collapsedContent: some View {
        Button {
            isExpanded = true
        } label: {
            HStack(spacing: 14) {
                // User Avatar with glow
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 50, height: 50)
                        .blur(radius: 6)
                        .opacity(0.4)
                    
                    AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Circle().fill(Color(white: 0.2))
                        }
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                    )
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.yellow)
                        Text("Bugünün Önerisi")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    
                    HStack(spacing: 6) {
                        Text(user.displayName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.8))
                        Text("•")
                            .foregroundStyle(.white.opacity(0.3))
                        Text("%\(Int(user.score)) uyum")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.pink)
                    }
                }
                
                Spacer()
                
                // Expand Arrow
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
        .buttonStyle(PremiumSectionButtonStyle())
    }
    
    // Expanded - Full card
    private var expandedContent: some View {
        VStack(spacing: 0) {
            // Header with collapse button
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.yellow)
                    Text("Bugünün Önerisi")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                // Collapse Button - DÜZELTME: Ayrı button
                Button {
                    isExpanded = false
                } label: {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.1))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "chevron.up")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .buttonStyle(PremiumCardButtonStyle())
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Main Content - Tappable area
            Button(action: onTap) {
                ZStack(alignment: .bottom) {
                    // Image
                    AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Rectangle().fill(Color(white: 0.12))
                        }
                    }
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    // Gradient
                    LinearGradient(colors: [.clear, .black.opacity(0.3), .black.opacity(0.85)], startPoint: .top, endPoint: .bottom)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    // Score Badge
                    VStack {
                        HStack {
                            Spacer()
                            HStack(spacing: 5) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 11))
                                Text("%\(Int(user.score))")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Capsule().fill(LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)))
                        }
                        .padding(14)
                        
                        Spacer()
                    }
                    
                    // User Info
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            Text(user.displayName)
                                .font(.system(size: 24, weight: .bold))
                            Text("\(user.age)")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                            if user.isBoosted {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.yellow)
                            }
                        }
                        
                        HStack(spacing: 8) {
                            HStack(spacing: 5) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.purple)
                                Text(user.city)
                            }
                            if let distance = user.distanceKm {
                                Text("•")
                                    .foregroundStyle(.white.opacity(0.4))
                                Text("\(String(format: "%.1f", distance)) km")
                            }
                        }
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.7))
                        
                        // Tags
                        HStack(spacing: 10) {
                            ForEach(user.tags.prefix(4), id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 18))
                            }
                            
                            if let interest = user.commonInterests.first {
                                Text(interest)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(.white.opacity(0.15)))
                            }
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.white)
                }
            }
            .buttonStyle(PremiumCardButtonStyle())
            .padding(.horizontal, 14)
            .padding(.bottom, 16)
        }
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .top)),
            removal: .opacity.combined(with: .scale(scale: 0.98, anchor: .top))
        ))
    }
}

// MARK: - Daily Missions Expandable Section

struct DailyMissionsExpandableSection: View {
    @Binding var isExpanded: Bool
    
    private let containerShape = RoundedRectangle(cornerRadius: 28)
    
    let missions = [
        ("Profil fotoğrafı ekle", "photo.badge.plus", 50, true),
        ("3 kişiyi beğen", "heart.fill", 30, false),
        ("Bio yaz", "text.quote", 40, false)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 14) {
                    // Icon with glow
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 44, height: 44)
                            .blur(radius: 8)
                            .opacity(0.5)
                        
                        Circle()
                            .fill(LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "target")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Günlük Görevler")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("1/3 tamamlandı • 120 puan kazan")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    // Progress + Arrow
                    HStack(spacing: 12) {
                        // Mini progress
                        ZStack {
                            Circle()
                                .stroke(.white.opacity(0.15), lineWidth: 3)
                                .frame(width: 32, height: 32)
                            
                            Circle()
                                .trim(from: 0, to: 0.33)
                                .stroke(LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                .frame(width: 32, height: 32)
                                .rotationEffect(.degrees(-90))
                            
                            Text("1")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.08))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white.opacity(0.6))
                                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }
            .buttonStyle(PremiumSectionButtonStyle())
            
            // Expanded Content
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(missions, id: \.0) { mission in
                        ExpandableMissionRow(
                            title: mission.0,
                            icon: mission.1,
                            points: mission.2,
                            isCompleted: mission.3
                        )
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 18)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.98, anchor: .top)),
                    removal: .opacity.combined(with: .scale(scale: 0.98, anchor: .top))
                ))
            }
        }
        .background(.ultraThinMaterial, in: containerShape)
        .shadow(color: .orange.opacity(0.15), radius: isExpanded ? 20 : 10, y: 5)
    }
}

struct ExpandableMissionRow: View {
    let title: String
    let icon: String
    let points: Int
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isCompleted ? .green.opacity(0.2) : .white.opacity(0.08))
                    .frame(width: 40, height: 40)
                
                Image(systemName: isCompleted ? "checkmark" : icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isCompleted ? .green : .white.opacity(0.7))
            }
            
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(isCompleted ? .white.opacity(0.5) : .white)
                .strikethrough(isCompleted)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.yellow)
                Text("+\(points)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.yellow)
            }
            .opacity(isCompleted ? 0.4 : 1)
        }
        .padding(14)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - ═══════════════════════════════════════════════════════════════
// MARK: - YENİ SADELEŞTİRİLMİŞ BİLEŞENLER
// MARK: - ═══════════════════════════════════════════════════════════════

// MARK: - Liked You Compact Bar (Minimal)

struct LikedYouCompactBar: View {
    let users: [DiscoverUser]
    let isPremium: Bool
    let onTap: () -> Void
    
    private let barShape = RoundedRectangle(cornerRadius: 20)
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Stacked Avatars
                ZStack {
                    ForEach(Array(users.prefix(3).enumerated().reversed()), id: \.element.id) { index, user in
                        AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            default:
                                Circle().fill(Color(white: 0.2))
                            }
                        }
                        .frame(width: 38, height: 38)
                        .clipShape(Circle())
                        .blur(radius: isPremium ? 0 : 8)
                        .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 2))
                        .offset(x: CGFloat(index * 14))
                    }
                }
                .frame(width: 66, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("Seni Beğenenler")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                        
                        if !isPremium {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.yellow)
                        }
                    }
                    
                    Text("\(users.count) kişi seni beğendi")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                }
                
                Spacer()
                
                // Count + Arrow
                HStack(spacing: 10) {
                    Text("\(users.count)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(
                            Circle()
                                .fill(LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .padding(14)
            .background(.regularMaterial, in: barShape)
            .glassEffect(.regular.interactive(), in: barShape)
        }
        .buttonStyle(MinimalButtonStyle())
    }
}

// MARK: - Discover Grid Section (Yeni + Popüler Birleşik)

struct DiscoverGridSection: View {
    let users: [DiscoverUser]
    let newUsers: [DiscoverUser]
    @Binding var isExpanded: Bool
    let onUserTap: (DiscoverUser) -> Void
    
    private let containerShape = RoundedRectangle(cornerRadius: 24)
    
    // Tüm kullanıcıları birleştir ve karıştır
    private var allUsers: [DiscoverUser] {
        var combined = newUsers + users.prefix(4)
        return Array(combined.prefix(8))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Keşfet")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("\(allUsers.count) profil")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    // Preview avatars when collapsed
                    if !isExpanded {
                        HStack(spacing: -10) {
                            ForEach(Array(allUsers.prefix(4).enumerated()), id: \.element.id) { _, user in
                                AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().scaledToFill()
                                    default:
                                        Circle().fill(Color(white: 0.2))
                                    }
                                }
                                .frame(width: 28, height: 28)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
                            }
                        }
                    }
                    
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.08))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.5))
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                }
                .padding(16)
            }
            .buttonStyle(MinimalButtonStyle())
            
            // Expanded Grid
            if isExpanded {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(allUsers) { user in
                        CompactUserCard(user: user) {
                            onUserTap(user)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
            }
        }
        .background(.regularMaterial, in: containerShape)
        .glassEffect(.regular.interactive(), in: containerShape)
    }
}

// MARK: - Match Section (Uyumluluk + Yakınındakiler Birleşik)

struct MatchSection: View {
    let compatibleUsers: [DiscoverUser]
    let nearbyUsers: [DiscoverUser]
    @Binding var isExpanded: Bool
    let onUserTap: (DiscoverUser) -> Void
    
    @State private var selectedTab = 0
    private let containerShape = RoundedRectangle(cornerRadius: 24)
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Eşleşmeler")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("Uyumluluk & Yakınlık")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.08))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.5))
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                }
                .padding(16)
            }
            .buttonStyle(MinimalButtonStyle())
            
            // Expanded Content
            if isExpanded {
                VStack(spacing: 14) {
                    // Tab Selector
                    HStack(spacing: 0) {
                        TabButton(title: "Uyumluluk", icon: "heart.fill", isSelected: selectedTab == 0) {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 0 }
                        }
                        
                        TabButton(title: "Yakınlık", icon: "location.fill", isSelected: selectedTab == 1) {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 1 }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Users
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(selectedTab == 0 ? compatibleUsers : nearbyUsers) { user in
                                MatchUserCard(user: user, showDistance: selectedTab == 1) {
                                    onUserTap(user)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 16)
                .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
            }
        }
        .background(.regularMaterial, in: containerShape)
        .glassEffect(.regular.interactive(), in: containerShape)
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected {
                        Capsule().fill(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                    } else {
                        Capsule().fill(.white.opacity(0.05))
                    }
                }
            )
        }
        .buttonStyle(MinimalButtonStyle())
    }
}

// MARK: - Activity Section (Görevler + Kişilik Testi)

struct ActivitySection: View {
    let onMissionsTap: () -> Void
    let onPersonalityTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Günlük Görevler
            ActivityCard(
                icon: "target",
                title: "Görevler",
                subtitle: "1/3",
                colors: [.orange, .yellow],
                action: onMissionsTap
            )
            
            // Ruh Eşini Bul (Kişilik Testi) - Redesigned
            Button(action: onPersonalityTap) {
                ZStack(alignment: .bottomLeading) {
                    // Background
                    LinearGradient(
                        colors: [Color(hex: "FF416C"), Color(hex: "FF4B2B")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Decorative Circles
                    GeometryReader { geo in
                        Circle()
                            .fill(.white.opacity(0.1))
                            .frame(width: 100, height: 100)
                            .offset(x: geo.size.width - 50, y: -20)
                        
                        Circle()
                            .fill(.white.opacity(0.1))
                            .frame(width: 60, height: 60)
                            .offset(x: geo.size.width - 80, y: 40)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white)
                            .padding(.bottom, 8)
                        
                        Text("Ruh Eşini")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("Bul")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("Kişilik Analizi")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.top, 4)
                    }
                    .padding(16)
                }
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color(hex: "FF416C").opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(MinimalButtonStyle())
        }
    }
}

struct ActivityCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let colors: [Color]
    let action: () -> Void
    
    private let cardShape = RoundedRectangle(cornerRadius: 20)
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(colors.first ?? .white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(.regularMaterial, in: cardShape)
            .glassEffect(.regular.interactive(), in: cardShape)
        }
        .buttonStyle(MinimalButtonStyle())
    }
}

// MARK: - Compact User Card (Grid için)

struct CompactUserCard: View {
    let user: DiscoverUser
    let onTap: () -> Void
    
    private let cardShape = RoundedRectangle(cornerRadius: 16)
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        RoundedRectangle(cornerRadius: 12).fill(Color(white: 0.12))
                    }
                }
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(spacing: 2) {
                    Text(user.displayName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Text("\(user.age)")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .padding(8)
            .background(.ultraThinMaterial, in: cardShape)
        }
        .buttonStyle(MinimalButtonStyle())
    }
}

// MARK: - Match User Card

struct MatchUserCard: View {
    let user: DiscoverUser
    var showDistance: Bool = false
    let onTap: () -> Void
    
    private let cardShape = RoundedRectangle(cornerRadius: 18)
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            RoundedRectangle(cornerRadius: 14).fill(Color(white: 0.12))
                        }
                    }
                    .frame(width: 95, height: 115)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                    // Badge
                    Text(showDistance ? "\(String(format: "%.0f", user.distanceKm ?? 0))km" : "%\(Int(user.score))")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(LinearGradient(colors: showDistance ? [.blue, .cyan] : [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                        )
                        .offset(x: -6, y: 6)
                }
                
                VStack(spacing: 2) {
                    Text(user.displayName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Text("\(user.age), \(user.city)")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(1)
                }
            }
            .frame(width: 95)
            .padding(10)
            .background(.ultraThinMaterial, in: cardShape)
        }
        .buttonStyle(MinimalButtonStyle())
    }
}

// MARK: - Minimal Button Style

struct MinimalButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    DiscoverView()
        .environment(AppState())
}

struct LikedYouBar: View {
    let users: [DiscoverUser]
    let isPremium: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Avatars Stack
                ZStack {
                    ForEach(Array(users.prefix(3).enumerated()), id: \.element.id) { index, user in
                        AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            default:
                                Circle().fill(Color(white: 0.2))
                            }
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .blur(radius: isPremium ? 0 : 8)
                        .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 2))
                        .offset(x: CGFloat(index * 20))
                    }
                }
                .frame(width: 80, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("Seni Beğenenler")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                        
                        if !isPremium {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.yellow)
                        }
                    }
                    
                    Text("\(users.count) kişi seni beğendi")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text("\(users.count)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)))
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .padding(14)
            .background(LinearGradient(colors: [.pink.opacity(0.15), .purple.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(LinearGradient(colors: [.pink.opacity(0.3), .purple.opacity(0.2)], startPoint: .leading, endPoint: .trailing), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Compatibility Bar (Tıklanabilir)

struct CompatibilityBar: View {
    let users: [DiscoverUser]
    let onTap: () -> Void
    
    private var topScore: Int { Int(users.first?.score ?? 0) }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(LinearGradient(colors: [.purple.opacity(0.3), .pink.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 3)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: Double(topScore) / 100.0)
                        .stroke(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                    
                    Text("%\(topScore)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Yüksek Uyumluluk")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    
                    Text("\(users.count) kişi seninle çok uyumlu")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                
                Spacer()
                
                HStack(spacing: -8) {
                    ForEach(Array(users.prefix(3).enumerated()), id: \.element.id) { _, user in
                        AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            default:
                                Circle().fill(Color(white: 0.2))
                            }
                        }
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(14)
            .background(LinearGradient(colors: [.purple.opacity(0.15), .blue.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(LinearGradient(colors: [.purple.opacity(0.3), .blue.opacity(0.2)], startPoint: .leading, endPoint: .trailing), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Liked You Premium Card (Yeni Tasarım)

struct LikedYouPremiumCard: View {
    let users: [DiscoverUser]
    let isPremium: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Header
                HStack {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 36, height: 36)
                            Image(systemName: "heart.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text("Seni Beğenenler")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                                
                                if !isPremium {
                                    HStack(spacing: 3) {
                                        Image(systemName: "crown.fill")
                                            .font(.system(size: 9))
                                        Text("PRO")
                                            .font(.system(size: 9, weight: .bold))
                                    }
                                    .foregroundStyle(.black)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)))
                                }
                            }
                            
                            Text("\(users.count) kişi seni beğendi")
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("Tümünü Gör")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.pink)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.pink)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                // Users Grid
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(users) { user in
                            LikedYouUserCard(user: user, isPremium: isPremium)
                        }
                        
                        // More indicator
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 70, height: 70)
                                
                                VStack(spacing: 2) {
                                    Text("+\(max(0, users.count - 3))")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(.white)
                                    Text("daha")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                        }
                        .frame(width: 80)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .background(
                LinearGradient(colors: [.pink.opacity(0.12), .purple.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(LinearGradient(colors: [.pink.opacity(0.4), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct LikedYouUserCard: View {
    let user: DiscoverUser
    let isPremium: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Circle().fill(Color(white: 0.2))
                    }
                }
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .blur(radius: isPremium ? 0 : 12)
                .overlay(
                    Circle()
                        .stroke(LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                )
                
                if !isPremium {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            
            VStack(spacing: 2) {
                Text(isPremium ? user.displayName : "???")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                Text("\(user.age), \(user.city)")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(1)
            }
        }
        .frame(width: 80)
    }
}

// MARK: - High Compatibility Section (Yeni Grid Tasarım)

struct HighCompatibilitySection: View {
    let users: [DiscoverUser]
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 14) {
            // Header
            HStack {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 36, height: 36)
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Yüksek Uyumluluk")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("Seninle en uyumlu kişiler")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                
                Spacer()
                
                Button(action: onTap) {
                    HStack(spacing: 4) {
                        Text("Tümü")
                            .font(.system(size: 12, weight: .medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(.purple)
                }
            }
            .padding(.horizontal, 16)
            
            // Users Grid - 2 rows
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        ForEach(Array(users.prefix(3).enumerated()), id: \.element.id) { index, user in
                            CompatibilityUserCard(user: user, rank: index + 1)
                        }
                    }
                    
                    if users.count > 3 {
                        HStack(spacing: 12) {
                            ForEach(Array(users.dropFirst(3).prefix(3).enumerated()), id: \.element.id) { index, user in
                                CompatibilityUserCard(user: user, rank: index + 4)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 16)
        .background(
            LinearGradient(colors: [.purple.opacity(0.08), .blue.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 16)
    }
}

struct CompatibilityUserCard: View {
    let user: DiscoverUser
    let rank: Int
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .purple
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        RoundedRectangle(cornerRadius: 16).fill(Color(white: 0.15))
                    }
                }
                .frame(width: 100, height: 130)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(LinearGradient(colors: [.purple.opacity(0.5), .blue.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                )
                
                // Uyumluluk Badge
                HStack(spacing: 3) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 8))
                    Text("%\(Int(user.score))")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Capsule().fill(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)))
                .offset(x: -6, y: 8)
                
                // Rank Badge (sadece ilk 3 için)
                if rank <= 3 {
                    ZStack {
                        Circle()
                            .fill(rankColor)
                            .frame(width: 22, height: 22)
                        Text("\(rank)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(rank == 1 ? .black : .white)
                    }
                    .offset(x: 6, y: -6)
                }
            }
            
            VStack(spacing: 2) {
                Text(user.displayName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text("\(user.age)")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.6))
                    
                    if let distance = user.distanceKm {
                        Text("•")
                            .font(.system(size: 8))
                            .foregroundStyle(.white.opacity(0.3))
                        Text("\(String(format: "%.1f", distance)) km")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
        }
        .frame(width: 100)
    }
}

// MARK: - Daily Pick Expandable Card (Yeni Tasarım - Açılır/Kapanır)

struct DailyPickExpandableCard: View {
    let user: DiscoverUser
    @Binding var isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if isExpanded {
                // Expanded State - Full Card
                expandedView
            } else {
                // Collapsed State - Capsule
                collapsedView
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
    }
    
    // MARK: - Collapsed View (Capsule)
    private var collapsedView: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isExpanded = true
            }
        } label: {
            HStack(spacing: 12) {
                // User Avatar
                AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Circle().fill(Color(white: 0.2))
                    }
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                )
                
                // Info
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.yellow)
                        Text("Bugünün Önerisi")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    
                    HStack(spacing: 4) {
                        Text(user.displayName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                        Text("•")
                            .foregroundStyle(.white.opacity(0.4))
                        Text("\(user.age)")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.7))
                        Text("•")
                            .foregroundStyle(.white.opacity(0.4))
                        Text("%\(Int(user.score)) uyum")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.pink)
                    }
                }
                
                Spacer()
                
                // Expand Arrow
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                LinearGradient(colors: [.purple.opacity(0.15), .pink.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
            )
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(LinearGradient(colors: [.purple.opacity(0.4), .pink.opacity(0.3)], startPoint: .leading, endPoint: .trailing), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Expanded View (Full Card)
    private var expandedView: some View {
        VStack(spacing: 0) {
            // Header with collapse button
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.yellow)
                    Text("Bugünün Önerisi")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                // Collapse Button
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isExpanded = false
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: "chevron.up")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)
            
            // Main Content
            Button(action: onTap) {
                ZStack(alignment: .bottom) {
                    // Image
                    AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Rectangle().fill(Color(white: 0.15))
                        }
                    }
                    .frame(height: 220)
                    .clipped()
                    
                    // Gradient Overlay
                    LinearGradient(colors: [.clear, .black.opacity(0.3), .black.opacity(0.85)], startPoint: .top, endPoint: .bottom)
                    
                    // Score Badge
                    VStack {
                        HStack {
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 10))
                                Text("%\(Int(user.score))")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)))
                        }
                        .padding(12)
                        
                        Spacer()
                    }
                    
                    // User Info
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Text(user.displayName)
                                        .font(.system(size: 22, weight: .bold))
                                    Text("\(user.age)")
                                        .font(.system(size: 20))
                                        .foregroundStyle(.white.opacity(0.8))
                                    if user.isBoosted {
                                        Image(systemName: "bolt.fill")
                                            .font(.system(size: 12))
                                            .foregroundStyle(.yellow)
                                    }
                                }
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.purple)
                                    Text(user.city)
                                    if let distance = user.distanceKm {
                                        Text("•").foregroundStyle(.white.opacity(0.4))
                                        Text("\(String(format: "%.1f", distance)) km")
                                    }
                                }
                                .font(.system(size: 13))
                                .foregroundStyle(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            // View Profile Button
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                        }
                        
                        // Tags
                        HStack(spacing: 8) {
                            ForEach(user.tags.prefix(3), id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 16))
                            }
                            
                            ForEach(user.commonInterests.prefix(2), id: \.self) { interest in
                                Text(interest)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Capsule().fill(.white.opacity(0.15)))
                            }
                        }
                    }
                    .padding(16)
                    .foregroundStyle(.white)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.bottom, 14)
        }
        .background(
            LinearGradient(colors: [.purple.opacity(0.12), .pink.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(LinearGradient(colors: [.purple.opacity(0.4), .pink.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
    }
}

// MARK: - Daily Pick Card (Yeni Tasarım)

struct DailyPickCard: View {
    let user: DiscoverUser
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Rectangle().fill(Color(white: 0.15))
                    }
                }
                .frame(height: 200)
                .clipped()
                
                LinearGradient(colors: [.clear, .black.opacity(0.4), .black.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                
                VStack {
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12))
                            Text("Bugünün Önerisi")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)))
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 10))
                            Text("%\(Int(user.score))")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(.pink.opacity(0.8)))
                    }
                    .padding(12)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text(user.displayName)
                                    .font(.title2.weight(.bold))
                                Text("\(user.age)")
                                    .font(.title3)
                                    .foregroundStyle(.white.opacity(0.8))
                                if user.isBoosted {
                                    Image(systemName: "bolt.fill")
                                        .font(.caption)
                                        .foregroundStyle(.yellow)
                                }
                            }
                            
                            HStack(spacing: 6) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.purple)
                                Text(user.city)
                                if let distance = user.distanceKm {
                                    Text("•").foregroundStyle(.white.opacity(0.4))
                                    Text("\(String(format: "%.1f", distance)) km")
                                }
                            }
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.white)
                            .background(Circle().fill(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)).padding(4))
                    }
                    
                    HStack(spacing: 8) {
                        ForEach(user.tags.prefix(3), id: \.self) { tag in
                            Text(tag).font(.subheadline)
                        }
                        
                        ForEach(user.commonInterests.prefix(2), id: \.self) { interest in
                            Text(interest)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(.white.opacity(0.15)))
                        }
                    }
                }
                .padding(16)
                .foregroundStyle(.white)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(LinearGradient(colors: [.purple.opacity(0.5), .pink.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Personality Test Promo Card

struct PersonalityTestPromoCard: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.purple.opacity(0.3), .pink.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 24))
                        .foregroundStyle(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("Kişilik Testi")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                        
                        Text("YENİ")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)))
                    }
                    
                    Text("10 soru ile kişiliğini keşfet!")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                
                Spacer()
                
                Text("Başla")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)))
            }
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(LinearGradient(colors: [.purple.opacity(0.4), .pink.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Liked You Detail Sheet

struct LikedYouDetailSheet: View {
    let users: [DiscoverUser]
    let isPremium: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.pink.opacity(0.2), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "heart.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        }
                        
                        Text("Seni Beğenenler")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                        
                        Text("\(users.count) kişi seni beğendi")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.top, 20)
                    
                    if !isPremium {
                        VStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .font(.title)
                                .foregroundStyle(.yellow)
                            
                            Text("Premium ile Aç")
                                .font(.headline)
                                .foregroundStyle(.white)
                            
                            Text("Seni beğenen herkesi görmek için Premium'a geç!")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                            
                            Button {} label: {
                                Text("Premium'a Geç")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Capsule().fill(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)))
                            }
                        }
                        .padding(20)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 20)
                    }
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(users) { user in
                            LikedYouGridCard(user: user, isBlurred: !isPremium)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
            .background(PremiumBackground())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
        }
    }
}

struct LikedYouGridCard: View {
    let user: DiscoverUser
    let isBlurred: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Rectangle().fill(Color(white: 0.15))
                }
            }
            .frame(height: 200)
            .blur(radius: isBlurred ? 20 : 0)
            
            LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
            
            if isBlurred {
                VStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                    Text("Premium")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.yellow)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(user.displayName)
                            .font(.subheadline.weight(.bold))
                        Text("\(user.age)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 9))
                        Text(user.city)
                            .font(.caption)
                    }
                    .foregroundStyle(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
            }
        }
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(LinearGradient(colors: [.pink.opacity(0.4), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
    }
}

// MARK: - Compatibility Detail Sheet

struct CompatibilityDetailSheet: View {
    let users: [DiscoverUser]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.purple.opacity(0.2), .blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "heart.text.square.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        }
                        
                        Text("Yüksek Uyumluluk")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                        
                        Text("Seninle en uyumlu profiller")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 12) {
                        ForEach(users) { user in
                            CompatibilityListCard(user: user)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
            .background(PremiumBackground())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
        }
    }
}

struct CompatibilityListCard: View {
    let user: DiscoverUser
    
    var body: some View {
        HStack(spacing: 14) {
            AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Circle().fill(Color(white: 0.15))
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .overlay(Circle().stroke(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2))
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(user.displayName)
                        .font(.subheadline.weight(.semibold))
                    Text("\(user.age)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                    if user.isBoosted {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.yellow)
                    }
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 9))
                    Text(user.city)
                    if let distance = user.distanceKm {
                        Text("• \(String(format: "%.1f", distance)) km")
                    }
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                
                HStack(spacing: 4) {
                    ForEach(user.commonInterests.prefix(2), id: \.self) { interest in
                        Text(interest)
                            .font(.system(size: 10))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(.purple.opacity(0.2)))
                    }
                }
            }
            .foregroundStyle(.white)
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("%\(Int(user.score))")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                Text("Uyum")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - New Users Section

struct NewUsersSection: View {
    let users: [DiscoverUser]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.badge.plus")
                    .foregroundStyle(.green)
                Text("Yeni Üyeler")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Text("YENİ")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(.green))
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(users) { user in
                        NewUserCard(user: user)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct NewUserCard: View {
    let user: DiscoverUser
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Circle().fill(Color(white: 0.15))
                    }
                }
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .overlay(Circle().stroke(LinearGradient(colors: [.green, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2))
                
                Circle()
                    .fill(.green)
                    .frame(width: 14, height: 14)
                    .overlay(Image(systemName: "sparkle").font(.system(size: 8, weight: .bold)).foregroundStyle(.white))
            }
            
            VStack(spacing: 2) {
                Text(user.displayName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                
                Text(user.city)
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .frame(width: 90)
    }
}

// MARK: - Popular Cities Section

struct PopularCitiesSection: View {
    let cities = [("İstanbul", "🏙️", 1250), ("Ankara", "🏛️", 890), ("İzmir", "🌊", 720), ("Antalya", "🏖️", 650), ("Bursa", "🌳", 480)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "map.fill")
                    .foregroundStyle(.cyan)
                Text("Popüler Şehirler")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(cities, id: \.0) { city, emoji, count in
                        CityCard(name: city, emoji: emoji, userCount: count)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct CityCard: View {
    let name: String
    let emoji: String
    let userCount: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text(emoji).font(.system(size: 28))
            Text(name).font(.caption.weight(.semibold)).foregroundStyle(.white)
            Text("\(userCount) kişi").font(.system(size: 9)).foregroundStyle(.white.opacity(0.5))
        }
        .frame(width: 80, height: 90)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Premium Promo Card

struct PremiumPromoCard: View {
    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Premium'a Geç")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Sınırsız beğeni, seni beğenenleri gör!")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                
                Spacer()
            }
            
            Button {} label: {
                Text("Premium'u Keşfet")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)))
            }
        }
        .padding(16)
        .background(LinearGradient(colors: [.yellow.opacity(0.1), .orange.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - Liked You Premium Bar (Glass + Glow)

struct LikedYouPremiumBar: View {
    let users: [DiscoverUser]
    let isPremium: Bool
    let onTap: () -> Void
    
    private let barShape = RoundedRectangle(cornerRadius: 22)
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Stacked Avatars (düzeltilmiş)
                HStack(spacing: -12) {
                    ForEach(Array(users.prefix(3).enumerated()), id: \.element.id) { index, user in
                        AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            default:
                                Circle().fill(Color(white: 0.2))
                            }
                        }
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                        .blur(radius: isPremium ? 0 : 8)
                        .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 2))
                        .zIndex(Double(3 - index))
                    }
                }
                .frame(width: 60, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("Seni Beğenenler")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                        
                        if !isPremium {
                            HStack(spacing: 3) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 9))
                                Text("PRO")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .foregroundStyle(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)))
                        }
                    }
                    
                    Text("\(users.count) kişi")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                }
                
                Spacer()
                
                HStack(spacing: 10) {
                    Text("\(users.count)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)))
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .padding(14)
            .background(.regularMaterial, in: barShape)
            .glassEffect(.regular.interactive(), in: barShape)
            .shadow(color: .pink.opacity(0.2), radius: 12, y: 4)
        }
        .buttonStyle(MinimalButtonStyle())
    }
}

// MARK: - Daily Pick Glass Card

struct DailyPickGlassCard: View {
    let user: DiscoverUser
    @Binding var isExpanded: Bool
    let onTap: () -> Void
    
    private let containerShape = RoundedRectangle(cornerRadius: 26)
    
    var body: some View {
        VStack(spacing: 0) {
            if isExpanded {
                expandedView
            } else {
                collapsedView
            }
        }
        .background(.regularMaterial, in: containerShape)
        .glassEffect(.regular.interactive(), in: containerShape)
        .shadow(color: .purple.opacity(0.25), radius: isExpanded ? 20 : 12, y: 6)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
    }
    
    private var collapsedView: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isExpanded = true
            }
        } label: {
            HStack(spacing: 14) {
                AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Circle().fill(Color(white: 0.2))
                    }
                }
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .overlay(Circle().stroke(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2))
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.yellow)
                        Text("Bugünün Önerisi")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    
                    Text("\(user.displayName) • %\(Int(user.score))")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(14)
        }
        .buttonStyle(MinimalButtonStyle())
    }
    
    private var expandedView: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.yellow)
                    Text("Bugünün Önerisi")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isExpanded = false
                    }
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(.white.opacity(0.15)))
                }
                .buttonStyle(.plain)
                .contentShape(Circle())
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)
            
            Button(action: onTap) {
                ZStack(alignment: .bottom) {
                    AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Rectangle().fill(Color(white: 0.12))
                        }
                    }
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    
                    LinearGradient(colors: [.clear, .black.opacity(0.3), .black.opacity(0.85)], startPoint: .top, endPoint: .bottom)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Text(user.displayName)
                                .font(.system(size: 22, weight: .bold))
                            Text("\(user.age)")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(.purple)
                            Text(user.city)
                            if let distance = user.distanceKm {
                                Text("• \(String(format: "%.1f", distance)) km")
                            }
                        }
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.white)
                }
            }
            .buttonStyle(MinimalButtonStyle())
            .padding(.horizontal, 12)
            .padding(.bottom, 14)
        }
    }
}

// MARK: - Discover Glass Grid

struct DiscoverGlassGrid: View {
    let users: [DiscoverUser]
    let newUsers: [DiscoverUser]
    @Binding var isExpanded: Bool
    let onUserTap: (DiscoverUser) -> Void
    
    private let containerShape = RoundedRectangle(cornerRadius: 26)
    
    private var allUsers: [DiscoverUser] {
        Array((newUsers + users.prefix(4)).prefix(8))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 38, height: 38)
                        
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Keşfet")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("\(allUsers.count) profil")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    if !isExpanded {
                        HStack(spacing: -8) {
                            ForEach(Array(allUsers.prefix(3).enumerated()), id: \.element.id) { _, user in
                                AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().scaledToFill()
                                    default:
                                        Circle().fill(Color(white: 0.2))
                                    }
                                }
                                .frame(width: 26, height: 26)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
                            }
                        }
                    }
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.5))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(14)
            }
            .buttonStyle(MinimalButtonStyle())
            
            if isExpanded {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ], spacing: 10) {
                    ForEach(allUsers) { user in
                        CompactGlassCard(user: user) {
                            onUserTap(user)
                        }
                    }
                }
                .padding(14)
                .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
            }
        }
        .background(.regularMaterial, in: containerShape)
        .glassEffect(.regular.interactive(), in: containerShape)
        .shadow(color: .purple.opacity(0.2), radius: 12, y: 4)
    }
}

struct CompactGlassCard: View {
    let user: DiscoverUser
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        RoundedRectangle(cornerRadius: 10).fill(Color(white: 0.12))
                    }
                }
                .frame(height: 95)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(spacing: 2) {
                    Text(user.displayName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Text("\(user.age)")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .padding(6)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(MinimalButtonStyle())
    }
}

// MARK: - Match Glass Section

struct MatchGlassSection: View {
    let compatibleUsers: [DiscoverUser]
    let nearbyUsers: [DiscoverUser]
    @Binding var isExpanded: Bool
    let onUserTap: (DiscoverUser) -> Void
    
    @State private var selectedTab = 0
    private let containerShape = RoundedRectangle(cornerRadius: 26)
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 38, height: 38)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Eşleşmeler")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("Uyumluluk & Yakınlık")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.5))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(14)
            }
            .buttonStyle(MinimalButtonStyle())
            
            if isExpanded {
                VStack(spacing: 12) {
                    HStack(spacing: 0) {
                        GlassTabButton(title: "Uyumluluk", icon: "heart.fill", isSelected: selectedTab == 0) {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 0 }
                        }
                        
                        GlassTabButton(title: "Yakınlık", icon: "location.fill", isSelected: selectedTab == 1) {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 1 }
                        }
                    }
                    .padding(.horizontal, 14)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(selectedTab == 0 ? compatibleUsers : nearbyUsers) { user in
                                MatchGlassCard(user: user, showDistance: selectedTab == 1) {
                                    onUserTap(user)
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                    }
                }
                .padding(.bottom, 14)
                .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
            }
        }
        .background(.regularMaterial, in: containerShape)
        .glassEffect(.regular.interactive(), in: containerShape)
        .shadow(color: .blue.opacity(0.2), radius: 12, y: 4)
    }
}

struct GlassTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(
                Group {
                    if isSelected {
                        Capsule().fill(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                    } else {
                        Capsule().fill(.white.opacity(0.05))
                    }
                }
            )
        }
        .buttonStyle(MinimalButtonStyle())
    }
}

struct MatchGlassCard: View {
    let user: DiscoverUser
    var showDistance: Bool = false
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            RoundedRectangle(cornerRadius: 12).fill(Color(white: 0.12))
                        }
                    }
                    .frame(width: 90, height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Text(showDistance ? "\(String(format: "%.0f", user.distanceKm ?? 0))km" : "%\(Int(user.score))")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(LinearGradient(colors: showDistance ? [.blue, .cyan] : [.purple, .pink], startPoint: .leading, endPoint: .trailing)))
                        .offset(x: -6, y: 6)
                }
                
                VStack(spacing: 2) {
                    Text(user.displayName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Text("\(user.age), \(user.city)")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(1)
                }
            }
            .frame(width: 90)
            .padding(8)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(MinimalButtonStyle())
    }
}

// MARK: - Activity Glass Section

struct ActivityGlassSection: View {
    let onMissionsTap: () -> Void
    let onPersonalityTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            ActivityGlassCard(
                icon: "target",
                title: "Görevler",
                subtitle: "1/3",
                colors: [.orange, .yellow],
                action: onMissionsTap
            )
            
            ActivityGlassCard(
                icon: "brain.head.profile",
                title: "Kişilik",
                subtitle: "Test",
                colors: [.purple, .pink],
                action: onPersonalityTap
            )
        }
    }
}

struct ActivityGlassCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let colors: [Color]
    let action: () -> Void
    
    private let cardShape = RoundedRectangle(cornerRadius: 22)
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 46, height: 46)
                    
                    Image(systemName: icon)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(colors.first ?? .white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.regularMaterial, in: cardShape)
            .glassEffect(.regular.interactive(), in: cardShape)
            .shadow(color: colors.first?.opacity(0.2) ?? .clear, radius: 10, y: 4)
        }
        .buttonStyle(MinimalButtonStyle())
    }
}

// MARK: - Premium Upgrade Sheet

struct PremiumUpgradeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [.yellow.opacity(0.4), .clear],
                                        center: .center,
                                        startRadius: 20,
                                        endRadius: 60
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "crown.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                        }
                        
                        Text("VibeU Premium")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("Seni beğenenleri gör, sınırsız beğen ve daha fazlası")
                            .font(.system(size: 15))
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    
                    // Tab Selector
                    HStack(spacing: 0) {
                        PremiumTabButton(title: "Premium", isSelected: selectedTab == 0) {
                            withAnimation { selectedTab = 0 }
                        }
                        PremiumTabButton(title: "Boost", isSelected: selectedTab == 1) {
                            withAnimation { selectedTab = 1 }
                        }
                    }
                    .padding(4)
                    .background(Capsule().fill(.white.opacity(0.1)))
                    .padding(.horizontal, 40)
                    
                    if selectedTab == 0 {
                        // Premium Paketleri
                        VStack(spacing: 16) {
                            PremiumTimePackageCard(
                                duration: "1 Yıl",
                                price: "₺1.499",
                                monthlyPrice: "₺125/ay",
                                savings: "%60 Tasarruf",
                                features: ["Sınırsız beğeni", "Seni beğenenleri gör", "50 Boost", "Öncelikli görünüm", "Reklamsız deneyim", "Geri alma"],
                                colors: [.purple, .pink],
                                isPopular: true
                            )
                            
                            PremiumTimePackageCard(
                                duration: "1 Ay",
                                price: "₺249",
                                monthlyPrice: nil,
                                savings: nil,
                                features: ["Sınırsız beğeni", "Seni beğenenleri gör", "10 Boost", "Öncelikli görünüm"],
                                colors: [.yellow, .orange],
                                isPopular: false
                            )
                            
                            PremiumTimePackageCard(
                                duration: "1 Hafta",
                                price: "₺99",
                                monthlyPrice: nil,
                                savings: nil,
                                features: ["Sınırsız beğeni", "Seni beğenenleri gör", "3 Boost"],
                                colors: [.cyan, .blue],
                                isPopular: false
                            )
                        }
                        .padding(.horizontal, 20)
                    } else {
                        // Boost Paketleri
                        VStack(spacing: 20) {
                            // Mevcut Boost
                            HStack {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.orange)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Mevcut Boost")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.white.opacity(0.6))
                                    Text("\(appState.boostCount)")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                                
                                Spacer()
                                
                                Text("5 Boost = Öne Çık")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.orange)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(.orange.opacity(0.2)))
                            }
                            .padding(16)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            
                            // Boost Paketleri
                            VStack(spacing: 12) {
                                BoostPackageCard(
                                    boostCount: 30,
                                    price: "₺199",
                                    perBoost: "₺6.6/boost",
                                    isPopular: true
                                ) {
                                    appState.addBoosts(30)
                                    dismiss()
                                }
                                
                                BoostPackageCard(
                                    boostCount: 15,
                                    price: "₺119",
                                    perBoost: "₺7.9/boost",
                                    isPopular: false
                                ) {
                                    appState.addBoosts(15)
                                    dismiss()
                                }
                                
                                BoostPackageCard(
                                    boostCount: 5,
                                    price: "₺49",
                                    perBoost: "₺9.8/boost",
                                    isPopular: false
                                ) {
                                    appState.addBoosts(5)
                                    dismiss()
                                }
                            }
                            
                            // Boost Açıklaması
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Boost Nasıl Çalışır?")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                                
                                BoostInfoRow(icon: "bolt.fill", text: "5 Boost harcayarak profilini öne çıkar")
                                BoostInfoRow(icon: "eye.fill", text: "30 dakika boyunca 10x daha fazla görünürlük")
                                BoostInfoRow(icon: "heart.fill", text: "Daha fazla eşleşme şansı yakala")
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Color.clear.frame(height: 40)
                }
            }
            .background(Color(red: 0.04, green: 0.02, blue: 0.08).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
        }
    }
}

// MARK: - Premium Tab Button
struct PremiumTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isSelected ? .black : .white.opacity(0.6))
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(isSelected ? Capsule().fill(.white) : nil)
        }
    }
}

// MARK: - Premium Time Package Card
struct PremiumTimePackageCard: View {
    let duration: String
    let price: String
    let monthlyPrice: String?
    let savings: String?
    let features: [String]
    let colors: [Color]
    let isPopular: Bool
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(duration)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                        
                        if isPopular {
                            Text("EN İYİ")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)))
                        }
                    }
                    
                    if let savings = savings {
                        Text(savings)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.green)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(price)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                    
                    if let monthlyPrice = monthlyPrice {
                        Text(monthlyPrice)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
            
            // Features
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(features, id: \.self) { feature in
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(colors[0])
                        Text(feature)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.8))
                        Spacer()
                    }
                }
            }
            
            // Buy Button
            Button {
                appState.purchasePremium()
                dismiss()
            } label: {
                Text("Satın Al")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(LinearGradient(colors: colors.map { $0.opacity(isPopular ? 0.6 : 0.3) }, startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: isPopular ? 2 : 1)
        )
    }
}

// MARK: - Boost Package Card
struct BoostPackageCard: View {
    let boostCount: Int
    let price: String
    let perBoost: String
    let isPopular: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Boost Icon
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("\(boostCount) Boost")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                        
                        if isPopular {
                            Text("POPÜLER")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(.orange))
                        }
                    }
                    
                    Text(perBoost)
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.5))
                }
                
                Spacer()
                
                // Price
                Text(price)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.orange)
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isPopular ? Color.orange.opacity(0.5) : Color.white.opacity(0.1), lineWidth: isPopular ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Boost Info Row
struct BoostInfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.orange)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}



// MARK: - Explore View (Eski Discover componentleri buraya taşındı)

struct ExploreView: View {
    @State private var selectedUser: DiscoverUser?
    @State private var showPremiumSheet = false
    @State private var searchText = ""
    
    @Environment(AppState.self) private var appState
    
    private let users = DiscoverUser.mockUsers
    private let newUsers = DiscoverUser.newUsers
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                PremiumBackground()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 28) {
                        
                        // Search Bar
                        ExploreSearchBar(text: $searchText)
                            .padding(.horizontal, 16)
                        
                        // Stories / Online Users
                        ExploreStoriesSection(users: users.filter { $0.isBoosted }) { user in
                            selectedUser = user
                        }
                        
                        // Yakınındakiler Section
                        ExploreSectionView(
                            title: "Yakınındakiler",
                            icon: "location.fill",
                            users: users.sorted { ($0.distanceKm ?? 999) < ($1.distanceKm ?? 999) }.prefix(6).map { $0 }
                        ) { user in
                            selectedUser = user
                        }
                        
                        // Yeni Üyeler Section
                        ExploreSectionView(
                            title: "Yeni Üyeler",
                            icon: "sparkle",
                            users: Array(newUsers.prefix(6))
                        ) { user in
                            selectedUser = user
                        }
                        
                        // Popüler Section
                        ExploreSectionView(
                            title: "Popüler",
                            icon: "flame.fill",
                            users: users.sorted { $0.score > $1.score }.prefix(6).map { $0 }
                        ) { user in
                            selectedUser = user
                        }
                        
                        Color.clear.frame(height: 100)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Keşfet")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color(red: 0.04, green: 0.02, blue: 0.08), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(item: $selectedUser) { user in
                ProfileDetailView(user: user)
            }
            .sheet(isPresented: $showPremiumSheet) {
                SubscriptionSheet()
            }
        }
    }
}

// MARK: - Explore Search Bar
struct ExploreSearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.4))
            
            TextField("Ara...", text: $text)
                .font(.system(size: 16))
                .foregroundStyle(.white)
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Explore Stories Section
struct ExploreStoriesSection: View {
    let users: [DiscoverUser]
    let onUserTap: (DiscoverUser) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(users) { user in
                    Button {
                        onUserTap(user)
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                // Gradient ring
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [.pink, .purple, .orange],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                                    .frame(width: 72, height: 72)
                                
                                AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    default:
                                        Circle()
                                            .fill(Color(white: 0.15))
                                    }
                                }
                                .frame(width: 64, height: 64)
                                .clipShape(Circle())
                                
                                // Online indicator
                                Circle()
                                    .fill(.green)
                                    .frame(width: 14, height: 14)
                                    .overlay(
                                        Circle()
                                            .stroke(Color(red: 0.04, green: 0.02, blue: 0.08), lineWidth: 2)
                                    )
                                    .offset(x: 24, y: 24)
                            }
                            
                            Text(user.displayName.split(separator: " ").first.map(String.init) ?? user.displayName)
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.8))
                                .lineLimit(1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Explore Section View
struct ExploreSectionView: View {
    let title: String
    let icon: String
    let users: [DiscoverUser]
    let onUserTap: (DiscoverUser) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(.pink)
                
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // Users Grid
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(users) { user in
                        ExploreUserCardNew(user: user) {
                            onUserTap(user)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Explore User Card (New Design)
struct ExploreUserCardNew: View {
    let user: DiscoverUser
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                // Photo
                AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Rectangle()
                            .fill(Color(white: 0.15))
                    }
                }
                .frame(width: 150, height: 200)
                .clipped()
                
                // Gradient
                LinearGradient(
                    colors: [.clear, .black.opacity(0.8)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(user.displayName)
                            .font(.system(size: 15, weight: .bold))
                        Text("\(user.age)")
                            .font(.system(size: 14))
                    }
                    .foregroundStyle(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text("\(String(format: "%.0f", user.distanceKm ?? 0)) km")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
            }
            .frame(width: 150, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Profile Summary Sheet
struct ProfileSummarySheet: View {
    let user: DiscoverUser
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var isRequestSent = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profil Fotoğrafı
                    AsyncImage(url: URL(string: user.profilePhotoURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 3))
                    
                    // İsim ve Şehir
                    VStack(spacing: 8) {
                        Text("\(user.displayName), \(user.age)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 14))
                            Text(user.city)
                                .font(.system(size: 16))
                        }
                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6))
                    }
                    
                    // İlgi Alanları
                    if !user.tags.isEmpty {
                        HStack(spacing: 8) {
                            ForEach(user.tags.prefix(4), id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1)))
                            }
                        }
                    }
                    
                    // Sosyal Medya Hesapları (Kilitli)
                    VStack(spacing: 16) {
                        Text("Sosyal Medya Hesapları")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                        
                        HStack(spacing: 20) {
                            LockedSocialIcon(platform: "instagram", hasAccount: user.instagramUsername != nil)
                            LockedSocialIcon(platform: "tiktok", hasAccount: user.tiktokUsername != nil)
                            LockedSocialIcon(platform: "snapchat", hasAccount: user.snapchatUsername != nil)
                        }
                        
                        Text("Arkadaş olunca sosyal medya hesaplarını görebilirsin")
                            .font(.system(size: 13))
                            .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 20)
                    
                    // Arkadaşlık İsteği Gönder Butonu
                    Button {
                        sendFriendRequest()
                    } label: {
                        HStack(spacing: 10) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: isRequestSent ? "checkmark.circle.fill" : "person.badge.plus")
                                    .font(.system(size: 20, weight: .semibold))
                            }
                            Text(isRequestSent ? "İstek Gönderildi" : "Arkadaşlık İsteği Gönder")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(isRequestSent ? 
                                      LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .leading, endPoint: .trailing) :
                                      LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
                                )
                        )
                    }
                    .disabled(isLoading || isRequestSent)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .padding(.top, 20)
            }
            .background((colorScheme == .dark ? Color(red: 0.04, green: 0.02, blue: 0.08) : Color(UIColor.systemBackground)).ignoresSafeArea())
            .navigationTitle("Profil Özeti")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6))
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func sendFriendRequest() {
        isLoading = true
        
        Task {
            do {
                _ = try await SocialService.shared.sendRequest(toUserId: user.id)
                await MainActor.run {
                    isLoading = false
                    isRequestSent = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Locked Social Icon
struct LockedSocialIcon: View {
    let platform: String
    let hasAccount: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    private var imageName: String {
        switch platform {
        case "instagram": return "InstagramIcon"
        case "tiktok": return "TikTokIcon"
        case "snapchat": return "SnapchatIcon"
        default: return ""
        }
    }
    
    var body: some View {
        ZStack {
            if !imageName.isEmpty {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .grayscale(hasAccount ? 0 : 1.0) // Hesabı yoksa gri yap
                    .opacity(hasAccount ? 1.0 : 0.5)
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 48, height: 48)
            }
            
            // Kilit ikonu ve overlay
            if hasAccount {
                // Kilit ikonu
                Image(systemName: "lock.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(5)
                    .background(Circle().fill(Color.black.opacity(0.6)))
                    .offset(x: 18, y: 18)
            }
        }
    }
}

// MARK: - Card Locked Social Icon (Smaller version for card)
struct CardLockedSocialIcon: View {
    let platform: String
    
    private var imageName: String {
        switch platform {
        case "instagram": return "InstagramIcon"
        case "tiktok": return "TikTokIcon"
        case "snapchat": return "SnapchatIcon"
        default: return ""
        }
    }
    
    var body: some View {
        ZStack {
            if !imageName.isEmpty {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
            
            // Küçük kilit ikonu
            Image(systemName: "lock.fill")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.white)
                .padding(3)
                .background(Circle().fill(Color.black.opacity(0.6)))
                .offset(x: 10, y: 10)
        }
    }
}


