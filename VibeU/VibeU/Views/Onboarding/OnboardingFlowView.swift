import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Onboarding Flow Coordinator
struct OnboardingFlowView: View {
    @Environment(AppState.self) private var appState
    @State private var currentStep: OnboardingStep = .hobbies
    @State private var onboardingData = OnboardingData()
    
    enum OnboardingStep: Int, CaseIterable {
        case hobbies = 0
        case lifestyle = 1
        case verification = 2
        case personalInfo = 3
        case photos = 4
        case premium = 5
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.02, blue: 0.08).ignoresSafeArea()
            
            Group {
                switch currentStep {
                case .hobbies:
                    HobbiesSelectionView(data: $onboardingData, onNext: { currentStep = .lifestyle })
                case .lifestyle:
                    LifestyleSelectionView(data: $onboardingData, onNext: { currentStep = .verification }, onBack: { currentStep = .hobbies })
                case .verification:
                    VerificationView(data: $onboardingData, onNext: { currentStep = .personalInfo }, onBack: { currentStep = .lifestyle })
                case .personalInfo:
                    PersonalInfoView(data: $onboardingData, onNext: { currentStep = .photos }, onBack: { currentStep = .verification })
                case .photos:
                    PhotoUploadView(data: $onboardingData, onNext: { currentStep = .premium }, onBack: { currentStep = .personalInfo })
                case .premium:
                    PremiumOfferView(data: onboardingData, onComplete: completeOnboarding, onSkip: completeOnboarding)
                }
            }
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        }
    }
    
    private func completeOnboarding() {
        Task {
            await saveUserData()
            await MainActor.run {
                appState.authState = .authenticated
            }
        }
    }
    
    private func saveUserData() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ [OnboardingFlow] No user ID!")
            return
        }
        
        print("💾 [OnboardingFlow] Saving onboarding data for user: \(userId)")
        
        let db = Firestore.firestore()
        
        // Calculate age from date of birth
        let age = Calendar.current.dateComponents([.year], from: onboardingData.dateOfBirth, to: Date()).year ?? 18
        
        // Update user document with onboarding data
        var userData: [String: Any] = [
            "hobbies": onboardingData.hobbies,
            "drinking": onboardingData.drinking,
            "smoking": onboardingData.smoking,
            "exercise": onboardingData.exercise,
            "pets": onboardingData.pets,
            "want_kids": onboardingData.wantKids,
            "zodiac": onboardingData.zodiac,
            "date_of_birth": Timestamp(date: onboardingData.dateOfBirth),
            "age": age,
            "profile_completed_at": Timestamp(date: Date())
        ]
        
        // Add gender if provided - convert Turkish to English enum value
        if !onboardingData.gender.isEmpty {
            let genderValue: String
            switch onboardingData.gender {
            case "Erkek":
                genderValue = "male"
            case "Kadın":
                genderValue = "female"
            case "Diğer":
                genderValue = "non_binary"
            default:
                genderValue = "prefer_not_to_say"
            }
            userData["gender"] = genderValue
        }
        
        // Add phone/email if provided
        if !onboardingData.phoneNumber.isEmpty {
            userData["phone_number"] = onboardingData.phoneNumber
        }
        if !onboardingData.email.isEmpty {
            userData["email"] = onboardingData.email
        }
        
        do {
            // Use setData with merge to avoid overwriting existing fields
            try await db.collection("users").document(userId).setData(userData, merge: true)
            print("✅ [OnboardingFlow] User data saved successfully")
            
            // Upload photos to Firebase Storage and update profile
            if !onboardingData.photos.isEmpty {
                await uploadPhotos(userId: userId)
            }
            
            // Update AppState currentUser
            if let updatedUser = try? await UserService.shared.fetchUser(uid: userId) {
                await MainActor.run {
                    appState.currentUser = updatedUser
                }
            }
            
            print("✅ [OnboardingFlow] Profile completed successfully")
        } catch {
            print("❌ [OnboardingFlow] Error saving onboarding data: \(error)")
        }
    }
    
    private func uploadPhotos(userId: String) async {
        print("📸 [OnboardingFlow] Uploading \(onboardingData.photos.count) photos for user \(userId)")
        
        guard !onboardingData.photos.isEmpty else { return }
        
        do {
            // Upload first photo as profile photo
            if let firstPhoto = onboardingData.photos.first {
                print("📸 [OnboardingFlow] Uploading profile photo...")
                let profilePhotoURL = try await PhotoUploadService.shared.uploadProfilePhoto(
                    image: firstPhoto,
                    userId: userId
                )
                print("✅ [OnboardingFlow] Profile photo uploaded: \(profilePhotoURL)")
            }
            
            // Upload remaining photos as gallery photos
            if onboardingData.photos.count > 1 {
                print("📸 [OnboardingFlow] Uploading \(onboardingData.photos.count - 1) gallery photos...")
                for (index, photo) in onboardingData.photos.dropFirst().enumerated() {
                    do {
                        let photoURL = try await PhotoUploadService.shared.uploadPhoto(
                            image: photo,
                            userId: userId,
                            orderIndex: index
                        )
                        print("✅ [OnboardingFlow] Gallery photo \(index + 1) uploaded: \(photoURL)")
                    } catch {
                        print("❌ [OnboardingFlow] Failed to upload gallery photo \(index + 1): \(error)")
                    }
                }
            }
            
            print("✅ [OnboardingFlow] All photos uploaded successfully")
        } catch {
            print("❌ [OnboardingFlow] Error uploading photos: \(error)")
        }
    }
}

// MARK: - Onboarding Data Model
struct OnboardingData {
    var hobbies: [String] = []
    var drinking: String = ""
    var smoking: String = ""
    var exercise: String = ""
    var pets: String = ""
    var wantKids: String = ""
    var verificationType: VerificationType = .phone
    var phoneNumber: String = ""
    var email: String = ""
    var verificationCode: String = ""
    var gender: String = ""
    var zodiac: String = ""
    var dateOfBirth: Date = Date()
    var photos: [UIImage] = []
    
    enum VerificationType {
        case phone, email
    }
}
