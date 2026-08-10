import Testing
@testable import SolaceCore

@MainActor
struct AIChatViewModelTests {
    @Test func startsWithWelcomeMessage() {
        let viewModel = AIChatViewModel(chatService: MockAIChatService())
        #expect(viewModel.messages.count == 1)
        #expect(viewModel.messages.first?.role == .assistant)
    }

    @Test func sendAppendsUserAndAssistantMessages() async {
        let mock = MockAIChatService()
        mock.result = .success("I'm here for you.")
        let viewModel = AIChatViewModel(chatService: mock)
        viewModel.draftText = "I'm feeling anxious"

        await viewModel.send()

        #expect(viewModel.messages.count == 3)
        #expect(viewModel.messages[1].role == .user)
        #expect(viewModel.messages[1].text == "I'm feeling anxious")
        #expect(viewModel.messages[2].role == .assistant)
        #expect(viewModel.messages[2].text == "I'm here for you.")
        #expect(viewModel.draftText == "")
        #expect(mock.receivedMessage == "I'm feeling anxious")
        #expect(mock.receivedHistory.count == 1) // just the welcome message
    }

    @Test func sendIgnoresBlankInput() async {
        let mock = MockAIChatService()
        let viewModel = AIChatViewModel(chatService: mock)
        viewModel.draftText = "   "

        await viewModel.send()

        #expect(viewModel.messages.count == 1)
        #expect(mock.receivedMessage == nil)
    }

    @Test func sendFailureSetsErrorAndKeepsUserMessage() async {
        let mock = MockAIChatService()
        mock.result = .failure(TestError())
        let viewModel = AIChatViewModel(chatService: mock)
        viewModel.draftText = "hello"

        await viewModel.send()

        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.messages.count == 2) // welcome + user message, no assistant reply
    }
}
