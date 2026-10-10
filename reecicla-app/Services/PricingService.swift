import Foundation

final class PricingService {
    static let shared = PricingService()
    private let client = APIClient.shared
    private init() {}

    func getRules(tenantId: String) async throws -> [PricingRule] {
        let response: TenantRulesResponse = try await client.get(
            endpoint: .tenantRules(tenantId: tenantId)
        )
        return response.rules
    }

    func defineRule(
        tenantId: String,
        deviceType: String,
        ruleKey: String,
        ruleValue: RuleValueRequest
    ) async throws {
        let body = DefinePricingRuleRequest(
            tenant_id: tenantId,
            device_type: deviceType,
            rule_key: ruleKey,
            rule_value: ruleValue
        )
        let _: DefinePricingRuleResponse = try await client.post(
            endpoint: .defineRule,
            body: body,
            authenticated: true
        )
    }
}
