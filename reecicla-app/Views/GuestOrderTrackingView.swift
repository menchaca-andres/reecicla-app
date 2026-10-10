import SwiftUI

struct GuestOrderTrackingView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var initialToken: String?

    @StateObject private var viewModel = QuotationViewModel()
    @State private var trackingLink = ""

    init(initialToken: String? = nil) {
        self.initialToken = initialToken
        _trackingLink = State(initialValue: initialToken ?? "")
    }

    var body: some View {
        ZStack {
            Color(hex: "f4f7fb").ignoresSafeArea()

            ScrollView {
                VStack {
                    VStack(alignment: .leading, spacing: 22) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SEGUIMIENTO DE PEDIDO")
                                .font(.system(size: 12, weight: .bold))
                                .tracking(1.2)
                                .foregroundColor(Color(hex: "2563eb"))
                            Text(viewModel.guestOrderTracking.map { "Pedido \($0.order_number)" } ?? "Consulta tu pedido")
                                .font(.system(size: 30, weight: .bold))
                                .tracking(-0.5)
                                .foregroundColor(Color(hex: "0f172a"))
                            if viewModel.guestOrderTracking == nil {
                                Text("Pega el enlace privado recibido por correo para consultar el estado. No necesitas iniciar sesión.")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "64748b"))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        if viewModel.guestOrderTracking == nil {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Enlace de seguimiento")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(hex: "0f172a"))
                                TextField("Pega aquí el enlace o token", text: $trackingLink, axis: .vertical)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .keyboardType(.URL)
                                    .font(.system(size: 14))
                                    .padding(13)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "cbd5e1"), lineWidth: 1))
                                Button(action: loadTracking) {
                                    HStack(spacing: 8) {
                                        if viewModel.isLoading {
                                            ProgressView().tint(.white)
                                        } else {
                                            Text("Consultar pedido")
                                            Image(systemName: "arrow.right")
                                        }
                                    }
                                    .font(.system(size: 15, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                                    .background(Color(hex: "2563eb"))
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .disabled(viewModel.isLoading || trackingLink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                        }

                        if let error = viewModel.errorMessage {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(error)
                                if error.localizedCaseInsensitiveContains("venció") {
                                    Text("Solicita un nuevo enlace al negocio para consultar el pedido.")
                                }
                                Button("Volver a intentar", action: loadTracking)
                                    .fontWeight(.semibold)
                                    .padding(.top, 4)
                            }
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "991b1b"))
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(hex: "fef2f2"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        if viewModel.isLoading && viewModel.guestOrderTracking == nil {
                            HStack(spacing: 10) {
                                ProgressView().tint(Color(hex: "2563eb"))
                                Text("Cargando el estado más reciente…")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "64748b"))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        if let order = viewModel.guestOrderTracking {
                            orderDetails(order)
                        }
                    }
                    .padding(.horizontal, horizontalSizeClass == .compact ? 18 : 36)
                    .padding(.vertical, horizontalSizeClass == .compact ? 24 : 36)
                    .frame(maxWidth: 720, alignment: .leading)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "e2e8f0"), lineWidth: 1))
                    .shadow(color: Color(hex: "0f172a").opacity(0.08), radius: 24, x: 0, y: 16)
                    .padding(.horizontal, 16)
                    .padding(.vertical, horizontalSizeClass == .compact ? 20 : 48)
                }
            }
        }
        .navigationTitle("Seguimiento")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if let initialToken, !initialToken.isEmpty, viewModel.guestOrderTracking == nil {
                await viewModel.loadGuestOrderTracking(token: initialToken)
            }
        }
    }

    private func orderDetails(_ order: GuestOrderTracking) -> some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 6) {
                Text("ESTADO ACTUAL")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.7)
                    .foregroundColor(.textMuted)
                HStack(spacing: 8) {
                    Circle().fill(Color(hex: "34c759")).frame(width: 8, height: 8)
                    Text(statusLabel(order.status))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "248a3d"))
                }
            }

            if horizontalSizeClass == .regular {
                summaryGrid(order, columns: 2)
            } else {
                summaryGrid(order, columns: 1)
            }

            Text("Historial del pedido")
                .font(.system(size: 20, weight: .semibold))
                .tracking(-0.3)
                .foregroundColor(.textMain)

            if order.status_history.isEmpty {
                Text("Aún no hay actualizaciones del pedido.")
                    .font(.system(size: 13))
                    .foregroundColor(.textMuted)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(order.status_history.indices, id: \.self) { index in
                        let event = order.status_history[index]
                        HStack(alignment: .top, spacing: 12) {
                            VStack(spacing: 0) {
                                Circle()
                                    .stroke(Color.bluePrimary, lineWidth: 2)
                                    .background(Circle().fill(.white))
                                    .frame(width: 14, height: 14)
                                if index < order.status_history.count - 1 {
                                    Rectangle()
                                        .fill(Color(hex: "dbeafe"))
                                        .frame(width: 2, height: 48)
                                }
                            }
                            VStack(alignment: .leading, spacing: 5) {
                                Text(statusLabel(event.new_status))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: "334155"))
                                Text(formattedDate(event.created_at))
                                    .font(.system(size: 12))
                                    .foregroundColor(.textMuted)
                                if let reason = event.reason, !reason.isEmpty {
                                    Text(reason)
                                        .font(.system(size: 13))
                                        .foregroundColor(.textMuted)
                                }
                            }
                            .padding(.bottom, 16)
                            Spacer(minLength: 0)
                        }
                    }
                }
            }

            Button {
                loadTracking()
            } label: {
                Label("Actualizar estado", systemImage: "arrow.clockwise")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(.white)
                    .foregroundColor(Color(hex: "1d1d1f"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.borderHover, lineWidth: 1))
            }
            .disabled(viewModel.isLoading)

            Text("Este enlace es privado. No lo compartas; vence a los 90 días.")
                .font(.system(size: 12))
                .foregroundColor(.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func summaryGrid(_ order: GuestOrderTracking, columns: Int) -> some View {
        let gridColumns = Array(repeating: GridItem(.flexible(), alignment: .leading), count: columns)
        return LazyVGrid(columns: gridColumns, alignment: .leading, spacing: 18) {
            summaryItem("Equipo", value: [order.device_type_name, order.brand, order.model].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " · "))
            summaryItem("Cotización aceptada", value: "\(order.currency) \(String(format: "%.2f", order.quoted_price))")
            if let trackingCode = order.tracking_code, !trackingCode.isEmpty {
                summaryItem("Código de envío", value: trackingCode)
            }
            if let boxStatus = order.box_status {
                summaryItem("Estado de la caja", value: statusLabel(boxStatus))
            }
        }
        .padding(20)
        .background(Color(hex: "f8fafc"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func summaryItem(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "64748b"))
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "0f172a"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func loadTracking() {
        guard let token = extractToken(from: trackingLink) else {
            viewModel.errorMessage = "Pega un enlace válido o un token de seguimiento."
            return
        }
        Task { await viewModel.loadGuestOrderTracking(token: token) }
    }

    private func extractToken(from value: String) -> String? {
        let input = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let candidate = URL(string: input)?.pathComponents.last ?? input
        guard candidate.range(of: "^[0-9a-fA-F]{64}$", options: .regularExpression) != nil else {
            return nil
        }
        return candidate
    }

    private func statusLabel(_ status: String) -> String {
        let labels = [
            "ACCEPTED": "Pedido aceptado",
            "BOX_REQUESTED": "Caja solicitada",
            "BOX_SHIPPED": "Caja enviada",
            "IN_TRANSIT": "Equipo en tránsito",
            "RECEIVED": "Equipo recibido",
            "INSPECTING": "En inspección",
            "INSPECTED": "Inspección completada",
            "ADJUSTMENT_PENDING": "Ajuste de cotización pendiente",
            "ADJUSTMENT_REJECTED": "Ajuste rechazado",
            "PAYMENT_PENDING": "Pago pendiente",
            "PAID": "Pago realizado",
            "DISPOSED": "Equipo procesado",
            "CLOSED": "Pedido cerrado",
            "CANCELLED": "Pedido cancelado",
            "REQUESTED": "Solicitada",
            "SHIPPED": "Enviada",
            "DELIVERED": "Entregada"
        ]
        return labels[status] ?? status.replacingOccurrences(of: "_", with: " ").capitalized
    }

    private func formattedDate(_ raw: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let fallback = ISO8601DateFormatter()
        guard let date = formatter.date(from: raw) ?? fallback.date(from: raw) else { return raw }
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}
