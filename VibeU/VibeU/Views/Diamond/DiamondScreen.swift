import SwiftUI

// MARK: - Diamond Screen (Elmas Ekranı)
struct DiamondScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var systemColorScheme
    
    @State private var balance: Int = 0
    @State private var canClaimReward = false
    @State private var isLoading = true
    @State private var isClaiming = false
    @State private var showSuccessAnimation = false
    @State private var timeUntilNextReward: TimeInterval?
    
    // Watch Ad for Diamonds
    @State private var canWatchAd = true
    @State private var isWatchingAd = false
    
    private var isDark: Bool {
        switch appState.currentTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }
    
    private var colors: ThemeColors { isDark ? .dark : .light }
    
    var body: some View {
        NavigationStack {
            ZStack {
                colors.background.ignoresSafeArea()
                
                // Diamond gradient overlay
                LinearGradient(
                    colors: [.clear, .cyan.opacity(isDark ? 0.1 : 0.05), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            balanceCard
                            dailyRewardSection
                            watchAdSection
                            infoSection
                            Spacer(minLength: 50)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    }
                }
            }
            .navigationTitle("Elmaslarım".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(colors.secondaryText)
                            .frame(width: 32, height: 32)
                            .background(colors.secondaryBackground, in: Circle())
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .task {
            await loadData()
        }
        .onAppear {
            checkAdWatchedToday()
        }
    }
    
    // MARK: - Balance Card
    private var balanceCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(RadialGradient(
                        colors: [.cyan.opacity(0.4), .clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 80
                    ))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image("diamond-icon")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.0))
                    .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.5), radius: 10)
            }
            
            VStack(spacing: 4) {
                Text("\(balance)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(colors.primaryText)
                
                Text("Elmas".localized)
                    .font(.subheadline)
                    .foregroundStyle(colors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [.cyan.opacity(0.3), .blue.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        #if DEBUG
        .onTapGesture(count: 3) { // Triple tap to add diamonds
            Task {
                try? await DiamondService.shared.addDiamonds(amount: 1000, type: .admin)
                balance += 1000
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        }
        #endif
    }
    
    // MARK: - Daily Reward Section
    private var dailyRewardSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "gift.fill")
                    .foregroundStyle(.orange)
                
                Text("Günlük Ödül".localized)
                    .font(.headline)
                    .foregroundStyle(colors.primaryText)
                
                Spacer()
                
                Text("+100")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.0))
                
                Image("diamond-icon")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.0))
            }
            
            if canClaimReward {
                Button {
                    Task {
                        await claimReward()
                    }
                } label: {
                    HStack {
                        if isClaiming {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "gift.fill")
                            Text("Ödülümü Al".localized)
                        }
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.orange, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                }
                .disabled(isClaiming)
            } else {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        
                        Text("Bugünkü ödülünü aldın!".localized)
                            .font(.subheadline)
                            .foregroundStyle(colors.secondaryText)
                    }
                    
                    if let time = timeUntilNextReward, time > 0 {
                        Text("\("Yeni ödül:".localized) \(formatTime(time))")
                            .font(.caption)
                            .foregroundStyle(colors.tertiaryText)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(colors.secondaryBackground, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(20)
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(colors.border, lineWidth: 0.5)
        )
    }
    
    // MARK: - Watch Ad Section (NEW - 25 Diamonds)
    private var watchAdSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "play.rectangle.fill")
                    .foregroundStyle(.purple)
                
                Text("Reklam İzle".localized)
                    .font(.headline)
                    .foregroundStyle(colors.primaryText)
                
                Spacer()
                
                Text("+25")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.0))
                
                Image("diamond-icon")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.0))
            }
            
            if canWatchAd {
                Button {
                    watchAdForDiamonds()
                } label: {
                    HStack {
                        if isWatchingAd {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "play.circle.fill")
                            Text("Reklam İzle & 25 Elmas Kazan".localized)
                        }
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.purple, .indigo],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                }
                .disabled(isWatchingAd)
                
                Text("Günde 1 kez kullanılabilir".localized)
                    .font(.caption)
                    .foregroundStyle(colors.tertiaryText)
            } else {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        
                        Text("Bugün reklamı izledin!".localized)
                            .font(.subheadline)
                            .foregroundStyle(colors.secondaryText)
                    }
                    
                    Text("Yarın tekrar izleyebilirsin".localized)
                        .font(.caption)
                        .foregroundStyle(colors.tertiaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(colors.secondaryBackground, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(20)
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(colors.border, lineWidth: 0.5)
        )
    }
    
    // MARK: - Info Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Elmas Nasıl Kullanılır?".localized)
                .font(.headline)
                .foregroundStyle(colors.primaryText)
            
            infoRow(icon: "heart.fill", color: .pink, text: "Eşleşme isteği göndermek: 10 elmas".localized)
            infoRow(icon: "gift.fill", color: .orange, text: "Her gün ücretsiz 100 elmas al".localized)
            infoRow(icon: "play.rectangle.fill", color: .purple, text: "Reklam izle, 25 elmas kazan".localized)
        }
        .padding(20)
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(colors.border, lineWidth: 0.5)
        )
    }
    
    private func infoRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(colors.secondaryText)
        }
    }
    
    // MARK: - Actions
    private func loadData() async {
        do {
            balance = try await DiamondService.shared.getBalance()
            canClaimReward = try await DiamondService.shared.canClaimDailyReward()
            timeUntilNextReward = try await DiamondService.shared.getTimeUntilNextReward()
        } catch {
            print("❌ [DiamondScreen] Error loading data: \(error)")
        }
        isLoading = false
    }
    
    private func claimReward() async {
        isClaiming = true
        
        do {
            try await DiamondService.shared.claimDailyReward()
            balance += 100
            canClaimReward = false
            showSuccessAnimation = true
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
        } catch {
            print("❌ [DiamondScreen] Error claiming reward: \(error)")
        }
        
        isClaiming = false
    }
    
    private func checkAdWatchedToday() {
        let lastWatchDate = UserDefaults.standard.object(forKey: "lastAdWatchDate") as? Date
        if let lastDate = lastWatchDate {
            canWatchAd = !Calendar.current.isDateInToday(lastDate)
        } else {
            canWatchAd = true
        }
    }
    
    private func watchAdForDiamonds() {
        isWatchingAd = true
        
        // Simulate ad watching (in real app, integrate AdMob/Unity Ads)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Grant diamonds
            balance += 25
            canWatchAd = false
            isWatchingAd = false
            
            // Save watch date
            UserDefaults.standard.set(Date(), forKey: "lastAdWatchDate")
            
            // Update Firestore
            Task {
                try? await DiamondService.shared.addDiamonds(amount: 25, type: .adReward)
            }
            
            // Haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours) " + "saat".localized + " \(minutes) " + "dakika".localized
        } else {
            return "\(minutes) " + "dakika".localized
        }
    }
}

#Preview {
    DiamondScreen()
        .environment(AppState())
}
