import SwiftUI
import FirebaseCore
import SolaceCore

@main
struct SolaceApp: App {
    @State private var authViewModel: AuthViewModel

    init() {
        FirebaseApp.configure()
        _authViewModel = State(initialValue: AuthViewModel(authService: FirebaseAuthService()))
    }

    var body: some Scene {
        WindowGroup {
            AuthRootView(authViewModel: authViewModel)
        }
    }
}
