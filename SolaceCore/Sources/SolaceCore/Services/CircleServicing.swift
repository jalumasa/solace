import Foundation

/// Abstracts peer support-circle membership and group messaging.
public protocol CircleServicing: Sendable {
    func observeCircles() -> AsyncStream<[SupportCircle]>
    func join(circleID: String, userID: String) async throws
    func leave(circleID: String, userID: String) async throws
    func observeMessages(circleID: String) -> AsyncStream<[CircleMessage]>
    func sendMessage(circleID: String, senderID: String, senderName: String, text: String) async throws
}
