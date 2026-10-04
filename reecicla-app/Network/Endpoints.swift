import Foundation

enum Endpoint {
    case register
    case login
    case profile
    case createQuote
    case userQuotes
    case defineRule
    case tenantRules(tenantId: String)

    var path: String {
        switch self {
        case .register:              return "/api/auth/register"
        case .login:                 return "/api/auth/login"
        case .profile:               return "/api/auth/me"
        case .createQuote:           return "/api/quotation/quotes"
        case .userQuotes:            return "/api/quotation/quotes/user"
        case .defineRule:            return "/api/quotation/rules"
        case .tenantRules(let tid):  return "/api/quotation/rules?tenant_id=\(tid)"
        }
    }

    var url: URL {
        guard let url = URL(string: AppConfig.baseURL + path) else {
            fatalError("Invalid URL for endpoint: \(path)")
        }
        return url
    }
}
