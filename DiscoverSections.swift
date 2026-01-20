import SwiftUI

// MARK: - Quick Action Strip

struct QuickActionStrip: View {
    let onFavorites: () -> Void
    let onRequests: () -> Void
    let onBoost: () -> Void
    let onLikedYou: () -> Void
    let isPremium: Bool
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                QuickActionItem(
                    icon: "star.fill",
                    title: "favorites",
                    color: .yellow,
                    action: onFavorites
                )
                
                QuickActionItem(
                    icon: "plus.message.fill",
                    title: "requests",
                    color: .purple,
                    action: onRequests
                )
                
                QuickActionItem(
                    icon: "bolt.fill",
                    title: "boost",
                    color: .orange,
                    action: onBoost
                )
                
                QuickActionItem(
                    icon: "eyes",
                    title: "liked_you",
                    color: .pink,
                    isPremiumLocked: !isPremium,
                    action: onLikedYou
                )
            }
            .padding(.horizontal, 16)
        }
    }
}

struct QuickActionItem: View {
    let icon: String
    let title: LocalizedStringKey
    let color: Color
    var isPremiumLocked: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                    
                    if isPremiumLocked {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                            .offset(x: 14, y: -14)
                    }
                }
                .frame(width: 50, height: 50)
                .glassEffect()
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(GlassButtonPressStyle())
    }
}

// MARK: - Trending Section

struct TrendingSection: View {
    let users: [DiscoverUser]
    let mode: DiscoverMode
    let onUserTap: (DiscoverUser) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text(mode == .local ? "trending_local" : "trending_global")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // Grid
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(users.prefix(4)) { user in
                    TrendingUserCard(user: user) {
                        onUserTap(user)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct TrendingUserCard: View {
    let user: DiscoverUser
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                // Photo
                GlassAsyncImage(url: user.profilePhotoURL)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Gradient
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    // Tags
                    if !user.tags.isEmpty {
                        HStack(spacing: 2) {
                            ForEach(user.tags.prefix(3), id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Text(user.displayName)
                            .font(.subheadline.weight(.semibold))
                        Text("\(user.age)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(12)
            }
            .glassEffect()
        }
        .buttonStyle(GlassButtonPressStyle())
    }
}

// MARK: - Spotlight Section

struct SpotlightSection: View {
    let users: [DiscoverUser]
    let mode: DiscoverMode
    let onUserTap: (DiscoverUser) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: mode == .local ? "location.fill" : "globe")
                    .foregroundStyle(.purple)
                Text(mode == .local ? "spotlight_local" : "spotlight_global")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // Horizontal Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(users) { user in
                        SpotlightUserCard(user: user, mode: mode) {
                            onUserTap(user)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct SpotlightUserCard: View {
    let user: DiscoverUser
    let mode: DiscoverMode
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottom) {
                // Photo - Cinematic Crop
                GlassAsyncImage(url: user.profilePhotoURL)
                    .frame(width: 160, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                // Gradient
                LinearGradient(
                    colors: [.clear, .black.opacity(0.8)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                // Info Footer
                VStack(spacing: 6) {
                    HStack(spacing: 4) {
                        Text(user.displayName)
                            .font(.subheadline.weight(.semibold))
                        Text("\(user.age)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        if mode == .global, let flag = user.countryFlag {
                            Text(flag)
                                .font(.caption)
                        }
                        Text(user.city)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let distance = user.distanceKm, mode == .local {
                            Text("• \(Int(distance))km")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .glassEffect()
            }
            .frame(width: 160, height: 220)
        }
        .buttonStyle(GlassButtonPressStyle())
    }
}

// MARK: - Continue Discover Section

struct ContinueDiscoverSection: View {
    let users: [DiscoverUser]
    let onLike: (DiscoverUser) -> Void
    let onSkip: (DiscoverUser) -> Void
    let onRequest: (DiscoverUser) -> Void
    let onTap: (DiscoverUser) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "rectangle.stack.fill")
                    .foregroundStyle(.blue)
                Text("continue_discover")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // Card Stack
            ZStack {
                ForEach(Array(users.prefix(3).enumerated().reversed()), id: \.element.id) { index, user in
                    MiniDiscoverCard(
                        user: user,
                        onLike: { onLike(user) },
                        onSkip: { onSkip(user) },
                        onTap: { onTap(user) }
                    )
                    .offset(y: CGFloat(index) * 8)
                    .scaleEffect(1 - CGFloat(index) * 0.05)
                    .opacity(index == 0 ? 1 : 0.7)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct MiniDiscoverCard: View {
    let user: DiscoverUser
    let onLike: () -> Void
    let onSkip: () -> Void
    let onTap: () -> Void
    
    @State private var offset: CGSize = .zero
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Photo
            GlassAsyncImage(url: user.profilePhotoURL)
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            // Gradient
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .center,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            // Info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(user.displayName)
                            .font(.title3.weight(.semibold))
                        Text("\(user.age)")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(user.city)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Mini Actions
                HStack(spacing: 8) {
                    GlassIconButton(icon: "xmark", size: 40, color: .white) {
                        onSkip()
                    }
                    GlassIconButton(icon: "heart.fill", size: 40, color: .red) {
                        onLike()
                    }
                }
            }
            .padding(16)
        }
        .glassEffect()
        .offset(offset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    offset = value.translation
                }
                .onEnded { value in
                    if value.translation.width > 100 {
                        withAnimation { offset = CGSize(width: 500, height: 0) }
                        onLike()
                    } else if value.translation.width < -100 {
                        withAnimation { offset = CGSize(width: -500, height: 0) }
                        onSkip()
                    } else {
                        withAnimation(.spring()) { offset = .zero }
                    }
                }
        )
        .onTapGesture {
            onTap()
        }
    }
}
