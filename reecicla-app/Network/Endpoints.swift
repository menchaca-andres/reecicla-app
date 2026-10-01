import Foundation

// Mirar Config.swift.example para configurar el environment local.
enum Endpoint {
    case register
    case login
    case profile

    var path: String {
        switch self {
        case .register: return "/api/auth/register"
        case .login:    return "/api/auth/login"
        case .profile:  return "/api/auth/me"
        }
    }

    var url: URL {
        guard let url = URL(string: AppConfig.baseURL + path) else {
            fatalError("Invalid URL for endpoint: \(path)")
        }
        return url
    }
}
