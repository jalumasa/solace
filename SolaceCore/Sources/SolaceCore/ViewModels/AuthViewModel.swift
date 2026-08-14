import Foundation
import Observation

@MainActor
@Observable
public final class AuthViewModel {
    public enum State: Equatable {
        case signedOut
        case signedIn(User)
    }

    public private(set) var state: State = .signedOut
    public var email: String = ""
    public var password: String = ""
    public var displayName: String = ""
    public var bio: String = ""
    public var major: String = ""
    public var academicYear: AcademicYear?
    public var age: String = ""
    public var selectedRole: Role = .student
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?

    private let authService: AuthServicing
    @ObservationIgnored
    private nonisolated(unsafe) var observationTask: Task<Void, Never>?

    public init(authService: AuthServicing) {
        self.authService = authService
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await user in authService.observeAuthState() {
                self.state = user.map(State.signedIn) ?? .signedOut
            }
        }
    }

    deinit {
        observationTask?.cancel()
    }

    public func signIn() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let user = try await authService.signIn(email: email, password: password)
            state = .signedIn(user)
            clearForm()
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    public func signUp() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let trimmedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedMajor = major.trimmingCharacters(in: .whitespacesAndNewlines)
            let details = SignUpDetails(
                email: email,
                password: password,
                displayName: displayName,
                role: selectedRole,
                bio: trimmedBio.isEmpty ? nil : trimmedBio,
                major: (selectedRole == .student && !trimmedMajor.isEmpty) ? trimmedMajor : nil,
                academicYear: selectedRole == .student ? academicYear : nil,
                age: selectedRole == .student ? Int(age) : nil
            )
            let user = try await authService.signUp(details)
            state = .signedIn(user)
            clearForm()
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    public func signOut() {
        do {
            try authService.signOut()
            state = .signedOut
            clearForm()
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    /// Resets sign-in/sign-up form state. Called after any successful auth
    /// transition so a stale email/password/bio from a previous session
    /// never lingers into the next one (e.g. signing out and creating a
    /// different account).
    private func clearForm() {
        email = ""
        password = ""
        displayName = ""
        bio = ""
        major = ""
        academicYear = nil
        age = ""
        errorMessage = nil
    }

    private static func message(for error: Error) -> String {
        guard let authError = error as? AuthError else {
            return "Something went wrong. Please try again."
        }
        switch authError {
        case .invalidCredentials: return "Incorrect email or password."
        case .emailAlreadyInUse: return "An account with that email already exists."
        case .weakPassword: return "Please choose a stronger password."
        case .network: return "Network error. Please check your connection."
        case .unknown(let message): return message
        }
    }
}
