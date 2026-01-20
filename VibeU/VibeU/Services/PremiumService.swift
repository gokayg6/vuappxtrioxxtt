import Foundation
import StoreKit

actor PremiumService {
    static let shared = PremiumService()
    
    private init() {}
    
    // MARK: - Products
    
    func getProducts() async throws -> [PremiumProduct] {
        struct Response: Codable {
            let products: [PremiumProduct]
        }
        let response: Response = try await APIClient.shared.request(
            endpoint: "/premium/products",
            method: .get
        )
        return response.products
    }
    
    // MARK: - Status
    
    func getStatus() async throws -> PremiumStatus {
        return try await APIClient.shared.request(
            endpoint: "/premium/status",
            method: .get
        )
    }
    
    // MARK: - Verify Purchase
    
    struct VerifyPurchaseRequest: Codable {
        let productId: String
        let transactionId: String
        let receiptData: String
        
        enum CodingKeys: String, CodingKey {
            case productId = "product_id"
            case transactionId = "transaction_id"
            case receiptData = "receipt_data"
        }
    }
    
    struct VerifyPurchaseResponse: Codable {
        let success: Bool
        let premiumStatus: PremiumStatus
        
        enum CodingKeys: String, CodingKey {
            case success
            case premiumStatus = "premium_status"
        }
    }
    
    func verifyPurchase(
        productId: String,
        transactionId: String,
        receiptData: String
    ) async throws -> VerifyPurchaseResponse {
        return try await APIClient.shared.request(
            endpoint: "/premium/verify-purchase",
            method: .post,
            body: VerifyPurchaseRequest(
                productId: productId,
                transactionId: transactionId,
                receiptData: receiptData
            )
        )
    }
    
    // MARK: - Activate Boost
    
    struct ActivateBoostRequest: Codable {
        let boostType: String
        
        enum CodingKeys: String, CodingKey {
            case boostType = "boost_type"
        }
    }
    
    struct ActivateBoostResponse: Codable {
        let success: Bool
        let boost: ActiveBoost
    }
    
    func activateBoost(type: BoostType) async throws -> ActivateBoostResponse {
        return try await APIClient.shared.request(
            endpoint: "/premium/activate-boost",
            method: .post,
            body: ActivateBoostRequest(boostType: type.rawValue)
        )
    }
    
    // MARK: - Rate Limits
    
    func getRateLimitStatus() async throws -> RateLimitStatus {
        return try await APIClient.shared.request(
            endpoint: "/rate-limits/status",
            method: .get
        )
    }
}

// MARK: - StoreKit Manager

@MainActor
@Observable
final class StoreKitManager {
    static let shared = StoreKitManager()
    
    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    
    private let productIDs = [
        "com.vibeu.premium.monthly",
        "com.vibeu.boost.30min",
        "com.vibeu.boost.1hour",
        "com.vibeu.boost.6hour"
    ]
    
    private init() {
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            // Verify with backend
            if let receiptData = await getReceiptData() {
                _ = try await PremiumService.shared.verifyPurchase(
                    productId: product.id,
                    transactionId: String(transaction.id),
                    receiptData: receiptData
                )
            }
            
            await transaction.finish()
            await updatePurchasedProducts()
            
            return transaction
            
        case .userCancelled:
            return nil
            
        case .pending:
            return nil
            
        @unknown default:
            return nil
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    private func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            purchasedProductIDs.insert(transaction.productID)
        }
    }
    
    private func getReceiptData() async -> String? {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: appStoreReceiptURL.path),
              let receiptData = try? Data(contentsOf: appStoreReceiptURL) else {
            return nil
        }
        return receiptData.base64EncodedString()
    }
}

enum StoreError: Error {
    case failedVerification
}
