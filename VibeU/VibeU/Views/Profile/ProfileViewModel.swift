import SwiftUI

@Observable @MainActor
final class ProfileViewModel {
    var likesCount = 0
    var friendsCount = 0
    var viewsCount = 0
    
    var showPremium = false
    var showSettings = false
    var showSafety = false
    var showLogoutConfirm = false
    var showDeleteConfirm = false
    
    var isLoading = false
    var error: Error?
    
    init() {
        Task {
            await loadStats()
        }
    }
    
    func loadStats() async {
        // Load stats from API
        // For now, using placeholder values
        likesCount = 42
        friendsCount = 15
        viewsCount = 128
    }
    
    func shareProfile() {
        // Share profile link
        guard let url = URL(string: "https://vibeu.app/profile/me") else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    func openHelp() {
        if let url = URL(string: "https://vibeu.app/help") {
            UIApplication.shared.open(url)
        }
    }
    
    func openFeedback() {
        if let url = URL(string: "mailto:feedback@vibeu.app") {
            UIApplication.shared.open(url)
        }
    }
    
    func deleteAccount(appState: AppState) async {
        isLoading = true
        
        do {
            try await UserService.shared.deleteAccount()
            appState.signOut()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}
