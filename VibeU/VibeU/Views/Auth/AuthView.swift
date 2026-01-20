import SwiftUI
import AuthenticationServices

// MARK: - Landing Page (AuthView)
struct AuthView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                PremiumAuthBackground()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Logo Section - Real Logo with subtle white glow
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.08))
                                .blur(radius: 40)
                                .frame(width: 150, height: 150)
                            
                            Image("VibeULogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        }
                        
                        VStack(spacing: 8) {
                            Text("VibeU")
                                .font(.system(size: 52, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: colorScheme == .dark ? [.white, .white.opacity(0.85)] : [.black, .black.opacity(0.85)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: .white.opacity(0.3), radius: 20, x: 0, y: 0)
                            
                            Text("Bağlantının yeni çağı")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5))
                                .tracking(1)
                        }
                    }
                    
                    Spacer()
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 14) {
                        NavigationLink {
                            LoginView()
                        } label: {
                            HStack(spacing: 8) {
                                Text("Giriş Yap")
                                    .font(.system(size: 17, weight: .semibold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.84, blue: 0.4),
                                        Color(red: 1.0, green: 0.7, blue: 0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        }
                        
                        NavigationLink {
                            RegisterView()
                        } label: {
                            Text("Hesap Oluştur")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(colorScheme == .dark ? .white : .black) // Fix visibility
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6))) // Contrast background
                                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

// MARK: - Login View
struct LoginView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var isRememberMe = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            PremiumAuthBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header - User icon (no glow)
                    VStack(spacing: 16) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 42))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: colorScheme == .dark ? [.white, Color(white: 0.9)] : [.black, Color(white: 0.2)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 75, height: 75)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                        
                        Text("Hoş Geldin")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                        
                        Text("Hesabına giriş yap")
                            .font(.subheadline)
                            .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5))
                    }
                    .padding(.top, 30)
                    
                    // Form fields
                    VStack(spacing: 16) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("E-posta")
                                .font(.caption)
                                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6))
                                .padding(.leading, 4)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.4))
                                    .frame(width: 20)
                                TextField("ornek@email.com", text: $email)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                            }
                            .padding(16)
                            .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Şifre")
                                .font(.caption)
                                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6))
                                .padding(.leading, 4)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.4))
                                    .frame(width: 20)
                                SecureField("••••••••", text: $password)
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                            }
                            .padding(16)
                            .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        
                        // Remember Me & Forgot
                        HStack {
                            Button {
                                isRememberMe.toggle()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: isRememberMe ? "checkmark.square.fill" : "square")
                                        .foregroundStyle(isRememberMe ? .blue : (colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.4)))
                                    Text("Beni Hatırla")
                                        .font(.subheadline)
                                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
                                }
                            }
                            
                            Spacer()
                            
                            // Forgot Password - Dynamic gradient
                            NavigationLink {
                                ForgotPasswordView()
                            } label: {
                                Text("Şifremi Unuttum?")
                                    .font(.subheadline)
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                            }
                        }
                        
                        // Login Button - GOLD gradient
                        Button {
                            Task {
                                await viewModel.login(email: email, password: password, isRemember: isRememberMe, appState: appState)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if viewModel.isLoading {
                                    ProgressView().tint(.black)
                                } else {
                                    Text("Giriş Yap")
                                        .font(.system(size: 17, weight: .semibold))
                                    Image(systemName: "arrow.right")
                                }
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.84, blue: 0.4),
                                        Color(red: 1.0, green: 0.7, blue: 0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        }
                        .disabled(email.isEmpty || password.isEmpty || viewModel.isLoading)
                        .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1)
                        
                        // Divider
                        HStack {
                            Rectangle().fill(colorScheme == .dark ? .white.opacity(0.15) : .black.opacity(0.1)).frame(height: 1)
                            Text("veya")
                                .font(.caption)
                                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.4))
                            Rectangle().fill(colorScheme == .dark ? .white.opacity(0.15) : .black.opacity(0.1)).frame(height: 1)
                        }
                        .padding(.vertical, 4)
                        
                        // Social Login Buttons
                        VStack(spacing: 10) {
                            Button {
                                viewModel.signInWithGoogle(appState: appState)
                            } label: {
                                HStack(spacing: 12) {
                                    // Real Google Logo
                                    Image("GoogleLogo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 22, height: 22)
                                    
                                    Text("Google ile Giriş Yap")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                            
                            SignInWithAppleButton(.signIn) { request in
                                request.requestedScopes = [.fullName, .email]
                            } onCompletion: { result in
                                viewModel.handleAppleSignIn(result: result, appState: appState)
                            }
                            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                            .frame(height: 52)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            
                            NavigationLink {
                                PhoneAuthView()
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "phone.fill")
                                        .foregroundStyle(.green)
                                    Text("Telefon ile Giriş Yap")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        }
                        
                        // Register link - WHITE
                        NavigationLink {
                            RegisterView()
                        } label: {
                            HStack(spacing: 4) {
                                Text("Hesabın yok mu?")
                                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5))
                                Text("Kayıt Ol")
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                        }
                        .padding(.top, 8)
                    }
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

// MARK: - Forgot Password View
struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var email = ""
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            PremiumAuthBackground()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Icon with glow
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.blue.opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "key.fill")
                        .font(.system(size: 45))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(spacing: 12) {
                    Text("Şifreni Sıfırla")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    
                    Text("E-posta adresini gir, sana şifre sıfırlama bağlantısı gönderelim")
                        .font(.subheadline)
                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                VStack(spacing: 20) {
                    HStack(spacing: 12) {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.4))
                        TextField("ornek@email.com", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }
                    .padding(16)
                    .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                    Button {
                        sendResetEmail()
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView().tint(.black)
                            } else {
                                Text("Bağlantı Gönder")
                                    .font(.system(size: 17, weight: .semibold))
                                Image(systemName: "paperplane.fill")
                            }
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    }
                    .disabled(email.isEmpty || isLoading)
                    .opacity(email.isEmpty ? 0.6 : 1)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(false)
        .alert("Başarılı!", isPresented: $showSuccess) {
            Button("Tamam") { dismiss() }
        } message: {
            Text("Şifre sıfırlama bağlantısı e-posta adresine gönderildi.")
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func sendResetEmail() {
        isLoading = true
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            showSuccess = true
        }
    }
}

// MARK: - Register View
struct RegisterView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var showSocialOptions = false
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var dateOfBirth = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @State private var gender: RegistrationData.Gender = .preferNotToSay
    
    var body: some View {
        ZStack {
            PremiumAuthBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header - User icon (Updated to match LoginView)
                    VStack(spacing: 16) {
                        Image(systemName: "person.badge.plus") // Kept badge plus but updated style
                            .font(.system(size: 42)) // Match LoginView size (42)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: colorScheme == .dark ? [.white, Color(white: 0.9)] : [.black, Color(white: 0.2)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 75, height: 75)
                            .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color.white.opacity(0.5))) // Slightly better bg
                            .clipShape(Circle())
                        
                        Text("Aramıza Katıl")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                        
                        Text("Yeni bir maceraya başla")
                            .font(.subheadline)
                            .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5))
                    }
                    .padding(.top, 20)
                    
                    // Toggle - Email vs Social
                    HStack(spacing: 0) {
                        MethodToggleButton(
                            title: "E-posta ile",
                            icon: "envelope.fill",
                            isSelected: !showSocialOptions
                        ) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showSocialOptions = false
                            }
                        }
                        
                        MethodToggleButton(
                            title: "Diğer Yollar",
                            icon: "apps.iphone",
                            isSelected: showSocialOptions
                        ) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showSocialOptions = true
                            }
                        }
                    }
                    .padding(4)
                    .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 20)
                    
                    // Content
                    if !showSocialOptions {
                        emailFormContent
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else {
                        socialOptionsContent
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                    }
                    
                    // Login link - WHITE, goes to LoginView
                    NavigationLink {
                        LoginView()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Zaten hesabın var mı?")
                                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5))
                            Text("Giriş Yap")
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                    }
                    .padding(.top, 8)
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
    
    // MARK: - Email Form
    private var emailFormContent: some View {
        VStack(spacing: 14) {
            // Name Fields
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ad").font(.caption).foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5)).padding(.leading, 4)
                    TextField("Ad", text: $firstName)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .padding(14)
                        .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Soyad").font(.caption).foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5)).padding(.leading, 4)
                    TextField("Soyad", text: $lastName)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .padding(14)
                        .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            
            // Email
            VStack(alignment: .leading, spacing: 4) {
                Text("E-posta").font(.caption).foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5)).padding(.leading, 4)
                HStack(spacing: 10) {
                    Image(systemName: "envelope.fill").foregroundStyle(colorScheme == .dark ? .white.opacity(0.3) : .black.opacity(0.3))
                    TextField("ornek@email.com", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
                .padding(14)
                .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            
            // Password
            VStack(alignment: .leading, spacing: 4) {
                Text("Şifre").font(.caption).foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5)).padding(.leading, 4)
                HStack(spacing: 10) {
                    Image(systemName: "lock.fill").foregroundStyle(colorScheme == .dark ? .white.opacity(0.3) : .black.opacity(0.3))
                    SecureField("En az 6 karakter", text: $password)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
                .padding(14)
                .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            
            // Date of Birth
            VStack(alignment: .leading, spacing: 4) {
                Text("Doğum Tarihi").font(.caption).foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5)).padding(.leading, 4)
                DatePicker("", selection: $dateOfBirth, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .tint(.purple)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            
            // Gender - Blob Glass Picker (horizontal, no overflow)
            VStack(alignment: .leading, spacing: 8) {
                Text("Cinsiyet").font(.caption).foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5)).padding(.leading, 4)
                
                BlobGenderPicker(selectedGender: $gender)
            }
            
            // Register Button - GOLD gradient
            Button {
                handleRegister()
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isLoading {
                        ProgressView().tint(.black)
                    } else {
                        Text("Hesap Oluştur")
                            .font(.system(size: 17, weight: .semibold))
                        Image(systemName: "arrow.right")
                    }
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.84, blue: 0.4),
                            Color(red: 1.0, green: 0.7, blue: 0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            }
            .disabled(!isValidForm || viewModel.isLoading)
            .opacity(!isValidForm ? 0.6 : 1)
            .padding(.top, 4)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Social Options
    private var socialOptionsContent: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.signInWithGoogle(appState: appState)
            } label: {
                HStack(spacing: 12) {
                    Image("GoogleLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                    
                    Text("Google ile Kayıt Ol")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            
            SignInWithAppleButton(.signUp) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                viewModel.handleAppleSignIn(result: result, appState: appState)
            }
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            NavigationLink {
                PhoneAuthView()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "phone.fill")
                        .foregroundStyle(.green)
                    Text("Telefon ile Kayıt Ol")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var isValidForm: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && password.count >= 6
    }
    
    private func handleRegister() {
        var data = RegistrationData()
        data.firstName = firstName
        data.lastName = lastName
        data.email = email
        data.password = password
        data.dateOfBirth = dateOfBirth
        data.gender = gender
        data.country = "Turkey"
        
        Task {
            await viewModel.register(data: data, appState: appState)
        }
    }
}

// MARK: - Components

struct PremiumAuthBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            if colorScheme == .dark {
                Color(red: 0.02, green: 0.01, blue: 0.06)
                    .ignoresSafeArea()
                
                GeometryReader { geo in
                    Circle()
                        .fill(Color.purple.opacity(0.12))
                        .blur(radius: 80)
                        .frame(width: 250, height: 250)
                        .offset(x: -80, y: 80)
                    
                    Circle()
                        .fill(Color.indigo.opacity(0.08))
                        .blur(radius: 100)
                        .frame(width: 300, height: 300)
                        .offset(x: geo.size.width - 100, y: geo.size.height - 250)
                }
            } else {
                Color.white
                    .ignoresSafeArea()
                
                // Light mode subtle circles
                GeometryReader { geo in
                    Circle()
                        .fill(Color.purple.opacity(0.05))
                        .blur(radius: 80)
                        .frame(width: 250, height: 250)
                        .offset(x: -80, y: 80)
                    
                    Circle()
                        .fill(Color.indigo.opacity(0.05))
                        .blur(radius: 100)
                        .frame(width: 300, height: 300)
                        .offset(x: geo.size.width - 100, y: geo.size.height - 250)
                }
            }
        }
    }
}

// MARK: - Premium Method Toggle (improved design)
struct PremiumMethodToggle: View {
    @Binding var showSocialOptions: Bool
    @Namespace private var toggleAnimation
    
    var body: some View {
        HStack(spacing: 0) {
            // Email Option
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    showSocialOptions = false
                }
            } label: {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(!showSocialOptions ? Color.white.opacity(0.2) : Color.clear)
                            .frame(width: 32, height: 32)
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 14))
                    }
                    Text("E-posta")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(!showSocialOptions ? .white : .white.opacity(0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background {
                    if !showSocialOptions {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.white.opacity(0.15))
                            .matchedGeometryEffect(id: "toggleBg", in: toggleAnimation)
                    }
                }
            }
            
            // Divider
            Rectangle()
                .fill(.white.opacity(0.1))
                .frame(width: 1, height: 30)
            
            // Social Option
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    showSocialOptions = true
                }
            } label: {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(showSocialOptions ? Color.white.opacity(0.2) : Color.clear)
                            .frame(width: 32, height: 32)
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                    }
                    Text("Diğer")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(showSocialOptions ? .white : .white.opacity(0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background {
                    if showSocialOptions {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.white.opacity(0.15))
                            .matchedGeometryEffect(id: "toggleBg", in: toggleAnimation)
                    }
                }
            }
        }
        .padding(5)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .glassEffect()
    }
}

struct MethodToggleButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(isSelected ? (colorScheme == .dark ? .black : .white) : (colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6)))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(colorScheme == .dark ? .white : .black)
                }
            }
        }
    }
}

// MARK: - Glass Gender Picker with Native Effect
struct BlobGenderPicker: View {
    @Binding var selectedGender: RegistrationData.Gender
    @Namespace private var animation
    @Environment(\.colorScheme) private var colorScheme
    
    private let genders: [(RegistrationData.Gender, String)] = [
        (.male, "Erkek"),
        (.female, "Kadın"),
        (.nonBinary, "Diğer"),
        (.preferNotToSay, "Belirtme")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(genders, id: \.0) { gender, label in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        selectedGender = gender
                    }
                } label: {
                    Text(label)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(selectedGender == gender ? (colorScheme == .dark ? .black : .white) : (colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6)))
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background {
                            if selectedGender == gender {
                                Capsule()
                                    .fill(colorScheme == .dark ? .white : .black)
                                    .matchedGeometryEffect(id: "genderBlob", in: animation)
                                    .shadow(color: colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.3), radius: 10, x: 0, y: 0)
                            }
                        }
                }
            }
        }
        .padding(3)
        .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
        .clipShape(Capsule())
        .glassEffect()
    }
}

#Preview {
    AuthView()
        .environment(AppState())
}
