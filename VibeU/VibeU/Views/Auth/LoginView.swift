import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var isRememberMe = true
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Dynamic Background
            if colorScheme == .dark {
                MeshGradientBackground()
                    .ignoresSafeArea()
            } else {
                Color.white
                    .ignoresSafeArea()
            }
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .indigo],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .purple.opacity(0.5), radius: 20)
                        
                        Text("Tekrar Hoş Geldin")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text("Hesabına giriş yap ve Vibe'ı yakala")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Form Card
                    VStack(spacing: 20) {
                        // Email Field
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(.secondary)
                            TextField("E-posta", text: $email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                        }
                        .padding()
                        .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        // Password Field
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.secondary)
                            SecureField("Şifre", text: $password)
                                .textContentType(.password)
                        }
                        .padding()
                        .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        // Remember Me & Forgot Password
                        HStack {
                            Toggle(isOn: $isRememberMe) {
                                Text("Beni Hatırla")
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            }
                            .toggleStyle(CheckboxToggleStyle())
                            
                            Spacer()
                            
                            Button("Şifremi Unuttum?") {
                                // Forgot password action
                            }
                            .font(.subheadline)
                            .foregroundStyle(.purple)
                        }
                        
                        // Login Button
                        Button {
                            Task {
                                await viewModel.login(email: email, password: password, appState: appState)
                            }
                        } label: {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Giriş Yap")
                                    .font(.headline)
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [.purple, .indigo],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 5)
                        .disabled(email.isEmpty || password.isEmpty || viewModel.isLoading)
                        .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1)
                        
                        // Divider
                        HStack {
                            Rectangle().fill(.secondary.opacity(0.3)).frame(height: 1)
                            Text("veya")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Rectangle().fill(.secondary.opacity(0.3)).frame(height: 1)
                        }
                        .padding(.vertical, 10)
                        
                        // Social Login Buttons
                        VStack(spacing: 12) {
                            // Google
                            Button {
                                viewModel.signInWithGoogle(appState: appState)
                            } label: {
                                AuthButtonContent(
                                    icon: "g.circle.fill",
                                    title: "Google ile Giriş Yap",
                                    isPrimary: false
                                )
                            }
                            
                            // Apple
                            SignInWithAppleButton(.signIn) { request in
                                request.requestedScopes = [.fullName, .email]
                            } onCompletion: { result in
                                viewModel.handleAppleSignIn(result: result, appState: appState)
                            }
                            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                            .frame(height: 52)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .background(.ultraThinMaterial)
                            
                            // Phone
                            NavigationLink {
                                PhoneAuthView()
                            } label: {
                                AuthButtonContent(
                                    icon: "phone.fill",
                                    title: "Telefon ile Giriş Yap",
                                    isPrimary: false
                                )
                            }
                        }
                    }
                    .padding(24)
                    .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color.white)) // Glass Card / Solid Card
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(false)
        .alert("Hata", isPresented: $viewModel.showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

// Custom Checkbox Style
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundStyle(configuration.isOn ? .purple : .secondary)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
        }
    }
}


