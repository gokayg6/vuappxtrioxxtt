import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Storage Keys
struct ProfileKeys {
    static let displayName = "user_displayName"
    static let bio = "user_bio"
    static let city = "user_city"
    static let jobTitle = "user_jobTitle"
    static let interests = "user_interests"
    static let instagram = "user_instagram"
    static let tiktok = "user_tiktok"
    static let snapchat = "user_snapchat"
    static let photos = "user_photos"
    static let superLikes = "user_superLikes"
    static let boosts = "user_boosts"
    static let isPremium = "user_isPremium"
    // New comprehensive fields
    static let university = "user_university"
    static let department = "user_department"
    static let company = "user_company"
    static let height = "user_height"
    static let zodiac = "user_zodiac"
    static let smoking = "user_smoking"
    static let drinking = "user_drinking"
    static let exercise = "user_exercise"
    static let pets = "user_pets"
    static let lookingFor = "user_lookingFor"
    static let wantKids = "user_wantKids"
    static let hobbies = "user_hobbies"
}

// MARK: - Edit Profile View (Premium iOS Design)
struct EditProfileView: View {
    // Basic Info
    @State private var displayName = ""
    @State private var username = ""
    @State private var bio = ""
    
    // Location & Career
    @State private var city = ""
    @State private var university = ""
    @State private var department = ""
    @State private var jobTitle = ""
    @State private var company = ""
    
    // Physical
    @State private var height = ""
    @State private var zodiac = ""
    
    // Lifestyle
    @State private var smoking = "Hiç"
    @State private var drinking = "Hiç"
    @State private var exercise = "Bazen"
    @State private var pets = "Yok"
    
    // Relationship
    @State private var lookingFor = "Belirsiz"
    @State private var wantKids = "Belki"
    
    // Hobbies
    @State private var selectedHobbies: Set<String> = []
    
    // Social media state removed - managed by SocialLinksEditView
    
    // UI State
    @State private var showSavedAlert = false
    @State private var savedPhoto: UIImage?
    @State private var showPhotoPicker = false
    @State private var photoItem: PhotosPickerItem?
    
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    
    private var ringGradient: LinearGradient {
        LinearGradient(
            colors: isDark ? [Color(white: 0.85), Color(white: 0.55), Color(white: 0.75)] : [Color(white: 0.4), Color(white: 0.6), Color(white: 0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Options
    private let frequencyOptions = ["Hiç", "Bazen", "Sık"]
    private let petOptions = ["Yok", "Var", "İstiyorum"]
    private let lookingForOptions = ["Ciddi İlişki", "Arkadaşlık", "Belirsiz"]
    private let kidsOptions = ["Evet", "Hayır", "Belki"]
    private let zodiacSigns = ["Koç", "Boğa", "İkizler", "Yengeç", "Aslan", "Başak", "Terazi", "Akrep", "Yay", "Oğlak", "Kova", "Balık"]
    
    private let hobbies: [(String, String)] = [
        ("🎵", "Müzik"), ("⚽", "Futbol"), ("🏀", "Basketbol"), ("🎮", "Oyun"),
        ("📚", "Okumak"), ("✈️", "Seyahat"), ("📷", "Fotoğraf"), ("🎬", "Film"),
        ("💃", "Dans"), ("🎨", "Sanat"), ("💻", "Teknoloji"), ("🍳", "Yemek"),
        ("☕", "Kahve"), ("🧘", "Yoga"), ("🏃", "Koşu"), ("🚴", "Bisiklet"),
        ("🎸", "Gitar"), ("🎤", "Şarkı"), ("🐾", "Hayvanlar"), ("🌱", "Doğa"),
        ("🎭", "Tiyatro"), ("📺", "Dizi"), ("🎌", "Anime"), ("🎹", "Piyano")
    ]
    
    var body: some View {
        ZStack {
            colors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Profile Photo Header
                    profilePhotoHeader
                    
                    // Basic Info Section
                    basicInfoSection
                    
                    // Location & Career Section
                    locationCareerSection
                    
                    // Physical Section
                    physicalSection
                    
                    // Lifestyle Section
                    lifestyleSection
                    
                    // Relationship Section
                    relationshipSection
                    
                    // Hobbies Section
                    hobbiesSection
                    
                    // Social Media Section
                    socialMediaSection
                    
                    Color.clear.frame(height: 120)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .navigationTitle("Profili Düzenle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Kaydet") { saveProfile() }
                    .fontWeight(.bold)
                    .foregroundStyle(.cyan)
            }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoItem, matching: .images)
        .onChange(of: photoItem) { _, item in
            Task { await loadPhoto(item) }
        }
        .onAppear { loadProfile() }
        .alert("Kaydedildi ✓", isPresented: $showSavedAlert) {
            Button("Tamam") { dismiss() }
        }
    }
    
    private func loadProfile() {
        let user = appState.currentUser
        
        // Load from appState.currentUser first, then UserDefaults fallback
        displayName = user?.displayName ?? UserDefaults.standard.string(forKey: ProfileKeys.displayName) ?? ""
        bio = user?.bio ?? UserDefaults.standard.string(forKey: ProfileKeys.bio) ?? ""
        city = user?.city ?? UserDefaults.standard.string(forKey: ProfileKeys.city) ?? ""
        username = user?.username ?? ""
        
        // Extended fields - appState first, UserDefaults fallback
        jobTitle = user?.jobTitle ?? UserDefaults.standard.string(forKey: ProfileKeys.jobTitle) ?? ""
        university = user?.university ?? UserDefaults.standard.string(forKey: ProfileKeys.university) ?? ""
        department = user?.department ?? UserDefaults.standard.string(forKey: ProfileKeys.department) ?? ""
        company = user?.company ?? UserDefaults.standard.string(forKey: ProfileKeys.company) ?? ""
        height = user?.height ?? UserDefaults.standard.string(forKey: ProfileKeys.height) ?? ""
        zodiac = user?.zodiac ?? UserDefaults.standard.string(forKey: ProfileKeys.zodiac) ?? ""
        smoking = user?.smoking ?? UserDefaults.standard.string(forKey: ProfileKeys.smoking) ?? "Hiç"
        drinking = user?.drinking ?? UserDefaults.standard.string(forKey: ProfileKeys.drinking) ?? "Hiç"
        exercise = user?.exercise ?? UserDefaults.standard.string(forKey: ProfileKeys.exercise) ?? "Bazen"
        pets = user?.pets ?? UserDefaults.standard.string(forKey: ProfileKeys.pets) ?? "Yok"
        lookingFor = user?.lookingFor ?? UserDefaults.standard.string(forKey: ProfileKeys.lookingFor) ?? "Belirsiz"
        wantKids = user?.wantKids ?? UserDefaults.standard.string(forKey: ProfileKeys.wantKids) ?? "Belki"
        
        // Hobbies
        if let hobbies = user?.hobbies, !hobbies.isEmpty {
            selectedHobbies = Set(hobbies)
        } else if let hobbies = UserDefaults.standard.array(forKey: ProfileKeys.hobbies) as? [String] {
            selectedHobbies = Set(hobbies)
        }
        
        // Social Links managed by SocialLinksEditView
        
        // Load photo from URL if savedPhoto is nil
        if savedPhoto == nil, let profileURL = user?.profilePhotoURL, !profileURL.contains("dicebear"), let url = URL(string: profileURL) {
            Task {
                if let data = try? await URLSession.shared.data(from: url).0,
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        self.savedPhoto = image
                    }
                }
            }
        }
        
        Task { await LogService.shared.info("Profil yüklendi", category: "Profile") }
    }
    
    private func saveProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Save to UserDefaults for local cache
        UserDefaults.standard.set(displayName, forKey: ProfileKeys.displayName)
        UserDefaults.standard.set(bio, forKey: ProfileKeys.bio)
        UserDefaults.standard.set(city, forKey: ProfileKeys.city)
        UserDefaults.standard.set(jobTitle, forKey: ProfileKeys.jobTitle)
        UserDefaults.standard.set(university, forKey: ProfileKeys.university)
        UserDefaults.standard.set(department, forKey: ProfileKeys.department)
        UserDefaults.standard.set(company, forKey: ProfileKeys.company)
        UserDefaults.standard.set(height, forKey: ProfileKeys.height)
        UserDefaults.standard.set(zodiac, forKey: ProfileKeys.zodiac)
        UserDefaults.standard.set(smoking, forKey: ProfileKeys.smoking)
        UserDefaults.standard.set(drinking, forKey: ProfileKeys.drinking)
        UserDefaults.standard.set(exercise, forKey: ProfileKeys.exercise)
        UserDefaults.standard.set(pets, forKey: ProfileKeys.pets)
        UserDefaults.standard.set(lookingFor, forKey: ProfileKeys.lookingFor)
        UserDefaults.standard.set(wantKids, forKey: ProfileKeys.wantKids)
        UserDefaults.standard.set(Array(selectedHobbies), forKey: ProfileKeys.hobbies)
        // Social links saved by SocialLinksEditView
        UserDefaults.standard.synchronize()
        
        let data: [String: Any] = [
            "display_name": displayName,
            "bio": bio,
            "city": city,
            "job_title": jobTitle,
            "university": university,
            "department": department,
            "company": company,
            "height": height,
            "zodiac": zodiac,
            "smoking": smoking,
            "drinking": drinking,
            "exercise": exercise,
            "pets": pets,
            "looking_for": lookingFor,
            "want_kids": wantKids,
            "hobbies": Array(selectedHobbies)
            // social_links managed separately
        ]
        
        Task {
            do {
                try await UserService.shared.updateUserFields(uid: uid, data: data)
                
                // Update ALL fields in appState immediately
                await MainActor.run {
                    appState.currentUser?.displayName = displayName
                    appState.currentUser?.bio = bio
                    appState.currentUser?.city = city
                    appState.currentUser?.jobTitle = jobTitle
                    appState.currentUser?.university = university
                    appState.currentUser?.department = department
                    appState.currentUser?.company = company
                    appState.currentUser?.height = height
                    appState.currentUser?.zodiac = zodiac
                    appState.currentUser?.smoking = smoking
                    appState.currentUser?.drinking = drinking
                    appState.currentUser?.exercise = exercise
                    appState.currentUser?.pets = pets
                    appState.currentUser?.lookingFor = lookingFor
                    appState.currentUser?.wantKids = wantKids
                    appState.currentUser?.hobbies = Array(selectedHobbies)
                    
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    showSavedAlert = true
                }
                
                await LogService.shared.info("Profil güncellendi (Firebase + UserDefaults)", category: "Profile")
            } catch {
                print("Error saving profile: \(error)")
                // Still show success for local save
                await MainActor.run { showSavedAlert = true }
            }
        }
    }
    
    private func loadPhoto(_ item: PhotosPickerItem?) async {
        guard let item = item,
              let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data),
              let userId = Auth.auth().currentUser?.uid else { return }
        
        await MainActor.run {
            savedPhoto = image
        }
        
        // Upload to Firebase
        do {
            let photoModel = try await PhotoUploadService.shared.uploadPhoto(
                image: image,
                userId: userId,
                orderIndex: 0 // Primary photo
            )
            
            // Update appState.currentUser with new photo URL
            await MainActor.run {
                appState.currentUser?.profilePhotoURL = photoModel.url
                
                // Also update photos array
                let newUserPhoto = UserPhoto(
                    id: photoModel.id,
                    url: photoModel.url,
                    thumbnailURL: photoModel.url,
                    orderIndex: photoModel.orderIndex,
                    isPrimary: photoModel.isPrimary
                )
                
                // Replace first photo or insert at beginning
                if appState.currentUser?.photos.isEmpty == true {
                    appState.currentUser?.photos = [newUserPhoto]
                } else {
                    appState.currentUser?.photos.insert(newUserPhoto, at: 0)
                }
            }
            
            await LogService.shared.info("Profil fotoğrafı güncellendi", category: "Profile")
        } catch {
            print("Profile photo upload failed: \(error)")
        }
    }
    
    // MARK: - Profile Photo Header (ProfileHeaderCard Style)
    private var profilePhotoHeader: some View {
        VStack(spacing: 16) {
            Button { showPhotoPicker = true } label: {
                ZStack {
                    // Subtle white glow
                    Circle()
                        .fill(RadialGradient(colors: [(isDark ? Color.white : colors.accent).opacity(0.15), Color.clear], center: .center, startRadius: 40, endRadius: 80))
                        .frame(width: 140, height: 140)
                        .blur(radius: 12)
                    
                    // Elegant silver ring
                    Circle()
                        .stroke(ringGradient, lineWidth: 3)
                        .frame(width: 120, height: 120)
                    
                    // Photo
                    Group {
                        if let photo = savedPhoto {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Circle()
                                .fill(LinearGradient(colors: [colors.secondaryBackground, colors.cardBackground], startPoint: .top, endPoint: .bottom))
                                .overlay {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 44))
                                        .foregroundStyle(colors.tertiaryText)
                                }
                        }
                    }
                    .frame(width: 106, height: 106)
                    .clipShape(Circle())
                    
                    // Camera badge
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 36, height: 36)
                            .shadow(color: .cyan.opacity(0.5), radius: 6, x: 0, y: 2)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .offset(x: 42, y: 42)
                }
            }
            
            Text("Fotoğrafı Değiştir")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.cyan)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(spacing: 0) {
            ThemedEditSectionHeader(icon: "person.fill", title: "Temel Bilgiler", colors: colors)
            
            VStack(spacing: 0) {
                ThemedEditRow(icon: "person", title: "İsim", text: $displayName, colors: colors)
                ThemedEditDivider(colors: colors)
                ThemedEditRow(icon: "at", title: "Kullanıcı Adı", text: $username, colors: colors)
                ThemedEditDivider(colors: colors)
                ThemedEditRowMultiline(icon: "text.quote", title: "Hakkımda", text: $bio, colors: colors)
            }
            .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(colors.border, lineWidth: 1))
        }
    }
    
    // MARK: - Location & Career Section
    private var locationCareerSection: some View {
        VStack(spacing: 0) {
            ThemedEditSectionHeader(icon: "briefcase.fill", title: "Konum & Kariyer", colors: colors)
            
            VStack(spacing: 0) {
                ThemedEditRow(icon: "location", title: "Şehir", text: $city, colors: colors)
                ThemedEditDivider(colors: colors)
                ThemedEditRow(icon: "building.columns", title: "Üniversite", text: $university, colors: colors)
                ThemedEditDivider(colors: colors)
                ThemedEditRow(icon: "book", title: "Bölüm", text: $department, colors: colors)
                ThemedEditDivider(colors: colors)
                ThemedEditRow(icon: "briefcase", title: "Meslek", text: $jobTitle, colors: colors)
                ThemedEditDivider(colors: colors)
                ThemedEditRow(icon: "building.2", title: "Şirket", text: $company, colors: colors)
            }
            .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(colors.border, lineWidth: 1))
        }
    }
    
    // MARK: - Physical Section
    private var physicalSection: some View {
        VStack(spacing: 0) {
            ThemedEditSectionHeader(icon: "figure.stand", title: "Fiziksel Özellikler", colors: colors)
            
            VStack(spacing: 0) {
                ThemedEditRow(icon: "ruler", title: "Boy (cm)", text: $height, colors: colors)
                ThemedEditDivider(colors: colors)
                ThemedEditPickerRow(icon: "sparkles", title: "Burç", selection: $zodiac, options: zodiacSigns, colors: colors)
            }
            .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(colors.border, lineWidth: 1))
        }
    }
    
    // MARK: - Lifestyle Section
    private var lifestyleSection: some View {
        VStack(spacing: 0) {
            ThemedEditSectionHeader(icon: "leaf.fill", title: "Yaşam Tarzı", colors: colors)
            
            VStack(spacing: 0) {
                ThemedEditPickerRow(icon: "smoke", title: "Sigara", selection: $smoking, options: frequencyOptions, colors: colors)
                ThemedEditDivider(colors: colors)
                ThemedEditPickerRow(icon: "wineglass", title: "Alkol", selection: $drinking, options: frequencyOptions, colors: colors)
                ThemedEditDivider(colors: colors)
                ThemedEditPickerRow(icon: "figure.run", title: "Egzersiz", selection: $exercise, options: frequencyOptions, colors: colors)
                ThemedEditDivider(colors: colors)
                ThemedEditPickerRow(icon: "pawprint", title: "Evcil Hayvan", selection: $pets, options: petOptions, colors: colors)
            }
            .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(colors.border, lineWidth: 1))
        }
    }
    
    // MARK: - Relationship Section
    private var relationshipSection: some View {
        VStack(spacing: 0) {
            ThemedEditSectionHeader(icon: "heart.fill", title: "İlişki Tercihleri", colors: colors)
            
            VStack(spacing: 0) {
                ThemedEditPickerRow(icon: "magnifyingglass", title: "Ne Arıyorum", selection: $lookingFor, options: lookingForOptions, colors: colors)
                ThemedEditDivider(colors: colors)
                ThemedEditPickerRow(icon: "figure.2.and.child.holdinghands", title: "Çocuk İstiyor musun", selection: $wantKids, options: kidsOptions, colors: colors)
            }
            .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(colors.border, lineWidth: 1))
        }
    }
    
    // MARK: - Hobbies Section
    private var hobbiesSection: some View {
        VStack(spacing: 0) {
            ThemedEditSectionHeader(icon: "star.fill", title: "Hobiler & İlgi Alanları", colors: colors)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("En fazla 8 hobi seç")
                    .font(.system(size: 13))
                    .foregroundStyle(colors.secondaryText)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                
                ThemedEditPillGrid(items: hobbies, selectedItems: $selectedHobbies, maxSelection: 8, colors: colors)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 16)
            }
            .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(colors.border, lineWidth: 1))
        }
    }
    
    // MARK: - Social Media Section
    private var socialMediaSection: some View {
        VStack(spacing: 0) {
            ThemedEditSectionHeader(icon: "link", title: "Sosyal Medya", colors: colors)
            
            NavigationLink {
                SocialLinksEditView()
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.purple.opacity(0.1), .blue.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "link")
                            .font(.system(size: 20))
                            .foregroundStyle(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sosyal Medya Hesapları")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(colors.primaryText)
                        
                        Text("Instagram, TikTok, Snapchat...")
                            .font(.system(size: 13))
                            .foregroundStyle(colors.secondaryText)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(colors.tertiaryText)
                }
                .padding(12)
                .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(colors.border, lineWidth: 1))
            }
        }
    }
}

// MARK: - Themed Edit Helper Components
private struct ThemedEditSectionHeader: View {
    let icon: String
    let title: String
    let colors: ThemeColors
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.cyan)
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(colors.secondaryText)
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 10)
    }
}

private struct ThemedEditRow: View {
    let icon: String
    let title: String
    @Binding var text: String
    let colors: ThemeColors
    
    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 8)
                .fill(colors.secondaryBackground)
                .frame(width: 36, height: 36)
                .overlay(Image(systemName: icon).font(.system(size: 15)).foregroundStyle(colors.secondaryText))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundStyle(colors.tertiaryText)
                TextField("", text: $text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(colors.primaryText)
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

private struct ThemedEditRowMultiline: View {
    let icon: String
    let title: String
    @Binding var text: String
    let colors: ThemeColors
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 8)
                .fill(colors.secondaryBackground)
                .frame(width: 36, height: 36)
                .overlay(Image(systemName: icon).font(.system(size: 15)).foregroundStyle(colors.secondaryText))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundStyle(colors.tertiaryText)
                TextField("", text: $text, axis: .vertical)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(colors.primaryText)
                    .lineLimit(3...6)
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

private struct ThemedEditPickerRow: View {
    let icon: String
    let title: String
    @Binding var selection: String
    let options: [String]
    let colors: ThemeColors
    
    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 8)
                .fill(colors.secondaryBackground)
                .frame(width: 36, height: 36)
                .overlay(Image(systemName: icon).font(.system(size: 15)).foregroundStyle(colors.secondaryText))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundStyle(colors.tertiaryText)
                
                Menu {
                    ForEach(options, id: \.self) { option in
                        Button(option) { selection = option }
                    }
                } label: {
                    HStack {
                        Text(selection.isEmpty ? "Seç" : selection)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(selection.isEmpty ? colors.tertiaryText : colors.primaryText)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(colors.tertiaryText)
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

private struct ThemedEditPillGrid: View {
    let items: [(String, String)]
    @Binding var selectedItems: Set<String>
    let maxSelection: Int
    let colors: ThemeColors
    
    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 8)]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(items, id: \.1) { emoji, name in
                let isSelected = selectedItems.contains(name)
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        if isSelected {
                            selectedItems.remove(name)
                        } else if selectedItems.count < maxSelection {
                            selectedItems.insert(name)
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(emoji)
                            .font(.system(size: 16))
                        Text(name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(isSelected ? colors.primaryText : colors.secondaryText)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.cyan.opacity(0.25) : colors.secondaryBackground)
                            .overlay(Capsule().stroke(isSelected ? Color.cyan : colors.border, lineWidth: 1))
                    )
                }
            }
        }
    }
}

private struct ThemedEditSocialRow: View {
    let platform: String
    let icon: String
    @Binding var username: String
    let gradient: [Color]
    let colors: ThemeColors
    
    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 40, height: 40)
                .overlay(Image(systemName: icon).font(.system(size: 16, weight: .semibold)).foregroundStyle(.white))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(platform)
                    .font(.system(size: 12))
                    .foregroundStyle(colors.tertiaryText)
                TextField("@kullanici_adi", text: $username)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(colors.primaryText)
                    .autocapitalization(.none)
            }
            
            Spacer()
            
            if !username.isEmpty {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.green)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

private struct ThemedEditDivider: View {
    let colors: ThemeColors
    
    var body: some View {
        Rectangle()
            .fill(colors.border)
            .frame(height: 0.5)
            .padding(.leading, 64)
    }
}

// MARK: - Photos Edit View (PREMIUM DESIGN with Drag & Drop)
// Requirements: 3.4, 3.5, 3.6 - Drag & drop sıralama, son fotoğraf silinmesini engelle, ana fotoğraf seçimi
struct PhotosEditView: View {
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var loadedImages: [UIImage] = []
    @State private var showPicker = false
    @State private var showSavedAlert = false
    @State private var showDeleteError = false
    @State private var primaryPhotoIndex: Int = 0
    @State private var draggingItem: Int?
    @State private var photoModels: [PhotoModel] = [] // Track remote models
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
    
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    
    // Min 1, Max 5 photos (Requirements: 2.1, 3.1)
    private let minPhotos = 1
    private let maxPhotos = 5
    
    var body: some View {
        ZStack {
            colors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.cyan.opacity(0.2), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "photo.stack.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom))
                        }
                        
                        Text("Fotoğrafların")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        
                        Text("En az 1, en fazla \(maxPhotos) fotoğraf ekleyebilirsin")
                            .font(.system(size: 15))
                            .foregroundStyle(colors.secondaryText)
                    }
                    .padding(.top, 20)
                    
                    // Photo Count Badge
                    HStack(spacing: 8) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.cyan)
                        Text("\(loadedImages.count)/\(maxPhotos) fotoğraf")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(colors.primaryText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(colors.secondaryBackground, in: Capsule())
                    
                    // Drag & Drop Tip
                    HStack(spacing: 10) {
                        Image(systemName: "hand.draw.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.cyan)
                        Text("Sıralamak için basılı tut ve sürükle")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(colors.secondaryText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.cyan.opacity(0.1), in: Capsule())
                    
                    // Premium Photo Grid with Drag & Drop
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(0..<maxPhotos, id: \.self) { index in
                            DraggablePhotoSlot(
                                image: index < loadedImages.count ? loadedImages[index] : nil,
                                index: index,
                                isPrimary: index == primaryPhotoIndex,
                                isOnlyPhoto: loadedImages.count == minPhotos,
                                draggingItem: $draggingItem,
                                colors: colors,
                                onAdd: { showPicker = true },
                                onDelete: { deletePhoto(at: index) },
                                onSetPrimary: { setPrimaryPhoto(at: index) },
                                onDrop: { fromIndex in movePhoto(from: fromIndex, to: index) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Primary Photo Tip
                    HStack(spacing: 10) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.yellow)
                        Text("İlk fotoğraf profil fotoğrafın olacak")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(colors.secondaryText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.yellow.opacity(0.1), in: Capsule())
                    
                    Color.clear.frame(height: 100)
                }
            }
        }
        .navigationTitle("Fotoğraflar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
        .photosPicker(isPresented: $showPicker, selection: $photoItems, maxSelectionCount: maxPhotos - loadedImages.count, matching: .images)
        .onChange(of: photoItems) { _, items in
            Task { await loadSelectedPhotos(items) }
        }
        .onAppear { loadSavedPhotos() }
        .alert("Kaydedildi ✓", isPresented: $showSavedAlert) {
            Button("Tamam") { }
        } message: {
            Text("\(loadedImages.count) fotoğraf kaydedildi.")
        }
        .alert("Silinemez", isPresented: $showDeleteError) {
            Button("Tamam") { }
        } message: {
            Text("En az 1 fotoğrafın olmalı. Son fotoğrafı silemezsin.")
        }
    }
    
    private func loadSavedPhotos() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Task {
            print("PhotosEditView: loadSavedPhotos started (Main Doc Source)")
            
            // 1. Get photos from appState (Main Document)
            let photos = await MainActor.run { 
                return appState.currentUser?.photos.map { 
                    PhotoModel(
                        id: $0.id, 
                        userId: userId, 
                        url: $0.url, 
                        thumbnailUrl: $0.thumbnailURL ?? $0.url, 
                        orderIndex: $0.orderIndex, 
                        isPrimary: $0.isPrimary, 
                        moderationStatus: "approved", 
                        createdAt: ""
                    )
                } ?? []
            }
            
            await MainActor.run {
                self.photoModels = photos
                self.loadedImages = []
            }
            
            // 2. Download from URLs in PARALLEL
            let downloadedImages = await withTaskGroup(of: (Int, UIImage?).self) { group in
                for (index, photo) in photos.enumerated() {
                    group.addTask {
                        guard let url = URL(string: photo.url) else { return (index, nil) }
                        do {
                            let (data, _) = try await URLSession.shared.data(from: url)
                            if let image = UIImage(data: data) {
                                return (index, image)
                            }
                        } catch {
                            print("Error downloading photo \(index): \(error)")
                        }
                        return (index, nil)
                    }
                }
                
                var results: [(Int, UIImage)] = []
                for await (index, image) in group {
                    if let img = image {
                        results.append((index, img))
                    }
                }
                return results.sorted { $0.0 < $1.0 }.map { $0.1 }
            }
            
            await MainActor.run {
                self.loadedImages = downloadedImages
                print("PhotosEditView: Parallel download complete. Loaded \(downloadedImages.count) images.")
            }
            
            await LogService.shared.info("PhotosEditView loaded \(photos.count) photos (Parallel)", category: "Profile")
        }
    }
    
    private func loadSelectedPhotos(_ items: [PhotosPickerItem]) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                
                // Show immediately (optimistic UI)
                await MainActor.run {
                    if loadedImages.count < maxPhotos {
                        withAnimation(.spring(response: 0.4)) {
                            loadedImages.append(image)
                        }
                    }
                }
                
                // Upload
                do {
                    // Current photo count including new one
                    let currentCount = photoModels.count
                    let photoModel = try await PhotoUploadService.shared.uploadPhoto(
                        image: image,
                        userId: userId,
                        orderIndex: currentCount
                    )
                    
                    await MainActor.run {
                        self.photoModels.append(photoModel)
                        
                        // SYNC APPSTATE (Single Source of Truth)
                        if var user = appState.currentUser {
                            let userPhoto = UserPhoto(
                                id: photoModel.id,
                                url: photoModel.url,
                                thumbnailURL: photoModel.thumbnailUrl,
                                orderIndex: photoModel.orderIndex,
                                isPrimary: photoModel.isPrimary
                            )
                            user.photos.append(userPhoto)
                            if photoModel.isPrimary {
                                user.profilePhotoURL = photoModel.url
                            }
                            appState.currentUser = user
                            print("PhotosEditView: Synced appState with new photo. Total: \(user.photos.count)")
                        }
                    }
                    
                } catch {
                    print("Upload failed: \(error)")
                    // Remove from UI if failed
                    await MainActor.run {
                         if let index = loadedImages.firstIndex(of: image) {
                             loadedImages.remove(at: index)
                         }
                         // Show error to user
                         self.showDeleteError = true // Reusing existing alert state or add new one?
                         // Existing alert is for "Can't delete last photo". Let's assume we can add a new one or print.
                         // Ideally, we should add a specific upload error state.
                         // But for now, let's just log it heavily.
                    }
                }
            }
        }
        photoItems = []
    }
    
    private func deletePhoto(at index: Int) {
        guard index < loadedImages.count else { return }
        
        // Requirements: 3.5 - Prevent deletion if it's the only remaining photo
        if loadedImages.count <= minPhotos {
            showDeleteError = true
            return
        }
        
        
        let removedModel = index < photoModels.count ? photoModels[index] : nil
        
        withAnimation(.spring(response: 0.3)) {
            loadedImages.remove(at: index)
            if index < photoModels.count {
                photoModels.remove(at: index)
            }
            
            // Adjust primary photo index if needed
            if primaryPhotoIndex >= loadedImages.count {
                primaryPhotoIndex = 0
            } else if index < primaryPhotoIndex {
                primaryPhotoIndex -= 1
            } else if index == primaryPhotoIndex {
                primaryPhotoIndex = 0
            }
        }
        
        // Delete from Firebase
        if let model = removedModel, let userId = Auth.auth().currentUser?.uid {
            Task {
                try? await ProfileService.shared.deletePhoto(userId: userId, photoId: model.id)
                
                await MainActor.run {
                    // SYNC APPSTATE (Single Source of Truth)
                    if var user = appState.currentUser {
                        user.photos.removeAll { $0.id == model.id }
                        if model.isPrimary {
                            // If we deleted the primary photo, update profile URL to new first photo or empty
                            user.profilePhotoURL = user.photos.first?.url ?? ""
                        }
                        appState.currentUser = user
                        print("PhotosEditView: Delete synced to appState. Remaining: \(user.photos.count)")
                    }
                }
            }
        }
        
        // Haptic
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    // Requirements: 3.6 - Set primary photo
    private func setPrimaryPhoto(at index: Int) {
        guard index < loadedImages.count else { return }
        
        withAnimation(.spring(response: 0.3)) {
            // Move the selected photo to the first position
            let photo = loadedImages.remove(at: index)
            loadedImages.insert(photo, at: 0)
            primaryPhotoIndex = 0
        }
        savePhotos()
        
        // Haptic
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    // Requirements: 3.4 - Drag & drop reordering
    private func movePhoto(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex,
              sourceIndex < loadedImages.count,
              destinationIndex < loadedImages.count else { return }
        
        withAnimation(.spring(response: 0.3)) {
            let photo = loadedImages.remove(at: sourceIndex)
            loadedImages.insert(photo, at: destinationIndex)
            
            // Update primary photo index
            if sourceIndex == primaryPhotoIndex {
                primaryPhotoIndex = destinationIndex
            } else if sourceIndex < primaryPhotoIndex && destinationIndex >= primaryPhotoIndex {
                primaryPhotoIndex -= 1
            } else if sourceIndex > primaryPhotoIndex && destinationIndex <= primaryPhotoIndex {
                primaryPhotoIndex += 1
            }
        }
        savePhotos()
        
        // Haptic
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    private func savePhotos() {
        // Sync order changes to Firestore
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Task {
            for (index, model) in photoModels.enumerated() {
                let isPrimary = index == primaryPhotoIndex
                try? await Firestore.firestore()
                    .collection("users").document(userId)
                    .collection("photos").document(model.id)
                    .updateData([
                        "orderIndex": index,
                        "isPrimary": isPrimary
                    ])
                
                // Update profile photo if this is primary
                if isPrimary {
                    try? await Firestore.firestore()
                        .collection("users").document(userId)
                        .updateData(["profile_photo_url": model.url])
                }
            }
        }
        
        Task { await LogService.shared.info("Fotoğraf sırası güncellendi (Firebase)", category: "Profile", metadata: ["count": "\(photoModels.count)", "primaryIndex": "\(primaryPhotoIndex)"]) }
        showSavedAlert = true
    }
}

// MARK: - Draggable Photo Slot (with Drag & Drop support)
struct DraggablePhotoSlot: View {
    let image: UIImage?
    let index: Int
    let isPrimary: Bool
    let isOnlyPhoto: Bool
    @Binding var draggingItem: Int?
    let colors: ThemeColors
    let onAdd: () -> Void
    let onDelete: () -> Void
    let onSetPrimary: () -> Void
    let onDrop: (Int) -> Void
    
    @State private var isPressed = false
    @State private var isDragOver = false
    
    var body: some View {
        ZStack {
            if let img = image {
                // Photo Card with Drag & Drop
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        // Gradient Overlay
                        LinearGradient(
                            colors: [.clear, .clear, .black.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    )
                    .overlay(alignment: .topTrailing) {
                        // Delete Button (disabled if only photo)
                        Button(action: onDelete) {
                            ZStack {
                                Circle()
                                    .fill(isOnlyPhoto ? Color.gray.opacity(0.6) : Color.black.opacity(0.6))
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: isOnlyPhoto ? "lock.fill" : "xmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .disabled(isOnlyPhoto)
                        .padding(10)
                    }
                    .overlay(alignment: .topLeading) {
                        // Set as Primary Button
                        if !isPrimary {
                            Button(action: onSetPrimary) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.6))
                                        .frame(width: 32, height: 32)
                                    
                                    Image(systemName: "star")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.yellow)
                                }
                            }
                            .padding(10)
                        }
                    }
                    .overlay(alignment: .bottomLeading) {
                        // Primary Badge
                        if isPrimary {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                Text("ANA")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .foregroundStyle(.black)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing),
                                in: Capsule()
                            )
                            .padding(10)
                        }
                    }
                    .overlay(
                        // Drag over indicator
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isDragOver ? Color.cyan : Color.clear, lineWidth: 3)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                    .opacity(draggingItem == index ? 0.5 : 1.0)
                    .scaleEffect(draggingItem == index ? 1.05 : 1.0)
                    .onDrag {
                        draggingItem = index
                        return NSItemProvider(object: String(index) as NSString)
                    }
                    .onDrop(of: [.text], isTargeted: $isDragOver) { providers in
                        guard let dragging = draggingItem else { return false }
                        onDrop(dragging)
                        draggingItem = nil
                        return true
                    }
            } else {
                // Empty Slot
                RoundedRectangle(cornerRadius: 16)
                    .fill(colors.secondaryBackground)
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                            .foregroundStyle(isDragOver ? Color.cyan : Color(white: 0.2))
                    )
                    .overlay {
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color(white: 0.12))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(Color(white: 0.4))
                            }
                            
                            Text("Ekle")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color(white: 0.4))
                        }
                    }
                    .onTapGesture(perform: onAdd)
                    .scaleEffect(isPressed ? 0.97 : 1.0)
                    .animation(.easeInOut(duration: 0.15), value: isPressed)
                    .onDrop(of: [.text], isTargeted: $isDragOver) { _ in
                        // Can't drop on empty slot
                        return false
                    }
            }
        }
    }
}

struct RealPhotoSlot: View {
    let image: UIImage?
    let isMain: Bool
    let onAdd: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        ZStack {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(alignment: .topTrailing) {
                        Button(action: onDelete) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .shadow(radius: 4)
                        }
                        .padding(8)
                    }
                    .overlay(alignment: .bottomLeading) {
                        if isMain {
                            Text("ANA")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.cyan, in: Capsule())
                                .padding(8)
                        }
                    }
            } else {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(white: 0.12))
                    .frame(height: 200)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(Color(white: 0.3))
                            Text("Ekle")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(white: 0.4))
                        }
                    }
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(white: 0.2), style: StrokeStyle(lineWidth: 2, dash: [8])))
                    .onTapGesture(perform: onAdd)
            }
        }
    }
}


// MARK: - Interests Edit View (BEAUTIFUL DESIGN)
struct InterestsEditView: View {
    @State private var selectedInterests: Set<String> = []
    @State private var selectedCategory = "Müzik"
    @State private var showSavedAlert = false
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
    
    private let categories = ["Müzik", "Spor", "Yemek", "Seyahat", "Film", "Hobiler", "Sanat", "Teknoloji"]
    
    private let allInterests: [String: [(String, String)]] = [
        "Müzik": [("🎵", "Pop"), ("🎸", "Rock"), ("🎤", "Hip Hop"), ("🎧", "Elektronik"), ("🎷", "Caz"), ("🎻", "Klasik"), ("🎶", "R&B"), ("🇹🇷", "Türkçe")],
        "Spor": [("⚽", "Futbol"), ("🏀", "Basketbol"), ("🎾", "Tenis"), ("🏊", "Yüzme"), ("💪", "Fitness"), ("🧘", "Yoga"), ("🏃", "Koşu"), ("🚴", "Bisiklet")],
        "Yemek": [("👨‍🍳", "Yemek"), ("☕", "Kahve"), ("🍷", "Şarap"), ("🍣", "Suşi"), ("🍕", "Pizza"), ("🥗", "Vegan"), ("🥙", "Kebap"), ("🍰", "Tatlı")],
        "Seyahat": [("🏖️", "Plaj"), ("🏔️", "Dağ"), ("🏙️", "Şehir"), ("⛺", "Kamp"), ("🚗", "Yolculuk"), ("🎒", "Backpack"), ("✈️", "Uçak"), ("🚢", "Cruise")],
        "Film": [("💥", "Aksiyon"), ("😂", "Komedi"), ("👻", "Korku"), ("💕", "Romantik"), ("🚀", "Bilim Kurgu"), ("📺", "Dizi"), ("🎌", "Anime"), ("🎬", "Belgesel")],
        "Hobiler": [("📚", "Okumak"), ("🎮", "Oyun"), ("📷", "Fotoğraf"), ("💃", "Dans"), ("🐾", "Hayvan"), ("✍️", "Yazmak"), ("🎨", "Çizim"), ("🎹", "Müzik")],
        "Sanat": [("🎨", "Resim"), ("🏛️", "Müze"), ("🎭", "Tiyatro"), ("🎤", "Konser"), ("👗", "Moda"), ("🗿", "Heykel"), ("📸", "Fotoğraf"), ("🎬", "Sinema")],
        "Teknoloji": [("💻", "Kodlama"), ("🤖", "AI"), ("₿", "Kripto"), ("🚀", "Startup"), ("📱", "Gadget"), ("📲", "Sosyal"), ("🎮", "Gaming"), ("🔬", "Bilim")]
    ]
    
    var body: some View {
        ZStack {
            colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with count
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("İlgi Alanlarını Seç")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        Text("En fazla 10 tane seçebilirsin")
                            .font(.system(size: 13))
                            .foregroundStyle(colors.secondaryText)
                    }
                    Spacer()
                    Text("\(selectedInterests.count)/10")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(selectedInterests.count >= 10 ? .orange : .cyan)
                }
                .padding(16)
                
                // Category Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories, id: \.self) { cat in
                            Button {
                                withAnimation(.spring(response: 0.3)) { selectedCategory = cat }
                            } label: {
                                Text(cat)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(selectedCategory == cat ? .black : colors.primaryText)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule()
                                            .fill(selectedCategory == cat ? Color.cyan : colors.secondaryBackground)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 20)
                
                // Interests Grid - Beautiful Cards
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(allInterests[selectedCategory] ?? [], id: \.1) { emoji, name in
                            let isSelected = selectedInterests.contains(name)
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    if isSelected {
                                        selectedInterests.remove(name)
                                    } else if selectedInterests.count < 10 {
                                        selectedInterests.insert(name)
                                    }
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    Text(emoji)
                                        .font(.system(size: 28))
                                    Text(name)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(isSelected ? .white : colors.secondaryText)
                                    Spacer()
                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.cyan)
                                    }
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(isSelected ? Color.cyan.opacity(0.8) : colors.cardBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(isSelected ? Color.cyan : colors.border, lineWidth: isSelected ? 2 : 1)
                                        )
                                )
                            }
                            .scaleEffect(isSelected ? 1.02 : 1.0)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationTitle("İlgi Alanları")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Kaydet") { saveInterests() }
                    .fontWeight(.bold)
                    .foregroundStyle(.cyan)
            }
        }
        .onAppear { loadInterests() }
        .alert("Kaydedildi ✓", isPresented: $showSavedAlert) {
            Button("Tamam") { dismiss() }
        } message: {
            Text("\(selectedInterests.count) ilgi alanı kaydedildi.")
        }
    }
    
    private func loadInterests() {
        if let saved = UserDefaults.standard.array(forKey: ProfileKeys.interests) as? [String] {
            selectedInterests = Set(saved)
        }
        Task { await LogService.shared.info("InterestsEditView açıldı", category: "Profile") }
    }
    
    private func saveInterests() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Save to local UserDefaults for cache
        UserDefaults.standard.set(Array(selectedInterests), forKey: ProfileKeys.interests)
        
        // Save to Firebase
        Task {
            do {
                try await UserService.shared.updateUserFields(uid: uid, data: [
                    "interests": Array(selectedInterests)
                ])
                
                await MainActor.run {
                    // Note: appState.currentUser?.interests is [Interest], skip direct assignment
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    showSavedAlert = true
                }
                
                await LogService.shared.info("İlgi alanları Firebase'e kaydedildi", category: "Profile", metadata: ["count": "\(selectedInterests.count)"])
            } catch {
                print("Error saving interests to Firebase: \(error)")
                await MainActor.run { showSavedAlert = true } // Still show success for local save
            }
        }
    }
}


// MARK: - Social Links Edit View (PREMIUM REDESIGN)
struct SocialLinksEditView: View {
    @State private var instagram = ""
    @State private var tiktok = ""
    @State private var snapchat = ""
    @State private var twitter = ""
    @State private var spotify = ""
    @State private var showSavedAlert = false
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
        ZStack {
            colors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.cyan.opacity(0.2), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "link.circle.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom))
                        }
                        
                        Text("Sosyal Medya")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        
                        Text("Hesaplarını ekle, profilinde görünsün")
                            .font(.system(size: 15))
                            .foregroundStyle(colors.secondaryText)
                    }
                    .padding(.top, 20)
                    
                    // Premium Social Cards
                    VStack(spacing: 14) {
                        PremiumSocialCard(
                            platform: .instagram,
                            username: $instagram,
                            colors: colors
                        )
                        
                        PremiumSocialCard(
                            platform: .tiktok,
                            username: $tiktok,
                            colors: colors
                        )
                        
                        PremiumSocialCard(
                            platform: .snapchat,
                            username: $snapchat,
                            colors: colors
                        )
                        
                        PremiumSocialCard(
                            platform: .twitter,
                            username: $twitter,
                            colors: colors
                        )
                        
                        PremiumSocialCard(
                            platform: .spotify,
                            username: $spotify,
                            colors: colors
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    // Info Badge
                    HStack(spacing: 10) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.cyan)
                        Text("Hesapların profilinde görünecek")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(colors.secondaryText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.cyan.opacity(0.1), in: Capsule())
                    .padding(.top, 8)
                    
                    Color.clear.frame(height: 100)
                }
            }
        }
        .navigationTitle("Sosyal Medya")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Kaydet") { saveSocialLinks() }
                    .fontWeight(.bold)
                    .foregroundStyle(.cyan)
            }
        }
        .onAppear { loadSocialLinks() }
        .alert("Kaydedildi ✓", isPresented: $showSavedAlert) {
            Button("Tamam") { dismiss() }
        } message: {
            Text("Sosyal medya hesapların güncellendi.")
        }
    }
    
    private func loadSocialLinks() {
        // Try to load from AppState (Firebase) first
        if let links = appState.currentUser?.socialLinks {
            instagram = links.instagram?.username ?? UserDefaults.standard.string(forKey: ProfileKeys.instagram) ?? ""
            tiktok = links.tiktok?.username ?? UserDefaults.standard.string(forKey: ProfileKeys.tiktok) ?? ""
            snapchat = links.snapchat?.username ?? UserDefaults.standard.string(forKey: ProfileKeys.snapchat) ?? ""
            
            // Now these are in User struct
            twitter = links.twitter?.username ?? UserDefaults.standard.string(forKey: "user_twitter") ?? ""
            spotify = links.spotify?.username ?? UserDefaults.standard.string(forKey: "user_spotify") ?? ""
        } else {
            // Fallback to UserDefaults
            instagram = UserDefaults.standard.string(forKey: ProfileKeys.instagram) ?? ""
            tiktok = UserDefaults.standard.string(forKey: ProfileKeys.tiktok) ?? ""
            snapchat = UserDefaults.standard.string(forKey: ProfileKeys.snapchat) ?? ""
            twitter = UserDefaults.standard.string(forKey: "user_twitter") ?? ""
            spotify = UserDefaults.standard.string(forKey: "user_spotify") ?? ""
        }
        
        Task { await LogService.shared.info("SocialLinksEditView yüklendi", category: "Profile") }
    }
    
    private func saveSocialLinks() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Save to local UserDefaults for cache
        UserDefaults.standard.set(instagram, forKey: ProfileKeys.instagram)
        UserDefaults.standard.set(tiktok, forKey: ProfileKeys.tiktok)
        UserDefaults.standard.set(snapchat, forKey: ProfileKeys.snapchat)
        UserDefaults.standard.set(twitter, forKey: "user_twitter")
        UserDefaults.standard.set(spotify, forKey: "user_spotify")
        UserDefaults.standard.synchronize()
        
        // Build social_links map for Firebase
        let socialLinksMap: [String: Any] = [
            "instagram": ["username": instagram, "web_url": "https://instagram.com/\(instagram)", "deeplink": "instagram://user?username=\(instagram)"],
            "tiktok": ["username": tiktok, "web_url": "https://tiktok.com/@\(tiktok)", "deeplink": "tiktok://user?user=\(tiktok)"],
            "snapchat": ["username": snapchat, "web_url": "https://snapchat.com/add/\(snapchat)", "deeplink": "snapchat://add/\(snapchat)"],
            "twitter": ["username": twitter, "web_url": "https://twitter.com/\(twitter)", "deeplink": "twitter://user?screen_name=\(twitter)"],
            "spotify": ["username": spotify, "web_url": spotify, "deeplink": spotify]
        ]
        
        // Save to Firebase
        Task {
            do {
                try await UserService.shared.updateUserFields(uid: uid, data: [
                    "social_links": socialLinksMap
                ])
                
                await MainActor.run {
                    // Haptic
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    showSavedAlert = true
                }
                
                await LogService.shared.info("Sosyal medya Firebase'e kaydedildi", category: "Profile", metadata: [
                    "instagram": instagram.isEmpty ? "empty" : "set",
                    "tiktok": tiktok.isEmpty ? "empty" : "set",
                    "snapchat": snapchat.isEmpty ? "empty" : "set",
                    "twitter": twitter.isEmpty ? "empty" : "set",
                    "spotify": spotify.isEmpty ? "empty" : "set"
                ])
            } catch {
                print("Error saving social links to Firebase: \(error)")
                await MainActor.run { 
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    showSavedAlert = true 
                }
            }
        }
    }
}

// MARK: - Social Platform Enum for Edit View
enum EditSocialPlatform {
    case instagram, tiktok, snapchat, twitter, spotify
    
    var name: String {
        switch self {
        case .instagram: return "Instagram"
        case .tiktok: return "TikTok"
        case .snapchat: return "Snapchat"
        case .twitter: return "X"
        case .spotify: return "Spotify"
        }
    }
    
    var placeholder: String {
        switch self {
        case .instagram: return "@kullanici_adi"
        case .tiktok: return "@kullanici_adi"
        case .snapchat: return "kullanici_adi"
        case .twitter: return "@kullanici_adi"
        case .spotify: return "Profil linki"
        }
    }
    
    var gradient: [Color] {
        switch self {
        case .instagram:
            return [Color(red: 0.98, green: 0.23, blue: 0.35), 
                    Color(red: 0.83, green: 0.18, blue: 0.42),
                    Color(red: 0.55, green: 0.23, blue: 0.73)]
        case .tiktok:
            return [Color.black, Color(red: 0.0, green: 0.96, blue: 0.93)]
        case .snapchat:
            return [Color(red: 1.0, green: 0.99, blue: 0.0), Color(red: 1.0, green: 0.85, blue: 0.0)]
        case .twitter:
            return [Color.black, Color(white: 0.15)]
        case .spotify:
            return [Color(red: 0.11, green: 0.73, blue: 0.33), Color(red: 0.07, green: 0.55, blue: 0.25)]
        }
    }
    
    var iconColor: Color {
        switch self {
        case .snapchat: return .black
        default: return .white
        }
    }
}

// MARK: - Premium Social Card
struct PremiumSocialCard: View {
    let platform: EditSocialPlatform
    @Binding var username: String
    var colors: ThemeColors
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            // Custom Icons (No Gradient, Larger)
            Group {
                switch platform {
                case .instagram:
                    InstagramIcon()
                case .tiktok:
                    TikTokIcon()
                case .snapchat:
                    SnapchatIcon()
                case .twitter:
                    TwitterXIcon()
                case .spotify:
                    SpotifyIcon()
                }
            }
            .frame(width: 44, height: 44)
            .foregroundStyle(colors.primaryText) // For X icon adaptation
            
            // Input Area
            VStack(alignment: .leading, spacing: 4) {
                Text(platform.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(colors.secondaryText)
                
                TextField(platform.placeholder, text: $username)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(colors.primaryText)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .focused($isFocused)
            }
            
            Spacer()
            
            // Status
            if !username.isEmpty {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.green)
            } else {
                Circle()
                    .stroke(Color(white: 0.25), lineWidth: 2)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(isFocused ? platform.gradient.first?.opacity(0.6) ?? .cyan : colors.border, lineWidth: isFocused ? 2 : 1)
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Custom Social Icons
struct InstagramIcon: View {
    var body: some View {
        Image("InstagramIcon")
            .resizable()
            .scaledToFit()
    }
}

struct TikTokIcon: View {
    var body: some View {
        Image("TikTokIcon")
            .resizable()
            .scaledToFit()
    }
}

struct SnapchatIcon: View {
    var body: some View {
        Image("SnapchatIcon")
            .resizable()
            .scaledToFit()
    }
}

struct TwitterXIcon: View {
    var body: some View {
        Text("𝕏")
            .font(.system(size: 32, weight: .bold))
            // Foreground style inherited from parent (colors.primaryText)
    }
}

struct SpotifyIcon: View {
    var body: some View {
        Image("SpotifyIcon")
            .resizable()
            .scaledToFit()
    }
}

// MARK: - Reusable Components
struct ProfilePhotoSection: View {
    let photoURL: String?
    @State private var showPicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var savedPhoto: UIImage?
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(LinearGradient(colors: [.cyan, .purple], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 3)
                    .frame(width: 110, height: 110)
                
                // Show saved photo from UserDefaults or fallback to URL
                Group {
                    if let photo = savedPhoto {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFill()
                    } else {
                        AsyncImage(url: URL(string: photoURL ?? "")) { img in
                            img.resizable().scaledToFill()
                        } placeholder: {
                            Circle().fill(Color(white: 0.2))
                                .overlay { Image(systemName: "person.fill").font(.largeTitle).foregroundStyle(.gray) }
                        }
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                
                Circle()
                    .fill(.cyan)
                    .frame(width: 32, height: 32)
                    .overlay { Image(systemName: "camera.fill").font(.system(size: 14)).foregroundStyle(.white) }
                    .offset(x: 38, y: 38)
            }
            
            Text("Fotoğrafı Değiştir")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.cyan)
        }
        .onTapGesture { showPicker = true }
        .photosPicker(isPresented: $showPicker, selection: $selectedItem, matching: .images)
        .onAppear { loadSavedPhoto() }
        .onChange(of: selectedItem) { _, item in
            Task { await loadAndSavePhoto(item) }
        }
    }
    
    private func loadSavedPhoto() {
        if let photosData = UserDefaults.standard.array(forKey: ProfileKeys.photos) as? [Data],
           let firstPhotoData = photosData.first,
           let image = UIImage(data: firstPhotoData) {
            savedPhoto = image
        }
    }
    
    private func loadAndSavePhoto(_ item: PhotosPickerItem?) async {
        guard let item = item,
              let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        
        await MainActor.run {
            savedPhoto = image
            // Save as first photo in array
            var photosData = UserDefaults.standard.array(forKey: ProfileKeys.photos) as? [Data] ?? []
            if let jpegData = image.jpegData(compressionQuality: 0.7) {
                if photosData.isEmpty {
                    photosData.append(jpegData)
                } else {
                    photosData[0] = jpegData
                }
                UserDefaults.standard.set(photosData, forKey: ProfileKeys.photos)
            }
        }
        Task { await LogService.shared.info("Profil fotoğrafı güncellendi", category: "Profile") }
    }
}

struct FormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(white: 0.5))
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) { content }
                .background(Color(white: 0.12), in: RoundedRectangle(cornerRadius: 14))
        }
    }
}

struct FormField: View {
    let icon: String
    let title: String
    @Binding var text: String
    var multiline: Bool = false
    
    var body: some View {
        HStack(alignment: multiline ? .top : .center, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color(white: 0.4))
                .frame(width: 24)
                .padding(.top, multiline ? 4 : 0)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(white: 0.5))
                
                if multiline {
                    TextField("", text: $text, axis: .vertical)
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                        .lineLimit(3...6)
                } else {
                    TextField("", text: $text)
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Settings Views
struct LanguageSettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLang: AppLanguage?
    
    private let bgColor = Color(red: 0.04, green: 0.02, blue: 0.08)
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "globe")
                            .font(.system(size: 44))
                            .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom))
                        
                        Text("Dil Seçin")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("Uygulama dilini değiştirin")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(white: 0.5))
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                    
                    // Language Options
                    VStack(spacing: 8) {
                        ForEach(AppLanguage.allCases, id: \.self) { lang in
                            LanguageOptionRow(
                                language: lang,
                                isSelected: appState.currentLanguage == lang
                            ) {
                                selectLanguage(lang)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Dil")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    private func selectLanguage(_ lang: AppLanguage) {
        let oldLang = appState.currentLanguage
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Change language
        appState.setLanguage(lang)
        UserDefaults.standard.synchronize()
        
        // Log
        Task {
            await LogService.shared.info("Dil değiştirildi", category: "Settings", metadata: [
                "from": oldLang.rawValue,
                "to": lang.rawValue,
                "displayName": lang.displayName
            ])
        }
        
        // Dismiss after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
        }
    }
}

struct LanguageOptionRow: View {
    let language: AppLanguage
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                // Flag
                Text(language.flag)
                    .font(.system(size: 32))
                
                // Language Name
                VStack(alignment: .leading, spacing: 2) {
                    Text(language.displayName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text(language.rawValue.uppercased())
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(white: 0.4))
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.cyan)
                } else {
                    Circle()
                        .stroke(Color(white: 0.25), lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.cyan.opacity(0.1) : Color(white: 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.cyan.opacity(0.5) : Color(white: 0.15), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(EditScaleButtonStyle())
    }
}

struct EditScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct ThemeSettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.02, blue: 0.08).ignoresSafeArea()
            List {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    Button {
                        let oldTheme = appState.currentTheme
                        appState.setTheme(theme)
                        UserDefaults.standard.synchronize()
                        
                        // Log theme change
                        Task {
                            await LogService.shared.info("Tema değiştirildi", category: "Settings", metadata: [
                                "from": oldTheme.rawValue,
                                "to": theme.rawValue,
                                "displayName": theme.displayName
                            ])
                        }
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: theme.icon).foregroundStyle(.purple)
                            Text(theme.displayName).foregroundStyle(.white)
                            Spacer()
                            if appState.currentTheme == theme {
                                Image(systemName: "checkmark").foregroundStyle(.cyan)
                            }
                        }
                    }
                    .listRowBackground(Color(white: 0.12))
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Tema")
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
