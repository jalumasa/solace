import Testing
@testable import SolaceCore

@MainActor
struct ResourceLibraryViewModelTests {
    private func makeResource(id: String, category: ResourceCategory) -> ResourceItem {
        ResourceItem(id: id, title: id, summary: "summary", body: "body", category: category)
    }

    @Test func loadPopulatesResourcesAndExercises() async {
        let mock = MockResourceService()
        mock.resources = [makeResource(id: "r1", category: .anxiety)]
        mock.relaxationExercises = RelaxationExercise.breathingExercises
        let viewModel = ResourceLibraryViewModel(resourceService: mock)

        await viewModel.load()

        #expect(viewModel.resources.count == 1)
        #expect(viewModel.relaxationExercises.count == RelaxationExercise.breathingExercises.count)
        #expect(!viewModel.isLoading)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func loadFailureSetsErrorMessage() async {
        let mock = MockResourceService()
        mock.shouldThrow = true
        let viewModel = ResourceLibraryViewModel(resourceService: mock)

        await viewModel.load()

        #expect(viewModel.errorMessage != nil)
    }

    @Test func filteredResourcesRespectsSelectedCategory() async {
        let mock = MockResourceService()
        mock.resources = [
            makeResource(id: "r1", category: .anxiety),
            makeResource(id: "r2", category: .sleep)
        ]
        let viewModel = ResourceLibraryViewModel(resourceService: mock)
        await viewModel.load()

        #expect(viewModel.filteredResources.count == 2)

        viewModel.selectedCategory = .sleep

        #expect(viewModel.filteredResources.map(\.id) == ["r2"])
    }
}
