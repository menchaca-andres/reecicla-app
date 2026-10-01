import Foundation
import Combine

final class AuthViewModel: ObservableObject {
    @Published var currentUser: UserResponse?
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isAuthenticated: Bool

    private let service = AuthService.shared

    init() {
        self.isAuthenticated = service.isLoggedIn
    }

    func login(tenantId: String, email: String, password: String) async {
        await run {
            let response = try await self.service.login(tenantId: tenantId, email: email, password: password)
            await MainActor.run {
                self.currentUser = response.user
                self.isAuthenticated = true
            }
        }
    }

    func register(tenantId: String, email: String, password: String, name: String, phone: String) async {
        await run {
            let response = try await self.service.register(
                tenantId: tenantId,
                email: email,
                password: password,
                name: name,
                phone: phone
            )
            await MainActor.run {
                self.currentUser = response.user
                self.isAuthenticated = true
            }
        }
    }

    @MainActor
    func logout() {
        service.logout()
        currentUser = nil
        isAuthenticated = false
    }

    private func run(_ task: @escaping () async throws -> Void) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        do {
            try await task()
        } catch let error as APIClientError {
            await MainActor.run { self.errorMessage = error.errorDescription }
        } catch {
            await MainActor.run { self.errorMessage = error.localizedDescription }
        }
        await MainActor.run { self.isLoading = false }
    }
}
