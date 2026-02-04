import SwiftUI
import UIKit
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

class AdMobManager: NSObject, ObservableObject {
    static let shared = AdMobManager()
    
    // Real Ad Unit ID provided by user
    let bannerId = "ca-app-pub-7489124652159259/6493909397"
    // Use Test ID for Rewarded Ad until user provides real one, or use a placeholder
    let rewardedId = "ca-app-pub-3940256099942544/1712485313" // Google Test ID
    
    // Rewarded Ad
    #if canImport(GoogleMobileAds)
    var rewardedAd: RewardedAd?
    #endif
    
    func initialize() {
        #if canImport(GoogleMobileAds)
        MobileAds.shared.start(completionHandler: nil)
        print("✅ AdMob SDK initialized")
        loadRewardedAd()
        #else
        print("⚠️ AdMob SDK not found. Skipping initialization.")
        #endif
    }
    
    func loadRewardedAd() {
        #if canImport(GoogleMobileAds)
        let request = Request()
        RewardedAd.load(with: rewardedId, request: request) { [weak self] ad, error in
            if let error = error {
                print("❌ Rewarded ad failed to load: \(error.localizedDescription)")
                return
            }
            print("✅ Rewarded ad loaded")
            self?.rewardedAd = ad
        }
        #endif
    }
    
    func showRewardedAd(from root: UIViewController, onReward: @escaping () -> Void) {
        #if canImport(GoogleMobileAds)
        if let ad = rewardedAd {
            ad.present(from: root) {
                print("🎁 User earned reward")
                onReward()
            }
            // Load next ad
            loadRewardedAd()
        } else {
            print("⚠️ Ad not ready")
            loadRewardedAd() // Try loading again
            // Fallback: Allow user to continue if ad fails to load
            onReward()
        }
        #else
        print("⚠️ AdMob not available (Simulator)")
        onReward() // Auto-reward in simulator
        #endif
    }
}

struct AdBannerView: View {
    var body: some View {
        #if canImport(GoogleMobileAds)
        BannerViewController(adUnitID: AdMobManager.shared.bannerId)
            .frame(height: 50) // Standard banner height
        #else
        // Mock Banner for UI Development when SDK is missing
        HStack {
            Spacer()
            VStack {
                Text("Reklam Alanı")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Text("(AdMob SDK Bekleniyor)")
                    .font(.caption2)
                    .foregroundStyle(.secondary.opacity(0.6))
            }
            Spacer()
        }
        .frame(height: 60)
        .background(Color(.systemGray6))
        #endif
    }
}

#if canImport(GoogleMobileAds)
struct BannerViewController: UIViewControllerRepresentable {
    let adUnitID: String

    func makeUIViewController(context: Context) -> UIViewController {
        let view = BannerView(adSize: AdSizeBanner)
        let viewController = UIViewController()
        view.adUnitID = adUnitID
        view.rootViewController = viewController
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: AdSizeBanner.size)
        view.load(Request())
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
#endif
