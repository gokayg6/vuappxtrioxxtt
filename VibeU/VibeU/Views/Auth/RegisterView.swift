import SwiftUI

struct RegisterView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    // Form States
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var dateOfBirth = Date()
    @State private var gender: RegistrationData.Gender = .preferNotToSay
    
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
                    VStack(spacing: 12) {
                        Text("Aramıza Katıl")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text("VibeU dünyasını keşfetmeye başla")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Form Card
                    VStack(spacing: 20) {
                        
                        // Name Fields
                        HStack(spacing: 16) {
                            TextField("Ad", text: $firstName)
                                .textContentType(.givenName)
                                .padding()
                                .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            TextField("Soyad", text: $lastName)
                                .textContentType(.familyName)
                                .padding()
                                .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        // Email
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
                        
                        // Password
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.secondary)
                            SecureField("Şifre", text: $password)
                                .textContentType(.newPassword)
                        }
                        .padding()
                        .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Doğum Tarihi")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 4)
                            
                            DatePicker("", selection: $dateOfBirth, displayedComponents: .date)
                                .labelsHidden()
                                .padding()
                                .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Gender
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Cinsiyet")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 4)
                            
                            Picker("Cinsiyet", selection: $gender) {
                                ForEach(RegistrationData.Gender.allCases, id: \.self) { gender in
                                    Text(gender.displayName).tag(gender)
                                }
                            }
                            .pickerStyle(.segmented)
                            .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        // Register Button
                        Button {
                            handleRegister()
                        } label: {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Hesap Oluştur")
                                    .font(.headline)
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .pink.opacity(0.4), radius: 10, x: 0, y: 5)
                        .disabled(!isValidForm || viewModel.isLoading)
                        .opacity(!isValidForm ? 0.6 : 1)
                        
                        Button("Zaten hesabın var mı? Giriş Yap") {
                            dismiss()
                        }
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .padding(.top, 8)
                    }
                    .padding(24)
                    .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color.white))
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 20)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 60)
            }
        }
        .navigationBarBackButtonHidden(false)
        .alert("Hata", isPresented: $viewModel.showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    private var isValidForm: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !password.isEmpty && password.count >= 6
    }
    
    private func handleRegister() {
        var data = RegistrationData()
        data.firstName = firstName
        data.lastName = lastName
        data.email = email
        data.password = password
        data.dateOfBirth = dateOfBirth
        data.gender = gender
        data.country = "Turkey" // Default
        
        Task {
            await viewModel.register(data: data, appState: appState)
        }
    }
}

// Reusing MeshGradientBackground... I should have shared it but for now I assume it comes from LoginView if in same module, but they are in same module so I can make it public in LoginView.
// Or I can redefine here if I want to avoid modifying LoginView again.
// I will just rely on LoginView's MeshGradientBackground being internal (accessible). Wait, Swift defaults to internal.
// I need to check if LoginView is in same target. Yes.
// But I need to make sure I didn't make MeshGradientBackground private in LoginView.
// In LoginView, I defined it as `struct MeshGradientBackground: View`. It is internal. So I can use it here.
