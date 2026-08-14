import Foundation
@testable import SolaceCore

final class MockAuthService: AuthServicing, @unchecked Sendable {
    var signInResult: Result<User, Error> = .failure(AuthError.invalidCredentials)
    var signUpResult: Result<User, Error> = .failure(AuthError.unknown("not configured"))
    var signOutError: Error?

    private let stream: AsyncStream<User?>
    private let continuation: AsyncStream<User?>.Continuation

    init() {
        (stream, continuation) = AsyncStream<User?>.makeStream()
    }

    func emit(_ user: User?) {
        continuation.yield(user)
    }

    func observeAuthState() -> AsyncStream<User?> {
        stream
    }

    func signIn(email: String, password: String) async throws -> User {
        try signInResult.get()
    }

    private(set) var lastSignUpDetails: SignUpDetails?

    func signUp(_ details: SignUpDetails) async throws -> User {
        lastSignUpDetails = details
        return try signUpResult.get()
    }

    func signOut() throws {
        if let signOutError {
            throw signOutError
        }
    }
}
