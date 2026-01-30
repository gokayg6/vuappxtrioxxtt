import SwiftUI

// MARK: - Step 3: Phone/Email Verification
struct VerificationView: View {
    @Binding var data: OnboardingData
    let onNext: () -> Void
    let onBack: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    private var isDark: Bool { colorScheme == .dark }
    
    private var backgroundColor: Color {
        isDark ? Color(red: 0.04, green: 0.02, blue: 0.08) : Color.white
    }
    
    @State private var showCodeInput = false
    
    var isInputValid: Bool {
        if data.verificationType == .phone {
            return data.phoneNumber.count >= 10
        } else {
            return data.email.contains("@") && data.email.contains(".")
        }
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Bar
                ProgressBar(current: 3, total: 6, isDark: isDark)
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
                        
                        Text("Doğrulama")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(isDark ? .white : .black)
                        
                        Text("Telefon veya email ile doğrulayın")
                            .font(.system(size: 16))
                            .foregroundStyle(isDark ? .white.opacity(0.7) : .black.opacity(0.7))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    // Type Selector
                    HStack(spacing: 12) {
                        VerificationTypeButton(
                            icon: "phone.fill",
                            title: "Telefon",
                            isSelected: data.verificationType == .phone,
                            onTap: { data.verificationType = .phone; showCodeInput = false }
                        )
                        
                        VerificationTypeButton(
                            icon: "envelope.fill",
                            title: "Email",
                            isSelected: data.verificationType == .email,
                            onTap: { data.verificationType = .email; showCodeInput = false }
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // Input Field
                    VStack(alignment: .leading, spacing: 16) {
                        if data.verificationType == .phone {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Telefon Numarası")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(isDark ? .white.opacity(0.7) : .black.opacity(0.7))
                                
                                TextField("5XX XXX XX XX", text: $data.phoneNumber)
                                    .keyboardType(.phonePad)
                                    .font(.system(size: 17))
                                    .foregroundStyle(isDark ? .white : .black)
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(.ultraThinMaterial)
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.1), lineWidth: 1)
                                    )
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email Adresi")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(isDark ? .white.opacity(0.7) : .black.opacity(0.7))
                                
                                TextField("ornek@email.com", text: $data.email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .font(.system(size: 17))
                                    .foregroundStyle(isDark ? .white : .black)
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(.ultraThinMaterial)
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.1), lineWidth: 1)
                                    )
                            }
                        }
                        
                        // Code Input (if verification sent)
                        if showCodeInput {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Doğrulama Kodu")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(isDark ? .white.opacity(0.7) : .black.opacity(0.7))
                                
                                TextField("6 haneli kod", text: $data.verificationCode)
                                    .keyboardType(.numberPad)
                                    .font(.system(size: 17))
                                    .foregroundStyle(isDark ? .white : .black)
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(.ultraThinMaterial)
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.1), lineWidth: 1)
                                    )
                                
                                Text("Test modunda kod gerekmez")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.green.opacity(0.8))
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Color.clear.frame(height: 100)
                }
            }
            
                // Action Button
                Button {
                    if showCodeInput {
                        // Verify code (test mode - skip)
                        onNext()
                    } else {
                        // Send code (test mode - just show input)
                        showCodeInput = true
                    }
                } label: {
                    Text(showCodeInput ? "Devam Et" : "Kod Gönder")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(isDark ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isInputValid ? (isDark ? .white : .black) : (isDark ? Color.white.opacity(0.2) : Color.black.opacity(0.2)))
                        )
                }
                .disabled(!isInputValid)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - Verification Type Button
struct VerificationTypeButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    private var isDark: Bool { colorScheme == .dark }
    
    private var textColor: Color {
        isSelected ? (isDark ? .black : .white) : (isDark ? .white.opacity(0.7) : .black.opacity(0.7))
    }
    
    private var bgColor: Color {
        isSelected ? (isDark ? .white : .black) : (isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
    }
    
    private var strokeColor: Color {
        isSelected ? (isDark ? Color.white.opacity(0.3) : Color.black.opacity(0.3)) : (isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
    }
    
    private var strokeWidth: CGFloat {
        isSelected ? 2 : 1
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
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
