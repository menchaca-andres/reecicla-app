import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        Group {
            if authVM.isAuthenticated {
                HomeView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut, value: authVM.isAuthenticated)
    }
}
