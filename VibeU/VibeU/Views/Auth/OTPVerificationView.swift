import SwiftUI

struct OTPVerificationView: View {
    let phone: String
    let verificationID: String
    
    @State private var viewModel: OTPViewModel
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    
    init(phone: String, verificationID: String) {
        self.phone = phone
        self.verificationID = verificationID
        self._viewModel = State(initialValue: OTPViewModel(phone: phone, verificationID: verificationID))
    }
    
    var body: some View {
        ZStack {

            if colorScheme == .dark {
                Color.black.ignoresSafeArea()
            } else {
                Color.white.ignoresSafeArea()
            }
            
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Text("verify_phone")
                        .font(.title.weight(.bold))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    
                    Text("otp_sent_to")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(phone)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.purple)
                }
                .padding(.top, 24)
                
                // OTP Input
                HStack(spacing: 10) {
                    ForEach(0..<6, id: \.self) { index in
                        OTPDigitBox(
                            digit: viewModel.digit(at: index),
                            isFocused: isFocused && viewModel.otpString.count == index
                        )
                    }
                }
                .padding(.horizontal, 24)
                .onTapGesture {
                    isFocused = true
                }
                
                // Hidden TextField
                TextField("", text: $viewModel.otpString)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .focused($isFocused)
                    .frame(width: 1, height: 1)
                    .opacity(0.01)
                    .onChange(of: viewModel.otpString) { _, newValue in
                        // Limit to 6 digits
                        if newValue.count > 6 {
                            viewModel.otpString = String(newValue.prefix(6))
                        }
                        // Auto verify when 6 digits entered
                        if newValue.count == 6 {
                            Task {
                                await viewModel.verifyOTP(appState: appState)
                            }
                        }
                    }
                
                // Resend Button
                Button {
                    Task {
                        await viewModel.resendOTP()
                    }
                } label: {
                    if viewModel.resendCountdown > 0 {
                        Text("resend_in_seconds \(viewModel.resendCountdown)")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("resend_code")
                            .foregroundStyle(.purple)
                    }
                }
                .font(.subheadline)
                .disabled(viewModel.resendCountdown > 0 || viewModel.isLoading)
                
                Spacer()
                
                // Error Message
                if let error = viewModel.errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text(error)
                            .font(.subheadline)
                    }
                    .padding()
                    .glassEffect()
                    .padding(.horizontal, 24)
                }
                
                // Loading
                if viewModel.isLoading {
                    GlassLoadingView()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
            }
        }
        .onAppear {
            isFocused = true
            viewModel.startResendTimer()
        }
        .sensoryFeedback(.error, trigger: viewModel.errorMessage)
    }
}

// MARK: - OTP Digit Box

struct OTPDigitBox: View {
    let digit: String
    let isFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                .glassEffect()
            
            Text(digit)
                .font(.title.monospacedDigit().weight(.semibold))
                .foregroundStyle(colorScheme == .dark ? .white : .black)
            
            if isFocused && digit.isEmpty {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.purple, lineWidth: 2)
            }
        }
        .frame(width: 48, height: 56)
        .animation(.easeInOut(duration: 0.15), value: digit)
    }
}

// MARK: - ViewModel

@Observable
final class OTPViewModel {
    let phone: String
    var verificationID: String
    var otpString = ""
    var isLoading = false
    var errorMessage: String?
    var resendCountdown = 60
    
    private var resendTimer: Timer?
    
    init(phone: String, verificationID: String) {
        self.phone = phone
        self.verificationID = verificationID
    }
    
    func digit(at index: Int) -> String {
        guard index < otpString.count else { return "" }
        let stringIndex = otpString.index(otpString.startIndex, offsetBy: index)
        return String(otpString[stringIndex])
    }
    
    @MainActor
    func verifyOTP(appState: AppState) async {
        guard otpString.count == 6 else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. OTP doğrula
            let token = try await PhoneAuthManager.shared.verifyOTP(
                verificationID: verificationID,
                otp: otpString
            )
            
            // 2. Backend'e gönder
            let response = try await AuthService.shared.authenticateWithBackend(firebaseToken: token)
            
            // 3. App state güncelle
            appState.signIn(
                user: response.user,
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
            )
        } catch {
            errorMessage = error.localizedDescription
            otpString = ""
        }
        
        isLoading = false
    }
    
    @MainActor
    func resendOTP() async {
        guard resendCountdown == 0 else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            verificationID = try await PhoneAuthManager.shared.sendOTP(phone: phone)
            resendCountdown = 60
            startResendTimer()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func startResendTimer() {
        resendTimer?.invalidate()
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if self.resendCountdown > 0 {
                    self.resendCountdown -= 1
                } else {
                    self.resendTimer?.invalidate()
                }
            }
        }
    }
    
    deinit {
        resendTimer?.invalidate()
    }
}

#Preview {
    NavigationStack {
        OTPVerificationView(phone: "+905551234567", verificationID: "test")
            .environment(AppState())
    }
}
