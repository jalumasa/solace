import Foundation
@testable import SolaceCore

final class MockMoodService: MoodServicing, @unchecked Sendable {
    var logMoodError: Error?
    private(set) var loggedMoods: [(mood: MoodLevel, note: String?, userID: String)] = []

    private let stream: AsyncStream<[MoodEntry]>
    private let continuation: AsyncStream<[MoodEntry]>.Continuation

    init() {
        (stream, continuation) = AsyncStream<[MoodEntry]>.makeStream()
    }

    func logMood(_ mood: MoodLevel, note: String?, for userID: String) async throws {
        if let logMoodError {
            throw logMoodError
        }
        loggedMoods.append((mood, note, userID))
    }

    func observeMoodHistory(for userID: String) -> AsyncStream<[MoodEntry]> {
        stream
    }

    func emit(_ entries: [MoodEntry]) {
        continuation.yield(entries)
    }
}
