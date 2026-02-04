import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Profile Summary Sheet (Compact Popup)
struct ProfileSummarySheet: View {
    let user: DiscoverUser
    let onSendRequest: (Bool, String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(AppState.self) private var appState
    @State private var isRequestSent = false
    @State private var isLoading = false
    @State private var showInsufficientDiamonds = false
    
    private let requestCost = 10
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag Indicator
            Capsule()
                .fill((colorScheme == .dark ? Color.white : Color.black).opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 24)
            
            // Profile Photo with gradient ring
            ZStack {
                // Gradient ring (like profile PP)
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: colorScheme == .dark ? 
                                [Color.white.opacity(0.6), Color.white.opacity(0.2)] :
                                [Color.gray.opacity(0.6), Color.gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 110, height: 110)
                
                // Profile photo
                CachedAsyncImage(url: user.profilePhotoURL)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }
            .padding(.bottom, 16)
            
            // Name, Age, City
            VStack(spacing: 6) {
                Text("\(user.displayName), \(user.age)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 12))
                    Text(user.city)
                        .font(.system(size: 14))
                }
                .foregroundStyle((colorScheme == .dark ? Color.white : Color.black).opacity(0.6))
            }
            .padding(.bottom, 20)
            
            // Tags (if available)
            if !user.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(user.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill((colorScheme == .dark ? Color.white : Color.black).opacity(0.1))
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 16)
            }
            
            // Sosyal Medya (Kilitli)
            HStack(spacing: 16) {
                if user.instagramUsername != nil {
                    LockedSocialIcon(platform: "instagram")
                }
                if user.tiktokUsername != nil {
                    LockedSocialIcon(platform: "tiktok")
                }
                if user.snapchatUsername != nil {
                    LockedSocialIcon(platform: "snapchat")
                }
            }
            .padding(.bottom, 8)
            
            Text("Arkadaş olunca sosyal medya hesaplarını görebilirsin")
                .font(.system(size: 12))
                .foregroundStyle((colorScheme == .dark ? Color.white : Color.black).opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            
            Spacer()
            
            // Send Friend Request Button (Golden glow like premium button)
            Button {
                sendFriendRequest()
            } label: {
                HStack(spacing: 10) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(isRequestSent ? "İstek Gönderildi" : "Arkadaşlık İsteği Gönder (-\(requestCost))")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    ZStack {
                        // Golden gradient background
                        LinearGradient(
                            colors: isRequestSent ? 
                                [.green, .green.opacity(0.8)] :
                                [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 1.0, green: 0.65, blue: 0.0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        
                        // Golden glow effect
                        if !isRequestSent {
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.6), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: isRequestSent ? .green.opacity(0.4) : Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.5), radius: 15, y: 5)
            }
            .disabled(isLoading || isRequestSent)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background((colorScheme == .dark ? Color(red: 0.05, green: 0.05, blue: 0.05) : Color.white).ignoresSafeArea())
        .presentationDetents([.height(400)])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(24)
        .alert("Yetersiz Elmas", isPresented: $showInsufficientDiamonds) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text("Arkadaşlık isteği göndermek için en az \(requestCost) elmasa ihtiyacınız var.")
        }
    }
    
    private func sendFriendRequest() {
        // Check diamond balance
        guard let currentBalance = appState.currentUser?.diamondBalance, currentBalance >= requestCost else {
            showInsufficientDiamonds = true
            let errorFeedback = UINotificationFeedbackGenerator()
            errorFeedback.notificationOccurred(.error)
            return
        }
        
        isLoading = true
        
        Task {
            do {
                guard let currentUserId = Auth.auth().currentUser?.uid,
                      appState.currentUser?.displayName != nil else {
                    await MainActor.run {
                        isLoading = false
                        onSendRequest(false, "Kullanıcı bulunamadı")
                        dismiss()
                    }
                    return
                }
                
                let db = Firestore.firestore()
                let requestId = UUID().uuidString
                let timestamp = Timestamp(date: Date())
                
                // Use global friend_requests collection (same as FriendsService reads from)
                let batch = db.batch()
                
                // 1. Create friend request in global collection
                let requestRef = db.collection("friend_requests").document(requestId)
                let requestData: [String: Any] = [
                    "fromId": currentUserId,
                    "toId": user.id,
                    "status": "pending",
                    "createdAt": timestamp
                ]
                batch.setData(requestData, forDocument: requestRef)
                
                // 2. Deduct diamonds from sender
                let senderRef = db.collection("users").document(currentUserId)
                batch.updateData([
                    "diamond_balance": FieldValue.increment(Int64(-requestCost))
                ], forDocument: senderRef)
                
                try await batch.commit()
                
                // Update local state
                await MainActor.run {
                    let newBalance = (appState.currentUser?.diamondBalance ?? 0) - requestCost
                    appState.currentUser?.diamondBalance = newBalance
                    
                    isLoading = false
                    isRequestSent = true
                    
                    // Success haptic
                    let successFeedback = UINotificationFeedbackGenerator()
                    successFeedback.notificationOccurred(.success)
                    
                    onSendRequest(true, "İstek başarıyla gönderildi!")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    
                    let errorFeedback = UINotificationFeedbackGenerator()
                    errorFeedback.notificationOccurred(.error)
                    
                    onSendRequest(false, "İstek gönderilemedi")
                    
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Locked Social Icon (Compact)
struct LockedSocialIcon: View {
    let platform: String
    
    private var imageName: String {
        switch platform {
        case "instagram": return "InstagramIcon"
        case "tiktok": return "TikTokIcon"
        case "snapchat": return "SnapchatIcon"
        default: return ""
        }
    }
    
    var body: some View {
        ZStack {
            if !imageName.isEmpty {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .grayscale(0.8)
                    .opacity(0.6)
            }
            
            // Kilit ikonu
            Image(systemName: "lock.fill")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .padding(4)
                .background(Circle().fill(Color.black.opacity(0.7)))
                .offset(x: 12, y: 12)
        }
    }
}
