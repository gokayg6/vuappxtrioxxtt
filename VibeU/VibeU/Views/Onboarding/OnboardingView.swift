import SwiftUI

// MARK: - Onboarding Page Data
struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let gradient: [Color]
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showWelcome = false
    @Binding var hasSeenOnboarding: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "person.2.fill",
            title: "Yeni İnsanlarla Tanış",
            subtitle: "Etrafındaki harika insanları keşfet ve anlamlı bağlantılar kur",
            gradient: [Color(hex: "667eea"), Color(hex: "764ba2")]
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "Ortak İlgi Alanları",
            subtitle: "Seninle aynı tutkuları paylaşan insanları bul",
            gradient: [Color(hex: "f093fb"), Color(hex: "f5576c")]
        ),
        OnboardingPage(
            icon: "message.fill",
            title: "Gerçek Bağlantılar",
            subtitle: "Sadece yüzeysel değil, gerçek ve derin arkadaşlıklar edin",
            gradient: [Color(hex: "4facfe"), Color(hex: "00f2fe")]
        ),
        OnboardingPage(
            icon: "shield.checkered",
            title: "Güvenli Ortam",
            subtitle: "Gizliliğin ve güvenliğin bizim önceliğimiz",
            gradient: [Color(hex: "43e97b"), Color(hex: "38f9d7")]
        )
    ]
    
    var body: some View {
        ZStack {
            // Dynamic background
            if colorScheme == .dark {
                LinearGradient(
                    colors: [
                        Color(hex: "0a0118"),
                        Color(hex: "1a0a2e"),
                        Color(hex: "0d0d1a")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            } else {
                Color.white
                    .ignoresSafeArea()
            }
            
            // Animated orbs
            OnboardingOrbs()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button {
                        completeOnboarding()
                    } label: {
                        Text("Geç")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .glassEffect()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Custom page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? 
                                  LinearGradient(colors: pages[currentPage].gradient, startPoint: .leading, endPoint: .trailing) :
                                  LinearGradient(colors: [colorScheme == .dark ? .white.opacity(0.3) : .black.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
                            .frame(width: index == currentPage ? 32 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 32)
                
                // Next/Get Started button
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation(.spring(response: 0.4)) {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                } label: {
                    HStack(spacing: 12) {
                        Text(currentPage == pages.count - 1 ? "Başla" : "Devam")
                            .font(.system(size: 18, weight: .bold))
                        
                        Image(systemName: currentPage == pages.count - 1 ? "arrow.right" : "chevron.right")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        LinearGradient(
                            colors: pages[currentPage].gradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: pages[currentPage].gradient[0].opacity(0.5), radius: 20, x: 0, y: 10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
        .fullScreenCover(isPresented: $showWelcome) {
            AuthView()
        }
    }
    
    private func completeOnboarding() {
        hasSeenOnboarding = true
        showWelcome = true
    }
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var animate = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon with animated ring
            ZStack {
                // Outer glow ring
                Circle()
                    .stroke(
                        LinearGradient(colors: page.gradient.map { $0.opacity(0.3) }, startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 3
                    )
                    .frame(width: 180, height: 180)
                    .scaleEffect(animate ? 1.1 : 1.0)
                    .opacity(animate ? (colorScheme == .dark ? 0.5 : 0.8) : 1.0)
                
                // Inner circle with glass
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 140, height: 140)
                    .glassEffect()
                
                // Icon
                Image(systemName: page.icon)
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(colors: page.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
            
            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Onboarding Orbs
struct OnboardingOrbs: View {
    @State private var offset1 = CGSize.zero
    @State private var offset2 = CGSize.zero
    @State private var offset3 = CGSize.zero
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Purple orb
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "667eea").opacity(0.4), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .blur(radius: 60)
                    .offset(offset1)
                    .position(x: 50, y: geo.size.height * 0.2)
                
                // Pink orb
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "f093fb").opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .blur(radius: 50)
                    .offset(offset2)
                    .position(x: geo.size.width - 50, y: geo.size.height * 0.5)
                
                // Cyan orb
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "4facfe").opacity(0.25), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .frame(width: 250, height: 250)
                    .blur(radius: 40)
                    .offset(offset3)
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.8)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                offset1 = CGSize(width: 40, height: -30)
            }
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                offset2 = CGSize(width: -50, height: 40)
            }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                offset3 = CGSize(width: 30, height: 50)
            }
        }
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}
