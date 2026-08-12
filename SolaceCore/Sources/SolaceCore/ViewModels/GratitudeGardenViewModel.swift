import Foundation
import Observation

@MainActor
@Observable
public final class GratitudeGardenViewModel {
    public let currentUserID: String
    public private(set) var entries: [GratitudeEntry] = []
    public var draftText: String = ""
    public private(set) var isSaving = false
    public private(set) var errorMessage: String?

    private let journalService: JournalServicing
    @ObservationIgnored
    private nonisolated(unsafe) var observationTask: Task<Void, Never>?

    public init(currentUserID: String, journalService: JournalServicing) {
        self.currentUserID = currentUserID
        self.journalService = journalService
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await entries in journalService.observeGratitudeEntries(for: currentUserID) {
                self.entries = entries
            }
        }
    }

    deinit {
        observationTask?.cancel()
    }

    public var stage: GardenStage {
        GardenStage.stage(forEntryCount: entries.count)
    }

    public func addEntry() async {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSaving else { return }
        errorMessage = nil
        isSaving = true
        defer { isSaving = false }
        do {
            try await journalService.addGratitudeEntry(text, for: currentUserID)
            draftText = ""
        } catch {
            errorMessage = "Couldn't save that entry. Please try again."
        }
    }
}
