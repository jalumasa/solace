import Foundation

public enum AuthError: Error, Sendable, Equatable {
    case invalidCredentials
    case emailAlreadyInUse
    case weakPassword
    case network
    case unknown(String)
}

/// Abstracts Firebase Authentication so ViewModels can be tested without
/// touching the network or the Firebase SDK.
public protocol AuthServicing: Sendable {
    /// Emits the current signed-in user (or nil) whenever auth state changes.
    func observeAuthState() -> AsyncStream<User?>

    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String, displayName: String, role: Role, bio: String?) async throws -> User
    func signOut() throws
}
