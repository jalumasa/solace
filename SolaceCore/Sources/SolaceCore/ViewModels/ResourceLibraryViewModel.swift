import Foundation
import Observation

@MainActor
@Observable
public final class ResourceLibraryViewModel {
    public private(set) var resources: [ResourceItem] = []
    public private(set) var relaxationExercises: [RelaxationExercise] = []
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?
    public var selectedCategory: ResourceCategory?

    private let resourceService: ResourceServicing

    public init(resourceService: ResourceServicing) {
        self.resourceService = resourceService
    }

    public func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let resourcesResult = resourceService.fetchResources()
            async let exercisesResult = resourceService.fetchRelaxationExercises()
            resources = try await resourcesResult
            relaxationExercises = try await exercisesResult
        } catch {
            errorMessage = "Couldn't load resources. Please try again."
        }
    }

    public var filteredResources: [ResourceItem] {
        guard let selectedCategory else { return resources }
        return resources.filter { $0.category == selectedCategory }
    }
}
