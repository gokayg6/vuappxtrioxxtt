import SwiftUI

// MARK: - Discover Action Buttons (Layer 3 - Micro Glass)

struct LikeButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isPressed = false
            }
        } label: {
            Image(systemName: isPressed ? "heart.fill" : "heart")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(isPressed ? .red : .white)
                .frame(width: 64, height: 64)
                .background(isPressed ? Color.red.opacity(0.3) : Color.clear)
                .glassEffect()
                .scaleEffect(isPressed ? 1.15 : 1.0)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .medium), trigger: isPressed)
    }
}

struct SkipButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isPressed = false
            }
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .glassEffect()
                .scaleEffect(isPressed ? 0.85 : 1.0)
                .opacity(isPressed ? 0.6 : 1.0)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .light), trigger: isPressed)
    }
}

struct FavoriteButton: View {
    @Binding var isFavorite: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.5)) {
                isFavorite.toggle()
            }
            action()
        } label: {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(isFavorite ? .yellow : .white)
                .frame(width: 52, height: 52)
                .background(isFavorite ? Color.yellow.opacity(0.3) : Color.clear)
                .glassEffect()
                .rotationEffect(.degrees(isFavorite ? 360 : 0))
                .scaleEffect(isFavorite ? 1.1 : 1.0)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .medium), trigger: isFavorite)
    }
}

struct RequestButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isPressed = false
            }
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .opacity(isPressed ? 0.8 : 0.5)
                )
                .glassEffect()
                .scaleEffect(isPressed ? 1.2 : 1.0)
                .shadow(color: .purple.opacity(isPressed ? 0.6 : 0), radius: 12)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .heavy), trigger: isPressed)
    }
}

// MARK: - Action Bar

struct DiscoverActionBar: View {
    let onSkip: () -> Void
    let onLike: () -> Void
    let onFavorite: () -> Void
    let onRequest: () -> Void
    @Binding var isFavorite: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            SkipButton(action: onSkip)
            
            Spacer()
            
            FavoriteButton(isFavorite: $isFavorite, action: onFavorite)
            
            LikeButton(action: onLike)
            
            RequestButton(action: onRequest)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .glassEffect()
    }
}

// MARK: - Request Action Buttons

struct AcceptButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "checkmark")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color.green.opacity(0.4))
                .glassEffect()
        }
        .buttonStyle(GlassIconPressStyle())
        .sensoryFeedback(.success, trigger: UUID())
    }
}

struct RejectButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color.red.opacity(0.3))
                .glassEffect()
        }
        .buttonStyle(GlassIconPressStyle())
        .sensoryFeedback(.impact(weight: .light), trigger: UUID())
    }
}

// MARK: - Social Link Buttons

struct SocialLinkButton: View {
    let platform: SocialPlatform
    let username: String
    let deeplink: String
    let webURL: String
    
    enum SocialPlatform {
        case tiktok
        case instagram
        case snapchat
        
        var icon: String {
            switch self {
            case .tiktok: return "play.rectangle.fill"
            case .instagram: return "camera.fill"
            case .snapchat: return "message.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .tiktok: return .pink
            case .instagram: return .purple
            case .snapchat: return .yellow
            }
        }
        
        var name: String {
            switch self {
            case .tiktok: return "TikTok"
            case .instagram: return "Instagram"
            case .snapchat: return "Snapchat"
            }
        }
    }
    
    var body: some View {
        Button {
            openSocialLink()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: platform.icon)
                    .font(.title3)
                    .foregroundStyle(platform.color)
                    .frame(width: 40, height: 40)
                    .glassEffect()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(platform.name)
                        .font(.subheadline.weight(.medium))
                    Text("@\(username)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .glassEffect()
        }
        .buttonStyle(GlassButtonPressStyle())
        .sensoryFeedback(.impact(weight: .light), trigger: UUID())
    }
    
    private func openSocialLink() {
        // Try deeplink first, fallback to web URL
        if let deeplinkURL = URL(string: deeplink),
           UIApplication.shared.canOpenURL(deeplinkURL) {
            UIApplication.shared.open(deeplinkURL)
        } else if let webURLObj = URL(string: webURL) {
            UIApplication.shared.open(webURLObj)
        }
    }
}
// MARK: - Homepage Action Button (Tinder Style)
// Replicates the buttons from DiscoverView for consistent styling
struct HomepageActionButton: View {
    let icon: String
    let size: CGFloat
    let iconSize: CGFloat
    let colors: [Color]
    let action: () -> Void
    var isHighlighted: Bool = false
    
    @State private var isPressed = false
    @Environment(\.colorScheme) private var colorScheme
    
    private var isActive: Bool {
        isPressed || isHighlighted
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                // Daire - Normal: Light modda beyaz, Dark modda koyu gri; Basılı: Gradient
                Circle()
                    .fill(
                        isActive ?
                        AnyShapeStyle(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)) :
                        AnyShapeStyle(colorScheme == .dark ? Color(white: 0.15) : Color.white)
                    )
                    .overlay {
                        Circle()
                            .stroke(
                                colorScheme == .dark ?
                                Color.white.opacity(isActive ? 0.3 : 0.08) :
                                Color.black.opacity(isActive ? 0.2 : 0.1),
                                lineWidth: 1
                            )
                    }
                    .shadow(color: colorScheme == .light ? Color.black.opacity(0.1) : Color.clear, radius: 8, x: 0, y: 2)
                
                // İkon - Normal: Gradient, Basılı: Koyu gri
                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .bold))
                    .foregroundStyle(
                        isActive ?
                        AnyShapeStyle(Color(white: 0.12)) :
                        AnyShapeStyle(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom))
                    )
            }
            .frame(width: size, height: size)
            .scaleEffect(isActive ? 1.1 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isActive)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
