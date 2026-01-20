import SwiftUI

@Observable @MainActor
final class DiscoverViewModel {
    // State
    var discoverMode: DiscoverMode = .local
    var heroUser: DiscoverUser?
    var discoverUsers: [DiscoverUser] = []
    var trendingUsers: [DiscoverUser] = []
    var spotlightUsers: [DiscoverUser] = []
    
    var isLoading = false
    var error: Error?
    var nextCursor: String?
    var hasMore = true
    
    // Sheets
    var selectedUser: DiscoverUser?
    var showFavorites = false
    var showIncomingRequests = false
    var showBoost = false
    var showLikedYou = false
    var showSearch = false
    
    // Notifications
    var unreadNotifications = 0
    
    // MARK: - Load Data
    
    func loadData() async {
        isLoading = true
        error = nil
        
        do {
            let discoverResponse = try await DiscoverService.shared.getDiscoverFeed(mode: discoverMode)
            let trendingResponse = try await DiscoverService.shared.getTrending(mode: discoverMode)
            let spotlightResponse = try await DiscoverService.shared.getSpotlight(mode: discoverMode)
            let notificationCount = try await NotificationService.shared.getUnreadCount()
            
            // Set hero user as first from discover
            if let first = discoverResponse.users.first {
                heroUser = first
                discoverUsers = Array(discoverResponse.users.dropFirst())
            } else {
                heroUser = nil
                discoverUsers = []
            }
            
            nextCursor = discoverResponse.nextCursor
            hasMore = discoverResponse.hasMore
            
            trendingUsers = trendingResponse.users
            spotlightUsers = spotlightResponse.users
            unreadNotifications = notificationCount
            
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadData()
    }
    
    func loadMore() async {
        guard hasMore, let cursor = nextCursor, !isLoading else { return }
        
        do {
            let response = try await DiscoverService.shared.getDiscoverFeed(
                mode: discoverMode,
                cursor: cursor
            )
            
            discoverUsers.append(contentsOf: response.users)
            nextCursor = response.nextCursor
            hasMore = response.hasMore
        } catch {
            // Silent fail for pagination
        }
    }
    
    // MARK: - Actions
    
    func like(user: DiscoverUser) {
        // Optimistic UI update
        removeUserFromFeed(user)
        
        Task {
            do {
                _ = try await DiscoverService.shared.like(userId: user.id)
            } catch let error as APIError {
                // Handle specific errors
                switch error {
                case .rateLimitExceeded:
                    // Show rate limit modal
                    break
                case .ageGroupMismatch:
                    // This should never happen due to backend filtering
                    break
                default:
                    // Revert optimistic update
                    break
                }
            } catch {
                // Revert optimistic update
            }
        }
    }
    
    func skip(user: DiscoverUser) {
        // Optimistic UI update
        removeUserFromFeed(user)
        
        Task {
            do {
                try await DiscoverService.shared.skip(userId: user.id)
            } catch {
                // Silent fail - user already removed from UI
            }
        }
    }
    
    func sendRequest(to user: DiscoverUser) {
        Task {
            do {
                _ = try await SocialService.shared.sendRequest(toUserId: user.id)
                // Show success feedback
            } catch let error as APIError {
                switch error {
                case .rateLimitExceeded:
                    // Show rate limit modal
                    break
                case .cooldownActive:
                    // Show cooldown modal
                    break
                default:
                    break
                }
            } catch {
                // Handle error
            }
        }
    }
    
    func addToFavorites(user: DiscoverUser) {
        Task {
            do {
                _ = try await DiscoverService.shared.addFavorite(userId: user.id)
            } catch {
                // Handle error
            }
        }
    }
    
    // MARK: - Helpers
    
    private func removeUserFromFeed(_ user: DiscoverUser) {
        if heroUser?.id == user.id {
            // Move next user to hero
            if let next = discoverUsers.first {
                heroUser = next
                discoverUsers.removeFirst()
            } else {
                heroUser = nil
            }
        } else {
            discoverUsers.removeAll { $0.id == user.id }
        }
        
        // Load more if running low
        if discoverUsers.count < 5 {
            Task {
                await loadMore()
            }
        }
    }
}
