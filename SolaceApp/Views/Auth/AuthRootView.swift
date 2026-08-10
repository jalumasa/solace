import SwiftUI
import SolaceCore

struct AuthRootView: View {
    @Bindable var authViewModel: AuthViewModel

    var body: some View {
        switch authViewModel.state {
        case .signedOut:
            SignInView(authViewModel: authViewModel)
        case .signedIn(let user):
            RootTabView(currentUser: user, authViewModel: authViewModel)
        }
    }
}
