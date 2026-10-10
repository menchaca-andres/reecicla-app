import SwiftUI

struct QuoteResultView: View {
    let quote: Quote
    @ObservedObject var viewModel: QuotationViewModel
    let isAuthenticated: Bool
    let onNewQuote: () -> Void

    @State private var customerName = ""
    @State private var customerEmail = ""
    @State private var customerPhone = ""
    @State private var customerAddress = ""
    @State private var verificationCode = ""
    @State private var showAcceptanceForm = false

    private var basePrice:   Double { Double(quote.base_price) }
    private var adjustment:  Double { Double(quote.adjustment) }
    private var finalPrice:  Double { Double(quote.final_price) }
    private var isNegAdj:    Bool   { adjustment < 0 }

    var body: some View {
        ZStack {
            Color.bgPage.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.bluePrimary.opacity(0.06))
                                .frame(width: 64, height: 64)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.bluePrimary.opacity(0.15), lineWidth: 1)
                                )
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(viewModel.isQuoteAccepted ? .greenPrimary : .bluePrimary)
                        }

                        Text(viewModel.isQuoteAccepted ? "¡Cotización Aceptada!" : "¡Cotización Generada!")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.textMain)

                        statusBadge(viewModel.lastQuote?.status ?? quote.status)

                        Text("ID de cotización: \(quote.id)")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.textMuted)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .padding(.top, 32)

                    if let error = viewModel.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                            Text(error)
                            Spacer()
                        }
                        .font(.system(size: 13))
                        .foregroundColor(.redPrimary)
                        .padding(12)
                        .background(Color.redLight)
                        .cornerRadius(10)
                    }

                    LazyVGrid(columns: [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)], alignment: .leading, spacing: 16) {
                        detailRow(icon: "cpu", label: "Equipo", value: quote.device_type.capitalized)
                        detailRow(
                            icon: "tag.fill",
                            label: "Marca / Modelo",
                            value: [quote.brand, quote.model].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " ").isEmpty
                                ? "No especificado"
                                : [quote.brand, quote.model].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " ")
                        )
                        detailRow(icon: "slider.horizontal.3", label: "Condición", value: quote.condition.capitalized)
                        detailRow(icon: "calendar", label: "Año", value: quote.year.map { "\($0)" } ?? "N/A")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "f5f5f7"))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.06), lineWidth: 1))

                    VStack(spacing: 0) {
                        HStack {
                            Text("Precio Base Estimado")
                                .font(.system(size: 14))
                                .foregroundColor(.textMuted)
                            Spacer()
                            Text("Bs. \(basePrice, specifier: "%.2f")")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.textMain)
                        }
                        .padding(.bottom, 12)

                        Rectangle().fill(Color.black.opacity(0.1)).frame(height: 1)

                        HStack {
                            Text("Ajuste por Condición")
                                .font(.system(size: 14))
                                .foregroundColor(.textMuted)
                            Spacer()
                            Text(isNegAdj
                                 ? "-Bs. \(abs(adjustment), specifier: "%.2f")"
                                 : "+Bs. \(adjustment, specifier: "%.2f")")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(isNegAdj ? .redPrimary : .greenPrimary)
                        }
                        .padding(.vertical, 12)

                        Rectangle().fill(Color.black.opacity(0.1)).frame(height: 1)

                        HStack(alignment: .bottom) {
                            Text("Precio Final Ofrecido")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.textMain)
                            Spacer()
                            HStack(alignment: .firstTextBaseline, spacing: 3) {
                                Text("Bs.")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.bluePrimary)
                                Text("\(finalPrice, specifier: "%.2f")")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.bluePrimary)
                            }
                        }
                        .padding(.top, 12)
                    }
                    .padding(20)
                    .background(Color(hex: "f5f5f7"))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black.opacity(0.08), lineWidth: 1))

                    if viewModel.isQuoteAccepted {
                        Text("✓ Cotización aceptada exitosamente. No necesitas crear una cuenta; te contactaremos a la brevedad para coordinar el retiro del equipo.")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "248a3d"))
                            .multilineTextAlignment(.center)
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .background(Color.greenPrimary.opacity(0.08))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.greenPrimary.opacity(0.2), lineWidth: 1))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else if showAcceptanceForm {
                        acceptanceForm
                    } else {
                        Button {
                            showAcceptanceForm = true
                        } label: {
                            HStack(spacing: 8) {
                                Text("Aceptar esta cotización")
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(Color.bluePrimary)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                        }
                    }

                    Button(action: onNewQuote) {
                        Text("Realizar otra cotización")
                            .font(.system(size: 15, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Color.black.opacity(0.05))
                            .foregroundColor(.textMain)
                            .clipShape(Capsule())
                    }
                    Spacer(minLength: 30)
                }
                .padding(32)
                .frame(maxWidth: 680)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.08), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.04), radius: 24, x: 0, y: 4)
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
        }
    }

    private var acceptanceForm: some View {
        detailCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Datos para coordinar el retiro", systemImage: "person.crop.circle")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.textMain)
                Text(viewModel.verificationRequired
                     ? "Enviamos un código a \(customerEmail). Ingrésalo para verificar tu correo y aceptar la cotización."
                     : isAuthenticated
                        ? "Confirma que aceptas esta cotización."
                        : "No necesitas crear una cuenta. Completa tus datos y te enviaremos un código para verificar el correo.")
                    .font(.system(size: 13))
                    .foregroundColor(.textMuted)

                if !isAuthenticated && !viewModel.verificationRequired {
                    AuthTextField(label: "Nombre completo *", placeholder: "Ej. Juan Pérez", text: $customerName)
                    AuthTextField(label: "Correo electrónico *", placeholder: "ejemplo@correo.com", text: $customerEmail, keyboardType: .emailAddress)
                    AuthTextField(label: "Teléfono / Celular *", placeholder: "70012345", text: $customerPhone, keyboardType: .phonePad)
                    AuthTextField(label: "Dirección de recolección", placeholder: "Av. Principal #123", text: $customerAddress)
                }

                if viewModel.verificationRequired {
                    AuthTextField(label: "Código de verificación *", placeholder: "123456", text: $verificationCode, keyboardType: .numberPad)
                }

                HStack(spacing: 12) {
                    Button(action: acceptQuote) {
                        actionLabel(viewModel.isLoading ? "Procesando..." : viewModel.verificationRequired ? "Verificar y aceptar" : isAuthenticated ? "Aceptar cotización" : "Enviar código")
                    }
                    .disabled(viewModel.isLoading || (!isAuthenticated && !guestDetailsAreValid) || (viewModel.verificationRequired && verificationCode.count != 6))

                    Button("Cancelar") {
                        showAcceptanceForm = false
                    }
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.05))
                    .foregroundColor(.textMain)
                    .clipShape(Capsule())
                }

                if viewModel.verificationRequired {
                    Button("Reenviar código") {
                        submitAcceptance(code: nil)
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.bluePrimary)
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }

    private var guestDetailsAreValid: Bool {
        !customerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        customerEmail.contains("@") &&
        !customerPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func acceptQuote() {
        submitAcceptance(code: viewModel.verificationRequired ? verificationCode : nil)
    }

    private func submitAcceptance(code: String?) {
        Task {
            await viewModel.acceptQuote(
                name: isAuthenticated ? nil : customerName,
                email: isAuthenticated ? nil : customerEmail,
                phone: isAuthenticated ? nil : customerPhone,
                address: isAuthenticated ? nil : customerAddress,
                verificationCode: code,
                authenticated: isAuthenticated
            )
        }
    }

    private func actionLabel(_ title: String) -> some View {
        Group {
            if viewModel.isLoading {
                ProgressView().tint(.white)
            } else {
                Text(title)
            }
        }
        .font(.system(size: 15, weight: .semibold))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.bluePrimary)
        .foregroundColor(.white)
        .cornerRadius(12)
    }

    private func detailCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(20)
            .background(Color(hex: "f5f5f7"))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.06), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(.textMuted)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.textMuted)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.textMain)
        }
    }

    private func statusBadge(_ status: String) -> some View {
        Text(status.uppercased())
            .font(.system(size: 10, weight: .bold))
            .tracking(0.8)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(status == "ACCEPTED" ? Color.greenPrimary.opacity(0.1) : Color.bluePrimary.opacity(0.08))
            .foregroundColor(status == "ACCEPTED" ? Color(hex: "248a3d") : .bluePrimary)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(status == "ACCEPTED" ? Color.greenPrimary.opacity(0.25) : Color.bluePrimary.opacity(0.15), lineWidth: 1)
            )
    }
}
