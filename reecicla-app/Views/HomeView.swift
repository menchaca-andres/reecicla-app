import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        ZStack {
            Color.bgPage.ignoresSafeArea()

            VStack(spacing: 24) {
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
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.textMain)
                        Text(authVM.currentUser?.role ?? "")
                            .font(.system(size: 12))
                            .foregroundColor(.textMuted)
                    }

                    Spacer()
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(14)
                .shadow(color: Color.textMain.opacity(0.05), radius: 10, x: 0, y: 2)

                VStack(spacing: 8) {
                    Image(systemName: "tray.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.textLight)
                    Text("Tu panel está en construcción")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textMuted)
                    Text("Aquí verás tus cotizaciones y dispositivos")
                        .font(.system(size: 12))
                        .foregroundColor(.textLight)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color.white)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.borderColor, lineWidth: 1)
                )

                Spacer()

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
            .padding(.top, 60)
            .padding(.bottom, 40)
        }
    }
}
