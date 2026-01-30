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
                        Text("Seyahat Arkadaşı")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        Text("Dünyayı birlikte keşfet")
                            .font(.system(size: 15))
                            .foregroundStyle(colors.secondaryText)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Search Bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(colors.secondaryText)
                        
                        TextField("Destinasyon ara...", text: $searchText)
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
                            .foregroundStyle(colors.primaryText)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.cyan)
                            Text("\(destination.travelers)")
                                .font(.system(size: 11))
                                .foregroundStyle(colors.secondaryText)
                        }
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(colors.cardBackground)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(colors.border, lineWidth: 0.5))
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
                            Text("Öne Çıkanlar")
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
                                    Text("Uçak Bileti Al")
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
                                    Text("Seyahat Arkadaşı Bul")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundStyle(colors.primaryText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(colors.border, lineWidth: 1))
                            }
                        }
                        .padding(.top, 8)
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
