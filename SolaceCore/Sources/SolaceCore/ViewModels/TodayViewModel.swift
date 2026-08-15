import Foundation
import Observation

@MainActor
@Observable
public final class TodayViewModel {
    public let currentUser: User
    public private(set) var moodHistory: [MoodEntry] = []
    public private(set) var gratitudeEntries: [GratitudeEntry] = []
    public private(set) var isSubmittingMood = false
    public private(set) var errorMessage: String?

    private let moodService: MoodServicing
    private let journalService: JournalServicing
    @ObservationIgnored
    private nonisolated(unsafe) var moodObservationTask: Task<Void, Never>?
    @ObservationIgnored
    private nonisolated(unsafe) var journalObservationTask: Task<Void, Never>?

    public init(currentUser: User, moodService: MoodServicing, journalService: JournalServicing) {
        self.currentUser = currentUser
        self.moodService = moodService
        self.journalService = journalService
        moodObservationTask = Task { [weak self] in
            guard let self else { return }
            for await history in moodService.observeMoodHistory(for: currentUser.id) {
                self.moodHistory = history
            }
        }
        journalObservationTask = Task { [weak self] in
            guard let self else { return }
            for await entries in journalService.observeGratitudeEntries(for: currentUser.id) {
                self.gratitudeEntries = entries
            }
        }
    }

    deinit {
        moodObservationTask?.cancel()
        journalObservationTask?.cancel()
    }

    public var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay: String
        switch hour {
        case 0..<12: timeOfDay = "morning"
        case 12..<17: timeOfDay = "afternoon"
        default: timeOfDay = "evening"
        }
        return "Good \(timeOfDay), \(currentUser.displayName)"
    }

    public var hasCheckedInToday: Bool {
        guard let mostRecent = moodHistory.first else { return false }
        return Calendar.current.isDateInToday(mostRecent.createdAt)
    }

    /// Consecutive calendar days (ending today or yesterday — a missed today
    /// doesn't zero out yesterday's progress until tomorrow) with at least
    /// one mood check-in or journal entry.
    public var streak: Int {
        let calendar = Calendar.current
        var days = Set(moodHistory.map { calendar.startOfDay(for: $0.createdAt) })
        days.formUnion(gratitudeEntries.map { calendar.startOfDay(for: $0.createdAt) })
        guard !days.isEmpty else { return 0 }

        var cursor = calendar.startOfDay(for: Date())
        if !days.contains(cursor) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor), days.contains(yesterday) else {
                return 0
            }
            cursor = yesterday
        }

        var streakCount = 0
        while days.contains(cursor) {
            streakCount += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streakCount
    }

    public func logMood(_ mood: MoodLevel, note: String? = nil) async {
        errorMessage = nil
        isSubmittingMood = true
        defer { isSubmittingMood = false }
        do {
            try await moodService.logMood(mood, note: note, for: currentUser.id)
        } catch {
            errorMessage = "Couldn't save your check-in. Please try again."
        }
    }
}
