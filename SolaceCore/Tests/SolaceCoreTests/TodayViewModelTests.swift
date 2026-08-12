import Testing
import Foundation
@testable import SolaceCore

@MainActor
struct TodayViewModelTests {
    private func makeUser() -> User {
        User(id: "u1", email: "a@b.com", displayName: "Alex", role: .student)
    }

    @Test func greetingIncludesDisplayName() {
        let viewModel = TodayViewModel(currentUser: makeUser(), moodService: MockMoodService())
        #expect(viewModel.greeting.contains("Alex"))
    }

    @Test func hasNotCheckedInTodayWithNoHistory() {
        let viewModel = TodayViewModel(currentUser: makeUser(), moodService: MockMoodService())
        #expect(!viewModel.hasCheckedInToday)
        #expect(viewModel.streak == 0)
    }

    @Test func hasCheckedInTodayAfterTodaysEntry() async {
        let mock = MockMoodService()
        let viewModel = TodayViewModel(currentUser: makeUser(), moodService: mock)
        let entry = MoodEntry(id: "1", mood: .good, createdAt: Date())

        mock.emit([entry])
        await allowStreamDelivery()

        #expect(viewModel.hasCheckedInToday)
        #expect(viewModel.streak == 1)
    }

    @Test func streakCountsConsecutiveDaysEndingYesterday() async {
        let mock = MockMoodService()
        let viewModel = TodayViewModel(currentUser: makeUser(), moodService: mock)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

        mock.emit([
            MoodEntry(id: "1", mood: .good, createdAt: yesterday),
            MoodEntry(id: "2", mood: .okay, createdAt: twoDaysAgo)
        ])
        await allowStreamDelivery()

        #expect(!viewModel.hasCheckedInToday)
        #expect(viewModel.streak == 2)
    }

    @Test func streakBreaksOnGap() async {
        let mock = MockMoodService()
        let viewModel = TodayViewModel(currentUser: makeUser(), moodService: mock)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!

        mock.emit([MoodEntry(id: "1", mood: .good, createdAt: threeDaysAgo)])
        await allowStreamDelivery()

        #expect(viewModel.streak == 0)
    }

    @Test func logMoodSuccessCallsService() async {
        let mock = MockMoodService()
        let viewModel = TodayViewModel(currentUser: makeUser(), moodService: mock)

        await viewModel.logMood(.great, note: "Good day")

        #expect(mock.loggedMoods.count == 1)
        #expect(mock.loggedMoods.first?.mood == .great)
        #expect(mock.loggedMoods.first?.note == "Good day")
        #expect(mock.loggedMoods.first?.userID == "u1")
        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.isSubmittingMood)
    }

    @Test func logMoodFailureSetsErrorMessage() async {
        let mock = MockMoodService()
        mock.logMoodError = TestError()
        let viewModel = TodayViewModel(currentUser: makeUser(), moodService: mock)

        await viewModel.logMood(.bad)

        #expect(viewModel.errorMessage != nil)
    }
}
