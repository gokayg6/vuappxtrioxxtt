import SwiftUI

// MARK: - Step 4: Personal Info (Glass Design + Min 15 Age)
struct PersonalInfoView: View {
    @Binding var data: OnboardingData
    let onNext: () -> Void
    let onBack: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    private var isDark: Bool { colorScheme == .dark }
    
    private let genders = ["Erkek", "Kadın", "Diğer"]
    private let zodiacs: [(icon: String, name: String)] = [
        ("flame", "Koç"),
        ("leaf", "Boğa"),
        ("person.2", "İkizler"),
        ("moon", "Yengeç"),
        ("sun.max", "Aslan"),
        ("sparkles", "Başak"),
        ("scale.3d", "Terazi"),
        ("drop", "Akrep"),
        ("arrow.up.right", "Yay"),
        ("mountain.2", "Oğlak"),
        ("wind", "Kova"),
        ("fish", "Balık")
    ]
    
    var isComplete: Bool {
        !data.gender.isEmpty && !data.zodiac.isEmpty && calculateAge() >= 15
    }
    
    private var backgroundColor: Color {
        isDark ? Color(red: 0.04, green: 0.02, blue: 0.08) : Color.white
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Bar
                ProgressBar(current: 4, total: 6, isDark: isDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        // Header
                        VStack(alignment: .leading, spacing: 12) {
                            Button(action: onBack) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(isDark ? .white : .black)
                            }
                            
                            Text("Kişisel Bilgiler")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(isDark ? .white : .black)
                            
                            Text("Kendinizi tanıtın")
                                .font(.system(size: 16))
                                .foregroundStyle(isDark ? .white.opacity(0.7) : .black.opacity(0.7))
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        
                        // Gender Selection
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "person")
                                    .font(.system(size: 18, weight: .medium))
                                Text("Cinsiyet")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundStyle(isDark ? .white : .black)
                            
                            HStack(spacing: 12) {
                                ForEach(genders, id: \.self) { gender in
                                    genderButton(gender)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Birth Date
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 18, weight: .medium))
                                Text("Doğum Tarihi")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundStyle(isDark ? .white : .black)
                            
                            DatePicker("", selection: $data.dateOfBirth, in: ...Date(), displayedComponents: .date)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .colorScheme(isDark ? .dark : .light)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(.ultraThinMaterial)
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.1), lineWidth: 1)
                                )
                            
                            if calculateAge() < 15 {
                                Text("15 yaşından küçükler kayıt olamaz")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.red.opacity(0.8))
                            } else {
                                Text("Yaşınız: \(calculateAge())")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.green.opacity(0.8))
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Zodiac Selection
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 18, weight: .medium))
                                Text("Burç")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundStyle(isDark ? .white : .black)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(zodiacs, id: \.name) { zodiac in
                                    zodiacButton(zodiac)
                                }
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
                                .fill(isComplete ? (isDark ? .white : .black) : (isDark ? Color.white.opacity(0.2) : Color.black.opacity(0.2)))
                        )
                }
                .disabled(!isComplete)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
    
    private func calculateAge() -> Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: data.dateOfBirth, to: Date())
        return ageComponents.year ?? 0
    }
    
    private func genderButton(_ gender: String) -> some View {
        let isSelected = data.gender == gender
        let textColor = isSelected ? (isDark ? Color.black : Color.white) : (isDark ? Color.white.opacity(0.7) : Color.black.opacity(0.7))
        let bgColor = isSelected ? (isDark ? Color.white : Color.black) : (isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
        let strokeColor = isSelected ? (isDark ? Color.white.opacity(0.3) : Color.black.opacity(0.3)) : (isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
        let strokeWidth: CGFloat = isSelected ? 2 : 1
        
        return Button {
            data.gender = gender
        } label: {
            Text(gender)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(bgColor)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(strokeColor, lineWidth: strokeWidth)
                )
        }
        .buttonStyle(.plain)
    }
    
    private func zodiacButton(_ zodiac: (icon: String, name: String)) -> some View {
        let isSelected = data.zodiac == zodiac.name
        let textColor = isSelected ? (isDark ? Color.black : Color.white) : (isDark ? Color.white.opacity(0.7) : Color.black.opacity(0.7))
        let bgColor = isSelected ? (isDark ? Color.white : Color.black) : (isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
        let strokeColor = isSelected ? (isDark ? Color.white.opacity(0.3) : Color.black.opacity(0.3)) : (isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
        let strokeWidth: CGFloat = isSelected ? 2 : 1
        
        return Button {
            data.zodiac = zodiac.name
        } label: {
            VStack(spacing: 8) {
                Image(systemName: zodiac.icon)
                    .font(.system(size: 20, weight: .medium))
                
                Text(zodiac.name)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(bgColor)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(strokeColor, lineWidth: strokeWidth)
            )
        }
        .buttonStyle(.plain)
    }
}
