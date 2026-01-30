import SwiftUI

// MARK: - Step 2: Lifestyle Selection (Glass Design)
struct LifestyleSelectionView: View {
    @Binding var data: OnboardingData
    let onNext: () -> Void
    let onBack: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    private var isDark: Bool { colorScheme == .dark }
    
    private var backgroundColor: Color {
        isDark ? Color(red: 0.04, green: 0.02, blue: 0.08) : Color.white
    }
    
    var isComplete: Bool {
        !data.drinking.isEmpty && !data.smoking.isEmpty && !data.exercise.isEmpty && !data.pets.isEmpty && !data.wantKids.isEmpty
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Bar
                ProgressBar(current: 2, total: 6, isDark: isDark)
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
                            
                            Text("Yaşam Tarzınız")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(isDark ? .white : .black)
                            
                            Text("Kendinizi tanımlayın")
                                .font(.system(size: 16))
                                .foregroundStyle(isDark ? .white.opacity(0.7) : .black.opacity(0.7))
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        
                        // Lifestyle Questions (2x2 Grid + 1)
                        VStack(spacing: 16) {
                            // Row 1: Alkol + Sigara
                            HStack(spacing: 16) {
                                LifestyleQuestion(
                                    title: "Alkol",
                                    icon: "wineglass",
                                    options: ["Hiç", "Sosyal", "Sık"],
                                    selected: $data.drinking,
                                    isDark: isDark
                                )
                                
                                LifestyleQuestion(
                                    title: "Sigara",
                                    icon: "smoke",
                                    options: ["Hiç", "Bazen", "Düzenli"],
                                    selected: $data.smoking,
                                    isDark: isDark
                                )
                            }
                            
                            // Row 2: Egzersiz + Evcil Hayvan
                            HStack(spacing: 16) {
                                LifestyleQuestion(
                                    title: "Egzersiz",
                                    icon: "figure.run",
                                    options: ["Hiç", "Bazen", "Düzenli"],
                                    selected: $data.exercise,
                                    isDark: isDark
                                )
                                
                                LifestyleQuestion(
                                    title: "Evcil Hayvan",
                                    icon: "pawprint",
                                    options: ["Yok", "Var", "İstiyorum"],
                                    selected: $data.pets,
                                    isDark: isDark
                                )
                            }
                            
                            // Row 3: Çocuk Planı (Full Width)
                            LifestyleQuestion(
                                title: "Çocuk Planı",
                                icon: "figure.2.and.child.holdinghands",
                                options: ["İstemiyorum", "Belki", "İstiyorum", "Var"],
                                selected: $data.wantKids,
                                isDark: isDark,
                                isFullWidth: true
                            )
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
}

// MARK: - Lifestyle Question (Glass Design)
struct LifestyleQuestion: View {
    let title: String
    let icon: String
    let options: [String]
    @Binding var selected: String
    let isDark: Bool
    var isFullWidth: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon + Title
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(isDark ? .white.opacity(0.8) : .black.opacity(0.8))
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isDark ? .white : .black)
            }
            
            // Options
            if isFullWidth {
                // Horizontal scroll for full width
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(options, id: \.self) { option in
                            optionButton(option)
                        }
                    }
                }
            } else {
                // Vertical stack for grid items
                VStack(spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        optionButton(option)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: isFullWidth ? .infinity : nil)
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
    }
    
    private func optionButton(_ option: String) -> some View {
        let isSelected = selected == option
        let textColor = isSelected ? (isDark ? Color.black : Color.white) : (isDark ? Color.white.opacity(0.7) : Color.black.opacity(0.7))
        let bgColor = isSelected ? (isDark ? Color.white : Color.black) : (isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
        let strokeColor = isSelected ? (isDark ? Color.white.opacity(0.3) : Color.black.opacity(0.3)) : (isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
        
        return Button {
            selected = option
        } label: {
            Text(option)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(textColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: isFullWidth ? nil : .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(bgColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(strokeColor, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
