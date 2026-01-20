import SwiftUI

// MARK: - Social Media Icons View
// Requirements: 9.4, 9.5 - Shows locked icons for non-friends, unlocked for friends

struct SocialMediaIconsView: View {
    let user: DiscoverUser
    let isFriend: Bool
    let accentColor: Color
    
    init(user: DiscoverUser, isFriend: Bool? = nil, accentColor: Color = .cyan) {
        self.user = user
        self.isFriend = isFriend ?? user.isFriend ?? false
        self.accentColor = accentColor
    }
    
    var body: some View {
        if user.hasAnySocialMedia {
            HStack(spacing: 12) {
                // TikTok
                if user.hasTikTok {
                    SocialMediaIconView(
                        platform: .tiktok,
                        username: user.tiktokUsername,
                        isUnlocked: isFriend,
                        accentColor: accentColor
                    )
                }
                
                // Instagram
                if user.hasInstagram {
                    SocialMediaIconView(
                        platform: .instagram,
                        username: user.instagramUsername,
                        isUnlocked: isFriend,
                        accentColor: accentColor
                    )
                }
                
                // Snapchat
                if user.hasSnapchat {
                    SocialMediaIconView(
                        platform: .snapchat,
                        username: user.snapchatUsername,
                        isUnlocked: isFriend,
                        accentColor: accentColor
                    )
                }
            }
        }
    }
}

// MARK: - Single Social Media Icon View

struct SocialMediaIconView: View {
    let platform: SocialMediaPlatform
    let username: String?
    let isUnlocked: Bool
    let accentColor: Color
    
    @State private var showLockedTooltip = false
    
    var body: some View {
        Button {
            if isUnlocked {
                openSocialMedia()
            } else {
                // Show tooltip for locked state
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showLockedTooltip = true
                }
                // Auto-hide after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showLockedTooltip = false
                    }
                }
            }
        } label: {
            ZStack {
                // Background
                Circle()
                    .fill(isUnlocked ? platform.color.opacity(0.15) : Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                // Icon
                if isUnlocked {
                    Image(systemName: platform.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(platform.color)
                } else {
                    // Locked state - show lock icon
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }
        }
        .buttonStyle(.plain)
        .overlay(alignment: .top) {
            if showLockedTooltip {
                LockedTooltip()
                    .offset(y: -50)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    private func openSocialMedia() {
        guard let username = username else { return }
        
        switch platform {
        case .tiktok:
            SocialMediaService.shared.openTikTok(username: username)
        case .instagram:
            SocialMediaService.shared.openInstagram(username: username)
        case .snapchat:
            SocialMediaService.shared.openSnapchat(username: username)
        }
    }
}

// MARK: - Locked Tooltip

private struct LockedTooltip: View {
    var body: some View {
        Text("Arkadaş ol, sosyal medyasını gör")
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.8))
            )
            .fixedSize()
    }
}

// MARK: - Social Media Row for Profile Detail

struct SocialMediaRow: View {
    let user: DiscoverUser
    let isFriend: Bool
    let accentColor: Color
    
    init(user: DiscoverUser, isFriend: Bool? = nil, accentColor: Color = .cyan) {
        self.user = user
        self.isFriend = isFriend ?? user.isFriend ?? false
        self.accentColor = accentColor
    }
    
    var body: some View {
        if user.hasAnySocialMedia {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: isFriend ? "link" : "lock.fill")
                        .foregroundStyle(isFriend ? accentColor : .gray)
                    Text(isFriend ? "Sosyal Medya" : "Sosyal Medya (Kilitli)")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                
                if isFriend {
                    // Show clickable social media links
                    VStack(spacing: 8) {
                        if let username = user.tiktokUsername, !username.isEmpty {
                            SocialMediaLinkButton(platform: .tiktok, username: username)
                        }
                        if let username = user.instagramUsername, !username.isEmpty {
                            SocialMediaLinkButton(platform: .instagram, username: username)
                        }
                        if let username = user.snapchatUsername, !username.isEmpty {
                            SocialMediaLinkButton(platform: .snapchat, username: username)
                        }
                    }
                } else {
                    // Show locked message
                    HStack(spacing: 8) {
                        Image(systemName: "person.badge.plus")
                            .foregroundStyle(accentColor)
                        Text("Arkadaş ol, sosyal medyasını gör")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    .padding(.vertical, 8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
}

// MARK: - Social Media Link Button

struct SocialMediaLinkButton: View {
    let platform: SocialMediaPlatform
    let username: String
    
    var body: some View {
        Button {
            openSocialMedia()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: platform.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(platform.color)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(platform.color.opacity(0.15))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(platform.displayName)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white)
                    Text("@\(username)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .buttonStyle(.plain)
    }
    
    private func openSocialMedia() {
        switch platform {
        case .tiktok:
            SocialMediaService.shared.openTikTok(username: username)
        case .instagram:
            SocialMediaService.shared.openInstagram(username: username)
        case .snapchat:
            SocialMediaService.shared.openSnapchat(username: username)
        }
    }
}

// MARK: - Social Media Platform Extension

extension SocialMediaPlatform {
    var displayName: String {
        switch self {
        case .tiktok: return "TikTok"
        case .instagram: return "Instagram"
        case .snapchat: return "Snapchat"
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(red: 0.04, green: 0.02, blue: 0.08)
            .ignoresSafeArea()
        
        VStack(spacing: 24) {
            // Unlocked state (friend)
            VStack(alignment: .leading, spacing: 8) {
                Text("Arkadaş (Açık)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                SocialMediaIconsView(
                    user: DiscoverUser(
                        id: "1",
                        displayName: "Test",
                        age: 22,
                        city: "İstanbul",
                        country: "Türkiye",
                        countryFlag: "🇹🇷",
                        distanceKm: 5.0,
                        profilePhotoURL: "",
                        photos: [],
                        tags: [],
                        commonInterests: [],
                        score: 90,
                        isBoosted: false,
                        tiktokUsername: "test_user",
                        instagramUsername: "test.user",
                        snapchatUsername: "testuser",
                        isFriend: true
                    ),
                    isFriend: true
                )
            }
            
            // Locked state (not friend)
            VStack(alignment: .leading, spacing: 8) {
                Text("Arkadaş Değil (Kilitli)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                SocialMediaIconsView(
                    user: DiscoverUser(
                        id: "2",
                        displayName: "Test2",
                        age: 23,
                        city: "Ankara",
                        country: "Türkiye",
                        countryFlag: "🇹🇷",
                        distanceKm: 10.0,
                        profilePhotoURL: "",
                        photos: [],
                        tags: [],
                        commonInterests: [],
                        score: 85,
                        isBoosted: false,
                        tiktokUsername: "test_user2",
                        instagramUsername: "test.user2",
                        snapchatUsername: nil,
                        isFriend: false
                    ),
                    isFriend: false
                )
            }
            
            // Social Media Row - Unlocked
            SocialMediaRow(
                user: DiscoverUser(
                    id: "3",
                    displayName: "Test3",
                    age: 24,
                    city: "İzmir",
                    country: "Türkiye",
                    countryFlag: "🇹🇷",
                    distanceKm: 15.0,
                    profilePhotoURL: "",
                    photos: [],
                    tags: [],
                    commonInterests: [],
                    score: 88,
                    isBoosted: false,
                    tiktokUsername: "test_user3",
                    instagramUsername: "test.user3",
                    snapchatUsername: "testuser3",
                    isFriend: true
                ),
                isFriend: true
            )
            
            // Social Media Row - Locked
            SocialMediaRow(
                user: DiscoverUser(
                    id: "4",
                    displayName: "Test4",
                    age: 25,
                    city: "Bursa",
                    country: "Türkiye",
                    countryFlag: "🇹🇷",
                    distanceKm: 20.0,
                    profilePhotoURL: "",
                    photos: [],
                    tags: [],
                    commonInterests: [],
                    score: 82,
                    isBoosted: false,
                    tiktokUsername: "test_user4",
                    instagramUsername: nil,
                    snapchatUsername: "testuser4",
                    isFriend: false
                ),
                isFriend: false
            )
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
