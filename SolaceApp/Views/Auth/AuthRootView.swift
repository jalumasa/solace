import SwiftUI
import SolaceCore

struct AuthRootView: View {
    @Bindable var authViewModel: AuthViewModel
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        switch authViewModel.state {
        case .signedOut:
            if hasCompletedOnboarding {
                SignInView(authViewModel: authViewModel)
            } else {
                OnboardingView(onFinish: { hasCompletedOnboarding = true })
            }
        case .signedIn(let user):
            RootTabView(currentUser: user, authViewModel: authViewModel)
        }
    }
}
