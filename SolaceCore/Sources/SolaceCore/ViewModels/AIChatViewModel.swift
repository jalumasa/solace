import Foundation
import Observation

@MainActor
@Observable
public final class AIChatViewModel {
    public private(set) var messages: [AIChatMessage] = []
    public var draftText: String = ""
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?

    private let chatService: AIChatServicing

    public init(chatService: AIChatServicing) {
        self.chatService = chatService
        messages = [
            AIChatMessage(
                role: .assistant,
                text: "Hi, I'm here to listen. This chat offers general emotional support, not emergency care — if you're in crisis, please use the resources below."
            )
        ]
    }

    public func send() async {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isLoading else { return }
        errorMessage = nil
        draftText = ""
        let historyBeforeSend = messages
        messages.append(AIChatMessage(role: .user, text: text))
        isLoading = true
        defer { isLoading = false }
        do {
            let reply = try await chatService.sendMessage(history: historyBeforeSend, newMessage: text)
            messages.append(AIChatMessage(role: .assistant, text: reply))
        } catch {
            errorMessage = "The assistant is unavailable right now. Please try again, or use the crisis resources below if you need immediate support."
        }
    }
}
