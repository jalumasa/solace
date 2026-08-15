import Foundation
import Observation

@MainActor
@Observable
public final class CircleChatViewModel {
    public private(set) var messages: [CircleMessage] = []
    public var draftText: String = ""
    public private(set) var isSending = false
    public private(set) var errorMessage: String?

    private let circleID: String
    private let currentUser: User
    private let circleService: CircleServicing
    @ObservationIgnored
    private nonisolated(unsafe) var observationTask: Task<Void, Never>?

    public init(circleID: String, currentUser: User, circleService: CircleServicing) {
        self.circleID = circleID
        self.currentUser = currentUser
        self.circleService = circleService
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await messages in circleService.observeMessages(circleID: circleID) {
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
            try await circleService.sendMessage(
                circleID: circleID,
                senderID: currentUser.id,
                senderName: currentUser.displayName,
                text: text
            )
        } catch {
            errorMessage = "Message failed to send. Please try again."
            draftText = text
        }
    }

    public func isFromCurrentUser(_ message: CircleMessage) -> Bool {
        message.senderID == currentUser.id
    }
}
