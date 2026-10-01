import SwiftUI

enum AuthTab { case login, register }

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var activeTab: AuthTab = .login

    @State private var loginTenant   = "reecicla"
    @State private var loginEmail    = ""
    @State private var loginPassword = ""

    @State private var regTenant   = "reecicla"
    @State private var regName     = ""
    @State private var regPhone    = ""
    @State private var regEmail    = ""
    @State private var regPassword = ""

    var body: some View {
        ZStack {
            Color.bgPage.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.blueLight)
                                .frame(width: 56, height: 56)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.blueBorder, lineWidth: 1)
                                )
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.bluePrimary)
                        }

                        Text("Reecicla")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.textMain)

                        Text("Recuperamos el valor de tus equipos")
                            .font(.system(size: 13))
                            .foregroundColor(.textMuted)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 28)

                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            tabButton("Iniciar Sesión", tab: .login)
                            tabButton("Registrarse",   tab: .register)
                        }
                        .padding(4)
                        .background(Color.bgSubtle)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.borderColor, lineWidth: 1)
                        )
                        .padding(.bottom, 20)

                        if let error = authVM.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.redPrimary)
                                Text(error)
                                    .font(.system(size: 13))
                                    .foregroundColor(.redPrimary)
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color.redLight)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.redBorder, lineWidth: 1)
                            )
                            .padding(.bottom, 16)
                        }

                        if activeTab == .login {
                            loginForm
                        } else {
                            registerForm
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.textMain.opacity(0.06), radius: 16, x: 0, y: 4)
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
            }
        }
    }

    private func tabButton(_ title: String, tab: AuthTab) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                activeTab = tab
                authVM.errorMessage = nil
            }
        }) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(activeTab == tab ? Color.white : Color.clear)
                .foregroundColor(activeTab == tab ? .bluePrimary : .textMuted)
                .cornerRadius(7)
                .shadow(color: activeTab == tab ? Color.black.opacity(0.08) : .clear,
                        radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    private var loginForm: some View {
        VStack(spacing: 12) {
            AuthTextField(
                label: "ID de Tenant",
                placeholder: "reecicla",
                text: $loginTenant,
                icon: "building.2.fill",
                iconColor: .orangePrimary
            )
            AuthTextField(
                label: "Correo Electrónico",
                placeholder: "cliente@ejemplo.com",
                text: $loginEmail,
                icon: "envelope.fill",
                iconColor: .bluePrimary,
                keyboardType: .emailAddress
            )
            AuthTextField(
                label: "Contraseña",
                placeholder: "••••••••",
                text: $loginPassword,
                icon: "lock.fill",
                iconColor: .bluePrimary,
                isSecure: true
            )

            primaryButton(
                title: "Ingresar a la Plataforma",
                loading: authVM.isLoading,
                disabled: loginTenant.isEmpty || loginEmail.isEmpty || loginPassword.isEmpty
            ) {
                Task {
                    await authVM.login(
                        tenantId: loginTenant,
                        email: loginEmail,
                        password: loginPassword
                    )
                }
            }
        }
    }

    private var registerForm: some View {
        VStack(spacing: 12) {
            AuthTextField(
                label: "ID de Tenant",
                placeholder: "reecicla",
                text: $regTenant,
                icon: "building.2.fill",
                iconColor: .orangePrimary
            )
            AuthTextField(
                label: "Nombre Completo",
                placeholder: "Ej. Juan Pérez",
                text: $regName,
                icon: "person.fill",
                iconColor: .bluePrimary
            )
            AuthTextField(
                label: "Celular / Teléfono",
                placeholder: "Ej. +591 71234567",
                text: $regPhone,
                icon: "phone.fill",
                iconColor: .greenPrimary,
                keyboardType: .phonePad
            )
            AuthTextField(
                label: "Correo Electrónico",
                placeholder: "cliente@ejemplo.com",
                text: $regEmail,
                icon: "envelope.fill",
                iconColor: .bluePrimary,
                keyboardType: .emailAddress
            )
            AuthTextField(
                label: "Contraseña",
                placeholder: "••••••••",
                text: $regPassword,
                icon: "lock.fill",
                iconColor: .bluePrimary,
                isSecure: true
            )

            primaryButton(
                title: "Crear Cuenta",
                loading: authVM.isLoading,
                disabled: regTenant.isEmpty || regEmail.isEmpty || regPassword.isEmpty
            ) {
                Task {
                    await authVM.register(
                        tenantId: regTenant,
                        email: regEmail,
                        password: regPassword,
                        name: regName,
                        phone: regPhone
                    )
                }
            }
        }
    }

    private func primaryButton(
        title: String,
        loading: Bool,
        disabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Group {
                if loading {
                    HStack(spacing: 8) {
                        ProgressView().tint(.white)
                        Text("Procesando...")
                    }
                } else {
                    Text(title)
                }
            }
            .font(.system(size: 15, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(disabled ? Color.bluePrimary.opacity(0.4) : Color.bluePrimary)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(color: Color.bluePrimary.opacity(disabled ? 0 : 0.25),
                    radius: 8, x: 0, y: 3)
        }
        .disabled(loading || disabled)
        .padding(.top, 8)
    }
}
