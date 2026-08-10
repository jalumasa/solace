import Foundation
@testable import SolaceCore

final class MockResourceService: ResourceServicing, @unchecked Sendable {
    var resources: [ResourceItem] = []
    var relaxationExercises: [RelaxationExercise] = []
    var shouldThrow = false

    func fetchResources() async throws -> [ResourceItem] {
        if shouldThrow { throw TestError() }
        return resources
    }

    func fetchRelaxationExercises() async throws -> [RelaxationExercise] {
        if shouldThrow { throw TestError() }
        return relaxationExercises
    }
}
