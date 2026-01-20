import SwiftUI

struct PhoneAuthView: View {
    @State private var viewModel = PhoneAuthViewModel()
    @FocusState private var isPhoneFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Background
            if colorScheme == .dark {
                Color.black.ignoresSafeArea()
            } else {
                Color.white.ignoresSafeArea()
            }
            
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Text("enter_phone")
                        .font(.title.weight(.bold))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    
                    Text("phone_description")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)
                
                // Phone Input
                HStack(spacing: 12) {
                    // Country Picker
                    Button {
                        viewModel.showCountryPicker = true
                    } label: {
                        HStack(spacing: 6) {
                            Text(viewModel.selectedCountry.flag)
                                .font(.title2)
                            Text(viewModel.selectedCountry.dialCode)
                                .font(.body.monospacedDigit())
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 52)
                        .glassEffect()
                        .background(colorScheme == .light ? Color(UIColor.systemGray6) : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    
                    // Phone Number Field
                    TextField("phone_placeholder", text: $viewModel.phoneNumber)
                        .keyboardType(.phonePad)
                        .font(.title3.monospacedDigit())
                        .focused($isPhoneFocused)
                        .padding(.horizontal, 16)
                        .frame(height: 52)
                        .glassEffect()
                        .background(colorScheme == .light ? Color(UIColor.systemGray6) : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Continue Button
                VStack(spacing: 16) {
                    GlassButton(
                        "send_code",
                        icon: "arrow.right",
                        style: .accent
                    ) {
                        Task {
                            await viewModel.sendOTP()
                        }
                    }
                    .disabled(!viewModel.isValidPhone || viewModel.isLoading)
                    .opacity(viewModel.isValidPhone ? 1 : 0.5)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.purple)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
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
        .navigationDestination(isPresented: $viewModel.showOTPView) {
            OTPVerificationView(
                phone: viewModel.fullPhoneNumber,
                verificationID: viewModel.verificationID ?? ""
            )
        }
        .sheet(isPresented: $viewModel.showCountryPicker) {
            CountryPickerSheet(selectedCountry: $viewModel.selectedCountry)
        }
        .alert("error", isPresented: $viewModel.showError) {
            Button("ok", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .onAppear {
            isPhoneFocused = true
        }
    }
}

// MARK: - ViewModel

@Observable
final class PhoneAuthViewModel {
    var phoneNumber = ""
    var selectedCountry = Country.turkey
    var isLoading = false
    var showOTPView = false
    var showCountryPicker = false
    var showError = false
    var errorMessage = ""
    var verificationID: String?
    
    var isValidPhone: Bool {
        phoneNumber.count >= 10 && phoneNumber.allSatisfy { $0.isNumber }
    }
    
    var fullPhoneNumber: String {
        "\(selectedCountry.dialCode)\(phoneNumber)"
    }
    
    @MainActor
    func sendOTP() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            verificationID = try await PhoneAuthManager.shared.sendOTP(phone: fullPhoneNumber)
            showOTPView = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - Country Model

struct Country: Identifiable, Equatable {
    let id: String
    let name: String
    let flag: String
    let dialCode: String
    
    static let turkey = Country(id: "TR", name: "Turkey", flag: "🇹🇷", dialCode: "+90")
    static let usa = Country(id: "US", name: "United States", flag: "🇺🇸", dialCode: "+1")
    static let uk = Country(id: "GB", name: "United Kingdom", flag: "🇬🇧", dialCode: "+44")
    static let germany = Country(id: "DE", name: "Germany", flag: "🇩🇪", dialCode: "+49")
    static let france = Country(id: "FR", name: "France", flag: "🇫🇷", dialCode: "+33")
    static let spain = Country(id: "ES", name: "Spain", flag: "🇪🇸", dialCode: "+34")
    static let brazil = Country(id: "BR", name: "Brazil", flag: "🇧🇷", dialCode: "+55")
    
    static let all: [Country] = [turkey, usa, uk, germany, france, spain, brazil]
}

// MARK: - Country Picker

struct CountryPickerSheet: View {
    @Binding var selectedCountry: Country
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    private var filteredCountries: [Country] {
        if searchText.isEmpty {
            return Country.all
        }
        return Country.all.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.dialCode.contains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredCountries) { country in
                Button {
                    selectedCountry = country
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Text(country.flag)
                            .font(.title2)
                        
                        Text(country.name)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Text(country.dialCode)
                            .foregroundStyle(.secondary)
                            .font(.body.monospacedDigit())
                        
                        if country == selectedCountry {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.purple)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "search_country")
            .navigationTitle("select_country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    NavigationStack {
        PhoneAuthView()
    }
}
