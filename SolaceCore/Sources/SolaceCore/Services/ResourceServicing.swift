import Foundation

/// Abstracts the curated content library (articles + relaxation exercises).
public protocol ResourceServicing: Sendable {
    func fetchResources() async throws -> [ResourceItem]
    func fetchRelaxationExercises() async throws -> [RelaxationExercise]
}
