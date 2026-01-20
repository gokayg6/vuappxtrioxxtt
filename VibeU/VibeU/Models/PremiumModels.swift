import Foundation

enum BoostType: String, Codable, CaseIterable {
    case thirtyMin = "30min"
    case oneHour = "1hour"
    case sixHour = "6hour"
    
    var displayKey: String {
        switch self {
        case .thirtyMin: return "boost_30min"
        case .oneHour: return "boost_1hour"
        case .sixHour: return "boost_6hour"
        }
    }
    
    var durationMinutes: Int {
        switch self {
        case .thirtyMin: return 30
        case .oneHour: return 60
        case .sixHour: return 360
        }
    }
}

struct PremiumProduct: Identifiable, Codable {
    let id: String
    let type: ProductType
    let name: String
    let price: String
    let features: [String]?
    
    enum ProductType: String, Codable {
        case subscription = "subscription"
        case consumable = "consumable"
    }
}

struct PremiumStatus: Codable {
    let isPremium: Bool
    let subscription: SubscriptionInfo?
    let activeBoosts: [ActiveBoost]
    
    enum CodingKeys: String, CodingKey {
        case isPremium = "is_premium"
        case subscription
        case activeBoosts = "active_boosts"
    }
}

struct SubscriptionInfo: Codable {
    let productId: String
    let expiresAt: Date
    let willRenew: Bool
    
    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case expiresAt = "expires_at"
        case willRenew = "will_renew"
    }
}

struct ActiveBoost: Codable {
    let type: BoostType
    let expiresAt: Date
    let remainingMinutes: Int
    
    enum CodingKeys: String, CodingKey {
        case type
        case expiresAt = "expires_at"
        case remainingMinutes = "remaining_minutes"
    }
}

struct RateLimitStatus: Codable {
    let likesRemaining: Int
    let requestsRemaining: Int
    let resetsAt: Date
    
    enum CodingKeys: String, CodingKey {
        case likesRemaining = "likes_remaining"
        case requestsRemaining = "requests_remaining"
        case resetsAt = "resets_at"
    }
}
