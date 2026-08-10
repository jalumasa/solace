import Foundation
@testable import SolaceCore

final class MockAIChatService: AIChatServicing, @unchecked Sendable {
    var result: Result<String, Error> = .success("mock reply")
    private(set) var receivedHistory: [AIChatMessage] = []
    private(set) var receivedMessage: String?

    func sendMessage(history: [AIChatMessage], newMessage: String) async throws -> String {
        receivedHistory = history
        receivedMessage = newMessage
        return try result.get()
    }
}
