import SwiftUI

// MARK: - Step 6: Premium Offer (VibeU Gold)
struct PremiumOfferView: View {
    let data: OnboardingData
    let onComplete: () -> Void
    let onSkip: () -> Void
    
    @State private var selectedPlan: PremiumPlan = .monthly
    
    enum PremiumPlan {
        case monthly, yearly
        
        var price: String {
            switch self {
            case .monthly: return "₺99,99"
            case .yearly: return "₺599,99"
            }
        }
        
        var period: String {
            switch self {
            case .monthly: return "/ay"
            case .yearly: return "/yıl"
            }
        }
        
        var savings: String? {
            switch self {
            case .monthly: return nil
            case .yearly: return "50% İndirim"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.04, green: 0.02, blue: 0.08).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        // Gold Icon
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 1.0, green: 0.55, blue: 0.0)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.5), radius: 20)
                            
                            Image(systemName: "crown.fill")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .padding(.top, 60)
                        
                        Text("VibeU Gold")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 1.0, green: 0.55, blue: 0.0)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Premium deneyimi yaşa")
                            .font(.system(size: 17))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    
                    // Features
                    VStack(spacing: 16) {
                        FeatureRow(icon: "infinity", title: "Sınırsız Beğeni", description: "Dilediğin kadar beğen")
                        FeatureRow(icon: "eye.slash.fill", title: "Gizli Mod", description: "Kimse profilini göremesin")
                        FeatureRow(icon: "star.fill", title: "Süper Beğeni", description: "Öne çık ve fark edil")
                        FeatureRow(icon: "arrow.uturn.backward", title: "Geri Al", description: "Yanlış kaydırmaları geri al")
                        FeatureRow(icon: "location.fill", title: "Konum Değiştir", description: "Dünyanın her yerinden eşleş")
                        FeatureRow(icon: "checkmark.seal.fill", title: "Öncelikli Destek", description: "7/24 premium destek")
                    }
                    .padding(.horizontal, 24)
                    
                    // Plan Selection
                    VStack(spacing: 12) {
                        OnboardingPlanCard(
                            plan: .monthly,
                            isSelected: selectedPlan == .monthly,
                            onTap: { selectedPlan = .monthly }
                        )
                        
                        OnboardingPlanCard(
                            plan: .yearly,
                            isSelected: selectedPlan == .yearly,
                            onTap: { selectedPlan = .yearly }
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // Subscribe Button
                    Button {
                        onComplete()
                    } label: {
                        Text("Şimdi Başla")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 1.0, green: 0.55, blue: 0.0)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.4), radius: 12, y: 4)
                    }
                    .padding(.horizontal, 24)
                    
                    // Skip Button
                    Button {
                        onSkip()
                    } label: {
                        Text("Şimdi Değil")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.bottom, 32)
                    
                    // Terms
                    Text("Abonelik otomatik yenilenir. İstediğin zaman iptal edebilirsin.")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 32)
                }
            }
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.2), Color(red: 1.0, green: 0.55, blue: 0.0).opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 1.0, green: 0.55, blue: 0.0)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.05))
        )
    }
}

// MARK: - Plan Card (Onboarding)
struct OnboardingPlanCard: View {
    let plan: PremiumOfferView.PremiumPlan
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(plan == .monthly ? "Aylık" : "Yıllık")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                        
                        if let savings = plan.savings {
                            Text(savings)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(.green))
                        }
                    }
                    
                    Text(plan.price + plan.period)
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 1.0, green: 0.55, blue: 0.0)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? LinearGradient(colors: [.white.opacity(0.15), .white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [.white.opacity(0.05), .white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? LinearGradient(colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 1.0, green: 0.55, blue: 0.0)], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [.white.opacity(0.1), .white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
