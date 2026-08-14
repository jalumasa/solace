import Testing
@testable import SolaceCore

@MainActor
struct WorryJarViewModelTests {
    @Test func cannotReleaseBlankText() {
        let viewModel = WorryJarViewModel()
        #expect(!viewModel.canRelease)
        viewModel.draftText = "   "
        #expect(!viewModel.canRelease)
    }

    @Test func releaseStartsAnimationWithoutIncrementingYet() {
        let viewModel = WorryJarViewModel()
        viewModel.draftText = "Midterms"

        viewModel.release()

        #expect(viewModel.isReleasing)
        #expect(viewModel.releasedCount == 0)
        #expect(viewModel.draftText == "Midterms") // still visible mid-animation
    }

    @Test func finishReleaseIncrementsCountAndClearsDraft() {
        let viewModel = WorryJarViewModel()
        viewModel.draftText = "Midterms"
        viewModel.release()

        viewModel.finishRelease()

        #expect(!viewModel.isReleasing)
        #expect(viewModel.releasedCount == 1)
        #expect(viewModel.draftText == "")
    }

    @Test func releaseIgnoredWhileAlreadyReleasing() {
        let viewModel = WorryJarViewModel()
        viewModel.draftText = "Midterms"
        viewModel.release()

        viewModel.draftText = "Something else"
        viewModel.release()

        #expect(viewModel.draftText == "Something else")
        viewModel.finishRelease()
        #expect(viewModel.releasedCount == 1)
    }

    @Test func multipleReleasesAccumulateCount() {
        let viewModel = WorryJarViewModel()

        viewModel.draftText = "One"
        viewModel.release()
        viewModel.finishRelease()

        viewModel.draftText = "Two"
        viewModel.release()
        viewModel.finishRelease()

        #expect(viewModel.releasedCount == 2)
    }
}
