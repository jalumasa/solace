import Foundation
@testable import SolaceCore

final class MockCircleService: CircleServicing, @unchecked Sendable {
    var joinError: Error?
    var leaveError: Error?
    var sendMessageError: Error?
    private(set) var joined: [(circleID: String, userID: String)] = []
    private(set) var left: [(circleID: String, userID: String)] = []
    private(set) var sentMessages: [(circleID: String, senderID: String, senderName: String, text: String)] = []

    private let circlesStream: AsyncStream<[SupportCircle]>
    private let circlesContinuation: AsyncStream<[SupportCircle]>.Continuation
    private let messagesStream: AsyncStream<[CircleMessage]>
    private let messagesContinuation: AsyncStream<[CircleMessage]>.Continuation

    init() {
        (circlesStream, circlesContinuation) = AsyncStream<[SupportCircle]>.makeStream()
        (messagesStream, messagesContinuation) = AsyncStream<[CircleMessage]>.makeStream()
    }

    func observeCircles() -> AsyncStream<[SupportCircle]> {
        circlesStream
    }

    func join(circleID: String, userID: String) async throws {
        if let joinError {
            throw joinError
        }
        joined.append((circleID, userID))
    }

    func leave(circleID: String, userID: String) async throws {
        if let leaveError {
            throw leaveError
        }
        left.append((circleID, userID))
    }

    func observeMessages(circleID: String) -> AsyncStream<[CircleMessage]> {
        messagesStream
    }

    func sendMessage(circleID: String, senderID: String, senderName: String, text: String) async throws {
        if let sendMessageError {
            throw sendMessageError
        }
        sentMessages.append((circleID, senderID, senderName, text))
    }

    func emitCircles(_ circles: [SupportCircle]) {
        circlesContinuation.yield(circles)
    }

    func emitMessages(_ messages: [CircleMessage]) {
        messagesContinuation.yield(messages)
    }
}
