import Foundation
import FirebaseFirestore
import SolaceCore

/// Firebase-backed implementation of `ResourceServicing`. Articles are
/// editorial content stored in Firestore (seeded via the console); relaxation
/// exercises are self-contained content shipped in the app, since they don't
/// need remote updates the way articles do.
final class FirestoreResourceService: ResourceServicing {
    private let firestore = Firestore.firestore()

    func fetchResources() async throws -> [ResourceItem] {
        let snapshot = try await firestore.collection("resources").getDocuments()
        return snapshot.documents.compactMap { document in
            let data = document.data()
            guard
                let title = data["title"] as? String,
                let summary = data["summary"] as? String,
                let body = data["body"] as? String,
                let category = ResourceCategory(rawValue: data["category"] as? String ?? "")
            else { return nil }
            return ResourceItem(
                id: document.documentID,
                title: title,
                summary: summary,
                body: body,
                category: category,
                tags: data["tags"] as? [String] ?? []
            )
        }
    }

    func fetchRelaxationExercises() async throws -> [RelaxationExercise] {
        RelaxationExercise.breathingExercises + RelaxationExercise.groundingExercises
    }
}
