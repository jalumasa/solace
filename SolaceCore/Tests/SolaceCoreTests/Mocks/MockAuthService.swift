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

    func signUp(email: String, password: String, displayName: String, role: Role, bio: String?) async throws -> User {
        try signUpResult.get()
    }

    func signOut() throws {
        if let signOutError {
            throw signOutError
        }
    }
}
