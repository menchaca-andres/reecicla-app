import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel

    private var role: String { authVM.currentUser?.role ?? "" }
    private var isAdmin: Bool { role == "ADMIN" || role == "SUPER_ADMIN" }
    private var isSuperAdmin: Bool { role == "SUPER_ADMIN" }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {

                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.greenLight)
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.greenBorder, lineWidth: 1)
                                    )
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.greenPrimary)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(authVM.currentUser.map { "Hola, \($0.name ?? $0.email)" } ?? "Bienvenido")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.textMain)
                                roleBadge(role)
                            }
                            Spacer()
                        }
                        .padding(18)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black.opacity(0.08), lineWidth: 1))
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)

                        sectionLabel("Mis Acciones")

                        NavigationLink(destination: QuotationView().environmentObject(authVM)) {
                            actionRow(
                                icon: "sparkles",
                                iconBg: .blueLight, iconBorder: .blueBorder, iconColor: .bluePrimary,
                                title: "Solicitar Cotización",
                                subtitle: "Calcula el valor de tu equipo"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink(destination: QuoteHistoryView()) {
                            actionRow(
                                icon: "clock.arrow.circlepath",
                                iconBg: .greenLight, iconBorder: .greenBorder, iconColor: .greenPrimary,
                                title: "Mis Cotizaciones",
                                subtitle: "Historial de solicitudes guardadas"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink(destination: GuestOrderTrackingView()) {
                            actionRow(
                                icon: "shippingbox",
                                iconBg: .greenLight, iconBorder: .greenBorder, iconColor: .greenPrimary,
                                title: "Seguimiento de pedido",
                                subtitle: "Consulta un pedido desde el enlace de tu correo"
                            )
                        }
                        .buttonStyle(.plain)

                        if isAdmin {
                            sectionLabel("Administración")

                            NavigationLink(destination: PricingRulesView().environmentObject(authVM)) {
                                actionRow(
                                    icon: "slider.horizontal.3",
                                    iconBg: Color(hex: "fff7ed"),
                                    iconBorder: Color(hex: "fed7aa"),
                                    iconColor: .orangePrimary,
                                    title: "Reglas de Precios",
                                    subtitle: "Configura precios base y ajustes por condición"
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        Spacer(minLength: 10)

                        Button(action: { authVM.logout() }) {
                            HStack(spacing: 8) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Cerrar Sesión")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.redPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Color.redLight)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.redBorder, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Reecicla")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
        }
    }

    @ViewBuilder
    private func roleBadge(_ role: String) -> some View {
        let (bg, border, fg, label): (Color, Color, Color, String) = {
            switch role {
            case "ADMIN":       return (.blueLight,   .blueBorder,                Color(hex: "1d4ed8"), "Admin")
            case "SUPER_ADMIN": return (Color(hex: "faf5ff"), Color(hex: "e9d5ff"), Color(hex: "7c3aed"), "Super Admin")
            default:            return (.greenLight,  .greenBorder,               .greenPrimary,         "Cliente")
            }
        }()

        Text(label.uppercased())
            .font(.system(size: 9, weight: .bold))
            .tracking(0.6)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(bg)
            .foregroundColor(fg)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(border, lineWidth: 1))
    }

    private func sectionLabel(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.textMuted)
                .tracking(-0.3)
            Spacer()
        }
    }

    private func actionRow(
        icon: String,
        iconBg: Color, iconBorder: Color, iconColor: Color,
        title: String, subtitle: String
    ) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconBg)
                    .frame(width: 42, height: 42)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(iconBorder, lineWidth: 1))
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textMain)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.textMuted)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.textLight)
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.08), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}
