import Foundation

public enum AuthError: Error, Sendable, Equatable {
    case invalidCredentials
    case emailAlreadyInUse
    case weakPassword
    case network
    case unknown(String)
}

public struct SignUpDetails: Sendable {
    public var email: String
    public var password: String
    public var displayName: String
    public var role: Role
    public var bio: String?
    public var major: String?
    public var academicYear: AcademicYear?
    public var age: Int?

    public init(
        email: String,
        password: String,
        displayName: String,
        role: Role,
        bio: String? = nil,
        major: String? = nil,
        academicYear: AcademicYear? = nil,
        age: Int? = nil
    ) {
        self.email = email
        self.password = password
        self.displayName = displayName
        self.role = role
        self.bio = bio
        self.major = major
        self.academicYear = academicYear
        self.age = age
    }
}

/// Abstracts Firebase Authentication so ViewModels can be tested without
/// touching the network or the Firebase SDK.
public protocol AuthServicing: Sendable {
    /// Emits the current signed-in user (or nil) whenever auth state changes.
    func observeAuthState() -> AsyncStream<User?>

    func signIn(email: String, password: String) async throws -> User
    func signUp(_ details: SignUpDetails) async throws -> User
    func signOut() throws
}
