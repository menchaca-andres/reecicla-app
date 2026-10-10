import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var trackingRoute: TrackingRoute?

    var body: some View {
        Group {
            if authVM.isAuthenticated {
                HomeView()
            } else {
                NavigationStack {
                    LoginView()
                }
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.light, for: .navigationBar)
            }
        }
        .animation(.easeInOut, value: authVM.isAuthenticated)
        .onOpenURL { url in
            if let token = trackingToken(from: url) {
                trackingRoute = TrackingRoute(token: token)
            }
        }
        .sheet(item: $trackingRoute) { route in
            NavigationStack {
                GuestOrderTrackingView(initialToken: route.token)
            }
        }
    }

    private func trackingToken(from url: URL) -> String? {
        let components = url.pathComponents
        let candidate = components.last
        guard let candidate,
              candidate.range(of: "^[0-9a-fA-F]{64}$", options: .regularExpression) != nil else {
            return nil
        }
        return candidate
    }
}

private struct TrackingRoute: Identifiable {
    let token: String
    var id: String { token }
}
