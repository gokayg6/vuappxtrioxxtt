import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case decodingError(Error)
    case networkError(Error)
    case unauthorized
    case ageGroupMismatch
    case rateLimitExceeded(resetsAt: Date?)
    case cooldownActive(expiresAt: Date?)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code, let message):
            return message ?? "HTTP Error: \(code)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized"
        case .ageGroupMismatch:
            return "Age group mismatch"
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case .cooldownActive:
            return "Cooldown active"
        }
    }
}

actor APIClient {
    static let shared = APIClient()
    
    #if DEBUG
    private let baseURL = "https://4dddfdf0d89cc4.lhr.life/api"
    #else
    private let baseURL = "https://api.vibeu.app/api/v1"
    #endif
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            guard let token = KeychainManager.shared.getAccessToken() else {
                print("❌ [APIClient] No auth token in keychain! Endpoint: \(endpoint)")
                throw APIError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("✅ [APIClient] Token found, making request to: \(url.absoluteString)")
        }
        
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        case 401:
            throw APIError.unauthorized
        case 403:
            if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                if errorResponse.code == "AGE_GROUP_MISMATCH" {
                    throw APIError.ageGroupMismatch
                }
            }
            throw APIError.httpError(statusCode: 403, message: "Forbidden")
        case 429:
            let errorResponse = try? decoder.decode(RateLimitErrorResponse.self, from: data)
            throw APIError.rateLimitExceeded(resetsAt: errorResponse?.resetsAt)
        default:
            let errorResponse = try? decoder.decode(ErrorResponse.self, from: data)
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorResponse?.message)
        }
    }
    
    func requestVoid(
        endpoint: String,
        method: HTTPMethod = .post,
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws {
        let _: EmptyResponse = try await request(
            endpoint: endpoint,
            method: method,
            body: body,
            requiresAuth: requiresAuth
        )
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

struct ErrorResponse: Codable {
    let message: String
    let code: String?
}

struct RateLimitErrorResponse: Codable {
    let message: String
    let resetsAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case message
        case resetsAt = "resets_at"
    }
}

struct EmptyResponse: Codable {}

struct SuccessResponse: Codable {
    let success: Bool
}
