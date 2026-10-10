import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var phone = ""
    @State private var showPasswordHelp = false
    @FocusState private var passwordFocused: Bool

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Spacer(minLength: 32)
                    authCard
                    NavigationLink(destination: GuestOrderTrackingView()) {
                        Label("Consultar seguimiento de pedido", systemImage: "shippingbox")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "0066cc"))
                            .padding(.top, 12)
                    }
                    Spacer(minLength: 32)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height)
                .padding(.horizontal, 16)
            }
            .background(Color.white)
        }
        .background(Color.white.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .alert("Restablecer contraseña", isPresented: $showPasswordHelp) {
            Button("Entendido", role: .cancel) {}
        } message: {
            Text("Contacta a soporte@reecicla.bo para restablecer tu contraseña.")
        }
    }

    private var authCard: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
            VStack(spacing: 0) {
                ZStack {
                    AuthLogoDots()
                        .frame(width: 120, height: 120)
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 26, weight: .regular))
                        .foregroundColor(Color(hex: "1d1d1f"))
                }
                .padding(.bottom, 20)

                Text(isLogin ? "Iniciar sesión" : "Crear cuenta")
                    .font(.system(size: 25, weight: .semibold))
                    .tracking(-0.5)
                    .foregroundColor(Color(hex: "1d1d1f"))

                Text(isLogin
                     ? "Ingresa con tu cuenta para continuar"
                     : "Registrate para solicitar y gestionar cotizaciones")
                    .font(.system(size: 13))
                    .foregroundColor(.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 24)

            if let error = authVM.errorMessage {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundColor(.redPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.redPrimary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.redPrimary.opacity(0.2), lineWidth: 1))
                    .padding(.bottom, 18)
            }

            VStack(spacing: 12) {
                if !isLogin {
                    AuthTextField(
                        label: "Nombre completo",
                        placeholder: "Nombre y Apellido",
                        text: $name
                    )
                    AuthTextField(
                        label: "Teléfono / Celular",
                        placeholder: "+591 70000000",
                        text: $phone,
                        keyboardType: .phonePad
                    )
                }

                AuthTextField(
                    label: "Reecicla ID (Correo electrónico)",
                    placeholder: "ejemplo@reecicla.bo",
                    text: $email,
                    keyboardType: .emailAddress
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Contraseña")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.textMuted)
                        .padding(.leading, 2)

                    ZStack(alignment: .trailing) {
                        SecureField("Contraseña", text: $password)
                            .font(.system(size: 14))
                            .foregroundColor(.textMain)
                            .padding(.leading, 16)
                            .padding(.trailing, 48)
                            .frame(height: 44)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "d2d2d7"), lineWidth: 1))
                            .focused($passwordFocused)
                            .submitLabel(.go)
                            .onSubmit(submit)

                        Button(action: submit) {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.textMuted)
                                .frame(width: 28, height: 28)
                                .background(Color.white)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(hex: "d2d2d7"), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .disabled(authVM.isLoading || email.isEmpty || password.isEmpty)
                        .opacity(authVM.isLoading || email.isEmpty || password.isEmpty ? 0.4 : 1)
                        .padding(.trailing, 8)
                        .accessibilityLabel("Continuar")
                    }
                }

                Button(action: submit) {
                    Group {
                        if authVM.isLoading {
                            HStack(spacing: 8) {
                                ProgressView().tint(.white)
                                Text("Procesando...")
                            }
                        } else {
                            Text(isLogin ? "Iniciar sesión" : "Crear cuenta")
                        }
                    }
                    .font(.system(size: 14, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(authVM.isLoading ? Color(hex: "99c9f6") : Color.bluePrimary)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(authVM.isLoading)
                .padding(.top, 8)
            }

            VStack(spacing: 10) {
                if isLogin {
                    Button("Crear cuenta") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isLogin = false
                            authVM.errorMessage = nil
                        }
                    }
                    .accessibilityHint("Cambia al formulario de registro")

                    Button {
                        showPasswordHelp = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("¿Olvidaste tu Reecicla ID o la contraseña?")
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 10))
                        }
                    }
                } else {
                    Button("¿Ya tienes una cuenta? Iniciar sesión") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isLogin = true
                            authVM.errorMessage = nil
                        }
                    }
                }
            }
            .font(.system(size: 13))
            .foregroundColor(Color(hex: "0066cc"))
            .buttonStyle(.plain)
            .padding(.top, 18)

            }
            .padding(.horizontal, 36)
            .padding(.top, 44)
            .padding(.bottom, 36)

        NavigationLink(destination: QuotationView().environmentObject(authVM)) {
            Label("Volver", systemImage: "arrow.left")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.textMuted)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.04))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.leading, 20)
        .padding(.top, 20)
        }
        .frame(maxWidth: 440)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.black.opacity(0.06), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.08), radius: 30, x: 0, y: 16)
        .frame(maxWidth: .infinity)
    }

    private func submit() {
        guard !email.isEmpty, !password.isEmpty else { return }
        Task {
            if isLogin {
                await authVM.login(email: email, password: password)
            } else {
                await authVM.register(email: email, password: password, name: name, phone: phone)
            }
        }
    }
}

private struct AuthLogoDots: View {
    private let rings: [(count: Int, radius: CGFloat, size: CGFloat)] = [
        (12, 24, 2.2),
        (18, 34, 2.5),
        (24, 44, 2.8)
    ]

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            for ring in rings {
                for index in 0..<ring.count {
                    let angle = CGFloat(index) / CGFloat(ring.count) * 2 * .pi - .pi / 2
                    let point = CGPoint(
                        x: center.x + ring.radius * cos(angle),
                        y: center.y + ring.radius * sin(angle)
                    )
                    let hue = Double(index) / Double(ring.count)
                    let dot = CGRect(
                        x: point.x - ring.size,
                        y: point.y - ring.size,
                        width: ring.size * 2,
                        height: ring.size * 2
                    )
                    context.fill(
                        Path(ellipseIn: dot),
                        with: .color(Color(hue: hue, saturation: 0.85, brightness: 1).opacity(0.85))
                    )
                }
            }
        }
        .accessibilityHidden(true)
    }
}
