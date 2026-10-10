import Foundation

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let name: String?
    let phone: String?
}

struct AuthResponse: Decodable {
    let message: String
    let token: String
    let user: UserResponse
}

struct UserResponse: Decodable {
    let id: String
    let tenant_id: String
    let email: String
    let name: String?
    let phone: String?
    let role: String
    let created_at: String
}

struct ProfileResponse: Decodable {
    let user: UserResponse
}

struct APIError: Decodable {
    let error: String
}
