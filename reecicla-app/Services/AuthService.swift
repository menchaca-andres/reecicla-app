import Foundation

final class AuthService {
    static let shared = AuthService()
    private let client = APIClient.shared

    private init() {}

    func login(email: String, password: String) async throws -> AuthResponse {
        let body = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await client.post(endpoint: .login, body: body)
        Keychain.save(token: response.token)
        return response
    }

    func register(email: String, password: String, name: String?, phone: String?) async throws -> AuthResponse {
        let body = RegisterRequest(
            email: email,
            password: password,
            name: name?.isEmpty == false ? name : nil,
            phone: phone?.isEmpty == false ? phone : nil
        )
        let response: AuthResponse = try await client.post(endpoint: .register, body: body)
        Keychain.save(token: response.token)
        return response
    }

    func getProfile() async throws -> UserResponse {
        let response: ProfileResponse = try await client.get(endpoint: .profile)
        return response.user
    }

    func logout() {
        Keychain.deleteToken()
    }

    var isLoggedIn: Bool {
        Keychain.loadToken() != nil
    }
}
