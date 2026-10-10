import SwiftUI

struct QuoteHistoryView: View {
    @StateObject private var vm = QuotationViewModel()

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blueLight)
                            .frame(width: 44, height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blueBorder, lineWidth: 1)
                            )
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 18))
                            .foregroundColor(.bluePrimary)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mis Cotizaciones")
                            .font(.system(size: 28, weight: .bold))
                            .tracking(-0.5)
                            .foregroundColor(.textMain)
                    }
                    Spacer()
                    Button(action: { Task { await vm.loadHistory() } }) {
                        Label("Actualizar", systemImage: "arrow.clockwise")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "374151"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "d1d5db"), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 28)

                Group {
                    if vm.isLoading {
                        Spacer()
                        ProgressView()
                            .tint(.bluePrimary)
                        Spacer()

                    } else if let error = vm.errorMessage {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.redPrimary)
                            Text(error)
                                .font(.system(size: 13))
                                .foregroundColor(.redPrimary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(20)
                        Spacer()

                    } else if vm.quotes.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "tray")
                                .font(.system(size: 36))
                                .foregroundColor(.textLight)
                            Text("Aún no tienes cotizaciones registradas")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .background(Color.bgSubtle)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                                .foregroundColor(Color.borderHover)
                        )
                        .padding(.horizontal, 20)
                        Spacer()

                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Cotizaciones")
                                    .font(.system(size: 22, weight: .semibold))
                                    .tracking(-0.3)
                                    .foregroundColor(Color(hex: "111111"))
                                LazyVStack(spacing: 0) {
                                    ForEach(vm.quotes) { quote in
                                        quoteRow(quote)
                                    }
                                }
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "e5e7eb"), lineWidth: 1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 32)
                        }
                    }
                }
            }
        }
        .navigationTitle("Historial")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.loadHistory() }
    }

    private func quoteRow(_ quote: Quote) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(quote.device_type.capitalized + (quote.brand.map { " • \($0)" } ?? ""))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "111111"))
                        statusBadge(quote.status)
                    }
                    HStack(spacing: 12) {
                        Text("Condición: \(quote.condition)")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "6b7280"))
                        Text(formattedDate(quote.created_at))
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "9ca3af"))
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Precio ofrecido")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(hex: "9ca3af"))
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("Bs.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "6b7280"))
                        Text(String(format: "%.2f", quote.final_price))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "111111"))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)

            if vm.quotes.last?.id != quote.id {
                Rectangle().fill(Color(hex: "f3f4f6")).frame(height: 1)
            }
        }
        .background(Color.white)
    }

    private func statusBadge(_ status: String) -> some View {
        Text(status.replacingOccurrences(of: "_", with: " "))
            .font(.system(size: 9, weight: .bold))
            .tracking(0.5)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(status == "ACCEPTED" ? Color(hex: "f0fdf4") : Color(hex: "fff7ed"))
            .foregroundColor(status == "ACCEPTED" ? Color(hex: "166534") : Color(hex: "c2410c"))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(status == "ACCEPTED" ? Color(hex: "bbf7d0") : Color(hex: "ffedd5"), lineWidth: 1))
    }

    private func formattedDate(_ raw: String) -> String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let fallback = ISO8601DateFormatter()
        guard let date = iso.date(from: raw) ?? fallback.date(from: raw) else { return raw }
        let f = DateFormatter()
        f.dateStyle = .short
        return f.string(from: date)
    }
}
