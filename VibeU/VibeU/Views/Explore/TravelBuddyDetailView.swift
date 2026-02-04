import SwiftUI

// MARK: - Travel Buddy Detail View
// Super detailed travel matching with bubilet.com integration
struct TravelBuddyDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    
    @State private var selectedDestination: TravelDestination?
    @State private var selectedTravelStyle: String = "Hepsi".localized
    @State private var selectedBudget: String = "Hepsi".localized
    @State private var selectedDuration: String = "Hepsi".localized
    @State private var searchText = ""
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    
    let travelStyles = ["Hepsi".localized, "Macera".localized, "Kültür".localized, "Plaj".localized, "Doğa".localized, "Şehir Turu".localized, "Gastronomi".localized, "Tarih".localized, "Lüks".localized, "Backpacking".localized]
    let budgets = ["Hepsi".localized, "Ekonomik (₺)", "Orta (₺₺)", "Konforlu (₺₺₺)", "Lüks (₺₺₺₺)"]
    let durations = ["Hepsi".localized, "Hafta Sonu".localized, "3-5 Gün".localized, "1 Hafta".localized, "2 Hafta".localized, "1 Ay+".localized]

    
    var filteredDestinations: [TravelDestination] {
        destinations.filter { dest in
            (selectedTravelStyle == "Hepsi".localized || dest.styles.contains(selectedTravelStyle)) &&
            (selectedBudget == "Hepsi".localized || dest.budget == selectedBudget) &&

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
                            FilterMenu(title: "Stil".localized, selection: $selectedTravelStyle, options: travelStyles)
                            FilterMenu(title: "Bütçe".localized, selection: $selectedBudget, options: budgets)
                            FilterMenu(title: "Süre".localized, selection: $selectedDuration, options: durations)
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
            TravelDestination(id: "1", name: "Kapadokya", country: "Türkiye".localized, imageURL: "https://images.unsplash.com/photo-1541432901042-2d8bd64b4a9b?w=800", styles: ["Macera".localized, "Kültür".localized, "Doğa".localized], budget: "Orta (₺₺)".localized, travelers: 450, rating: 4.9, description: "Balon turu, peribacaları, yeraltı şehirleri".localized, highlights: ["Sıcak Hava Balonu".localized, "Göreme Açık Hava Müzesi".localized, "Yeraltı Şehirleri".localized, "Kaya Oteller".localized]),
            TravelDestination(id: "2", name: "Antalya", country: "Türkiye".localized, imageURL: "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800", styles: ["Plaj".localized, "Tarih".localized, "Doğa".localized], budget: "Orta (₺₺)".localized, travelers: 680, rating: 4.7, description: "Akdeniz kıyısı, antik kentler".localized, highlights: ["Kaleiçi".localized, "Düden Şelalesi".localized, "Aspendos".localized, "Plajlar".localized]),
            TravelDestination(id: "3", name: "İstanbul", country: "Türkiye".localized, imageURL: "https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=800", styles: ["Şehir Turu".localized, "Kültür".localized, "Tarih".localized, "Gastronomi".localized], budget: "Orta (₺₺)".localized, travelers: 920, rating: 4.8, description: "İki kıta, binlerce yıllık tarih".localized, highlights: ["Ayasofya".localized, "Topkapı Sarayı".localized, "Boğaz Turu".localized, "Kapalıçarşı".localized]),
            
            // Avrupa
            TravelDestination(id: "4", name: "Paris", country: "Fransa".localized, imageURL: "https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800", styles: ["Şehir Turu".localized, "Kültür".localized, "Gastronomi".localized, "Lüks".localized], budget: "Konforlu (₺₺₺)".localized, travelers: 1200, rating: 4.9, description: "Aşk şehri, sanat ve moda başkenti".localized, highlights: ["Eyfel Kulesi".localized, "Louvre".localized, "Notre Dame".localized, "Champs-Élysées".localized]),
            TravelDestination(id: "5", name: "Roma", country: "İtalya".localized, imageURL: "https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800", styles: ["Tarih".localized, "Kültür".localized, "Gastronomi".localized], budget: "Orta (₺₺)".localized, travelers: 890, rating: 4.8, description: "Antik Roma'nın kalbi".localized, highlights: ["Kolezyum".localized, "Vatikan".localized, "Trevi Çeşmesi".localized, "Pantheon".localized]),
            TravelDestination(id: "6", name: "Barselona", country: "İspanya".localized, imageURL: "https://images.unsplash.com/photo-1583422409516-2895a77efded?w=800", styles: ["Şehir Turu".localized, "Plaj".localized, "Kültür".localized], budget: "Orta (₺₺)".localized, travelers: 750, rating: 4.7, description: "Gaudí'nin şehri".localized, highlights: ["Sagrada Familia".localized, "Park Güell".localized, "La Rambla".localized, "Plajlar".localized]),
            TravelDestination(id: "7", name: "Amsterdam", country: "Hollanda".localized, imageURL: "https://images.unsplash.com/photo-1534351590666-13e3e96b5017?w=800", styles: ["Şehir Turu".localized, "Kültür".localized], budget: "Konforlu (₺₺₺)".localized, travelers: 620, rating: 4.6, description: "Kanallar şehri".localized, highlights: ["Anne Frank Evi".localized, "Van Gogh Müzesi".localized, "Kanal Turu".localized, "Bisiklet".localized]),
            
            // Asya
            TravelDestination(id: "8", name: "Tokyo", country: "Japonya".localized, imageURL: "https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800", styles: ["Şehir Turu".localized, "Kültür".localized, "Gastronomi".localized], budget: "Konforlu (₺₺₺)".localized, travelers: 980, rating: 4.9, description: "Gelecek ve gelenek".localized, highlights: ["Shibuya".localized, "Senso-ji".localized, "Tokyo Tower".localized, "Akihabara".localized]),
            TravelDestination(id: "9", name: "Bali", country: "Endonezya".localized, imageURL: "https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800", styles: ["Plaj".localized, "Doğa".localized, "Macera".localized], budget: "Ekonomik (₺)".localized, travelers: 1100, rating: 4.8, description: "Cennet ada".localized, highlights: ["Ubud".localized, "Tanah Lot".localized, "Plajlar".localized, "Pirinç Tarlaları".localized]),
            TravelDestination(id: "10", name: "Dubai", country: "BAE".localized, imageURL: "https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800", styles: ["Lüks".localized, "Şehir Turu".localized, "Macera".localized], budget: "Lüks (₺₺₺₺)".localized, travelers: 850, rating: 4.7, description: "Çöldeki mucize".localized, highlights: ["Burj Khalifa".localized, "Dubai Mall".localized, "Çöl Safari".localized, "Palm Jumeirah".localized]),
            
            // Add 40 more destinations
            TravelDestination(id: "11", name: "Santorini", country: "Yunanistan".localized, imageURL: "https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800", styles: ["Plaj".localized, "Romantik".localized], budget: "Konforlu (₺₺₺)".localized, travelers: 560, rating: 4.9, description: "Beyaz evler, mavi kubbeler".localized, highlights: ["Oia Gün Batımı".localized, "Fira".localized, "Plajlar".localized, "Şarap Turları".localized]),
            TravelDestination(id: "12", name: "Prag", country: "Çek Cumhuriyeti".localized, imageURL: "https://images.unsplash.com/photo-1541849546-216549ae216d?w=800", styles: ["Şehir Turu".localized, "Tarih".localized], budget: "Ekonomik (₺)".localized, travelers: 490, rating: 4.6, description: "Masal şehri".localized, highlights: ["Prag Kalesi".localized, "Charles Köprüsü".localized, "Eski Şehir Meydanı".localized]),
            TravelDestination(id: "13", name: "Maldivler", country: "Maldivler".localized, imageURL: "https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=800", styles: ["Plaj".localized, "Lüks".localized], budget: "Lüks (₺₺₺₺)".localized, travelers: 320, rating: 5.0, description: "Tropik cennet".localized, highlights: ["Su Üstü Villalar".localized, "Dalış".localized, "Spa".localized, "Romantik Akşam Yemekleri".localized]),
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
                Text(selection == "Hepsi".localized ? title : selection)

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
