import Testing
@testable import SolaceCore

@MainActor
struct FocusRingsViewModelTests {
    @Test func tickDoesNothingWhenNotRunning() {
        let viewModel = FocusRingsViewModel(growDuration: 2, readyWindow: 1, settleDuration: 0.5)
        viewModel.tick(deltaTime: 5)
        #expect(viewModel.phase == .growing)
        #expect(viewModel.progress == 0)
    }

    @Test func ringBecomesReadyAfterGrowDuration() {
        let viewModel = FocusRingsViewModel(growDuration: 2, readyWindow: 1, settleDuration: 0.5)
        viewModel.start()

        viewModel.tick(deltaTime: 1)
        #expect(viewModel.phase == .growing)
        #expect(viewModel.progress == 0.5)

        viewModel.tick(deltaTime: 1)
        #expect(viewModel.phase == .ready)
    }

    @Test func tapWhileReadyIncrementsCalmStreakAndSettles() {
        let viewModel = FocusRingsViewModel(growDuration: 2, readyWindow: 1, settleDuration: 0.5)
        viewModel.start()
        viewModel.tick(deltaTime: 2)
        #expect(viewModel.phase == .ready)

        viewModel.tap()

        #expect(viewModel.calmStreak == 1)
        #expect(viewModel.phase == .settling)
    }

    @Test func tapWhileGrowingIsIgnored() {
        let viewModel = FocusRingsViewModel(growDuration: 2, readyWindow: 1, settleDuration: 0.5)
        viewModel.start()

        viewModel.tap()

        #expect(viewModel.calmStreak == 0)
        #expect(viewModel.phase == .growing)
    }

    @Test func missingTheReadyWindowIsNotPenalized() {
        let viewModel = FocusRingsViewModel(growDuration: 2, readyWindow: 1, settleDuration: 0.5)
        viewModel.start()
        viewModel.tick(deltaTime: 2) // now ready
        viewModel.tick(deltaTime: 1) // window missed, no tap

        #expect(viewModel.phase == .settling)
        #expect(viewModel.calmStreak == 0)

        viewModel.tick(deltaTime: 0.5) // settle finishes
        #expect(viewModel.phase == .growing)
    }

    @Test func resetReturnsToInitialState() {
        let viewModel = FocusRingsViewModel(growDuration: 2, readyWindow: 1, settleDuration: 0.5)
        viewModel.start()
        viewModel.tick(deltaTime: 2)
        viewModel.tap()

        viewModel.reset()

        #expect(!viewModel.isRunning)
        #expect(viewModel.phase == .growing)
        #expect(viewModel.progress == 0)
        #expect(viewModel.calmStreak == 0)
    }
}
