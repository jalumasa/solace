import Foundation

/// Abstracts mood check-in persistence. Implementations should emit history
/// ordered most-recent-first, since `TodayViewModel` reads `.first` as "today's"
/// entry when computing streaks and check-in state.
public protocol MoodServicing: Sendable {
    func logMood(_ mood: MoodLevel, note: String?, for userID: String) async throws
    func observeMoodHistory(for userID: String) -> AsyncStream<[MoodEntry]>
}
