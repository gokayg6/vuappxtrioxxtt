import SwiftUI

// MARK: - Step 1: Hobbies Selection (Min 5) - Glass Design
struct HobbiesSelectionView: View {
    @Binding var data: OnboardingData
    let onNext: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    private var isDark: Bool { colorScheme == .dark }
    
    private var backgroundColor: Color {
        isDark ? Color(red: 0.04, green: 0.02, blue: 0.08) : Color.white
    }
    
    private let availableHobbies: [(icon: String, title: String)] = [
        ("music.note", "Müzik"),
        ("airplane", "Seyahat"),
        ("camera", "Fotoğrafçılık"),
        ("figure.pool.swim", "Yüzme"),
        ("figure.yoga", "Yoga"),
        ("book", "Kitap"),
        ("gamecontroller", "Oyun"),
        ("film", "Sinema"),
        ("fork.knife", "Yemek"),
        ("paintpalette", "Sanat"),
        ("sportscourt", "Futbol"),
        ("basketball", "Basketbol"),
        ("tennis.racket", "Tenis"),
        ("figure.run", "Koşu"),
        ("bicycle", "Bisiklet"),
        ("theatermasks", "Tiyatro"),
        ("mic", "Karaoke"),
        ("guitars", "Gitar"),
        ("pianokeys", "Piyano"),
        ("figure.dance", "Dans"),
        ("leaf", "Bahçecilik"),
        ("pawprint", "Hayvanlar"),
        ("target", "Dart"),
        ("circle.grid.cross", "Bilardo"),
        ("checkerboard.shield", "Satranç")
    ]
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Bar
                ProgressBar(current: 1, total: 6, isDark: isDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Hobilerinizi Seçin")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(isDark ? .white : .black)
                            
                            Text("En az 5 hobi seçmelisiniz")
                                .font(.system(size: 16))
                                .foregroundStyle(isDark ? .white.opacity(0.7) : .black.opacity(0.7))
                            
                            Text("\(data.hobbies.count)/5 seçildi")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(data.hobbies.count >= 5 ? .green : .orange)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                                )
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                        
                        // Hobbies Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(availableHobbies, id: \.title) { hobby in
                                HobbyChip(
                                    icon: hobby.icon,
                                    title: hobby.title,
                                    isSelected: data.hobbies.contains(hobby.title),
                                    isDark: isDark,
                                    onTap: { toggleHobby(hobby.title) }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Color.clear.frame(height: 100)
                    }
                }
                
                // Next Button
                Button {
                    onNext()
                } label: {
                    Text("Devam Et")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(isDark ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(data.hobbies.count >= 5 ? (isDark ? .white : .black) : (isDark ? Color.white.opacity(0.2) : Color.black.opacity(0.2)))
                        )
                }
                .disabled(data.hobbies.count < 5)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
    
    private func toggleHobby(_ hobby: String) {
        if data.hobbies.contains(hobby) {
            data.hobbies.removeAll { $0 == hobby }
        } else {
            data.hobbies.append(hobby)
        }
    }
}

// MARK: - Hobby Chip (Glass Design)
struct HobbyChip: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let isDark: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(isSelected ? (isDark ? .black : .white) : (isDark ? .white.opacity(0.7) : .black.opacity(0.7)))
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isSelected ? (isDark ? .black : .white) : (isDark ? .white.opacity(0.7) : .black.opacity(0.7)))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(glassBackground)
            .overlay(glassStroke)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var glassBackground: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 16)
                .fill(isDark ? .white : .black)
        } else {
            RoundedRectangle(cornerRadius: 16)
                .fill(isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
        }
    }
    
    @ViewBuilder
    private var glassStroke: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 16)
                .stroke(isDark ? Color.white.opacity(0.3) : Color.black.opacity(0.3), lineWidth: 2)
        } else {
            RoundedRectangle(cornerRadius: 16)
                .stroke(isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.1), lineWidth: 1)
        }
    }
}

// MARK: - Progress Bar (Updated)
struct ProgressBar: View {
    let current: Int
    let total: Int
    let isDark: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(1...total, id: \.self) { step in
                    Capsule()
                        .fill(step <= current ? (isDark ? .white : .black) : (isDark ? Color.white.opacity(0.2) : Color.black.opacity(0.2)))
                        .frame(height: 4)
                }
            }
            
            HStack {
                Text("Adım \(current)/\(total)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isDark ? .white.opacity(0.6) : .black.opacity(0.6))
                Spacer()
            }
        }
    }
}
