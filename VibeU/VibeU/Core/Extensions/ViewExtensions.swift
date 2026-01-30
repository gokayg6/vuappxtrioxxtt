import SwiftUI

// MARK: - Glass Effect Modifier
extension View {
    func glassEffect(isDark: Bool = true) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.1), lineWidth: 1)
            )
    }
    
    func glassButton(isSelected: Bool, isDark: Bool = true) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected 
                            ? (isDark ? Color.white.opacity(0.15) : Color.black.opacity(0.15))
                            : (isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected
                            ? (isDark ? Color.white.opacity(0.3) : Color.black.opacity(0.3))
                            : (isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.1)),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
    }
}
