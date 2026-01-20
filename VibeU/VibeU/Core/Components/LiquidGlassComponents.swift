import SwiftUI

// MARK: - Liquid Glass Button (Layer 3 - Micro Glass)

struct GlassButton: View {
    let title: LocalizedStringKey
    let icon: String?
    let style: GlassButtonStyle
    let action: () -> Void
    
    enum GlassButtonStyle {
        case primary
        case secondary
        case destructive
        case accent
    }
    
    init(
        _ title: LocalizedStringKey,
        icon: String? = nil,
        style: GlassButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                }
                Text(title)
                    .font(.body.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(backgroundGradient)
            .glassEffect()
        }
        .buttonStyle(GlassButtonPressStyle())
        .sensoryFeedback(.impact(weight: .medium), trigger: UUID())
    }
    
    @ViewBuilder
    private var backgroundGradient: some View {
        switch style {
        case .primary:
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.purple.opacity(0.3))
        case .secondary:
            Color.clear
        case .destructive:
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.red.opacity(0.3))
        case .accent:
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.4), .pink.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
}

struct GlassButtonPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Glass Icon Button (Layer 3 - Micro Glass)

struct GlassIconButton: View {
    let icon: String
    let size: CGFloat
    let color: Color
    let action: () -> Void
    
    init(
        icon: String,
        size: CGFloat = 44,
        color: Color = .primary,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: size, height: size)
                .glassEffect()
        }
        .buttonStyle(GlassIconPressStyle())
        .sensoryFeedback(.impact(weight: .light), trigger: UUID())
    }
}

struct GlassIconPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

// MARK: - Glass Card (Layer 1 - Primary Glass)

struct GlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .glassEffect()
    }
}

// MARK: - Glass Container

struct GlassContainer<Content: View>: View {
    let padding: CGFloat
    let content: Content
    
    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .glassEffect()
    }
}

// MARK: - Glass Segment Control (Layer 3 - Micro Glass)

struct GlassSegmentControl<T: Hashable>: View {
    @Binding var selection: T
    let options: [(T, LocalizedStringKey, String?)]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.0) { option in
                GlassSegmentButton(
                    title: option.1,
                    icon: option.2,
                    isSelected: selection == option.0
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selection = option.0
                    }
                }
            }
        }
        .padding(4)
        .glassEffect()
        .sensoryFeedback(.selection, trigger: selection)
    }
}

struct GlassSegmentButton: View {
    let title: LocalizedStringKey
    let icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Text(icon)
                        .font(.body)
                }
                Text(title)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Color.purple.opacity(0.4))
                        .glassEffect()
                }
            }
            .foregroundStyle(isSelected ? .white : .secondary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Glass Badge

struct GlassBadge: View {
    let count: Int
    
    var body: some View {
        if count > 0 {
            Text(count > 99 ? "99+" : "\(count)")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.red)
                .clipShape(Capsule())
                .glassEffect()
        }
    }
}

// MARK: - Glass Pill Tag

struct GlassPillTag: View {
    let text: String
    let isSelected: Bool
    let action: (() -> Void)?
    
    init(_ text: String, isSelected: Bool = false, action: (() -> Void)? = nil) {
        self.text = text
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        if let action = action {
            Button(action: action) {
                pillContent
            }
            .buttonStyle(.plain)
        } else {
            pillContent
        }
    }
    
    private var pillContent: some View {
        Text(text)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                if isSelected {
                    Color.purple.opacity(0.4)
                }
            }
            .glassEffect()
            .foregroundStyle(isSelected ? .white : .primary)
    }
}

// MARK: - Glass Text Field

struct GlassTextField: View {
    let placeholder: LocalizedStringKey
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .padding(.horizontal, 16)
            .frame(height: 52)
            .glassEffect()
    }
}

// MARK: - Glass Loading View

struct GlassLoadingView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(.white)
            .frame(width: 60, height: 60)
            .glassEffect()
    }
}

// MARK: - Glass Empty State

struct GlassEmptyState: View {
    let icon: String
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    let actionTitle: LocalizedStringKey?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: LocalizedStringKey,
        message: LocalizedStringKey,
        actionTitle: LocalizedStringKey? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.weight(.semibold))
                
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                GlassButton(actionTitle, style: .primary, action: action)
                    .frame(width: 200)
            }
        }
        .padding(32)
        .glassEffect()
    }
}

// MARK: - Glass Error View

struct GlassErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(.orange)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            GlassButton("retry", icon: "arrow.clockwise", action: retryAction)
                .frame(width: 140)
        }
        .padding(24)
        .glassEffect()
        .sensoryFeedback(.error, trigger: UUID())
    }
}

// MARK: - Skeleton Loading

struct GlassSkeletonCard: View {
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.05),
                        Color.white.opacity(0.1),
                        Color.white.opacity(0.05)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .glassEffect()
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.1), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: isAnimating ? 400 : -400)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}
