import SwiftUI

struct ProfileDetailView: View {
    let user: DiscoverUser
    
    @State private var isFavorite = false
    @State private var showingRequestSentAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var colors
    @Environment(AppState.self) private var appState
    
    var body: some View {
        ZStack {
            // Background - Adaptive
            colors.background.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Photo Section
                    ZStack(alignment: .top) {
                        // Photos
                        PhotoSlider(
                            photos: user.photos,
                            profilePhotoURL: user.profilePhotoURL
                        )
                        .frame(height: 480)
                        
                        // Gradient Fade
                        LinearGradient(
                            colors: [.clear, .clear, colors.background], // Adapt gradient to background
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    
                    // Content
                    VStack(spacing: 24) {
                        // Name & Basic Info
                        VStack(spacing: 8) {
                            HStack(spacing: 10) {
                                Text(user.displayName)
                                    .font(.largeTitle.weight(.bold))
                                    .foregroundStyle(colors.primaryText) // Adaptive text
                                
                                Text("\(user.age)")
                                    .font(.title)
                                    .foregroundStyle(colors.secondaryText)
                                
                                if user.isBoosted {
                                    Image(systemName: "bolt.fill")
                                        .foregroundStyle(.yellow)
                                        .font(.title2)
                                }
                            }
                            
                            HStack(spacing: 6) {
                                Image(systemName: "location.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(.purple)
                                
                                Text(user.city)
                                    .foregroundStyle(colors.secondaryText)
                                
                                if let flag = user.countryFlag {
                                    Text(flag)
                                }
                                
                                if let distance = user.distanceKm {
                                    Text("•")
                                        .foregroundStyle(colors.secondaryText)
                                    Text("\(Int(distance)) km away")
                                        .foregroundStyle(colors.secondaryText)
                                }
                            }
                            .font(.subheadline)
                        }
                        
                        // Tags
                        if !user.tags.isEmpty {
                            HStack(spacing: 10) {
                                ForEach(user.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.title2)
                                        .padding(10)
                                        .foregroundStyle(colors.primaryText)
                                        .glassEffect()
                                }
                            }
                        }
                        
                        // Common Interests
                        if !user.commonInterests.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundStyle(.purple)
                                    Text("common_interests")
                                        .font(.headline)
                                        .foregroundStyle(colors.primaryText)
                                }
                                
                                FlowLayout(spacing: 8) {
                                    ForEach(user.commonInterests, id: \.self) { interest in
                                        GlassPillTag(interest)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .glassEffect()
                        }
                        
                    // Social Media Section
                        ProfileSocialMediaRow(user: user, isFriend: false, accentColor: .cyan)
                        
                        // Bottom Padding for Action Bar
                        Color.clear.frame(height: 140)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, -60)
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // Floating Action Buttons (Homepage Style - Tinder Clone)
            VStack {
                Spacer()
                
                HStack(spacing: 20) {
                    // Skip (X - Pembe gradient - 64pt)
                    HomepageActionButton(
                        icon: "xmark",
                        size: 64,
                        iconSize: 32,
                        colors: [Color(red: 1.0, green: 0.3, blue: 0.5), Color(red: 1.0, green: 0.15, blue: 0.4)],
                        action: { dismiss() }
                    )
                    
                    Spacer()
                    
                    // Super Like / Star (Mavi gradient - 54pt)
                    HomepageActionButton(
                        icon: "star.fill",
                        size: 54,
                        iconSize: 26,
                        colors: [Color(red: 0.3, green: 0.85, blue: 1.0), Color(red: 0.1, green: 0.5, blue: 1.0)],
                        action: {
                            // Star Logic
                            isFavorite.toggle()
                        }
                    )
                    
                    // Like (Kalp - Yeşil gradient - 64pt)
                    HomepageActionButton(
                        icon: "heart.fill",
                        size: 64,
                        iconSize: 32,
                        colors: [Color(red: 0.5, green: 1.0, blue: 0.3), Color(red: 0.2, green: 0.9, blue: 0.4)],
                        action: {
                            // Like Logic
                            dismiss()
                        }
                    )
                    
                    // Add Friend (Plus - Mor gradient - 54pt)
                    HomepageActionButton(
                        icon: "plus",
                        size: 54,
                        iconSize: 28,
                        colors: [Color(red: 0.6, green: 0.3, blue: 1.0), Color(red: 0.4, green: 0.2, blue: 0.8)],
                        action: {
                            let generator = UINotificationFeedbackGenerator()
                            
                            Task {
                                do {
                                    try await FriendsService.shared.sendFriendRequest(userId: user.id)
                                    // Success - show alert
                                    await MainActor.run {
                                        generator.notificationOccurred(.success)
                                        showingRequestSentAlert = true
                                    }
                                } catch {
                                    // Failed - show error on screen!
                                    await MainActor.run {
                                        generator.notificationOccurred(.error)
                                        errorMessage = "Hata: \(error.localizedDescription)"
                                        showingErrorAlert = true
                                    }
                                }
                            }
                        }
                    )
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.down")
                    .font(.body.weight(.semibold))
                    .frame(width: 36, height: 36)
                    .foregroundStyle(colors.primaryText)
                    .glassEffect()
                }
            }
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                // Share Button
                if let url = URL(string: "https://vibeu.app/user/\(user.id)") {
                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.up")
                        .font(.body.weight(.semibold))
                        .frame(width: 36, height: 36)
                        .foregroundStyle(colors.primaryText)
                        .glassEffect()
                    }
                }
                
                Menu {
                    Button {
                        // Report
                    } label: {
                        Label("Raporla", systemImage: "exclamationmark.triangle")
                    }
                    
                    Button {
                        // Block
                    } label: {
                        Label("Engelle", systemImage: "hand.raised")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                    .font(.body.weight(.semibold))
                    .frame(width: 36, height: 36)
                    .foregroundStyle(colors.primaryText)
                    .glassEffect()
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .alert("İstek Gönderildi", isPresented: $showingRequestSentAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text("\(user.displayName) kişisine arkadaşlık isteği gönderildi.")
        }
        .alert("İstek Gönderilemedi", isPresented: $showingErrorAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            withAnimation {
                appState.isTabBarHidden = true
            }
        }
        .onDisappear {
            withAnimation {
                appState.isTabBarHidden = false
            }
        }
    }
}

// MARK: - Flow Layout for Tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                
                self.size.width = max(self.size.width, x - spacing)
            }
            
            self.size.height = y + rowHeight
        }
    }
}

#Preview {
    NavigationStack {
        ProfileDetailView(user: DiscoverUser.mockUsers[0])
            .environment(AppState())
    }
}

// MARK: - Social Media Row for Profile Detail

struct ProfileSocialMediaRow: View {
    let user: DiscoverUser
    let isFriend: Bool
    let accentColor: Color
    @Environment(\.themeColors) private var colors
    
    init(user: DiscoverUser, isFriend: Bool? = nil, accentColor: Color = .cyan) {
        self.user = user
        self.isFriend = isFriend ?? user.isFriend ?? false
        self.accentColor = accentColor
    }
    
    var body: some View {
        if user.hasAnySocialMedia {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Image(systemName: isFriend ? "link" : "lock.fill")
                        .font(.headline)
                        .foregroundStyle(isFriend ? accentColor : .gray)
                    Text(isFriend ? "Sosyal Medya" : "Sosyal Hesaplar")
                        .font(.headline)
                        .foregroundStyle(colors.primaryText)
                    
                    if !isFriend {
                        Spacer()
                        Text("Kilitli")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.gray.opacity(0.8)))
                    }
                }
                
                if isFriend {
                    VStack(spacing: 12) {
                        if let username = user.tiktokUsername, !username.isEmpty {
                            SocialMediaLinkButtonLocal(platform: .tiktok, username: username)
                        }
                        if let username = user.instagramUsername, !username.isEmpty {
                            SocialMediaLinkButtonLocal(platform: .instagram, username: username)
                        }
                        if let username = user.snapchatUsername, !username.isEmpty {
                            SocialMediaLinkButtonLocal(platform: .snapchat, username: username)
                        }
                    }
                } else {
                    // Locked State Design
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: "lock.fill")
                                .font(.title3)
                                .foregroundStyle(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hesaplar Gizli")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(colors.primaryText)
                            Text("Sosyal medya hesaplarını görmek için arkadaş olmalısın.")
                            .font(.caption)
                            .foregroundStyle(colors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(colors.cardBackground.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                    .stroke(colors.border.opacity(0.5), lineWidth: 1)
                )
            )
        }
    }
}

// MARK: - Social Media Link Button Local

struct SocialMediaLinkButtonLocal: View {
    let platform: SocialMediaPlatform
    let username: String
    @Environment(\.themeColors) private var colors
    
    var body: some View {
        Button {
            openSocialMedia()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: platform.iconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(platform.color)
                .frame(width: 36, height: 36)
                .background(Circle().fill(platform.color.opacity(0.15)))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(platformDisplayName)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(colors.primaryText)
                    Text("@\(username)")
                    .font(.caption)
                    .foregroundColor(colors.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(colors.secondaryText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(colors.cardBackground))
        }
        .buttonStyle(.plain)
    }
    
    private var platformDisplayName: String {
        switch platform {
        case .tiktok: return "TikTok"
        case .instagram: return "Instagram"
        case .snapchat: return "Snapchat"
        }
    }
    
    private func openSocialMedia() {
        if let deepLink = platform.deepLink(username: username),
           UIApplication.shared.canOpenURL(deepLink) {
            UIApplication.shared.open(deepLink)
        } else if let webURL = platform.webURL(username: username) {
            UIApplication.shared.open(webURL)
        }
    }
}
