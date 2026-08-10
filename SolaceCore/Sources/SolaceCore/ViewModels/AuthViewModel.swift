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
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    public func signUp() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let user = try await authService.signUp(
                email: email,
                password: password,
                displayName: displayName,
                role: selectedRole
            )
            state = .signedIn(user)
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    public func signOut() {
        do {
            try authService.signOut()
            state = .signedOut
        } catch {
            errorMessage = Self.message(for: error)
        }
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
