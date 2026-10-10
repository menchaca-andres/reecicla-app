import Foundation

final class QuotationService {
    static let shared = QuotationService()
    private let client = APIClient.shared

    private init() {}

    func getDeviceTypes() async throws -> [CatalogDeviceType] {
        let response: CatalogDeviceTypesResponse = try await client.get(
            endpoint: .catalogDeviceTypes,
            authenticated: false
        )
        return response.device_types.filter { $0.status == "ACTIVE" }
    }

    func getDevices(deviceTypeId: String) async throws -> [CatalogDevice] {
        let response: CatalogDevicesResponse = try await client.get(
            endpoint: .catalogDevices(deviceTypeId: deviceTypeId),
            authenticated: false
        )
        return response.devices.filter { $0.status == "ACTIVE" }
    }

    func createQuote(
        tenantId: String,
        deviceType: String,
        brand: String?,
        model: String?,
        year: Int?,
        condition: String,
        authenticated: Bool
    ) async throws -> Quote {
        let body = CreateQuoteRequest(
            tenant_id: tenantId,
            device_type: deviceType,
            brand: brand?.isEmpty == false ? brand : nil,
            model: model?.isEmpty == false ? model : nil,
            year: year,
            condition: condition
        )
        let response: CreateQuoteResponse = try await client.post(
            endpoint: .createQuote,
            body: body,
            authenticated: authenticated
        )
        return response.quote
    }

    func acceptQuote(
        id: String,
        name: String?,
        email: String?,
        phone: String?,
        address: String?,
        verificationCode: String?,
        authenticated: Bool
    ) async throws -> AcceptQuoteResponse {
        let body = GuestQuoteAcceptanceRequest(
            customer_name: name,
            customer_email: email,
            phone: phone,
            address: address,
            verification_code: verificationCode
        )
        return try await client.post(
            endpoint: .acceptQuote(id: id),
            body: body,
            authenticated: authenticated
        )
    }

    func getGuestOrderTracking(token: String) async throws -> GuestOrderTracking {
        let response: GuestOrderTrackingResponse = try await client.get(
            endpoint: .guestTracking(token: token),
            authenticated: false
        )
        return response.order
    }

    func getUserQuotes() async throws -> [Quote] {
        let response: UserQuotesResponse = try await client.get(endpoint: .userQuotes)
        return response.quotes
    }
}
