import Testing
@testable import SolaceCore

@MainActor
struct AuthViewModelTests {
    @Test func initialStateIsSignedOut() {
        let viewModel = AuthViewModel(authService: MockAuthService())
        #expect(viewModel.state == .signedOut)
    }

    @Test func signInSuccessUpdatesState() async {
        let mock = MockAuthService()
        let user = User(id: "1", email: "a@b.com", displayName: "Alex", role: .student)
        mock.signInResult = .success(user)
        let viewModel = AuthViewModel(authService: mock)
        viewModel.email = "a@b.com"
        viewModel.password = "password123"

        await viewModel.signIn()

        #expect(viewModel.state == .signedIn(user))
        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.isLoading)
    }

    @Test func signInFailureSetsErrorMessage() async {
        let mock = MockAuthService()
        mock.signInResult = .failure(AuthError.invalidCredentials)
        let viewModel = AuthViewModel(authService: mock)

        await viewModel.signIn()

        #expect(viewModel.state == .signedOut)
        #expect(viewModel.errorMessage == "Incorrect email or password.")
    }

    @Test func signUpSuccessUpdatesState() async {
        let mock = MockAuthService()
        let user = User(id: "2", email: "c@d.com", displayName: "Sam", role: .counselor)
        mock.signUpResult = .success(user)
        let viewModel = AuthViewModel(authService: mock)
        viewModel.selectedRole = .counselor

        await viewModel.signUp()

        #expect(viewModel.state == .signedIn(user))
    }

    @Test func authStateObservationUpdatesState() async {
        let mock = MockAuthService()
        let viewModel = AuthViewModel(authService: mock)
        let user = User(id: "3", email: "e@f.com", displayName: "Jo", role: .student)

        mock.emit(user)
        await allowStreamDelivery()

        #expect(viewModel.state == .signedIn(user))
    }

    @Test func signOutResetsState() async {
        let mock = MockAuthService()
        let user = User(id: "1", email: "a@b.com", displayName: "Alex", role: .student)
        mock.signInResult = .success(user)
        let viewModel = AuthViewModel(authService: mock)
        await viewModel.signIn()

        viewModel.signOut()

        #expect(viewModel.state == .signedOut)
    }
}
