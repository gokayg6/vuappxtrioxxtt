import SwiftUI

struct ProfileDetailView: View {
    let user: DiscoverUser
    
    @State private var isFavorite = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
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
                            colors: [.clear, .clear, .black],
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
                                
                                Text("\(user.age)")
                                    .font(.title)
                                    .foregroundStyle(.secondary)
                                
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
                                
                                if let flag = user.countryFlag {
                                    Text(flag)
                                }
                                
                                if let distance = user.distanceKm {
                                    Text("•")
                                        .foregroundStyle(.secondary)
                                    Text("\(Int(distance)) km away")
                                        .foregroundStyle(.secondary)
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
                        
                        // Bottom Padding
                        Color.clear.frame(height: 120)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, -60)
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // Floating Action Bar
            VStack {
                Spacer()
                
                HStack(spacing: 16) {
                    SkipButton {
                        dismiss()
                    }
                    
                    Spacer()
                    
                    FavoriteButton(isFavorite: $isFavorite) {
                        // Add to favorites
                    }
                    
                    LikeButton {
                        // Like
                        dismiss()
                    }
                    
                    RequestButton {
                        // Send request
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .glassEffect()
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
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
                        .glassEffect()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        // Report
                    } label: {
                        Label("report", systemImage: "exclamationmark.triangle")
                    }
                    
                    Button {
                        // Block
                    } label: {
                        Label("block", systemImage: "hand.raised")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.body.weight(.semibold))
                        .frame(width: 36, height: 36)
                        .glassEffect()
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
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
        ProfileDetailView(user: DiscoverUser(
            id: "1",
            displayName: "Jane",
            age: 24,
            city: "Istanbul",
            country: "Turkey",
            countryFlag: "🇹🇷",
            distanceKm: 5.2,
            profilePhotoURL: "",
            photos: [],
            tags: ["🎨", "🎵", "📚"],
            commonInterests: ["Music", "Art", "Travel"],
            score: 850,
            isBoosted: true,
            instagramUsername: "jane_doe",
            snapchatUsername: "jane_snap"
        ))
    }
}
