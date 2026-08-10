import Testing
@testable import SolaceCore

@MainActor
struct ChatViewModelTests {
    @Test func observesMessages() async {
        let mock = MockMessagingService()
        let viewModel = ChatViewModel(conversationID: "c1", currentUserID: "u1", messagingService: mock)
        let message = Message(id: "m1", conversationID: "c1", senderID: "u1", text: "hi")

        mock.emitMessages([message])
        await allowStreamDelivery()

        #expect(viewModel.messages == [message])
    }

    @Test func sendTrimsAndClearsDraftOnSuccess() async {
        let mock = MockMessagingService()
        let viewModel = ChatViewModel(conversationID: "c1", currentUserID: "u1", messagingService: mock)
        viewModel.draftText = "  hello there  "

        await viewModel.send()

        #expect(viewModel.draftText == "")
        #expect(mock.sentMessages.count == 1)
        #expect(mock.sentMessages.first?.text == "hello there")
        #expect(mock.sentMessages.first?.conversationID == "c1")
        #expect(mock.sentMessages.first?.senderID == "u1")
    }

    @Test func sendDoesNothingForBlankText() async {
        let mock = MockMessagingService()
        let viewModel = ChatViewModel(conversationID: "c1", currentUserID: "u1", messagingService: mock)
        viewModel.draftText = "   "

        await viewModel.send()

        #expect(mock.sentMessages.isEmpty)
    }

    @Test func sendFailureRestoresDraftAndSetsError() async {
        let mock = MockMessagingService()
        mock.sendMessageError = TestError()
        let viewModel = ChatViewModel(conversationID: "c1", currentUserID: "u1", messagingService: mock)
        viewModel.draftText = "hello"

        await viewModel.send()

        #expect(viewModel.draftText == "hello")
        #expect(viewModel.errorMessage != nil)
        #expect(mock.sentMessages.isEmpty)
    }

    @Test func isFromCurrentUser() {
        let mock = MockMessagingService()
        let viewModel = ChatViewModel(conversationID: "c1", currentUserID: "u1", messagingService: mock)
        let mine = Message(id: "1", conversationID: "c1", senderID: "u1", text: "hi")
        let theirs = Message(id: "2", conversationID: "c1", senderID: "u2", text: "hey")

        #expect(viewModel.isFromCurrentUser(mine))
        #expect(!viewModel.isFromCurrentUser(theirs))
    }
}
