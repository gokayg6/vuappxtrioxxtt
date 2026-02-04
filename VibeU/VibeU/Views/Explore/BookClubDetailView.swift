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
            Book(id: "1", title: "Kürk Mantolu Madonna", author: "Sabahattin Ali", genre: "Klasik".localized, year: 1943, pages: 176, rating: 4.8, readers: 1250, imageURL: "https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400", description: "Türk edebiyatının başyapıtlarından biri".localized),
            Book(id: "2", title: "Tutunamayanlar", author: "Oğuz Atay", genre: "Roman".localized, year: 1971, pages: 724, rating: 4.7, readers: 890, imageURL: "https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400", description: "Modern Türk romanının kilometre taşı".localized),
            Book(id: "3", title: "1984", author: "George Orwell", genre: "Bilim Kurgu".localized, year: 1949, pages: 328, rating: 4.9, readers: 2100, imageURL: "https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400", description: "Distopik edebiyatın başyapıtı".localized),
            Book(id: "4", title: "Suç ve Ceza", author: "Dostoyevski", genre: "Klasik".localized, year: 1866, pages: 671, rating: 4.8, readers: 1560, imageURL: "https://images.unsplash.com/photo-1524578271613-d550eacf6090?w=400", description: "Psikolojik roman".localized),
            Book(id: "5", title: "Yüzüklerin Efendisi", author: "J.R.R. Tolkien", genre: "Fantastik".localized, year: 1954, pages: 1178, rating: 4.9, readers: 3200, imageURL: "https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400", description: "Fantastik edebiyatın zirvesi".localized),
            Book(id: "6", title: "Şeker Portakalı", author: "Jose Mauro de Vasconcelos", genre: "Roman".localized, year: 1968, pages: 192, rating: 4.7, readers: 980, imageURL: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400", description: "Çocukluk ve yoksulluk".localized),
            Book(id: "7", title: "Simyacı", author: "Paulo Coelho", genre: "Roman".localized, year: 1988, pages: 208, rating: 4.6, readers: 1780, imageURL: "https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400", description: "Kişisel efsane arayışı".localized),
            Book(id: "8", title: "Beyaz Zambaklar Ülkesinde", author: "Grigory Petrov", genre: "Tarih".localized, year: 1923, pages: 144, rating: 4.5, readers: 670, imageURL: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400", description: "Finlandiya'nın gelişimi".localized),
            Book(id: "9", title: "İnce Memed", author: "Yaşar Kemal", genre: "Roman".localized, year: 1955, pages: 448, rating: 4.7, readers: 1120, imageURL: "https://images.unsplash.com/photo-1519682337058-a94d519337bc?w=400", description: "Çukurova destanı".localized),
            Book(id: "10", title: "Fareler ve İnsanlar", author: "John Steinbeck", genre: "Klasik".localized, year: 1937, pages: 107, rating: 4.6, readers: 890, imageURL: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400", description: "Dostluk ve hayaller".localized),

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
