import Testing
@testable import SolaceCore

@MainActor
struct CircleListViewModelTests {
    @Test func myCirclesAndAvailableCirclesSplitByMembership() async {
        let mock = MockCircleService()
        let viewModel = CircleListViewModel(currentUserID: "u1", circleService: mock)
        let joined = SupportCircle(id: "c1", name: "Exam Stress", topicDescription: "Support during exams", memberIDs: ["u1"])
        let notJoined = SupportCircle(id: "c2", name: "Homesickness", topicDescription: "Adjusting away from home", memberIDs: [])

        mock.emitCircles([joined, notJoined])
        await allowStreamDelivery()

        #expect(viewModel.myCircles == [joined])
        #expect(viewModel.availableCircles == [notJoined])
    }

    @Test func joinCallsServiceWithCurrentUserID() async {
        let mock = MockCircleService()
        let viewModel = CircleListViewModel(currentUserID: "u1", circleService: mock)
        let circle = SupportCircle(id: "c1", name: "Exam Stress", topicDescription: "Support during exams")

        await viewModel.join(circle)

        #expect(mock.joined.count == 1)
        #expect(mock.joined.first?.circleID == "c1")
        #expect(mock.joined.first?.userID == "u1")
    }

    @Test func leaveCallsServiceWithCurrentUserID() async {
        let mock = MockCircleService()
        let viewModel = CircleListViewModel(currentUserID: "u1", circleService: mock)
        let circle = SupportCircle(id: "c1", name: "Exam Stress", topicDescription: "Support during exams", memberIDs: ["u1"])

        await viewModel.leave(circle)

        #expect(mock.left.count == 1)
        #expect(mock.left.first?.circleID == "c1")
        #expect(mock.left.first?.userID == "u1")
    }

    @Test func joinFailureSetsErrorMessage() async {
        let mock = MockCircleService()
        mock.joinError = TestError()
        let viewModel = CircleListViewModel(currentUserID: "u1", circleService: mock)
        let circle = SupportCircle(id: "c1", name: "Exam Stress", topicDescription: "Support during exams")

        await viewModel.join(circle)

        #expect(viewModel.errorMessage != nil)
    }
}
