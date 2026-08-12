import Foundation

/// Abstracts gratitude-journal persistence for the Gratitude Garden activity.
public protocol JournalServicing: Sendable {
    func addGratitudeEntry(_ text: String, for userID: String) async throws
    func observeGratitudeEntries(for userID: String) -> AsyncStream<[GratitudeEntry]>
}
