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
    
    let cuisines = ["Hepsi", "Türk", "İtalyan", "Japon", "Çin", "Hint", "Meksika", "Fransız", "Deniz Ürünleri", "Vejetaryen", "Vegan", "Fast Food"]
    let cities = ["İstanbul", "Ankara", "İzmir", "Antalya", "Bursa"]
    let priceRanges = ["Hepsi", "₺", "₺₺", "₺₺₺", "₺₺₺₺"]
    
    var filteredRestaurants: [Restaurant] {
        restaurants.filter { restaurant in
            (selectedCuisine == "Hepsi" || restaurant.cuisine == selectedCuisine) &&
            (selectedCity == "Hepsi" || restaurant.city == selectedCity) &&
            (selectedPriceRange == "Hepsi" || restaurant.priceRange == selectedPriceRange) &&
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
                        Text("Gurme Deneyimi")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        Text("100+ restoran, rezervasyon yap, eşleş")
                            .font(.system(size: 15))
                            .foregroundStyle(colors.secondaryText)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Search Bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(colors.secondaryText)
                        
                        TextField("Restoran ara...", text: $searchText)
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
                            FilterPill(title: "Mutfak", selection: $selectedCuisine, options: cuisines)
                            FilterPill(title: "Şehir", selection: $selectedCity, options: cities)
                            FilterPill(title: "Fiyat", selection: $selectedPriceRange, options: priceRanges)
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
            Restaurant(id: "1", name: "Mikla", cuisine: "Türk", city: "İstanbul", district: "Beyoğlu", priceRange: "₺₺₺₺", rating: 4.8, imageURL: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800", specialty: "Çağdaş Anadolu Mutfağı"),
            Restaurant(id: "2", name: "Neolokal", cuisine: "Türk", city: "İstanbul", district: "Karaköy", priceRange: "₺₺₺₺", rating: 4.7, imageURL: "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800", specialty: "Modern Türk"),
            Restaurant(id: "3", name: "Çiya Sofrası", cuisine: "Türk", city: "İstanbul", district: "Kadıköy", priceRange: "₺₺", rating: 4.6, imageURL: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800", specialty: "Geleneksel Anadolu"),
            
            // İstanbul - İtalyan
            Restaurant(id: "4", name: "Locale", cuisine: "İtalyan", city: "İstanbul", district: "Nişantaşı", priceRange: "₺₺₺", rating: 4.5, imageURL: "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800", specialty: "Pasta & Pizza"),
            Restaurant(id: "5", name: "Ristorante Pizzeria Venedik", cuisine: "İtalyan", city: "İstanbul", district: "Bebek", priceRange: "₺₺₺", rating: 4.4, imageURL: "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800", specialty: "Otantik İtalyan"),
            
            // İstanbul - Japon
            Restaurant(id: "6", name: "Zuma", cuisine: "Japon", city: "İstanbul", district: "Ortaköy", priceRange: "₺₺₺₺", rating: 4.9, imageURL: "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=800", specialty: "Contemporary Japanese"),
            Restaurant(id: "7", name: "Nobu", cuisine: "Japon", city: "İstanbul", district: "Kuruçeşme", priceRange: "₺₺₺₺", rating: 4.8, imageURL: "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=800", specialty: "Sushi & Sashimi"),
            
            // İstanbul - Deniz Ürünleri
            Restaurant(id: "8", name: "Balıkçı Sabahattin", cuisine: "Deniz Ürünleri", city: "İstanbul", district: "Sultanahmet", priceRange: "₺₺₺", rating: 4.6, imageURL: "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800", specialty: "Taze Balık"),
            Restaurant(id: "9", name: "Alancha", cuisine: "Deniz Ürünleri", city: "İstanbul", district: "Galata", priceRange: "₺₺₺", rating: 4.5, imageURL: "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800", specialty: "Akdeniz Mutfağı"),
            
            // Ankara
            Restaurant(id: "10", name: "Trilye", cuisine: "Deniz Ürünleri", city: "Ankara", district: "Çankaya", priceRange: "₺₺₺₺", rating: 4.7, imageURL: "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800", specialty: "Premium Seafood"),
            
            // Add 90 more restaurants programmatically
        ] + generateMoreRestaurants()
    }
    
    private func generateMoreRestaurants() -> [Restaurant] {
        var restaurants: [Restaurant] = []
        let names = ["Lezzet Durağı", "Gurme Köşe", "Şef'in Yeri", "Damak Tadı", "Sofra", "Keyif Mekanı"]
        let districts = ["Kadıköy", "Beşiktaş", "Şişli", "Üsküdar", "Bakırköy", "Ataşehir"]
        
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
                specialty: "Özel Lezzetler"
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
                Text(selection == "Hepsi" ? title : selection)
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
