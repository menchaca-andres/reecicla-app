import Foundation
import Combine

final class QuotationViewModel: ObservableObject {
    @Published var quotes: [Quote] = []
    @Published var lastQuote: Quote?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var verificationRequired = false
    @Published var isQuoteAccepted = false
    @Published var guestOrderTracking: GuestOrderTracking?

    private let service = QuotationService.shared

    func createQuote(
        tenantId: String,
        deviceType: String,
        brand: String?,
        model: String?,
        year: Int?,
        condition: String,
        authenticated: Bool
    ) async {
        await run {
            let quote = try await self.service.createQuote(
                tenantId: tenantId,
                deviceType: deviceType,
                brand: brand,
                model: model,
                year: year,
                condition: condition,
                authenticated: authenticated
            )
            await MainActor.run {
                self.lastQuote = quote
                self.verificationRequired = false
                self.isQuoteAccepted = false
            }
        }
    }

    func acceptQuote(
        name: String?,
        email: String?,
        phone: String?,
        address: String?,
        verificationCode: String?,
        authenticated: Bool
    ) async {
        guard let quoteId = lastQuote?.id else { return }
        await run {
            let response = try await self.service.acceptQuote(
                id: quoteId,
                name: name,
                email: email,
                phone: phone,
                address: address,
                verificationCode: verificationCode,
                authenticated: authenticated
            )
            await MainActor.run {
                if response.verification_required == true {
                    self.verificationRequired = true
                } else if let quote = response.quote {
                    self.lastQuote = quote
                    self.isQuoteAccepted = true
                    self.verificationRequired = false
                } else {
                    self.errorMessage = "El servidor no confirmó la aceptación de la cotización."
                }
            }
        }
    }

    func loadGuestOrderTracking(token: String) async {
        await run {
            let order = try await self.service.getGuestOrderTracking(token: token)
            await MainActor.run { self.guestOrderTracking = order }
        }
    }

    func loadHistory() async {
        await run {
            let result = try await self.service.getUserQuotes()
            await MainActor.run { self.quotes = result }
        }
    }

    private func run(_ task: @escaping () async throws -> Void) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        do {
            try await task()
        } catch let error as APIClientError {
            await MainActor.run { self.errorMessage = error.errorDescription }
        } catch {
            await MainActor.run { self.errorMessage = error.localizedDescription }
        }
        await MainActor.run { self.isLoading = false }
    }
}
