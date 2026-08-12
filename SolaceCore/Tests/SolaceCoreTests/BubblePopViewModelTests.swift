import Testing
@testable import SolaceCore

@MainActor
struct BubblePopViewModelTests {
    @Test func initialStateHasNoPoppedBubbles() {
        let viewModel = BubblePopViewModel(columns: 3, rows: 2)
        #expect(viewModel.bubbleCount == 6)
        #expect(!viewModel.isPopped(0))
        #expect(!viewModel.isComplete)
    }

    @Test func popMarksBubbleAsPopped() {
        let viewModel = BubblePopViewModel(columns: 3, rows: 2)
        viewModel.pop(at: 2)
        #expect(viewModel.isPopped(2))
        #expect(!viewModel.isPopped(0))
    }

    @Test func popIgnoresOutOfBoundsIndex() {
        let viewModel = BubblePopViewModel(columns: 3, rows: 2)
        viewModel.pop(at: -1)
        viewModel.pop(at: 6)
        #expect(!viewModel.isPopped(-1))
        #expect(!viewModel.isPopped(6))
    }

    @Test func isCompleteOnceAllBubblesPopped() {
        let viewModel = BubblePopViewModel(columns: 2, rows: 1)
        viewModel.pop(at: 0)
        #expect(!viewModel.isComplete)
        viewModel.pop(at: 1)
        #expect(viewModel.isComplete)
    }

    @Test func resetClearsAllPoppedBubbles() {
        let viewModel = BubblePopViewModel(columns: 2, rows: 1)
        viewModel.pop(at: 0)
        viewModel.pop(at: 1)

        viewModel.reset()

        #expect(!viewModel.isComplete)
        #expect(!viewModel.isPopped(0))
        #expect(!viewModel.isPopped(1))
    }
}
