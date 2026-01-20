import SwiftUI

struct AuthButtonContent: View {
    let icon: String
    let title: LocalizedStringKey
    let isPrimary: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
            
            Text(title)
                .font(.headline)
        }
        .foregroundStyle(.primary)
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(colorScheme == .dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color(UIColor.systemGray6)))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// Animated Mesh Background
struct MeshGradientBackground: View {
    @State private var animate = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            colorScheme == .dark ? Color.black : Color.white
            
            GeometryReader { geometry in
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.4))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: animate ? -50 : 50, y: animate ? -50 : 50)
                    
                    Circle()
                        .fill(Color.indigo.opacity(0.4))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: animate ? 50 : -50, y: animate ? 50 : -50)
                    
                    Circle()
                        .fill(Color.pink.opacity(0.3))
                        .frame(width: 250, height: 250)
                        .blur(radius: 50)
                        .offset(x: animate ? -20 : 20, y: animate ? 100 : -100)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
        .ignoresSafeArea()
    }
}
