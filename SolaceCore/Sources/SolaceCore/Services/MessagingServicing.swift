import Foundation

/// Abstracts Firestore-backed conversations/messages between students and
/// counselors so ViewModels can be tested without a live Firestore instance.
public protocol MessagingServicing: Sendable {
    func fetchCounselors() async throws -> [User]

    /// Finds an existing conversation between the student and counselor, or creates one.
    func startConversation(
        studentID: String,
        studentName: String,
        counselorID: String,
        counselorName: String
    ) async throws -> Conversation

    /// Emits the list of conversations a user participates in, updated in real time.
    func observeConversations(for userID: String) -> AsyncStream<[Conversation]>

    /// Emits the messages in a conversation, ordered oldest to newest, updated in real time.
    func observeMessages(conversationID: String) -> AsyncStream<[Message]>

    func sendMessage(conversationID: String, senderID: String, text: String) async throws
}
