import SwiftUI

// MARK: - Theme Colors
struct ThemeColors {
    let background: Color
    let cardBackground: Color
    let secondaryBackground: Color
    let primaryText: Color
    let secondaryText: Color
    let tertiaryText: Color
    let border: Color
    let accent: Color
    let tabBarBackground: Color
    let tabBarSelected: Color
    let tabBarUnselected: Color
    
    // Dark Theme
    static let dark = ThemeColors(
        background: Color(red: 0.04, green: 0.02, blue: 0.08),
        cardBackground: Color(red: 0.11, green: 0.11, blue: 0.12),
        secondaryBackground: Color(red: 0.08, green: 0.06, blue: 0.1),
        primaryText: .white,
        secondaryText: Color(white: 0.6),
        tertiaryText: Color(white: 0.4),
        border: Color(white: 0.16),
        accent: Color(red: 0.62, green: 0.31, blue: 0.87),
        tabBarBackground: Color(red: 0.06, green: 0.04, blue: 0.1),
        tabBarSelected: .white,
        tabBarUnselected: Color(white: 0.5)
    )
    
    // Light Theme
    static let light = ThemeColors(
        background: Color(red: 0.98, green: 0.98, blue: 0.99),
        cardBackground: .white,
        secondaryBackground: Color(red: 0.95, green: 0.95, blue: 0.97),
        primaryText: Color(red: 0.1, green: 0.1, blue: 0.12),
        secondaryText: Color(red: 0.4, green: 0.4, blue: 0.45),
        tertiaryText: Color(red: 0.6, green: 0.6, blue: 0.65),
        border: Color(red: 0.9, green: 0.9, blue: 0.92),
        accent: Color(red: 0.55, green: 0.25, blue: 0.8),
        tabBarBackground: .white,
        tabBarSelected: .black,
        tabBarUnselected: Color(red: 0.5, green: 0.5, blue: 0.55)
    )
}

// MARK: - Theme Environment Key
struct ThemeColorsKey: EnvironmentKey {
    static let defaultValue: ThemeColors = .dark
}

extension EnvironmentValues {
    var themeColors: ThemeColors {
        get { self[ThemeColorsKey.self] }
        set { self[ThemeColorsKey.self] = newValue }
    }
}

// MARK: - Theme Provider View Modifier
struct ThemeProvider: ViewModifier {
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    
    var effectiveTheme: ThemeColors {
        switch appState.currentTheme {
        case .dark:
            return .dark
        case .light:
            return .light
        case .system:
            return systemColorScheme == .dark ? .dark : .light
        }
    }
    
    var effectiveColorScheme: ColorScheme {
        switch appState.currentTheme {
        case .dark:
            return .dark
        case .light:
            return .light
        case .system:
            return systemColorScheme
        }
    }
    
    func body(content: Content) -> some View {
        content
            .environment(\.themeColors, effectiveTheme)
            .preferredColorScheme(appState.currentTheme.colorScheme)
    }
}

extension View {
    func withTheme() -> some View {
        modifier(ThemeProvider())
    }
}

// MARK: - Convenience Extensions
extension View {
    func themedBackground(_ colors: ThemeColors) -> some View {
        self.background(colors.background.ignoresSafeArea())
    }
    
    func themedCard(_ colors: ThemeColors, cornerRadius: CGFloat = 16) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(colors.border, lineWidth: 0.5)
                    )
            )
    }
}
