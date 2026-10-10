import Foundation

enum Endpoint {
    case register
    case login
    case profile
    case createQuote
    case userQuotes
    case catalogDeviceTypes
    case catalogDevices(deviceTypeId: String)
    case acceptQuote(id: String)
    case defineRule
    case tenantRules(tenantId: String)
    case guestTracking(token: String)

    var path: String {
        let scope = "/recicla/\(AppConfig.tenantSlug)"
        switch self {
        case .register:              return "\(scope)/auth/register"
        case .login:                 return "\(scope)/auth/login"
        case .profile:               return "/api/auth/me"
        case .createQuote:           return "\(scope)/quotation/quotes"
        case .userQuotes:            return "\(scope)/quotation/quotes/user"
        case .catalogDeviceTypes:    return "\(scope)/catalog/device-types"
        case .catalogDevices(let deviceTypeId):
            return "\(scope)/catalog/devices?device_type_id=\(deviceTypeId)"
        case .acceptQuote(let id):   return "\(scope)/quotation/quotes/\(id)/accept"
        case .defineRule:            return "\(scope)/quotation/rules"
        case .tenantRules(let tid):  return "\(scope)/quotation/rules?tenant_id=\(tid)"
        case .guestTracking(let token):
            return "\(scope)/orders/tracking/\(token)"
        }
    }

    var url: URL {
        guard let url = URL(string: AppConfig.baseURL + path) else {
            fatalError("Invalid URL for endpoint: \(path)")
        }
        return url
    }
}
