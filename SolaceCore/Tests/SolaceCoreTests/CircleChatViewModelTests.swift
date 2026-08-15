import Testing
@testable import SolaceCore

@MainActor
struct CircleChatViewModelTests {
    private func makeUser() -> User {
        User(id: "u1", email: "a@b.com", displayName: "Alex", role: .student)
    }

    @Test func observesMessages() async {
        let mock = MockCircleService()
        let viewModel = CircleChatViewModel(circleID: "circle1", currentUser: makeUser(), circleService: mock)
        let message = CircleMessage(id: "m1", circleID: "circle1", senderID: "u1", senderName: "Alex", text: "hi")

        mock.emitMessages([message])
        await allowStreamDelivery()

        #expect(viewModel.messages == [message])
    }

    @Test func sendTrimsAndClearsDraftOnSuccess() async {
        let mock = MockCircleService()
        let viewModel = CircleChatViewModel(circleID: "circle1", currentUser: makeUser(), circleService: mock)
        viewModel.draftText = "  hello there  "

        await viewModel.send()

        #expect(viewModel.draftText == "")
        #expect(mock.sentMessages.count == 1)
        #expect(mock.sentMessages.first?.text == "hello there")
        #expect(mock.sentMessages.first?.circleID == "circle1")
        #expect(mock.sentMessages.first?.senderID == "u1")
        #expect(mock.sentMessages.first?.senderName == "Alex")
    }

    @Test func sendDoesNothingForBlankText() async {
        let mock = MockCircleService()
        let viewModel = CircleChatViewModel(circleID: "circle1", currentUser: makeUser(), circleService: mock)
        viewModel.draftText = "   "

        await viewModel.send()

        #expect(mock.sentMessages.isEmpty)
    }

    @Test func sendFailureRestoresDraftAndSetsError() async {
        let mock = MockCircleService()
        mock.sendMessageError = TestError()
        let viewModel = CircleChatViewModel(circleID: "circle1", currentUser: makeUser(), circleService: mock)
        viewModel.draftText = "hello"

        await viewModel.send()

        #expect(viewModel.draftText == "hello")
        #expect(viewModel.errorMessage != nil)
        #expect(mock.sentMessages.isEmpty)
    }

    @Test func isFromCurrentUser() {
        let mock = MockCircleService()
        let viewModel = CircleChatViewModel(circleID: "circle1", currentUser: makeUser(), circleService: mock)
        let mine = CircleMessage(id: "1", circleID: "circle1", senderID: "u1", senderName: "Alex", text: "hi")
        let theirs = CircleMessage(id: "2", circleID: "circle1", senderID: "u2", senderName: "Jamie", text: "hey")

        #expect(viewModel.isFromCurrentUser(mine))
        #expect(!viewModel.isFromCurrentUser(theirs))
    }
}
