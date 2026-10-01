import Foundation
import Security

enum APIClientError: LocalizedError {
    case invalidResponse
    case serverError(String)
    case decodingError(Error)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidResponse:      return "Invalid server response."
        case .serverError(let msg): return msg
        case .decodingError(let e): return "Decoding error: \(e.localizedDescription)"
        case .unauthorized:         return "Session expired. Please log in again."
        }
    }
}

enum Keychain {
    private static let tokenKey = "reecicla.jwt.token"

    static func save(token: String) {
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String:   data,
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func loadToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String:            kSecClassGenericPassword,
            kSecAttrAccount as String:      tokenKey,
            kSecReturnData as String:       true,
            kSecMatchLimit as String:       kSecMatchLimitOne,
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
        ]
        SecItemDelete(query as CFDictionary)
    }
}

final class APIClient {
    static let shared = APIClient()
    private let session = URLSession.shared
    private let decoder = JSONDecoder()

    private init() {}

    func post<Body: Encodable, Response: Decodable>(
        endpoint: Endpoint,
        body: Body
    ) async throws -> Response {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        return try await perform(request)
    }

    func get<Response: Decodable>(
        endpoint: Endpoint,
        authenticated: Bool = true
    ) async throws -> Response {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = "GET"
        if authenticated {
            guard let token = Keychain.loadToken() else { throw APIClientError.unauthorized }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return try await perform(request)
    }

    private func perform<Response: Decodable>(_ request: URLRequest) async throws -> Response {
        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            let apiError = try? decoder.decode(APIError.self, from: data)
            throw APIClientError.serverError(apiError?.error ?? "Unknown server error (\(http.statusCode))")
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIClientError.decodingError(error)
        }
    }
}
