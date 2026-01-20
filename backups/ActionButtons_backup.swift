            }
            messageText = ""
            
            // 2 saniye sonra confirmation'ı gizle
            try? await Task.sleep(for: .seconds(2))
            withAnimation {
                showSentConfirmation = false
            }
        }
    }
}

// MARK: - Tinder Action Bar
struct TinderActionBar: View {
    let onRewind: () -> Void
    let onSkip: () -> Void
    let onSuperLike: () -> Void
    let onLike: () -> Void
    let onBoost: () -> Void
    var cardOffset: CGSize = .zero // Kart kaydırma durumu
    
    // Hangi buton highlight olacak
    private var highlightSkip: Bool {
        cardOffset.width < -50
    }
    
    private var highlightLike: Bool {
        cardOffset.width > 50
    }
    
    private var highlightSuperLike: Bool {
        cardOffset.height < -50
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Rewind (Turuncu gradient)
            GlassActionButton(
                icon: "arrow.uturn.backward",
                size: 54,
                iconSize: 24,
                colors: [Color(red: 1.0, green: 0.8, blue: 0), Color(red: 1.0, green: 0.5, blue: 0)],
                action: onRewind
            )
            
            // Skip (X - Pembe gradient) - Sola kaydırınca highlight
            GlassActionButton(
                icon: "xmark",
                size: 64,
                iconSize: 32,
                colors: [Color(red: 1.0, green: 0.3, blue: 0.5), Color(red: 1.0, green: 0.15, blue: 0.4)],
                action: onSkip,
                isHighlighted: highlightSkip
            )
            
            // Super Like (Yıldız) - Yukarı kaydırınca highlight
            GlassActionButton(
                icon: "star.fill",
                size: 54,
                iconSize: 26,
                colors: [Color(red: 0.3, green: 0.85, blue: 1.0), Color(red: 0.1, green: 0.5, blue: 1.0)],
                action: onSuperLike,
                isHighlighted: highlightSuperLike
            )
            
            // Like (Kalp) - Sağa kaydırınca highlight
            GlassActionButton(
                icon: "heart.fill",
                size: 64,
                iconSize: 32,
                colors: [Color(red: 0.5, green: 1.0, blue: 0.3), Color(red: 0.2, green: 0.9, blue: 0.4)],
                action: onLike,
                isHighlighted: highlightLike
            )
            
            // Message (Mavi gradient)
            GlassActionButton(
                icon: "paperplane.fill",
                size: 54,
                iconSize: 24,
                colors: [Color(red: 0.3, green: 0.7, blue: 1.0), Color(red: 0.2, green: 0.5, blue: 0.9)],
                action: onBoost
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Glass Action Button (Gradient Icons with Hover Swap)
struct GlassActionButton: View {
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

// MARK: - Filter Sheet
