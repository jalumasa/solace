import Foundation
import Observation

@MainActor
@Observable
public final class ChatViewModel {
    public private(set) var messages: [Message] = []
    public var draftText: String = ""
    public private(set) var isSending = false
    public private(set) var errorMessage: String?

    private let conversationID: String
    private let currentUserID: String
    private let messagingService: MessagingServicing
    @ObservationIgnored
    private nonisolated(unsafe) var observationTask: Task<Void, Never>?

    public init(conversationID: String, currentUserID: String, messagingService: MessagingServicing) {
        self.conversationID = conversationID
        self.currentUserID = currentUserID
        self.messagingService = messagingService
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await messages in messagingService.observeMessages(conversationID: conversationID) {
                self.messages = messages
            }
        }
    }

    deinit {
        observationTask?.cancel()
    }

    public func send() async {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        draftText = ""
        isSending = true
        defer { isSending = false }
        do {
            try await messagingService.sendMessage(conversationID: conversationID, senderID: currentUserID, text: text)
        } catch {
            errorMessage = "Message failed to send. Please try again."
            draftText = text
        }
    }

    public func isFromCurrentUser(_ message: Message) -> Bool {
        message.senderID == currentUserID
    }
}
