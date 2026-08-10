import Foundation
import FirebaseFunctions
import SolaceCore

/// Calls the `chatWithAI` Cloud Function, which proxies OpenAI's API.
/// The OpenAI API key lives only in Firebase Functions' secret storage —
/// never on-device and never in this repo.
final class CloudFunctionAIChatService: AIChatServicing {
    private let functions = Functions.functions()

    func sendMessage(history: [AIChatMessage], newMessage: String) async throws -> String {
        let callable = functions.httpsCallable("chatWithAI")
        let payload: [String: Any] = [
            "history": history.map { ["role": $0.role.rawValue, "text": $0.text] },
            "message": newMessage
        ]
        do {
            let result = try await callable.call(payload)
            guard let data = result.data as? [String: Any], let reply = data["reply"] as? String else {
                throw AIChatError.unknown("The assistant returned an unexpected response.")
            }
            return reply
        } catch let error as AIChatError {
            throw error
        } catch {
            throw Self.mapFunctionsError(error)
        }
    }

    private static func mapFunctionsError(_ error: Error) -> AIChatError {
        let nsError = error as NSError
        guard nsError.domain == FunctionsErrorDomain, let code = FunctionsErrorCode(rawValue: nsError.code) else {
            return .unknown(error.localizedDescription)
        }
        switch code {
        case .unauthenticated:
            return .notSignedIn
        case .resourceExhausted:
            return .rateLimited
        case .unavailable, .deadlineExceeded:
            return .network
        default:
            return .unknown(error.localizedDescription)
        }
    }
}
