import Foundation
@testable import SolaceCore

final class MockMessagingService: MessagingServicing, @unchecked Sendable {
    var counselors: [User] = []
    var startConversationResult: Result<Conversation, Error> = .failure(TestError())
    var sendMessageError: Error?
    private(set) var sentMessages: [(conversationID: String, senderID: String, text: String)] = []

    // Streams (and their continuations) are created eagerly rather than lazily
    // inside observe*, so a test can call emit* before the ViewModel's
    // consuming Task has started iterating — AsyncStream buffers the value
    // until it's consumed, so nothing is lost either way.
    private let conversationsStream: AsyncStream<[Conversation]>
    private let conversationsContinuation: AsyncStream<[Conversation]>.Continuation
    private let messagesStream: AsyncStream<[Message]>
    private let messagesContinuation: AsyncStream<[Message]>.Continuation

    init() {
        (conversationsStream, conversationsContinuation) = AsyncStream<[Conversation]>.makeStream()
        (messagesStream, messagesContinuation) = AsyncStream<[Message]>.makeStream()
    }

    func fetchCounselors() async throws -> [User] {
        counselors
    }

    func startConversation(
        studentID: String,
        studentName: String,
        counselorID: String,
        counselorName: String
    ) async throws -> Conversation {
        try startConversationResult.get()
    }

    func observeConversations(for userID: String) -> AsyncStream<[Conversation]> {
        conversationsStream
    }

    func observeMessages(conversationID: String) -> AsyncStream<[Message]> {
        messagesStream
    }

    func sendMessage(conversationID: String, senderID: String, text: String) async throws {
        if let sendMessageError {
            throw sendMessageError
        }
        sentMessages.append((conversationID, senderID, text))
    }

    func emitConversations(_ conversations: [Conversation]) {
        conversationsContinuation.yield(conversations)
    }

    func emitMessages(_ messages: [Message]) {
        messagesContinuation.yield(messages)
    }
}
