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
                    VStack(spacing: 32) {
                        // Diamond Balance Card
                        balanceCard
                        
                        // Daily Reward Section
                        dailyRewardSection
                        
                        // Info Section
                        infoSection
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
            }
            .navigationTitle("Elmaslarım")
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
    }
    
    // MARK: - Balance Card
    private var balanceCard: some View {
        VStack(spacing: 16) {
            // Diamond Icon with Glow
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
                
                Image(systemName: "diamond.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .cyan.opacity(0.5), radius: 10)
            }
            
            // Balance
            VStack(spacing: 4) {
                Text("\(balance)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(colors.primaryText)
                
                Text("Elmas")
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
    }
    
    // MARK: - Daily Reward Section
    private var dailyRewardSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "gift.fill")
                    .foregroundStyle(.orange)
                
                Text("Günlük Ödül")
                    .font(.headline)
                    .foregroundStyle(colors.primaryText)
                
                Spacer()
                
                Text("+100")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.cyan)
                
                Image(systemName: "diamond.fill")
                    .foregroundStyle(.cyan)
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
                            Text("Ödülümü Al")
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
                        
                        Text("Bugünkü ödülünü aldın!")
                            .font(.subheadline)
                            .foregroundStyle(colors.secondaryText)
                    }
                    
                    if let time = timeUntilNextReward, time > 0 {
                        Text("Yeni ödül: \(formatTime(time))")
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
    
    // MARK: - Info Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Elmas Nasıl Kullanılır?")
                .font(.headline)
                .foregroundStyle(colors.primaryText)
            
            infoRow(icon: "heart.fill", color: .pink, text: "Eşleşme isteği göndermek: 10 elmas")
            infoRow(icon: "gift.fill", color: .orange, text: "Her gün ücretsiz 100 elmas al")
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
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
        } catch {
            print("❌ [DiamondScreen] Error claiming reward: \(error)")
        }
        
        isClaiming = false
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours) saat \(minutes) dakika"
        } else {
            return "\(minutes) dakika"
        }
    }
}

#Preview {
    DiamondScreen()
        .environment(AppState())
}
