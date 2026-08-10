import Foundation
import FirebaseAuth
import FirebaseFirestore
import SolaceCore

/// Firebase-backed implementation of `AuthServicing`. User profile data
/// (display name, role) lives in Firestore rather than on the Firebase Auth
/// user record, since Firebase Auth only stores a handful of built-in fields.
final class FirebaseAuthService: AuthServicing {
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()

    func observeAuthState() -> AsyncStream<SolaceCore.User?> {
        AsyncStream { continuation in
            let handle = auth.addStateDidChangeListener { [weak self] _, firebaseUser in
                guard let self else { return }
                guard let firebaseUser else {
                    continuation.yield(nil)
                    return
                }
                Task {
                    let user = try? await self.fetchUserProfile(uid: firebaseUser.uid)
                    continuation.yield(user)
                }
            }
            continuation.onTermination = { [auth] _ in
                auth.removeStateDidChangeListener(handle)
            }
        }
    }

    func signIn(email: String, password: String) async throws -> SolaceCore.User {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            guard let user = try await fetchUserProfile(uid: result.user.uid) else {
                throw AuthError.unknown("Your account exists but its profile is missing.")
            }
            return user
        } catch let error as AuthError {
            throw error
        } catch {
            throw Self.mapAuthError(error)
        }
    }

    func signUp(email: String, password: String, displayName: String, role: Role) async throws -> SolaceCore.User {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let user = SolaceCore.User(id: result.user.uid, email: email, displayName: displayName, role: role)
            try await saveUserProfile(user)
            return user
        } catch let error as AuthError {
            throw error
        } catch {
            throw Self.mapAuthError(error)
        }
    }

    func signOut() throws {
        try auth.signOut()
    }

    private func fetchUserProfile(uid: String) async throws -> SolaceCore.User? {
        let snapshot = try await firestore.collection("users").document(uid).getDocument()
        guard snapshot.exists, let data = snapshot.data() else { return nil }
        return SolaceCore.User(
            id: uid,
            email: data["email"] as? String ?? "",
            displayName: data["displayName"] as? String ?? "",
            role: Role(rawValue: data["role"] as? String ?? "") ?? .student,
            bio: data["bio"] as? String,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }

    private func saveUserProfile(_ user: SolaceCore.User) async throws {
        try await firestore.collection("users").document(user.id).setData([
            "email": user.email,
            "displayName": user.displayName,
            "role": user.role.rawValue,
            "createdAt": FieldValue.serverTimestamp()
        ])
    }

    private static func mapAuthError(_ error: Error) -> AuthError {
        let nsError = error as NSError
        guard let code = AuthErrorCode(rawValue: nsError.code) else {
            return .unknown(error.localizedDescription)
        }
        switch code {
        case .wrongPassword, .invalidEmail, .userNotFound, .invalidCredential:
            return .invalidCredentials
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .networkError:
            return .network
        default:
            return .unknown(error.localizedDescription)
        }
    }
}
