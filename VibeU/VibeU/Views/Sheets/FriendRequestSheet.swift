import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Friend Request Sheet

struct FriendRequestSheet: View {
    let user: DiscoverUser
    let onSend: (Bool, String) -> Void // success, message
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var isSending = false
    @State private var showInsufficientDiamonds = false
    @State private var avatarScale: CGFloat = 0.8
    @State private var contentOpacity: Double = 0
    
    private let requestCost = 10 // Elmas maliyeti
    
    var body: some View {
        ZStack {
            // Subtle gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.06, blue: 0.12),
                    Color(red: 0.04, green: 0.02, blue: 0.08)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Main content
            mainContent
        }
        .presentationDetents([.height(480)])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(28)
        .presentationBackground(.clear)
        .alert("Yetersiz Elmas", isPresented: $showInsufficientDiamonds) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text("Arkadaşlık isteği göndermek için en az \(requestCost) elmasa ihtiyacınız var.")
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                avatarScale = 1.0
                contentOpacity = 1.0
            }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Drag Indicator
            Capsule()
                .fill(Color.white.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 20)
            
            // User Avatar with glow effect
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.purple.opacity(0.4), .clear],
                            center: .center,
                            startRadius: 40,
                            endRadius: 80
                        )
                    )
                    .frame(width: 140, height: 140)
                
                // Avatar
                AsyncImage(url: URL(string: user.profilePhotoURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(white: 0.2), Color(white: 0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                    }
                }
                .frame(width: 88, height: 88)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.6), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
                .shadow(color: .purple.opacity(0.3), radius: 20, y: 5)
            }
            .scaleEffect(avatarScale)
            .padding(.bottom, 20)
            
            // User Name
            Text(user.displayName)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.bottom, 6)
            
            // Subtitle
            Text("Sosyal medya bağlantısı isteği")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
                .padding(.bottom, 24)
            
            // Social Media Cards
            HStack(spacing: 12) {
                SocialPlatformCard(
                    icon: "play.rectangle.fill",
                    name: "TikTok",
                    gradient: [Color(red: 0.1, green: 0.1, blue: 0.1), Color(red: 0.2, green: 0.2, blue: 0.2)]
                )
                
                SocialPlatformCard(
                    icon: "camera.fill",
                    name: "Instagram",
                    gradient: [Color(red: 0.55, green: 0.23, blue: 0.6), Color(red: 0.95, green: 0.3, blue: 0.4)]
                )
                
                SocialPlatformCard(
                    icon: "bolt.fill",
                    name: "Snapchat",
                    gradient: [Color(red: 1.0, green: 0.85, blue: 0.1), Color(red: 1.0, green: 0.75, blue: 0.0)]
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            
            // Info text
            Text("İstek kabul edildiğinde sosyal medya hesapları görünür olacak")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 28)
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 10) {
                // Send Button
                Button {
                    sendFriendRequest()
                } label: {
                    HStack(spacing: 10) {
                        if isSending {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.9)
                        } else {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Image("diamond-icon")
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                                .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.0))
                        }
                        Text(isSending ? "Gönderiliyor..." : "İstek Gönder (-\(requestCost) 💎)")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .purple.opacity(0.4), radius: 12, y: 4)
                }
                .disabled(isSending)
                .scaleEffect(isSending ? 0.98 : 1.0)
                
                // Cancel Button
                Button {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    dismiss()
                } label: {
                    Text("İptal")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .disabled(isSending)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .opacity(contentOpacity)
    }
    
    private func sendFriendRequest() {
        print("🔵 sendFriendRequest called")
        
        // Check diamond balance
        guard let currentBalance = appState.currentUser?.diamondBalance, currentBalance >= requestCost else {
            print("❌ Insufficient diamonds: \(appState.currentUser?.diamondBalance ?? 0)")
            showInsufficientDiamonds = true
            let errorFeedback = UINotificationFeedbackGenerator()
            errorFeedback.notificationOccurred(.error)
            return
        }
        
        print("💎 Current balance: \(currentBalance), deducting \(requestCost)")
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isSending = true
        }
        
        Task {
            do {
                guard let currentUserId = Auth.auth().currentUser?.uid else {
                    print("❌ No current user ID")
                    await MainActor.run {
                        isSending = false
                        onSend(false, "Kullanıcı bulunamadı")
                        dismiss()
                    }
                    return
                }
                
                let db = Firestore.firestore()
                
                // Add to current user's sent_requests array
                let sentRequest: [String: Any] = [
                    "to_user_id": user.id,
                    "to_user_name": user.displayName,
                    "status": "pending",
                    "sent_at": Timestamp(date: Date())
                ]
                
                print("🔄 Adding to sent_requests array...")
                try await db.collection("users").document(currentUserId).updateData([
                    "sent_friend_requests": FieldValue.arrayUnion([sentRequest]),
                    "diamond_balance": FieldValue.increment(Int64(-requestCost))
                ])
                print("✅ Friend request sent and diamonds deducted")
                
                // Update local state
                await MainActor.run {
                    let newBalance = (appState.currentUser?.diamondBalance ?? 0) - requestCost
                    appState.currentUser?.diamondBalance = newBalance
                    print("💎 Local balance updated: \(newBalance)")
                    
                    // Success haptic (tek titreşim)
                    let successFeedback = UINotificationFeedbackGenerator()
                    successFeedback.notificationOccurred(.success)
                    
                    // Call callback with success
                    onSend(true, "İstek başarıyla gönderildi!")
                    
                    // Dismiss sheet immediately
                    dismiss()
                }
            } catch {
                print("❌ Failed to send friend request: \(error)")
                await MainActor.run {
                    isSending = false
                    
                    // Error haptic (çift titreşim)
                    let errorFeedback = UINotificationFeedbackGenerator()
                    errorFeedback.notificationOccurred(.error)
                    
                    // Call callback with error
                    onSend(false, "İstek gönderilemedi")
                    
                    // Dismiss sheet
                    dismiss()
                }
            }
        }
    }
    
}

// MARK: - Social Platform Card

private struct SocialPlatformCard: View {
    let icon: String
    let name: String
    let gradient: [Color]
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(.white)
            }
            
            Text(name)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

// MARK: - Preview

#Preview {
    Color.black
        .sheet(isPresented: .constant(true)) {
            FriendRequestSheet(
                user: DiscoverUser.mockUsers[0],
                onSend: { _, _ in }
            )
        }
}
