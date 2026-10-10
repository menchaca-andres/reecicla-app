import Foundation

struct PricingRule: Decodable, Identifiable {
    let id: String
    let tenant_id: String
    let device_type: String
    let rule_key: String
    let rule_value: RuleValue
    let is_active: Bool
    let created_at: String
}

struct RuleValue: Decodable {
    let amount: FlexibleDouble?
    let currency: String?
    let working: FlexibleDouble?
    let damaged: FlexibleDouble?
    let broken: FlexibleDouble?
}

struct TenantRulesResponse: Decodable {
    let rules: [PricingRule]
}

struct DefinePricingRuleRequest: Encodable {
    let tenant_id: String
    let device_type: String
    let rule_key: String
    let rule_value: RuleValueRequest
}

struct RuleValueRequest: Encodable {
    var amount: Double?
    var currency: String?
    var working: Double?
    var damaged: Double?
    var broken: Double?
}

struct DefinePricingRuleResponse: Decodable {
    let message: String
}
