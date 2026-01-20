import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var transitionBlur: CGFloat = 12
    @State private var transitionOpacity: Double = 0.5
    @State private var hasTransitioned = false
    
    var body: some View {
        @Bindable var appState = appState
        
        ZStack {
            // Main content
            Group {
                switch appState.authState {
                case .loading:
                    SplashView()
                case .onboarding:
                    // Show onboarding if not seen
                    if !hasSeenOnboarding {
                        OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                            .blur(radius: hasTransitioned ? 0 : transitionBlur)
                            .opacity(hasTransitioned ? 1 : transitionOpacity)
                    } else {
                        AuthView()
                            .blur(radius: hasTransitioned ? 0 : transitionBlur)
                            .opacity(hasTransitioned ? 1 : transitionOpacity)
                    }
                case .unauthenticated:
                    AuthView()
                        .blur(radius: hasTransitioned ? 0 : transitionBlur)
                        .opacity(hasTransitioned ? 1 : transitionOpacity)
                case .authenticated:
                    MainTabView()
                        .blur(radius: hasTransitioned ? 0 : transitionBlur)
                        .opacity(hasTransitioned ? 1 : transitionOpacity)
                }
            }
        }
        .withTheme() // Inject theme provider
        .onChange(of: appState.authState) { oldValue, newValue in
            // Splash'tan çıkış animasyonu
            if oldValue == .loading && newValue != .loading {
                performEpicTransition()
            }
        }
        .onChange(of: hasSeenOnboarding) { _, newValue in
            // Onboarding bittikten sonra unauthenticated'a geç
            if newValue && appState.authState == .onboarding {
                appState.authState = .unauthenticated
            }
        }

        .fullScreenCover(isPresented: $appState.showPremiumOnLaunch) {
            PremiumView(isForced: true)
        }
    }
    
    private func performEpicTransition() {
        transitionBlur = 12
        transitionOpacity = 0.5
        
        withAnimation(.easeOut(duration: 0.4)) {
            transitionBlur = 0
            transitionOpacity = 1
            hasTransitioned = true
        }
    }
}

#Preview {
    RootView()
        .environment(AppState())
}
