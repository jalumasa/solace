import Foundation
@testable import SolaceCore

final class MockJournalService: JournalServicing, @unchecked Sendable {
    var addEntryError: Error?
    private(set) var addedEntries: [(text: String, userID: String)] = []

    private let stream: AsyncStream<[GratitudeEntry]>
    private let continuation: AsyncStream<[GratitudeEntry]>.Continuation

    init() {
        (stream, continuation) = AsyncStream<[GratitudeEntry]>.makeStream()
    }

    func addGratitudeEntry(_ text: String, for userID: String) async throws {
        if let addEntryError {
            throw addEntryError
        }
        addedEntries.append((text, userID))
    }

    func observeGratitudeEntries(for userID: String) -> AsyncStream<[GratitudeEntry]> {
        stream
    }

    func emit(_ entries: [GratitudeEntry]) {
        continuation.yield(entries)
    }
}
