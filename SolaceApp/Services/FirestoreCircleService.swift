import Foundation
import FirebaseFirestore
import SolaceCore

/// Firebase-backed implementation of `CircleServicing`. Circles themselves
/// are seeded via the console (see `firestore.rules` — create/delete are
/// disallowed from the client); this service only supports browsing,
/// joining/leaving, and posting within a circle.
final class FirestoreCircleService: CircleServicing, @unchecked Sendable {
    private let firestore = Firestore.firestore()

    func observeCircles() -> AsyncStream<[SupportCircle]> {
        AsyncStream { continuation in
            nonisolated(unsafe) let listener = firestore.collection("circles")
                .order(by: "name")
                .addSnapshotListener { snapshot, _ in
                    guard let snapshot else { return }
                    continuation.yield(snapshot.documents.compactMap(Self.circle(from:)))
                }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    func join(circleID: String, userID: String) async throws {
        try await firestore.collection("circles").document(circleID).setData([
            "memberIDs": FieldValue.arrayUnion([userID])
        ], merge: true)
    }

    func leave(circleID: String, userID: String) async throws {
        try await firestore.collection("circles").document(circleID).setData([
            "memberIDs": FieldValue.arrayRemove([userID])
        ], merge: true)
    }

    func observeMessages(circleID: String) -> AsyncStream<[CircleMessage]> {
        AsyncStream { continuation in
            nonisolated(unsafe) let listener = firestore.collection("circles").document(circleID)
                .collection("messages")
                .order(by: "sentAt")
                .addSnapshotListener { snapshot, _ in
                    guard let snapshot else { return }
                    let messages = snapshot.documents.compactMap { Self.message(from: $0, circleID: circleID) }
                    continuation.yield(messages)
                }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    func sendMessage(circleID: String, senderID: String, senderName: String, text: String) async throws {
        try await firestore.collection("circles").document(circleID).collection("messages").addDocument(data: [
            "senderID": senderID,
            "senderName": senderName,
            "text": text,
            "sentAt": FieldValue.serverTimestamp()
        ])
    }

    private static func circle(from document: QueryDocumentSnapshot) -> SupportCircle? {
        let data = document.data()
        guard let name = data["name"] as? String else { return nil }
        return SupportCircle(
            id: document.documentID,
            name: name,
            topicDescription: data["topicDescription"] as? String ?? "",
            memberIDs: data["memberIDs"] as? [String] ?? [],
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }

    private static func message(from document: QueryDocumentSnapshot, circleID: String) -> CircleMessage? {
        let data = document.data()
        guard
            let senderID = data["senderID"] as? String,
            let text = data["text"] as? String
        else { return nil }
        return CircleMessage(
            id: document.documentID,
            circleID: circleID,
            senderID: senderID,
            senderName: data["senderName"] as? String ?? "Member",
            text: text,
            sentAt: (data["sentAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}
