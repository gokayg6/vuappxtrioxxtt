import SwiftUI

struct SplashView: View {
    // Animation states
    @State private var logoBlur: CGFloat = 20
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var logoYOffset: CGFloat = 40
    @State private var textBlur: CGFloat = 10
    @State private var textOpacity: Double = 0
    @State private var textYOffset: CGFloat = 15
    @State private var studioOpacity: Double = 0
    @State private var glowScale: CGFloat = 0.3
    @State private var glowOpacity: Double = 0
    @State private var vignetteOpacity: Double = 0
    @State private var starsVisible = false
    @State private var shimmerOffset: CGFloat = -200
    @State private var pulseScale: CGFloat = 1.0
    
    // App background color
    private let bgColorDark = Color(red: 0.04, green: 0.02, blue: 0.08)
    @Environment(\.colorScheme) private var colorScheme
    
    private var bgColor: Color {
        colorScheme == .dark ? bgColorDark : .white
    }
    
    var body: some View {
        ZStack {
            // Base dark background
            bgColor.ignoresSafeArea()
            
            // Vignette - darker edges
            RadialGradient(
                colors: [
                    Color.clear,
                    bgColor.opacity(0.5),
                    bgColor.opacity(0.85),
                    bgColor
                ],
                center: .center,
                startRadius: 80,
                endRadius: 500
            )
            .ignoresSafeArea()
            .opacity(vignetteOpacity)
            
            // Tiny stars
            if starsVisible && colorScheme == .dark {
                PremiumStarsView()
            }
            
            // Glow behind logo
            ZStack {
                // Primary glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.9, green: 0.45, blue: 0.8).opacity(0.25),
                                Color(red: 0.6, green: 0.4, blue: 0.95).opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 180
                        )
                    )
                    .frame(width: 350, height: 350)
                    .blur(radius: 60)
                
                // Secondary pulse glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.85, green: 0.5, blue: 0.9).opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 120
                        )
                    )
                    .frame(width: 250, height: 250)
                    .blur(radius: 40)
                    .scaleEffect(pulseScale)
            }
            .scaleEffect(glowScale)
            .opacity(glowOpacity)
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo
                ZStack {
                    // Shimmer overlay
                    Image("VibeULogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .overlay(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    colorScheme == .dark ? Color.white.opacity(0.3) : Color.black.opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: 100)
                            .offset(x: shimmerOffset)
                            .blur(radius: 10)
                        )
                        .mask(
                            Image("VibeULogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180, height: 180)
                        )
                    
                    // Main logo
                    Image("VibeULogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                }
                .blur(radius: logoBlur)
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                .offset(y: logoYOffset)
                .shadow(color: Color(red: 0.8, green: 0.4, blue: 0.9).opacity(0.5), radius: 40, x: 0, y: 20)
                
                // VibeU text
                Text("VibeU")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: colorScheme == .dark ? [.white, Color(white: 0.85)] : [.black, Color(white: 0.2)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .blur(radius: textBlur)
                    .opacity(textOpacity)
                    .offset(y: textYOffset)
                    .padding(.top, 24)
                
                Spacer()
                
                // Loegs Studio
                VStack(spacing: 4) {
                    Text("by")
                        .font(.system(size: 11, weight: .light))
                        .foregroundStyle(Color(white: 0.4))
                    
                    Text("Loegs Studio")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: colorScheme == .dark ? [Color(white: 0.55), Color(white: 0.45)] : [Color(white: 0.3), Color(white: 0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .tracking(1.5)
                }
                .opacity(studioOpacity)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startEpicAnimations()
        }
    }
    
    private func startEpicAnimations() {
        // Phase 1: Vignette appears (hızlı)
        withAnimation(.easeOut(duration: 0.25)) {
            vignetteOpacity = 1.0
        }
        
        // Phase 2: Logo appears blurred, then unblurs (hızlı)
        withAnimation(.easeOut(duration: 0.2).delay(0.05)) {
            logoOpacity = 1.0
        }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.08)) {
            logoScale = 1.0
            logoYOffset = 0
        }
        
        withAnimation(.easeOut(duration: 0.4).delay(0.15)) {
            logoBlur = 0
        }
        
        // Phase 3: Glow expands (hızlı)
        withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
            glowScale = 1.0
            glowOpacity = 1.0
        }
        
        // Phase 4: Text appears (hızlı)
        withAnimation(.easeOut(duration: 0.2).delay(0.3)) {
            textOpacity = 1.0
        }
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8).delay(0.3)) {
            textYOffset = 0
        }
        
        withAnimation(.easeOut(duration: 0.25).delay(0.35)) {
            textBlur = 0
        }
        
        // Phase 5: Stars fade in (hızlı)
        withAnimation(.easeIn(duration: 0.3).delay(0.4)) {
            starsVisible = true
        }
        
        // Phase 6: Studio credit (hızlı)
        withAnimation(.easeOut(duration: 0.2).delay(0.5)) {
            studioOpacity = 1.0
        }
        
        // Continuous: Shimmer effect
        withAnimation(.linear(duration: 2.0).delay(0.3).repeatForever(autoreverses: false)) {
            shimmerOffset = 200
        }
        
        // Continuous: Pulse glow
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.5)) {
            pulseScale = 1.15
        }
    }
}

// MARK: - Premium Stars
struct PremiumStarsView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                PremiumStar(size: 1.8, delay: 0.0)
                    .position(x: geo.size.width * 0.12, y: geo.size.height * 0.15)
                
                PremiumStar(size: 2.2, delay: 0.2)
                    .position(x: geo.size.width * 0.88, y: geo.size.height * 0.20)
                
                PremiumStar(size: 1.5, delay: 0.4)
                    .position(x: geo.size.width * 0.06, y: geo.size.height * 0.52)
                
                PremiumStar(size: 2.0, delay: 0.1)
                    .position(x: geo.size.width * 0.94, y: geo.size.height * 0.45)
                
                PremiumStar(size: 1.6, delay: 0.3)
                    .position(x: geo.size.width * 0.18, y: geo.size.height * 0.80)
                
                PremiumStar(size: 1.4, delay: 0.5)
                    .position(x: geo.size.width * 0.82, y: geo.size.height * 0.85)
            }
        }
    }
}

struct PremiumStar: View {
    let size: CGFloat
    let delay: Double
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.5
    @State private var twinkle: Double = 1.0
    
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: size, height: size)
            .scaleEffect(scale)
            .opacity(opacity * twinkle)
            .blur(radius: size * 0.15)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(delay)) {
                    opacity = Double.random(in: 0.4...0.7)
                    scale = 1.0
                }
                withAnimation(.easeInOut(duration: Double.random(in: 2.5...4.0)).repeatForever(autoreverses: true).delay(delay + 0.3)) {
                    twinkle = Double.random(in: 0.3...0.6)
                }
            }
    }
}

#Preview {
    SplashView()
}
