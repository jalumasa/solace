import Foundation
import FirebaseFirestore
import SolaceCore

// Firestore's SDK type is documented as thread-safe but doesn't yet carry
// Sendable conformance itself, hence @unchecked here.
final class FirestoreJournalService: JournalServicing, @unchecked Sendable {
    private let firestore = Firestore.firestore()

    func addGratitudeEntry(_ text: String, for userID: String) async throws {
        try await firestore.collection("users").document(userID)
            .collection("gratitudeEntries").addDocument(data: [
                "text": text,
                "createdAt": FieldValue.serverTimestamp()
            ])
    }

    func observeGratitudeEntries(for userID: String) -> AsyncStream<[GratitudeEntry]> {
        AsyncStream { continuation in
            nonisolated(unsafe) let listener = firestore.collection("users").document(userID)
                .collection("gratitudeEntries")
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { snapshot, _ in
                    guard let snapshot else { return }
                    continuation.yield(snapshot.documents.compactMap(Self.entry(from:)))
                }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    private static func entry(from document: QueryDocumentSnapshot) -> GratitudeEntry? {
        let data = document.data()
        guard let text = data["text"] as? String else { return nil }
        return GratitudeEntry(
            id: document.documentID,
            text: text,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}
