import Foundation

public enum AIChatError: Error, Sendable, Equatable {
    case notSignedIn
    case network
    case rateLimited
    case unknown(String)
}

/// Abstracts the AI support chatbot. The concrete implementation calls a
/// Firebase Cloud Function proxy — the OpenAI API key never lives on-device.
public protocol AIChatServicing: Sendable {
    func sendMessage(history: [AIChatMessage], newMessage: String) async throws -> String
}
