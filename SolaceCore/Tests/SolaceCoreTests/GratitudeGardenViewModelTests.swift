import Testing
@testable import SolaceCore

@MainActor
struct GratitudeGardenViewModelTests {
    @Test func stageProgressesWithEntryCount() {
        #expect(GardenStage.stage(forEntryCount: 0) == .seed)
        #expect(GardenStage.stage(forEntryCount: 2) == .seed)
        #expect(GardenStage.stage(forEntryCount: 3) == .sprout)
        #expect(GardenStage.stage(forEntryCount: 6) == .sprout)
        #expect(GardenStage.stage(forEntryCount: 7) == .bloom)
        #expect(GardenStage.stage(forEntryCount: 14) == .bloom)
        #expect(GardenStage.stage(forEntryCount: 15) == .flourishing)
    }

    @Test func stageReflectsObservedEntries() async {
        let mock = MockJournalService()
        let viewModel = GratitudeGardenViewModel(currentUserID: "u1", journalService: mock)
        #expect(viewModel.stage == .seed)

        let entries = (1...5).map { GratitudeEntry(id: "\($0)", text: "thing \($0)") }
        mock.emit(entries)
        await allowStreamDelivery()

        #expect(viewModel.entries.count == 5)
        #expect(viewModel.stage == .sprout)
    }

    @Test func addEntryTrimsAndClearsDraftOnSuccess() async {
        let mock = MockJournalService()
        let viewModel = GratitudeGardenViewModel(currentUserID: "u1", journalService: mock)
        viewModel.draftText = "  my roommate  "

        await viewModel.addEntry()

        #expect(viewModel.draftText == "")
        #expect(mock.addedEntries.count == 1)
        #expect(mock.addedEntries.first?.text == "my roommate")
        #expect(mock.addedEntries.first?.userID == "u1")
    }

    @Test func addEntryIgnoresBlankText() async {
        let mock = MockJournalService()
        let viewModel = GratitudeGardenViewModel(currentUserID: "u1", journalService: mock)
        viewModel.draftText = "   "

        await viewModel.addEntry()

        #expect(mock.addedEntries.isEmpty)
    }

    @Test func addEntryFailureSetsErrorAndKeepsDraft() async {
        let mock = MockJournalService()
        mock.addEntryError = TestError()
        let viewModel = GratitudeGardenViewModel(currentUserID: "u1", journalService: mock)
        viewModel.draftText = "sunshine"

        await viewModel.addEntry()

        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.draftText == "sunshine")
    }
}
