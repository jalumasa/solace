import Foundation
import FirebaseFirestore
import SolaceCore

// Firestore's SDK type is documented as thread-safe but doesn't yet carry
// Sendable conformance itself, hence @unchecked here.
final class FirestoreMoodService: MoodServicing, @unchecked Sendable {
    private let firestore = Firestore.firestore()

    func logMood(_ mood: MoodLevel, note: String?, for userID: String) async throws {
        var data: [String: Any] = [
            "mood": mood.rawValue,
            "createdAt": FieldValue.serverTimestamp()
        ]
        if let note, !note.isEmpty {
            data["note"] = note
        }
        try await firestore.collection("users").document(userID)
            .collection("moodEntries").addDocument(data: data)
    }

    func observeMoodHistory(for userID: String) -> AsyncStream<[MoodEntry]> {
        AsyncStream { continuation in
            nonisolated(unsafe) let listener = firestore.collection("users").document(userID)
                .collection("moodEntries")
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { snapshot, _ in
                    guard let snapshot else { return }
                    continuation.yield(snapshot.documents.compactMap(Self.entry(from:)))
                }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    private static func entry(from document: QueryDocumentSnapshot) -> MoodEntry? {
        let data = document.data()
        guard
            let rawMood = data["mood"] as? Int,
            let mood = MoodLevel(rawValue: rawMood)
        else { return nil }
        return MoodEntry(
            id: document.documentID,
            mood: mood,
            note: data["note"] as? String,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}
