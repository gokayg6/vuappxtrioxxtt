import SwiftUI
import PhotosUI

// MARK: - Onboarding Step Enum
enum OnboardingStep: Int, CaseIterable {
    case name = 0
    case birthdate = 1
    case gender = 2
    case location = 3
    case photo = 4
    case optional = 5
    
    var title: String {
        switch self {
        case .name: return "İsim"
        case .birthdate: return "Doğum Tarihi"
        case .gender: return "Cinsiyet"
        case .location: return "Konum"
        case .photo: return "Fotoğraf"
        case .optional: return "Opsiyonel"
        }
    }
    
    var icon: String {
        switch self {
        case .name: return "person.fill"
        case .birthdate: return "calendar"
        case .gender: return "person.2.fill"
        case .location: return "mappin.circle.fill"
        case .photo: return "camera.fill"
        case .optional: return "sparkles"
        }
    }
}

// MARK: - Profile Creation Data
struct ProfileCreationData {
    var displayName: String = ""
    var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    var gender: Gender = .preferNotToSay
    var country: String = ""
    var city: String = ""
    var profilePhoto: UIImage?
    var additionalPhotos: [UIImage] = []
    var bio: String = ""
    var badges: [String] = []
    var tiktokUsername: String = ""
    var instagramUsername: String = ""
    var snapchatUsername: String = ""
}

// MARK: - ProfileSetupView Container
struct ProfileSetupView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep: OnboardingStep = .name
    @State private var profileData = ProfileCreationData()
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    private let bgColor = Color(red: 0.04, green: 0.02, blue: 0.08)
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Indicator
                ProgressIndicator(currentStep: currentStep)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                
                // Step Content
                TabView(selection: $currentStep) {
                    NameInputStep(profileData: $profileData, onNext: nextStep)
                        .tag(OnboardingStep.name)
                    
                    BirthdateInputStep(profileData: $profileData, onNext: nextStep, onBack: previousStep)
                        .tag(OnboardingStep.birthdate)
                    
                    GenderSelectStep(profileData: $profileData, onNext: nextStep, onBack: previousStep)
                        .tag(OnboardingStep.gender)
                    
                    LocationSelectStep(profileData: $profileData, onNext: nextStep, onBack: previousStep)
                        .tag(OnboardingStep.location)
                    
                    PhotoUploadStep(profileData: $profileData, onNext: nextStep, onBack: previousStep)
                        .tag(OnboardingStep.photo)
                    
                    OptionalInfoStep(profileData: $profileData, onComplete: completeSetup, onBack: previousStep)
                        .tag(OnboardingStep.optional)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
            }
            
            // Loading Overlay
            if isLoading {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.cyan)
                        .scaleEffect(1.5)
                    
                    Text("Profil oluşturuluyor...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                }
                .padding(32)
                .background(Color(white: 0.1), in: RoundedRectangle(cornerRadius: 20))
            }
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Navigation
    private func nextStep() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if let nextIndex = OnboardingStep(rawValue: currentStep.rawValue + 1) {
                currentStep = nextIndex
            }
        }
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    private func previousStep() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if let prevIndex = OnboardingStep(rawValue: currentStep.rawValue - 1) {
                currentStep = prevIndex
            }
        }
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    private func completeSetup() {
        isLoading = true
        
        Task {
            do {
                // Save profile data to backend
                try await saveProfileToBackend()
                
                await MainActor.run {
                    isLoading = false
                    // Navigate to main app
                    appState.authState = .authenticated
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func saveProfileToBackend() async throws {
        guard let userId = appState.currentUser?.id else { return }
        
        // Prepare profile data
        var data: [String: Any] = [
            "displayName": profileData.displayName,
            "dateOfBirth": ISO8601DateFormatter().string(from: profileData.dateOfBirth),
            "gender": profileData.gender.rawValue,
            "country": profileData.country,
            "city": profileData.city
        ]
        
        // Add optional fields
        if !profileData.bio.isEmpty {
            data["bio"] = profileData.bio
        }
        
        if !profileData.tiktokUsername.isEmpty {
            data["tiktokUsername"] = profileData.tiktokUsername
        }
        
        if !profileData.instagramUsername.isEmpty {
            data["instagramUsername"] = profileData.instagramUsername
        }
        
        if !profileData.snapchatUsername.isEmpty {
            data["snapchatUsername"] = profileData.snapchatUsername
        }
        
        // Update profile
        try await ProfileService.shared.updateProfile(userId: userId, data: data)
        
        // Update local user
        await MainActor.run {
            appState.currentUser?.displayName = profileData.displayName
            appState.currentUser?.dateOfBirth = profileData.dateOfBirth
            appState.currentUser?.gender = profileData.gender
            appState.currentUser?.country = profileData.country
            appState.currentUser?.city = profileData.city
            appState.currentUser?.bio = profileData.bio
        }
    }
}

// MARK: - Progress Indicator
struct ProgressIndicator: View {
    let currentStep: OnboardingStep
    
    private let totalSteps = OnboardingStep.allCases.count
    
    var body: some View {
        VStack(spacing: 12) {
            // Step dots
            HStack(spacing: 8) {
                ForEach(OnboardingStep.allCases, id: \.rawValue) { step in
                    Circle()
                        .fill(step.rawValue <= currentStep.rawValue ? Color.cyan : Color(white: 0.2))
                        .frame(width: step == currentStep ? 12 : 8, height: step == currentStep ? 12 : 8)
                        .animation(.spring(response: 0.3), value: currentStep)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(white: 0.15))
                        .frame(height: 4)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 4)
                        .animation(.spring(response: 0.4), value: currentStep)
                }
            }
            .frame(height: 4)
            
            // Step title
            Text(currentStep.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color(white: 0.5))
        }
    }
    
    private var progress: CGFloat {
        CGFloat(currentStep.rawValue + 1) / CGFloat(totalSteps)
    }
}

// MARK: - Step Container
struct StepContainer<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let content: Content
    
    private let bgColor = Color(red: 0.04, green: 0.02, blue: 0.08)
    
    init(
        icon: String,
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.cyan.opacity(0.2), .blue.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: icon)
                            .font(.system(size: 36))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    
                    VStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text(subtitle)
                            .font(.system(size: 15))
                            .foregroundStyle(Color(white: 0.5))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                }
                .padding(.top, 40)
                
                // Content
                content
                    .padding(.horizontal, 24)
                
                Spacer(minLength: 120)
            }
        }
    }
}

// MARK: - Navigation Buttons
struct OnboardingNavigationButtons: View {
    let canContinue: Bool
    let showBack: Bool
    let continueTitle: String
    let onContinue: () -> Void
    let onBack: (() -> Void)?
    
    init(
        canContinue: Bool,
        showBack: Bool = true,
        continueTitle: String = "Devam",
        onContinue: @escaping () -> Void,
        onBack: (() -> Void)? = nil
    ) {
        self.canContinue = canContinue
        self.showBack = showBack
        self.continueTitle = continueTitle
        self.onContinue = onContinue
        self.onBack = onBack
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Continue Button
            Button(action: onContinue) {
                HStack(spacing: 8) {
                    Text(continueTitle)
                        .font(.system(size: 17, weight: .semibold))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    canContinue
                        ? LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(colors: [Color(white: 0.3), Color(white: 0.25)], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(!canContinue)
            
            // Back Button
            if showBack, let onBack = onBack {
                Button(action: onBack) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 14, weight: .medium))
                        Text("Geri")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundStyle(Color(white: 0.5))
                }
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }
}

#Preview {
    ProfileSetupView()
        .environment(AppState())
}


// MARK: - Step 1: Name Input
struct NameInputStep: View {
    @Binding var profileData: ProfileCreationData
    let onNext: () -> Void
    
    @FocusState private var isNameFocused: Bool
    
    private var isValid: Bool {
        !profileData.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        ZStack {
            StepContainer(
                icon: "person.fill",
                title: "Adın ne?",
                subtitle: "Gerçek adın olmak zorunda değil"
            ) {
                VStack(spacing: 24) {
                    // Name Input
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("İsim", text: $profileData.displayName)
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                            .padding(16)
                            .background(Color(white: 0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(isNameFocused ? Color.cyan : Color(white: 0.2), lineWidth: 1)
                            )
                            .focused($isNameFocused)
                        
                        Text("Bu isim profilinde görünecek")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(white: 0.4))
                            .padding(.leading, 4)
                    }
                    
                    // Info Card
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.cyan)
                        
                        Text("Takma ad, rumuz veya gerçek adını kullanabilirsin")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(white: 0.6))
                    }
                    .padding(16)
                    .background(Color.cyan.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            VStack {
                Spacer()
                OnboardingNavigationButtons(
                    canContinue: isValid,
                    showBack: false,
                    onContinue: onNext,
                    onBack: nil
                )
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isNameFocused = true
            }
        }
    }
}

// MARK: - Step 2: Birthdate Input
struct BirthdateInputStep: View {
    @Binding var profileData: ProfileCreationData
    let onNext: () -> Void
    let onBack: () -> Void
    
    @State private var showAgeError = false
    
    private var calculatedAge: Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: profileData.dateOfBirth, to: now)
        return ageComponents.year ?? 0
    }
    
    private var isValidAge: Bool {
        calculatedAge >= 15
    }
    
    private var ageGroup: String {
        if calculatedAge < 15 {
            return "Kayıt için çok genç"
        } else if calculatedAge <= 17 {
            return "15-17 yaş grubu"
        } else {
            return "18+ yaş grubu"
        }
    }
    
    var body: some View {
        ZStack {
            StepContainer(
                icon: "calendar",
                title: "Doğum tarihin",
                subtitle: "Yaşını hesaplamak için kullanılacak"
            ) {
                VStack(spacing: 24) {
                    // Date Picker
                    DatePicker(
                        "Doğum Tarihi",
                        selection: $profileData.dateOfBirth,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .padding()
                    .background(Color(white: 0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Age Display
                    VStack(spacing: 8) {
                        HStack {
                            Text("Yaşın:")
                                .font(.system(size: 16))
                                .foregroundStyle(Color(white: 0.5))
                            
                            Text("\(calculatedAge)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(isValidAge ? .cyan : .red)
                        }
                        
                        Text(ageGroup)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(isValidAge ? Color(white: 0.5) : .red)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(Color(white: 0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Age Error
                    if !isValidAge {
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.red)
                            
                            Text("Bu uygulama 15 yaş altı kullanıcılar için uygun değildir")
                                .font(.system(size: 14))
                                .foregroundStyle(.red)
                        }
                        .padding(14)
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Info
                    HStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.cyan)
                        
                        Text("Doğum tarihin gizli tutulur, sadece yaşın gösterilir")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(white: 0.5))
                    }
                    .padding(14)
                    .background(Color.cyan.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            VStack {
                Spacer()
                OnboardingNavigationButtons(
                    canContinue: isValidAge,
                    showBack: true,
                    onContinue: onNext,
                    onBack: onBack
                )
            }
        }
    }
}

// MARK: - Step 3: Gender Select
struct GenderSelectStep: View {
    @Binding var profileData: ProfileCreationData
    let onNext: () -> Void
    let onBack: () -> Void
    
    private let genderOptions: [(Gender, String, String)] = [
        (.male, "Erkek", "♂️"),
        (.female, "Kadın", "♀️"),
        (.nonBinary, "Diğer", "⚧️"),
        (.preferNotToSay, "Belirtmek İstemiyorum", "🤐")
    ]
    
    var body: some View {
        ZStack {
            StepContainer(
                icon: "person.2.fill",
                title: "Cinsiyetin",
                subtitle: "Seni daha iyi tanımamıza yardımcı olur"
            ) {
                VStack(spacing: 12) {
                    ForEach(genderOptions, id: \.0) { gender, title, emoji in
                        GenderOptionButton(
                            title: title,
                            emoji: emoji,
                            isSelected: profileData.gender == gender
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                profileData.gender = gender
                            }
                            
                            // Haptic
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                        }
                    }
                }
            }
            
            VStack {
                Spacer()
                OnboardingNavigationButtons(
                    canContinue: true,
                    showBack: true,
                    onContinue: onNext,
                    onBack: onBack
                )
            }
        }
    }
}

struct GenderOptionButton: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(emoji)
                    .font(.system(size: 28))
                
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.cyan)
                } else {
                    Circle()
                        .stroke(Color(white: 0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.cyan.opacity(0.15) : Color(white: 0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.cyan : Color(white: 0.15), lineWidth: isSelected ? 2 : 1)
            )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}


// MARK: - Step 4: Location Select
struct LocationSelectStep: View {
    @Binding var profileData: ProfileCreationData
    let onNext: () -> Void
    let onBack: () -> Void
    
    @State private var countrySearchText = ""
    @State private var citySearchText = ""
    @State private var showCountryPicker = false
    @State private var showCityPicker = false
    
    private var isValid: Bool {
        !profileData.country.isEmpty && !profileData.city.isEmpty
    }
    
    // Popular countries with cities
    private let countriesWithCities: [String: [String]] = [
        "Türkiye": ["İstanbul", "Ankara", "İzmir", "Bursa", "Antalya", "Adana", "Konya", "Gaziantep", "Mersin", "Diyarbakır", "Kayseri", "Eskişehir", "Samsun", "Denizli", "Şanlıurfa", "Malatya", "Trabzon", "Erzurum", "Van", "Batman"],
        "United States": ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia", "San Antonio", "San Diego", "Dallas", "San Jose", "Austin", "Jacksonville", "Fort Worth", "Columbus", "Charlotte", "Seattle", "Denver", "Boston", "Detroit", "Miami"],
        "United Kingdom": ["London", "Birmingham", "Manchester", "Glasgow", "Liverpool", "Leeds", "Sheffield", "Edinburgh", "Bristol", "Leicester"],
        "Germany": ["Berlin", "Hamburg", "Munich", "Cologne", "Frankfurt", "Stuttgart", "Düsseldorf", "Leipzig", "Dortmund", "Essen"],
        "France": ["Paris", "Marseille", "Lyon", "Toulouse", "Nice", "Nantes", "Strasbourg", "Montpellier", "Bordeaux", "Lille"],
        "Spain": ["Madrid", "Barcelona", "Valencia", "Seville", "Zaragoza", "Málaga", "Murcia", "Palma", "Las Palmas", "Bilbao"],
        "Italy": ["Rome", "Milan", "Naples", "Turin", "Palermo", "Genoa", "Bologna", "Florence", "Bari", "Catania"],
        "Netherlands": ["Amsterdam", "Rotterdam", "The Hague", "Utrecht", "Eindhoven", "Tilburg", "Groningen", "Almere", "Breda", "Nijmegen"],
        "Belgium": ["Brussels", "Antwerp", "Ghent", "Charleroi", "Liège", "Bruges", "Namur", "Leuven", "Mons", "Aalst"],
        "Switzerland": ["Zurich", "Geneva", "Basel", "Lausanne", "Bern", "Winterthur", "Lucerne", "St. Gallen", "Lugano", "Biel"],
        "Austria": ["Vienna", "Graz", "Linz", "Salzburg", "Innsbruck", "Klagenfurt", "Villach", "Wels", "St. Pölten", "Dornbirn"],
        "Poland": ["Warsaw", "Kraków", "Łódź", "Wrocław", "Poznań", "Gdańsk", "Szczecin", "Bydgoszcz", "Lublin", "Białystok"],
        "Sweden": ["Stockholm", "Gothenburg", "Malmö", "Uppsala", "Västerås", "Örebro", "Linköping", "Helsingborg", "Jönköping", "Norrköping"],
        "Norway": ["Oslo", "Bergen", "Trondheim", "Stavanger", "Drammen", "Fredrikstad", "Kristiansand", "Sandnes", "Tromsø", "Sarpsborg"],
        "Denmark": ["Copenhagen", "Aarhus", "Odense", "Aalborg", "Esbjerg", "Randers", "Kolding", "Horsens", "Vejle", "Roskilde"],
        "Finland": ["Helsinki", "Espoo", "Tampere", "Vantaa", "Oulu", "Turku", "Jyväskylä", "Lahti", "Kuopio", "Pori"],
        "Russia": ["Moscow", "Saint Petersburg", "Novosibirsk", "Yekaterinburg", "Kazan", "Nizhny Novgorod", "Chelyabinsk", "Samara", "Omsk", "Rostov-on-Don"],
        "Ukraine": ["Kyiv", "Kharkiv", "Odesa", "Dnipro", "Donetsk", "Zaporizhzhia", "Lviv", "Kryvyi Rih", "Mykolaiv", "Mariupol"],
        "Brazil": ["São Paulo", "Rio de Janeiro", "Brasília", "Salvador", "Fortaleza", "Belo Horizonte", "Manaus", "Curitiba", "Recife", "Porto Alegre"],
        "Argentina": ["Buenos Aires", "Córdoba", "Rosario", "Mendoza", "San Miguel de Tucumán", "La Plata", "Mar del Plata", "Salta", "Santa Fe", "San Juan"],
        "Mexico": ["Mexico City", "Guadalajara", "Monterrey", "Puebla", "Tijuana", "León", "Juárez", "Zapopan", "Mérida", "San Luis Potosí"],
        "Canada": ["Toronto", "Montreal", "Vancouver", "Calgary", "Edmonton", "Ottawa", "Winnipeg", "Quebec City", "Hamilton", "Kitchener"],
        "Australia": ["Sydney", "Melbourne", "Brisbane", "Perth", "Adelaide", "Gold Coast", "Newcastle", "Canberra", "Sunshine Coast", "Wollongong"],
        "Japan": ["Tokyo", "Yokohama", "Osaka", "Nagoya", "Sapporo", "Fukuoka", "Kobe", "Kawasaki", "Kyoto", "Saitama"],
        "South Korea": ["Seoul", "Busan", "Incheon", "Daegu", "Daejeon", "Gwangju", "Suwon", "Ulsan", "Changwon", "Goyang"],
        "India": ["Mumbai", "Delhi", "Bangalore", "Hyderabad", "Chennai", "Kolkata", "Ahmedabad", "Pune", "Surat", "Jaipur"],
        "China": ["Shanghai", "Beijing", "Guangzhou", "Shenzhen", "Chengdu", "Tianjin", "Wuhan", "Dongguan", "Chongqing", "Nanjing"],
        "United Arab Emirates": ["Dubai", "Abu Dhabi", "Sharjah", "Al Ain", "Ajman", "Ras Al Khaimah", "Fujairah", "Umm Al Quwain"],
        "Saudi Arabia": ["Riyadh", "Jeddah", "Mecca", "Medina", "Dammam", "Khobar", "Tabuk", "Buraidah", "Khamis Mushait", "Abha"]
    ]
    
    private var sortedCountries: [String] {
        countriesWithCities.keys.sorted()
    }
    
    private var filteredCountries: [String] {
        if countrySearchText.isEmpty {
            return sortedCountries
        }
        return sortedCountries.filter { $0.localizedCaseInsensitiveContains(countrySearchText) }
    }
    
    private var citiesForSelectedCountry: [String] {
        countriesWithCities[profileData.country] ?? []
    }
    
    private var filteredCities: [String] {
        if citySearchText.isEmpty {
            return citiesForSelectedCountry
        }
        return citiesForSelectedCountry.filter { $0.localizedCaseInsensitiveContains(citySearchText) }
    }
    
    var body: some View {
        ZStack {
            StepContainer(
                icon: "mappin.circle.fill",
                title: "Neredesin?",
                subtitle: "Yakınındaki kişileri bulmana yardımcı olur"
            ) {
                VStack(spacing: 20) {
                    // Country Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ülke")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(white: 0.5))
                        
                        Button {
                            showCountryPicker = true
                        } label: {
                            HStack {
                                Text(profileData.country.isEmpty ? "Ülke seç" : profileData.country)
                                    .font(.system(size: 17))
                                    .foregroundStyle(profileData.country.isEmpty ? Color(white: 0.4) : .white)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color(white: 0.4))
                            }
                            .padding(16)
                            .background(Color(white: 0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(white: 0.15), lineWidth: 1)
                            )
                        }
                    }
                    
                    // City Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Şehir")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(white: 0.5))
                        
                        Button {
                            if !profileData.country.isEmpty {
                                showCityPicker = true
                            }
                        } label: {
                            HStack {
                                Text(profileData.city.isEmpty ? "Şehir seç" : profileData.city)
                                    .font(.system(size: 17))
                                    .foregroundStyle(profileData.city.isEmpty ? Color(white: 0.4) : .white)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color(white: 0.4))
                            }
                            .padding(16)
                            .background(Color(white: 0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(white: 0.15), lineWidth: 1)
                            )
                        }
                        .disabled(profileData.country.isEmpty)
                        .opacity(profileData.country.isEmpty ? 0.5 : 1)
                    }
                    
                    // Info
                    if !profileData.country.isEmpty && !profileData.city.isEmpty {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.green)
                            
                            Text("\(profileData.city), \(profileData.country)")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.white)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            
            VStack {
                Spacer()
                OnboardingNavigationButtons(
                    canContinue: isValid,
                    showBack: true,
                    onContinue: onNext,
                    onBack: onBack
                )
            }
        }
        .sheet(isPresented: $showCountryPicker) {
            LocationPickerSheet(
                title: "Ülke Seç",
                searchText: $countrySearchText,
                items: filteredCountries,
                selectedItem: $profileData.country
            ) {
                // Reset city when country changes
                profileData.city = ""
                showCountryPicker = false
            }
        }
        .sheet(isPresented: $showCityPicker) {
            LocationPickerSheet(
                title: "Şehir Seç",
                searchText: $citySearchText,
                items: filteredCities,
                selectedItem: $profileData.city
            ) {
                showCityPicker = false
            }
        }
    }
}

// MARK: - Location Picker Sheet
struct LocationPickerSheet: View {
    let title: String
    @Binding var searchText: String
    let items: [String]
    @Binding var selectedItem: String
    let onSelect: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    private let bgColor = Color(red: 0.04, green: 0.02, blue: 0.08)
    
    var body: some View {
        NavigationStack {
            ZStack {
                bgColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16))
                            .foregroundStyle(Color(white: 0.4))
                        
                        TextField("Ara...", text: $searchText)
                            .font(.system(size: 16))
                            .foregroundStyle(.white)
                    }
                    .padding(14)
                    .background(Color(white: 0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    
                    // List
                    ScrollView {
                        LazyVStack(spacing: 2) {
                            ForEach(items, id: \.self) { item in
                                Button {
                                    selectedItem = item
                                    onSelect()
                                } label: {
                                    HStack {
                                        Text(item)
                                            .font(.system(size: 17))
                                            .foregroundStyle(.white)
                                        
                                        Spacer()
                                        
                                        if selectedItem == item {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundStyle(.cyan)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(selectedItem == item ? Color.cyan.opacity(0.1) : Color.clear)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundStyle(.cyan)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}


// MARK: - Step 5: Photo Upload
struct PhotoUploadStep: View {
    @Binding var profileData: ProfileCreationData
    let onNext: () -> Void
    let onBack: () -> Void
    
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showSourcePicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var showError = false
    @State private var errorMessage = ""
    
    private var isValid: Bool {
        profileData.profilePhoto != nil
    }
    
    var body: some View {
        ZStack {
            StepContainer(
                icon: "camera.fill",
                title: "Profil fotoğrafın",
                subtitle: "Seni en iyi yansıtan bir fotoğraf seç"
            ) {
                VStack(spacing: 24) {
                    // Photo Preview
                    ZStack {
                        if let photo = profileData.profilePhoto {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 200)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [.cyan, .blue],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 4
                                        )
                                )
                                .shadow(color: .cyan.opacity(0.3), radius: 20)
                            
                            // Edit button
                            Button {
                                showSourcePicker = true
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.cyan)
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "pencil")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(.black)
                                }
                            }
                            .offset(x: 70, y: 70)
                        } else {
                            // Empty state
                            Button {
                                showSourcePicker = true
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color(white: 0.08))
                                        .frame(width: 200, height: 200)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    style: StrokeStyle(lineWidth: 3, dash: [10, 8])
                                                )
                                                .foregroundStyle(Color(white: 0.2))
                                        )
                                    
                                    VStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(Color(white: 0.12))
                                                .frame(width: 60, height: 60)
                                            
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 26))
                                                .foregroundStyle(Color(white: 0.4))
                                        }
                                        
                                        Text("Fotoğraf Ekle")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundStyle(Color(white: 0.4))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 20)
                    
                    // Requirements
                    VStack(spacing: 12) {
                        RequirementRow(
                            icon: "checkmark.circle.fill",
                            text: "Minimum 500x500 piksel",
                            isMet: profileData.profilePhoto != nil
                        )
                        
                        RequirementRow(
                            icon: "checkmark.circle.fill",
                            text: "JPEG veya PNG formatı",
                            isMet: profileData.profilePhoto != nil
                        )
                        
                        RequirementRow(
                            icon: "checkmark.circle.fill",
                            text: "Yüzün net görünmeli",
                            isMet: profileData.profilePhoto != nil
                        )
                    }
                    .padding(16)
                    .background(Color(white: 0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                    // Tips
                    HStack(spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.yellow)
                        
                        Text("Güler yüzlü fotoğraflar daha çok ilgi çeker")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(white: 0.5))
                    }
                    .padding(14)
                    .background(Color.yellow.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            VStack {
                Spacer()
                OnboardingNavigationButtons(
                    canContinue: isValid,
                    showBack: true,
                    onContinue: onNext,
                    onBack: onBack
                )
            }
        }
        .confirmationDialog("Fotoğraf Kaynağı", isPresented: $showSourcePicker) {
            Button("Kamera") {
                showCamera = true
            }
            
            Button("Galeri") {
                showImagePicker = true
            }
            
            Button("İptal", role: .cancel) { }
        }
        .photosPicker(isPresented: $showImagePicker, selection: $selectedItem, matching: .images)
        .fullScreenCover(isPresented: $showCamera) {
            CameraView { image in
                validateAndSetPhoto(image)
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        validateAndSetPhoto(image)
                    }
                }
            }
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func validateAndSetPhoto(_ image: UIImage) {
        // Check minimum resolution (500x500)
        if image.size.width < 500 || image.size.height < 500 {
            errorMessage = "Fotoğraf en az 500x500 piksel olmalı"
            showError = true
            return
        }
        
        // Set the photo
        withAnimation(.spring(response: 0.4)) {
            profileData.profilePhoto = image
        }
        
        // Haptic
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
}

struct RequirementRow: View {
    let icon: String
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(isMet ? .green : Color(white: 0.3))
            
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(isMet ? .white : Color(white: 0.5))
            
            Spacer()
        }
    }
}

// MARK: - Camera View
struct CameraView: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraDevice = .front
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onCapture(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Step 6: Optional Info
struct OptionalInfoStep: View {
    @Binding var profileData: ProfileCreationData
    let onComplete: () -> Void
    let onBack: () -> Void
    
    @State private var showBadgePicker = false
    
    private let availableBadges: [(String, String)] = [
        ("🔥", "Enerjik"),
        ("🎮", "Gamer"),
        ("🎧", "Müzikçi"),
        ("📸", "Estetik"),
        ("🤝", "Sosyal"),
        ("😂", "Komik"),
        ("💪", "Sporcu"),
        ("📚", "Kitap Kurdu"),
        ("🎬", "Sinefil"),
        ("✈️", "Gezgin")
    ]
    
    var body: some View {
        ZStack {
            StepContainer(
                icon: "sparkles",
                title: "Son dokunuşlar",
                subtitle: "Bu bilgiler opsiyonel, istersen atlayabilirsin"
            ) {
                VStack(spacing: 20) {
                    // Bio
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Hakkında")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color(white: 0.5))
                            
                            Spacer()
                            
                            Text("\(profileData.bio.count)/500")
                                .font(.system(size: 12))
                                .foregroundStyle(profileData.bio.count > 450 ? .orange : Color(white: 0.4))
                        }
                        
                        TextEditor(text: $profileData.bio)
                            .font(.system(size: 16))
                            .foregroundStyle(.white)
                            .scrollContentBackground(.hidden)
                            .frame(height: 100)
                            .padding(12)
                            .background(Color(white: 0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(white: 0.15), lineWidth: 1)
                            )
                            .onChange(of: profileData.bio) { _, newValue in
                                if newValue.count > 500 {
                                    profileData.bio = String(newValue.prefix(500))
                                }
                            }
                    }
                    
                    // Badges
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Rozetler")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color(white: 0.5))
                            
                            Spacer()
                            
                            Text("\(profileData.badges.count)/5")
                                .font(.system(size: 12))
                                .foregroundStyle(profileData.badges.count >= 5 ? .orange : Color(white: 0.4))
                        }
                        
                        // Badge Grid
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(availableBadges, id: \.1) { emoji, name in
                                let isSelected = profileData.badges.contains(name)
                                
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        if isSelected {
                                            profileData.badges.removeAll { $0 == name }
                                        } else if profileData.badges.count < 5 {
                                            profileData.badges.append(name)
                                        }
                                    }
                                    
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                } label: {
                                    HStack(spacing: 6) {
                                        Text(emoji)
                                            .font(.system(size: 18))
                                        Text(name)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(isSelected ? .white : Color(white: 0.7))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(isSelected ? Color.cyan.opacity(0.2) : Color(white: 0.08))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(isSelected ? Color.cyan : Color(white: 0.15), lineWidth: 1)
                                    )
                                }
                                .disabled(!isSelected && profileData.badges.count >= 5)
                                .opacity(!isSelected && profileData.badges.count >= 5 ? 0.5 : 1)
                            }
                        }
                    }
                    
                    // Social Links
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sosyal Medya")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(white: 0.5))
                        
                        SocialInputField(
                            platform: "TikTok",
                            icon: "play.rectangle.fill",
                            color: .pink,
                            username: $profileData.tiktokUsername
                        )
                        
                        SocialInputField(
                            platform: "Instagram",
                            icon: "camera.fill",
                            color: .purple,
                            username: $profileData.instagramUsername
                        )
                        
                        SocialInputField(
                            platform: "Snapchat",
                            icon: "camera.viewfinder",
                            color: .yellow,
                            username: $profileData.snapchatUsername
                        )
                    }
                    
                    // Info
                    HStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.cyan)
                        
                        Text("Sosyal medya hesapların sadece arkadaşlarına görünür")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(white: 0.5))
                    }
                    .padding(12)
                    .background(Color.cyan.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            VStack {
                Spacer()
                OnboardingNavigationButtons(
                    canContinue: true,
                    showBack: true,
                    continueTitle: "Tamamla",
                    onContinue: onComplete,
                    onBack: onBack
                )
            }
        }
    }
}

struct SocialInputField: View {
    let platform: String
    let icon: String
    let color: Color
    @Binding var username: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(color)
            }
            
            TextField("@kullaniciadi", text: $username)
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .autocapitalization(.none)
                .autocorrectionDisabled()
        }
        .padding(12)
        .background(Color(white: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(white: 0.15), lineWidth: 1)
        )
    }
}

// MARK: - Additional Photos Step (Task 26.1)
struct AdditionalPhotosStep: View {
    @Binding var profileData: ProfileCreationData
    let onNext: () -> Void
    let onBack: () -> Void
    let onSkip: () -> Void
    
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showSourcePicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var draggedPhoto: UIImage?
    
    private var photoCount: Int {
        profileData.additionalPhotos.count
    }
    
    private var canAddMore: Bool {
        photoCount < 4 // Max 4 additional (5 total with profile photo)
    }
    
    var body: some View {
        ZStack {
            StepContainer(
                icon: "photo.on.rectangle.angled",
                title: "Ek Fotoğraflar",
                subtitle: "Profilini zenginleştirmek için 1-4 ek fotoğraf ekle"
            ) {
                VStack(spacing: 24) {
                    // Photo count indicator
                    HStack {
                        Text("Fotoğraflar")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(white: 0.5))
                        
                        Spacer()
                        
                        Text("\(photoCount + 1)/5") // +1 for profile photo
                            .font(.system(size: 12))
                            .foregroundStyle(photoCount >= 4 ? .orange : Color(white: 0.4))
                    }
                    
                    // Photo Grid with Drag & Drop
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        // Profile photo (not draggable, always first)
                        if let profilePhoto = profileData.profilePhoto {
                            PhotoGridItem(
                                image: profilePhoto,
                                isPrimary: true,
                                onDelete: nil
                            )
                        }
                        
                        // Additional photos (draggable)
                        ForEach(Array(profileData.additionalPhotos.enumerated()), id: \.offset) { index, photo in
                            PhotoGridItem(
                                image: photo,
                                isPrimary: false,
                                onDelete: {
                                    withAnimation(.spring(response: 0.3)) {
                                        profileData.additionalPhotos.remove(at: index)
                                    }
                                    let impact = UIImpactFeedbackGenerator(style: .medium)
                                    impact.impactOccurred()
                                }
                            )
                            .onDrag {
                                draggedPhoto = photo
                                return NSItemProvider(object: UIImage())
                            }
                            .onDrop(of: [.image], delegate: PhotoDropDelegate(
                                item: photo,
                                items: $profileData.additionalPhotos,
                                draggedItem: $draggedPhoto
                            ))
                        }
                        
                        // Add photo button
                        if canAddMore {
                            AddPhotoButton {
                                showSourcePicker = true
                            }
                        }
                    }
                    
                    // Info card
                    HStack(spacing: 12) {
                        Image(systemName: "hand.draw.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.cyan)
                        
                        Text("Fotoğrafları sürükleyerek sıralayabilirsin")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(white: 0.5))
                    }
                    .padding(14)
                    .background(Color.cyan.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Tips
                    VStack(alignment: .leading, spacing: 8) {
                        TipRow(icon: "checkmark.circle.fill", text: "Farklı açılardan fotoğraflar ekle", color: .green)
                        TipRow(icon: "checkmark.circle.fill", text: "Hobilerini gösteren fotoğraflar ilgi çeker", color: .green)
                        TipRow(icon: "xmark.circle.fill", text: "Grup fotoğraflarından kaçın", color: .red)
                    }
                    .padding(16)
                    .background(Color(white: 0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            
            VStack {
                Spacer()
                VStack(spacing: 12) {
                    OnboardingNavigationButtons(
                        canContinue: true,
                        showBack: true,
                        onContinue: onNext,
                        onBack: onBack
                    )
                    
                    Button(action: onSkip) {
                        Text("Bu adımı atla")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(white: 0.4))
                    }
                    .padding(.bottom, 8)
                }
            }
        }
        .confirmationDialog("Fotoğraf Kaynağı", isPresented: $showSourcePicker) {
            Button("Kamera") {
                showCamera = true
            }
            
            Button("Galeri") {
                showImagePicker = true
            }
            
            Button("İptal", role: .cancel) { }
        }
        .photosPicker(isPresented: $showImagePicker, selection: $selectedItem, matching: .images)
        .fullScreenCover(isPresented: $showCamera) {
            CameraView { image in
                addPhoto(image)
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        addPhoto(image)
                    }
                }
            }
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func addPhoto(_ image: UIImage) {
        guard canAddMore else {
            errorMessage = "Maksimum 5 fotoğraf ekleyebilirsin"
            showError = true
            return
        }
        
        // Check minimum resolution
        if image.size.width < 500 || image.size.height < 500 {
            errorMessage = "Fotoğraf en az 500x500 piksel olmalı"
            showError = true
            return
        }
        
        withAnimation(.spring(response: 0.4)) {
            profileData.additionalPhotos.append(image)
        }
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
}

// MARK: - Photo Grid Item
struct PhotoGridItem: View {
    let image: UIImage
    let isPrimary: Bool
    let onDelete: (() -> Void)?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isPrimary ? Color.cyan : Color(white: 0.15), lineWidth: isPrimary ? 2 : 1)
                )
            
            if isPrimary {
                // Primary badge
                Text("Ana")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.cyan)
                    .clipShape(Capsule())
                    .padding(8)
            } else if let onDelete = onDelete {
                // Delete button
                Button(action: onDelete) {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.6))
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .padding(8)
            }
        }
    }
}

// MARK: - Add Photo Button
struct AddPhotoButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(white: 0.08))
                    .frame(height: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                            .foregroundStyle(Color(white: 0.2))
                    )
                
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color(white: 0.12))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color(white: 0.4))
                    }
                    
                    Text("Ekle")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color(white: 0.4))
                }
            }
        }
    }
}

// MARK: - Photo Drop Delegate
struct PhotoDropDelegate: DropDelegate {
    let item: UIImage
    @Binding var items: [UIImage]
    @Binding var draggedItem: UIImage?
    
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem,
              draggedItem != item,
              let fromIndex = items.firstIndex(where: { $0 === draggedItem }),
              let toIndex = items.firstIndex(where: { $0 === item }) else {
            return
        }
        
        withAnimation(.spring(response: 0.3)) {
            items.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

// MARK: - Tip Row
struct TipRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(Color(white: 0.6))
        }
    }
}

// MARK: - Bio Input Step (Task 26.2)
struct BioInputStep: View {
    @Binding var profileData: ProfileCreationData
    let onNext: () -> Void
    let onBack: () -> Void
    let onSkip: () -> Void
    
    @FocusState private var isBioFocused: Bool
    
    private let maxCharacters = 500
    
    private var characterCount: Int {
        profileData.bio.count
    }
    
    private var remainingCharacters: Int {
        maxCharacters - characterCount
    }
    
    private var counterColor: Color {
        if remainingCharacters <= 0 {
            return .red
        } else if remainingCharacters <= 50 {
            return .orange
        } else {
            return Color(white: 0.4)
        }
    }
    
    var body: some View {
        ZStack {
            StepContainer(
                icon: "text.quote",
                title: "Hakkında",
                subtitle: "Kendini birkaç cümleyle tanıt"
            ) {
                VStack(spacing: 24) {
                    // Bio Input
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Bio")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color(white: 0.5))
                            
                            Spacer()
                            
                            // Live character counter
                            Text("\(characterCount)/\(maxCharacters)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(counterColor)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $profileData.bio)
                                .font(.system(size: 16))
                                .foregroundStyle(.white)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 150, maxHeight: 200)
                                .padding(14)
                                .background(Color(white: 0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(isBioFocused ? Color.cyan : Color(white: 0.15), lineWidth: isBioFocused ? 2 : 1)
                                )
                                .focused($isBioFocused)
                                .onChange(of: profileData.bio) { _, newValue in
                                    // Enforce character limit
                                    if newValue.count > maxCharacters {
                                        profileData.bio = String(newValue.prefix(maxCharacters))
                                    }
                                }
                            
                            if profileData.bio.isEmpty {
                                Text("Merhaba! Ben...")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color(white: 0.3))
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 22)
                                    .allowsHitTesting(false)
                            }
                        }
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(white: 0.15))
                                    .frame(height: 4)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(counterColor)
                                    .frame(width: geometry.size.width * min(CGFloat(characterCount) / CGFloat(maxCharacters), 1.0), height: 4)
                                    .animation(.spring(response: 0.3), value: characterCount)
                            }
                        }
                        .frame(height: 4)
                    }
                    
                    // Suggestions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Öneriler")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(white: 0.5))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                BioSuggestionChip(text: "Hobilerinden bahset") {
                                    appendToBio("Hobilerim: ")
                                }
                                BioSuggestionChip(text: "Ne iş yapıyorsun?") {
                                    appendToBio("Mesleğim: ")
                                }
                                BioSuggestionChip(text: "Favori müzik türün") {
                                    appendToBio("Favori müzik: ")
                                }
                                BioSuggestionChip(text: "Hayalindeki tatil") {
                                    appendToBio("Hayalimdeki tatil: ")
                                }
                            }
                        }
                    }
                    
                    // Info card
                    HStack(spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.yellow)
                        
                        Text("İlgi çekici bir bio, profilinin daha fazla görülmesini sağlar")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(white: 0.5))
                    }
                    .padding(14)
                    .background(Color.yellow.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            VStack {
                Spacer()
                VStack(spacing: 12) {
                    OnboardingNavigationButtons(
                        canContinue: true,
                        showBack: true,
                        onContinue: onNext,
                        onBack: onBack
                    )
                    
                    Button(action: onSkip) {
                        Text("Bu adımı atla")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(white: 0.4))
                    }
                    .padding(.bottom, 8)
                }
            }
        }
        .onTapGesture {
            isBioFocused = false
        }
    }
    
    private func appendToBio(_ text: String) {
        let newText = profileData.bio.isEmpty ? text : profileData.bio + "\n" + text
        if newText.count <= maxCharacters {
            profileData.bio = newText
            isBioFocused = true
        }
    }
}

// MARK: - Bio Suggestion Chip
struct BioSuggestionChip: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.cyan)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.cyan.opacity(0.15))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                )
        }
    }
}


// MARK: - Badge Select Step (Task 26.4)
struct BadgeSelectStep: View {
    @Binding var profileData: ProfileCreationData
    let onNext: () -> Void
    let onBack: () -> Void
    let onSkip: () -> Void
    
    private let maxBadges = 5
    
    private let availableBadges: [(emoji: String, name: String)] = [
        ("🔥", "Enerjik"),
        ("🎮", "Gamer"),
        ("🎧", "Müzikçi"),
        ("📸", "Estetik"),
        ("🤝", "Sosyal"),
        ("😂", "Komik"),
        ("💪", "Sporcu"),
        ("📚", "Kitap Kurdu"),
        ("🎬", "Sinefil"),
        ("✈️", "Gezgin")
    ]
    
    private var selectedCount: Int {
        profileData.badges.count
    }
    
    private var canSelectMore: Bool {
        selectedCount < maxBadges
    }
    
    var body: some View {
        ZStack {
            StepContainer(
                icon: "sparkles",
                title: "Rozetlerini Seç",
                subtitle: "Seni en iyi tanımlayan 5 rozet seç"
            ) {
                VStack(spacing: 24) {
                    // Selection counter
                    HStack {
                        Text("Seçilen Rozetler")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(white: 0.5))
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("\(selectedCount)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(selectedCount >= maxBadges ? .orange : .cyan)
                            
                            Text("/")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(white: 0.4))
                            
                            Text("\(maxBadges)")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(white: 0.4))
                        }
                    }
                    
                    // Selected badges preview
                    if !profileData.badges.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(profileData.badges, id: \.self) { badgeName in
                                    if let badge = availableBadges.first(where: { $0.name == badgeName }) {
                                        SelectedBadgeChip(emoji: badge.emoji, name: badge.name) {
                                            withAnimation(.spring(response: 0.3)) {
                                                profileData.badges.removeAll { $0 == badgeName }
                                            }
                                            let impact = UIImpactFeedbackGenerator(style: .light)
                                            impact.impactOccurred()
                                        }
                                    }
                                }
                            }
                        }
                        .frame(height: 44)
                    }
                    
                    // Badge Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(availableBadges, id: \.name) { badge in
                            let isSelected = profileData.badges.contains(badge.name)
                            
                            BadgeOptionButton(
                                emoji: badge.emoji,
                                name: badge.name,
                                isSelected: isSelected,
                                isDisabled: !isSelected && !canSelectMore
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    if isSelected {
                                        profileData.badges.removeAll { $0 == badge.name }
                                    } else if canSelectMore {
                                        profileData.badges.append(badge.name)
                                    }
                                }
                                
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                            }
                        }
                    }
                    
                    // Info card
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.cyan)
                        
                        Text("Rozetler profilinde görünür ve ortak ilgi alanlarını bulmana yardımcı olur")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(white: 0.5))
                    }
                    .padding(14)
                    .background(Color.cyan.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            VStack {
                Spacer()
                VStack(spacing: 12) {
                    OnboardingNavigationButtons(
                        canContinue: true,
                        showBack: true,
                        onContinue: onNext,
                        onBack: onBack
                    )
                    
                    Button(action: onSkip) {
                        Text("Bu adımı atla")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(white: 0.4))
                    }
                    .padding(.bottom, 8)
                }
            }
        }
    }
}

// MARK: - Badge Option Button
struct BadgeOptionButton: View {
    let emoji: String
    let name: String
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(emoji)
                    .font(.system(size: 24))
                
                Text(name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(isSelected ? .white : Color(white: 0.7))
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.cyan)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.cyan.opacity(0.15) : Color(white: 0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.cyan : Color(white: 0.15), lineWidth: isSelected ? 2 : 1)
            )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Selected Badge Chip
struct SelectedBadgeChip: View {
    let emoji: String
    let name: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(emoji)
                .font(.system(size: 16))
            
            Text(name)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(white: 0.5))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.cyan.opacity(0.2))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.cyan.opacity(0.4), lineWidth: 1)
        )
    }
}


// MARK: - Social Links Step (Task 26.6)
struct SocialLinksStep: View {
    @Binding var profileData: ProfileCreationData
    let onComplete: () -> Void
    let onBack: () -> Void
    let onSkip: () -> Void
    
    @FocusState private var focusedField: SocialPlatform?
    
    enum SocialPlatform {
        case tiktok
        case instagram
        case snapchat
    }
    
    private var hasAnySocialLink: Bool {
        !profileData.tiktokUsername.isEmpty ||
        !profileData.instagramUsername.isEmpty ||
        !profileData.snapchatUsername.isEmpty
    }
    
    var body: some View {
        ZStack {
            StepContainer(
                icon: "link.circle.fill",
                title: "Sosyal Medya",
                subtitle: "Arkadaşlarınla bağlantı kurmak için hesaplarını ekle"
            ) {
                VStack(spacing: 24) {
                    // TikTok Input
                    SocialLinkInputField(
                        platform: "TikTok",
                        icon: "play.rectangle.fill",
                        color: .pink,
                        placeholder: "kullaniciadi",
                        prefix: "@",
                        username: $profileData.tiktokUsername,
                        isFocused: focusedField == .tiktok
                    )
                    .focused($focusedField, equals: .tiktok)
                    
                    // Instagram Input
                    SocialLinkInputField(
                        platform: "Instagram",
                        icon: "camera.fill",
                        color: .purple,
                        placeholder: "kullaniciadi",
                        prefix: "@",
                        username: $profileData.instagramUsername,
                        isFocused: focusedField == .instagram
                    )
                    .focused($focusedField, equals: .instagram)
                    
                    // Snapchat Input
                    SocialLinkInputField(
                        platform: "Snapchat",
                        icon: "camera.viewfinder",
                        color: .yellow,
                        placeholder: "kullaniciadi",
                        prefix: "",
                        username: $profileData.snapchatUsername,
                        isFocused: focusedField == .snapchat
                    )
                    .focused($focusedField, equals: .snapchat)
                    
                    // Privacy Info
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.cyan)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Gizlilik Koruması")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.white)
                                
                                Text("Sosyal medya hesapların sadece arkadaşlarına görünür")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color(white: 0.5))
                            }
                            
                            Spacer()
                        }
                        .padding(14)
                        .background(Color.cyan.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        HStack(spacing: 12) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(.green)
                            
                            Text("Arkadaşlık isteği kabul edildiğinde hesapların paylaşılır")
                                .font(.system(size: 12))
                                .foregroundStyle(Color(white: 0.5))
                            
                            Spacer()
                        }
                        .padding(14)
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Status indicator
                    if hasAnySocialLink {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.green)
                            
                            Text("En az bir hesap eklendi")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.green)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            
            VStack {
                Spacer()
                VStack(spacing: 12) {
                    OnboardingNavigationButtons(
                        canContinue: true,
                        showBack: true,
                        continueTitle: "Tamamla",
                        onContinue: onComplete,
                        onBack: onBack
                    )
                    
                    Button(action: onSkip) {
                        Text("Bu adımı atla")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(white: 0.4))
                    }
                    .padding(.bottom, 8)
                }
            }
        }
        .onTapGesture {
            focusedField = nil
        }
    }
}

// MARK: - Social Link Input Field
struct SocialLinkInputField: View {
    let platform: String
    let icon: String
    let color: Color
    let placeholder: String
    let prefix: String
    @Binding var username: String
    let isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Platform label
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
                
                Text(platform)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(white: 0.5))
                
                Spacer()
                
                if !username.isEmpty {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.green)
                }
            }
            
            // Input field
            HStack(spacing: 12) {
                // Platform icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(color)
                }
                
                // Text input
                HStack(spacing: 4) {
                    if !prefix.isEmpty {
                        Text(prefix)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color(white: 0.4))
                    }
                    
                    TextField(placeholder, text: $username)
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
            }
            .padding(12)
            .background(Color(white: 0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isFocused ? color : Color(white: 0.15), lineWidth: isFocused ? 2 : 1)
            )
        }
    }
}
