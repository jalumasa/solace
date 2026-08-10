import Testing
@testable import SolaceCore

@MainActor
struct BreathingSessionViewModelTests {
    @Test func initialPhaseIsInhale() {
        let viewModel = BreathingSessionViewModel(pattern: .box)
        #expect(viewModel.phase == .inhale)
        #expect(viewModel.timeRemainingInPhase == 4)
    }

    @Test func tickDoesNothingWhenNotRunning() {
        let viewModel = BreathingSessionViewModel(pattern: .box)
        viewModel.tick(deltaTime: 10)
        #expect(viewModel.phase == .inhale)
        #expect(viewModel.timeRemainingInPhase == 4)
    }

    @Test func tickAdvancesThroughPhases() {
        let viewModel = BreathingSessionViewModel(pattern: .box) // 4-4-4-4
        viewModel.start()

        viewModel.tick(deltaTime: 4)
        #expect(viewModel.phase == .hold)

        viewModel.tick(deltaTime: 4)
        #expect(viewModel.phase == .exhale)

        viewModel.tick(deltaTime: 4)
        #expect(viewModel.phase == .holdAfterExhale)
        #expect(viewModel.completedCycles == 0)

        viewModel.tick(deltaTime: 4)
        #expect(viewModel.phase == .inhale)
        #expect(viewModel.completedCycles == 1)
    }

    @Test func tickHandlesMultiplePhaseTransitionsInOneCall() {
        let viewModel = BreathingSessionViewModel(pattern: .box)
        viewModel.start()

        viewModel.tick(deltaTime: 16) // exactly one full cycle

        #expect(viewModel.phase == .inhale)
        #expect(viewModel.completedCycles == 1)
    }

    @Test func fourSevenEightSkipsZeroDurationHoldAfterExhale() {
        let viewModel = BreathingSessionViewModel(pattern: .fourSevenEight) // 4-7-8-0
        viewModel.start()

        viewModel.tick(deltaTime: 4)
        #expect(viewModel.phase == .hold)
        viewModel.tick(deltaTime: 7)
        #expect(viewModel.phase == .exhale)
        viewModel.tick(deltaTime: 8)

        // holdAfterExhale has 0 duration for this pattern, so it's skipped entirely.
        #expect(viewModel.phase == .inhale)
        #expect(viewModel.completedCycles == 1)
    }

    @Test func resetReturnsToInitialState() {
        let viewModel = BreathingSessionViewModel(pattern: .box)
        viewModel.start()
        viewModel.tick(deltaTime: 20)

        viewModel.reset()

        #expect(!viewModel.isRunning)
        #expect(viewModel.phase == .inhale)
        #expect(viewModel.completedCycles == 0)
        #expect(viewModel.timeRemainingInPhase == 4)
    }
}
