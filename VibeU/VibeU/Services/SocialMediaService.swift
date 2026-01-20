import Foundation
import UIKit

// MARK: - Social Media Service

/// Service for handling social media deep links and URL opening
final class SocialMediaService {
    static let shared = SocialMediaService()
    
    private init() {}
    
    // MARK: - Deep Link URLs
    
    /// TikTok deep link format
    /// - Parameter username: TikTok username
    /// - Returns: Deep link URL string
    static func tiktokDeepLink(username: String) -> String {
        return "tiktok://user?username=\(username)"
    }
    
    /// TikTok web fallback URL
    /// - Parameter username: TikTok username
    /// - Returns: Web URL string
    static func tiktokWebURL(username: String) -> String {
        return "https://tiktok.com/@\(username)"
    }
    
    /// Instagram deep link format
    /// - Parameter username: Instagram username
    /// - Returns: Deep link URL string
    static func instagramDeepLink(username: String) -> String {
        return "instagram://user?username=\(username)"
    }
    
    /// Instagram web fallback URL
    /// - Parameter username: Instagram username
    /// - Returns: Web URL string
    static func instagramWebURL(username: String) -> String {
        return "https://instagram.com/\(username)"
    }
    
    /// Snapchat deep link format
    /// - Parameter username: Snapchat username
    /// - Returns: Deep link URL string
    static func snapchatDeepLink(username: String) -> String {
        return "snapchat://add/\(username)"
    }
    
    /// Snapchat web fallback URL
    /// - Parameter username: Snapchat username
    /// - Returns: Web URL string
    static func snapchatWebURL(username: String) -> String {
        return "https://snapchat.com/add/\(username)"
    }
    
    // MARK: - Open Methods
    
    /// Opens TikTok profile with deep link, falls back to web URL
    /// - Parameter username: TikTok username
    @MainActor
    func openTikTok(username: String) {
        let deepLinkURL = Self.tiktokDeepLink(username: username)
        let webURL = Self.tiktokWebURL(username: username)
        openURL(deepLink: deepLinkURL, fallback: webURL)
    }
    
    /// Opens Instagram profile with deep link, falls back to web URL
    /// - Parameter username: Instagram username
    @MainActor
    func openInstagram(username: String) {
        let deepLinkURL = Self.instagramDeepLink(username: username)
        let webURL = Self.instagramWebURL(username: username)
        openURL(deepLink: deepLinkURL, fallback: webURL)
    }
    
    /// Opens Snapchat profile with deep link, falls back to web URL
    /// - Parameter username: Snapchat username
    @MainActor
    func openSnapchat(username: String) {
        let deepLinkURL = Self.snapchatDeepLink(username: username)
        let webURL = Self.snapchatWebURL(username: username)
        openURL(deepLink: deepLinkURL, fallback: webURL)
    }
    
    // MARK: - Private Helpers
    
    /// Attempts to open deep link URL, falls back to web URL if app is not installed
    /// - Parameters:
    ///   - deepLink: Deep link URL string
    ///   - fallback: Web fallback URL string
    @MainActor
    private func openURL(deepLink: String, fallback: String) {
        guard let deepLinkURL = URL(string: deepLink) else {
            openFallbackURL(fallback)
            return
        }
        
        if UIApplication.shared.canOpenURL(deepLinkURL) {
            UIApplication.shared.open(deepLinkURL, options: [:]) { success in
                if !success {
                    Task { @MainActor in
                        self.openFallbackURL(fallback)
                    }
                }
            }
        } else {
            openFallbackURL(fallback)
        }
    }
    
    /// Opens fallback web URL
    /// - Parameter urlString: Web URL string
    @MainActor
    private func openFallbackURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
