import Foundation

struct CreateQuoteRequest: Encodable {
    let tenant_id: String
    let device_type: String
    let brand: String?
    let model: String?
    let year: Int?
    let condition: String
}

struct GuestQuoteAcceptanceRequest: Encodable {
    let customer_name: String?
    let customer_email: String?
    let phone: String?
    let address: String?
    let verification_code: String?
}

struct FlexibleDouble: Decodable, Equatable {
    let value: Double

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let d = try? container.decode(Double.self) {
            value = d
        } else if let s = try? container.decode(String.self), let d = Double(s) {
            value = d
        } else {
            throw DecodingError.typeMismatch(
                Double.self,
                .init(codingPath: decoder.codingPath,
                      debugDescription: "Cannot decode Double from JSON value")
            )
        }
    }
}

struct Quote: Decodable, Identifiable, Equatable {
    let id: String
    let tenant_id: String
    let user_id: String?
    let device_type: String
    let brand: String?
    let model: String?
    let year: Int?
    let condition: String
    private let _base_price:  FlexibleDouble
    private let _adjustment:  FlexibleDouble
    private let _final_price: FlexibleDouble
    let status: String
    let created_at: String

    var base_price:  Double { _base_price.value  }
    var adjustment:  Double { _adjustment.value  }
    var final_price: Double { _final_price.value }

    enum CodingKeys: String, CodingKey {
        case id, tenant_id, user_id, device_type, brand, model, year, condition, status, created_at
        case _base_price  = "base_price"
        case _adjustment  = "adjustment"
        case _final_price = "final_price"
    }
}

struct CreateQuoteResponse: Decodable {
    let message: String
    let quote: Quote
}

struct UserQuotesResponse: Decodable {
    let quotes: [Quote]
}

struct CatalogDeviceTypesResponse: Decodable {
    let device_types: [CatalogDeviceType]

    private enum CodingKeys: String, CodingKey {
        case device_types
        case deviceTypes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        device_types = try container.decodeIfPresent([CatalogDeviceType].self, forKey: .device_types)
            ?? container.decode([CatalogDeviceType].self, forKey: .deviceTypes)
    }
}

struct CatalogDevicesResponse: Decodable {
    let devices: [CatalogDevice]
}

struct CatalogDeviceType: Decodable, Identifiable {
    let id: String
    let code: String
    let name: String
    let status: String
}

struct CatalogDevice: Decodable, Identifiable {
    let id: String
    let model: String
    let year: Int?
    let status: String
    let brand_name: String?
    let device_type_code: String?
}

struct AcceptQuoteResponse: Decodable {
    let message: String?
    let verification_required: Bool?
    let quote: Quote?
}

struct GuestOrderTrackingResponse: Decodable {
    let order: GuestOrderTracking
}

struct GuestOrderTracking: Decodable, Identifiable {
    var id: String { order_number }
    let order_number: String
    let quote_id: String?
    let device_type_name: String
    let brand: String?
    let model: String?
    let device_year: Int?
    let declared_condition: String?
    private let _quoted_price: FlexibleDouble
    let currency: String
    let status: String
    let accepted_at: String?
    let tracking_code: String?
    let box_status: String?
    let shipped_at: String?
    let status_history: [OrderStatusHistory]

    var quoted_price: Double { _quoted_price.value }

    enum CodingKeys: String, CodingKey {
        case order_number, quote_id, device_type_name, brand, model, device_year
        case declared_condition, currency, status, accepted_at, tracking_code
        case box_status, shipped_at, status_history
        case _quoted_price = "quoted_price"
    }
}

struct OrderStatusHistory: Decodable, Identifiable {
    var id: String { "\(created_at)-\(new_status)" }
    let previous_status: String?
    let new_status: String
    let reason: String?
    let created_at: String
}

enum DeviceType: String, CaseIterable {
    case refrigerator   = "refrigerator"
    case washingMachine = "washing_machine"
    case tv             = "tv"
    case laptop         = "laptop"
    case smartphone     = "smartphone"

    var label: String {
        switch self {
        case .refrigerator:   return "Refrigerador"
        case .washingMachine: return "Lavadora"
        case .tv:             return "Televisor"
        case .laptop:         return "Laptop"
        case .smartphone:     return "Smartphone"
        }
    }

    var icon: String {
        switch self {
        case .refrigerator:   return "refrigerator"
        case .washingMachine: return "washer"
        case .tv:             return "tv"
        case .laptop:         return "laptopcomputer"
        case .smartphone:     return "iphone"
        }
    }
}

enum DeviceCondition: String, CaseIterable {
    case working = "working"
    case damaged = "damaged"
    case broken  = "broken"

    var label: String {
        switch self {
        case .working: return "Excelente / Funcionando"
        case .damaged: return "Detalles / Daño Estético"
        case .broken:  return "Averiado / Para Repuestos"
        }
    }

    var description: String {
        switch self {
        case .working: return "Sin fallas operativas"
        case .damaged: return "Desgaste o fallas menores"
        case .broken:  return "No enciende o daño mayor"
        }
    }

    var accentColor: String {
        switch self {
        case .working: return "16a34a"
        case .damaged: return "ea580c"
        case .broken:  return "dc2626"
        }
    }
}
