import SwiftUI

struct PricingRulesView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = PricingViewModel()

    @State private var selectedDevice: DeviceType = .smartphone
    @State private var basePriceText = "1400"
    @State private var workingText   = "0"
    @State private var damagedText   = "-350"
    @State private var brokenText    = "-700"

    private var tenantId: String {
        authVM.currentUser?.tenant_id ?? "00000000-0000-0000-0000-000000000001"
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    VStack(alignment: .leading, spacing: 8) {
                        Text("ADMINISTRACIÓN")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(1.1)
                            .foregroundColor(.bluePrimary)
                        Text("Reglas de valoración")
                            .font(.system(size: 34, weight: .bold))
                            .tracking(-0.8)
                            .foregroundColor(Color(hex: "1d1d1f"))
                        Text("Configura precios base y ajustes por condición.")
                            .font(.system(size: 14))
                            .foregroundColor(.textMuted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if let success = vm.successMessage {
                        feedbackBanner(text: success, isError: false)
                    }
                    if let error = vm.errorMessage {
                        feedbackBanner(text: error, isError: true)
                    }

                    sectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Tipo de Dispositivo")
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(DeviceType.allCases, id: \.self) { device in
                                    deviceChip(device)
                                }
                            }
                        }
                    }

                    sectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Precio Base (Bs.)")
                            AuthTextField(
                                label: "Monto base",
                                placeholder: "Ej. 1400",
                                text: $basePriceText,
                                icon: "banknote",
                                iconColor: .greenPrimary,
                                keyboardType: .decimalPad
                            )
                            saveButton(title: "Guardar Precio Base") {
                                if let amount = Double(basePriceText) {
                                    Task { await vm.saveBasePrice(tenantId: tenantId, deviceType: selectedDevice.rawValue, amount: amount) }
                                }
                            }
                        }
                    }

                    sectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Ajustes por Condición (Bs.)")
                            AuthTextField(label: "Excelente / Funcionando", placeholder: "Ej. 0", text: $workingText,
                                          icon: "checkmark.circle.fill", iconColor: .greenPrimary, keyboardType: .numbersAndPunctuation)
                            AuthTextField(label: "Detalles / Daño Estético", placeholder: "Ej. -350", text: $damagedText,
                                          icon: "exclamationmark.circle.fill", iconColor: .orangePrimary, keyboardType: .numbersAndPunctuation)
                            AuthTextField(label: "Averiado / Para Repuestos", placeholder: "Ej. -700", text: $brokenText,
                                          icon: "xmark.circle.fill", iconColor: .redPrimary, keyboardType: .numbersAndPunctuation)
                            saveButton(title: "Guardar Ajustes") {
                                if let w = Double(workingText), let d = Double(damagedText), let b = Double(brokenText) {
                                    Task { await vm.saveConditionAdjustment(tenantId: tenantId, deviceType: selectedDevice.rawValue, working: w, damaged: d, broken: b) }
                                }
                            }
                        }
                    }

                    sectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                sectionLabel("Reglas Activas")
                                Spacer()
                                Button(action: { Task { await vm.loadRules(tenantId: tenantId) } }) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 13))
                                        .foregroundColor(.bluePrimary)
                                }
                            }

                            if vm.isLoading {
                                HStack { Spacer(); ProgressView().tint(.bluePrimary); Spacer() }
                            } else if vm.rules.isEmpty {
                                Text("No hay reglas configuradas para este tenant.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.textMuted)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 12)
                            } else {
                                ForEach(vm.rules) { rule in
                                    ruleRow(rule)
                                    if rule.id != vm.rules.last?.id {
                                        Divider()
                                    }
                                }
                            }
                        }
                    }

                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationTitle("Reglas de Precios")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.loadRules(tenantId: tenantId) }
    }

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.08), lineWidth: 1))
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.textMuted)
            .textCase(.uppercase)
            .tracking(0.5)
    }

    private func deviceChip(_ device: DeviceType) -> some View {
        let isSelected = selectedDevice == device
        return Button(action: { selectedDevice = device }) {
            VStack(spacing: 5) {
                Image(systemName: device.icon)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? .orangePrimary : .textMuted)
                Text(device.label)
                    .font(.system(size: 10, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(isSelected ? .textMain : .textMuted)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(isSelected ? Color.bluePrimary.opacity(0.04) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? Color.bluePrimary : Color.black.opacity(0.1), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func saveButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Group {
                if vm.isSaving {
                    HStack(spacing: 8) { ProgressView().tint(.white); Text("Guardando...") }
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                        Text(title)
                    }
                }
            }
            .font(.system(size: 14, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.bluePrimary)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(vm.isSaving)
    }

    private func ruleRow(_ rule: PricingRule) -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text("\(rule.device_type.capitalized) — \(ruleKeyLabel(rule.rule_key))")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textMain)
                Text(formatRuleValue(rule))
                    .font(.system(size: 12))
                    .foregroundColor(.textMuted)
            }
            Spacer()
            Circle()
                .fill(rule.is_active ? Color.greenPrimary : Color.textLight)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 4)
    }

    private func feedbackBanner(text: String, isError: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: isError ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                .foregroundColor(isError ? .redPrimary : .greenPrimary)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(isError ? .redPrimary : .greenPrimary)
            Spacer()
        }
        .padding(12)
        .background(isError ? Color.redLight : Color.greenLight)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(isError ? Color.redBorder : Color.greenBorder, lineWidth: 1))
    }

    private func ruleKeyLabel(_ key: String) -> String {
        switch key {
        case "base_price":            return "Precio Base"
        case "condition_adjustment":  return "Ajuste por Condición"
        default:                      return key
        }
    }

    private func formatRuleValue(_ rule: PricingRule) -> String {
        let v = rule.rule_value
        if rule.rule_key == "base_price", let amount = v.amount?.value {
            return "Bs. \(String(format: "%.0f", amount)) \(v.currency ?? "")"
        }
        if rule.rule_key == "condition_adjustment" {
            var parts: [String] = []
            if let w = v.working?.value { parts.append("Exc: \(w >= 0 ? "+" : "")\(Int(w))") }
            if let d = v.damaged?.value { parts.append("Det: \(d >= 0 ? "+" : "")\(Int(d))") }
            if let b = v.broken?.value  { parts.append("Ave: \(b >= 0 ? "+" : "")\(Int(b))") }
            return parts.joined(separator: " / ")
        }
        return "—"
    }
}
