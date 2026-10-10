import Foundation
import Combine

final class PricingViewModel: ObservableObject {
    @Published var rules: [PricingRule] = []
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let service = PricingService.shared

    func loadRules(tenantId: String) async {
        await MainActor.run { isLoading = true; errorMessage = nil }
        do {
            let result = try await service.getRules(tenantId: tenantId)
            await MainActor.run { self.rules = result }
        } catch let error as APIClientError {
            await MainActor.run { self.errorMessage = error.errorDescription }
        } catch {
            await MainActor.run { self.errorMessage = error.localizedDescription }
        }
        await MainActor.run { self.isLoading = false }
    }

    func saveBasePrice(tenantId: String, deviceType: String, amount: Double) async {
        await save(tenantId: tenantId, deviceType: deviceType, ruleKey: "base_price",
                   value: RuleValueRequest(amount: amount, currency: "Bs."))
    }

    func saveConditionAdjustment(
        tenantId: String, deviceType: String,
        working: Double, damaged: Double, broken: Double
    ) async {
        await save(tenantId: tenantId, deviceType: deviceType, ruleKey: "condition_adjustment",
                   value: RuleValueRequest(working: working, damaged: damaged, broken: broken))
    }

    private func save(tenantId: String, deviceType: String, ruleKey: String, value: RuleValueRequest) async {
        await MainActor.run { isSaving = true; errorMessage = nil; successMessage = nil }
        do {
            try await service.defineRule(tenantId: tenantId, deviceType: deviceType, ruleKey: ruleKey, ruleValue: value)
            await MainActor.run { self.successMessage = "Regla guardada correctamente." }
            await loadRules(tenantId: tenantId)
        } catch let error as APIClientError {
            await MainActor.run { self.errorMessage = error.errorDescription }
        } catch {
            await MainActor.run { self.errorMessage = error.localizedDescription }
        }
        await MainActor.run { self.isSaving = false }
    }
}
