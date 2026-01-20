import SwiftUI
import StoreKit

struct PremiumView: View {
    @State private var viewModel = PremiumViewModel()
    @State private var selectedPlan: PremiumPlan = .monthly
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    var isForced: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Premium Background
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.02, blue: 0.15),
                        Color(red: 0.1, green: 0.02, blue: 0.2),
                        Color(red: 0.05, green: 0.02, blue: 0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Animated gradient orbs
                GeometryReader { geo in
                    Circle()
                        .fill(Color.purple.opacity(0.3))
                        .blur(radius: 80)
                        .frame(width: 200, height: 200)
                        .offset(x: -50, y: 100)
                    
                    Circle()
                        .fill(Color.pink.opacity(0.2))
                        .blur(radius: 100)
                        .frame(width: 250, height: 250)
                        .offset(x: geo.size.width - 100, y: geo.size.height - 200)
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Header
                        premiumHeader
                        
                        // Features
                        premiumFeatures
                        
                        // Pricing Plans
                        pricingPlans
                        
                        // Subscribe Button
                        subscribeButton
                        
                        // Terms
                        termsSection
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isForced {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.7))
                                .frame(width: 32, height: 32)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                    }
                }
            }
            .alert("error", isPresented: $viewModel.showError) {
                Button("ok", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("Tebrikler! 🎉", isPresented: $viewModel.showSuccess) {
                Button("Harika!") {
                    appState.isPremium = true
                    dismiss()
                }
            } message: {
                Text("Premium üyeliğiniz aktif edildi!")
            }
        }
    }
    
    // MARK: - Header
    private var premiumHeader: some View {
        VStack(spacing: 16) {
            // Crown Icon with glow
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.yellow.opacity(0.4), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text("Vibe")
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text("U")
                        .foregroundStyle(.white)
                    Text("Premium")
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .font(.system(size: 32, weight: .bold, design: .rounded))
                
                Text("Sınırsız eşleşme, sınırsız bağlantı")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Features
    private var premiumFeatures: some View {
        VStack(spacing: 10) {
            PremiumFeatureRow(
                icon: "heart.fill",
                title: "Sınırsız Beğeni",
                description: "Günlük limit olmadan beğen",
                color: .red
            )
            
            PremiumFeatureRow(
                icon: "eyes",
                title: "Seni Beğenenleri Gör",
                description: "Kimin beğendiğini anında öğren",
                color: .pink
            )
            
            PremiumFeatureRow(
                icon: "globe",
                title: "Global Keşif",
                description: "Dünyanın her yerinden bağlan",
                color: .blue
            )
            
            PremiumFeatureRow(
                icon: "sparkles",
                title: "Özel Profil Çerçevesi",
                description: "Premium rozeti ile öne çık",
                color: .purple
            )
            
            PremiumFeatureRow(
                icon: "bolt.fill",
                title: "Öncelikli Görünürlük",
                description: "Profilin daha çok gösterilsin",
                color: .orange
            )
            
            PremiumFeatureRow(
                icon: "arrow.uturn.backward",
                title: "Sınırsız Geri Alma",
                description: "Yanlışlıkla geçtiklerini geri al",
                color: .yellow
            )
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Pricing Plans
    private var pricingPlans: some View {
        VStack(spacing: 12) {
            Text("Planını Seç")
                .font(.headline)
                .foregroundStyle(.white)
            
            HStack(spacing: 12) {
                PlanCard(
                    plan: .weekly,
                    isSelected: selectedPlan == .weekly
                ) {
                    selectedPlan = .weekly
                }
                
                PlanCard(
                    plan: .monthly,
                    isSelected: selectedPlan == .monthly
                ) {
                    selectedPlan = .monthly
                }
                
                PlanCard(
                    plan: .yearly,
                    isSelected: selectedPlan == .yearly
                ) {
                    selectedPlan = .yearly
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Subscribe Button
    private var subscribeButton: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await viewModel.purchase(plan: selectedPlan)
                }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Premium'a Geç")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                            .font(.headline)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .disabled(viewModel.isLoading)
            
            if isForced {
                Button {
                    appState.hasSkippedPremium = true
                    dismiss()
                } label: {
                    Text("Şimdilik Geç")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Terms
    private var termsSection: some View {
        VStack(spacing: 8) {
            Text("Abonelik otomatik olarak yenilenir. İstediğiniz zaman iptal edebilirsiniz.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Button("Kullanım Şartları") {}
                Button("Gizlilik Politikası") {}
                Button("Satın Alımları Geri Yükle") {
                    Task {
                        await viewModel.restorePurchases()
                    }
                }
            }
            .font(.caption)
            .foregroundStyle(.purple)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Premium Plan Enum

enum PremiumPlan: String, CaseIterable {
    case weekly
    case monthly
    case yearly
    
    var title: String {
        switch self {
        case .weekly: return "Haftalık"
        case .monthly: return "Aylık"
        case .yearly: return "Yıllık"
        }
    }
    
    var price: String {
        switch self {
        case .weekly: return "₺49,99"
        case .monthly: return "₺149,99"
        case .yearly: return "₺899,99"
        }
    }
    
    var perWeekPrice: String {
        switch self {
        case .weekly: return "₺49,99/hafta"
        case .monthly: return "₺37,50/hafta"
        case .yearly: return "₺17,30/hafta"
        }
    }
    
    var savings: String? {
        switch self {
        case .weekly: return nil
        case .monthly: return "%25 Tasarruf"
        case .yearly: return "%65 Tasarruf"
        }
    }
    
    var isBestValue: Bool {
        self == .yearly
    }
    
    var isMostPopular: Bool {
        self == .monthly
    }
}

// MARK: - Plan Card

struct PlanCard: View {
    let plan: PremiumPlan
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Badge
                if plan.isBestValue {
                    Text("EN İYİ")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                } else if plan.isMostPopular {
                    Text("POPÜLER")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.purple)
                        .clipShape(Capsule())
                } else {
                    Color.clear.frame(height: 18)
                }
                
                // Duration
                Text(plan.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                
                // Price
                Text(plan.price)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                
                // Per week
                Text(plan.perWeekPrice)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.5))
                
                // Savings
                if let savings = plan.savings {
                    Text(savings)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.green)
                } else {
                    Color.clear.frame(height: 14)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.purple.opacity(0.3))
                }
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.purple : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Feature Row

struct PremiumFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.15), in: Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.body)
                .foregroundStyle(.green)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - ViewModel

@Observable
final class PremiumViewModel {
    var isLoading = false
    var showError = false
    var errorMessage = ""
    var showSuccess = false
    
    @MainActor
    func purchase(plan: PremiumPlan) async {
        isLoading = true
        
        // Simulate purchase - gerçek uygulamada StoreKit kullanılacak
        try? await Task.sleep(for: .seconds(1.5))
        
        isLoading = false
        showSuccess = true
    }
    
    @MainActor
    func restorePurchases() async {
        isLoading = true
        try? await Task.sleep(for: .seconds(1))
        isLoading = false
    }
}

#Preview {
    PremiumView()
        .environment(AppState())
}
