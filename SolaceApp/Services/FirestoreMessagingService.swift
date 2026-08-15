import Foundation
import FirebaseFirestore
import SolaceCore

/// Firebase-backed implementation of `MessagingServicing`. Conversation
/// documents store both participant IDs (for querying) and their display
/// names (denormalized at creation time) so the conversation list doesn't
/// need a separate lookup per row.
// Firestore's SDK type is documented as thread-safe but doesn't yet carry
// Sendable conformance itself, hence @unchecked here.
final class FirestoreMessagingService: MessagingServicing, @unchecked Sendable {
    private let firestore = Firestore.firestore()

    func fetchCounselors() async throws -> [User] {
        let snapshot = try await firestore.collection("users")
            .whereField("role", isEqualTo: Role.counselor.rawValue)
            .getDocuments()
        return snapshot.documents.compactMap(Self.user(from:))
    }

    func startConversation(
        studentID: String,
        studentName: String,
        counselorID: String,
        counselorName: String
    ) async throws -> Conversation {
        // Filtered by participantIDs (not studentID/counselorID) so the query
        // shape matches what the security rule can prove safe — a compound
        // equality filter on studentID/counselorID can't be verified against
        // an `auth.uid in participantIDs` rule and gets rejected outright.
        let existing = try await firestore.collection("conversations")
            .whereField("participantIDs", arrayContains: studentID)
            .getDocuments()

        if let document = existing.documents.first(where: { ($0.data()["counselorID"] as? String) == counselorID }),
           let conversation = Self.conversation(from: document) {
            return conversation
        }

        let reference = firestore.collection("conversations").document()
        try await reference.setData([
            "studentID": studentID,
            "studentName": studentName,
            "counselorID": counselorID,
            "counselorName": counselorName,
            "participantIDs": [studentID, counselorID],
            "createdAt": FieldValue.serverTimestamp()
        ])
        return Conversation(
            id: reference.documentID,
            studentID: studentID,
            studentName: studentName,
            counselorID: counselorID,
            counselorName: counselorName
        )
    }

    func observeConversations(for userID: String) -> AsyncStream<[Conversation]> {
        AsyncStream { continuation in
            nonisolated(unsafe) let listener = firestore.collection("conversations")
                .whereField("participantIDs", arrayContains: userID)
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { snapshot, _ in
                    guard let snapshot else { return }
                    continuation.yield(snapshot.documents.compactMap(Self.conversation(from:)))
                }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    func observeMessages(conversationID: String) -> AsyncStream<[Message]> {
        AsyncStream { continuation in
            nonisolated(unsafe) let listener = firestore.collection("conversations").document(conversationID)
                .collection("messages")
                .order(by: "sentAt")
                .addSnapshotListener { snapshot, _ in
                    guard let snapshot else { return }
                    let messages = snapshot.documents.compactMap { Self.message(from: $0, conversationID: conversationID) }
                    continuation.yield(messages)
                }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    func sendMessage(conversationID: String, senderID: String, text: String) async throws {
        let conversationRef = firestore.collection("conversations").document(conversationID)
        try await conversationRef.collection("messages").addDocument(data: [
            "senderID": senderID,
            "text": text,
            "sentAt": FieldValue.serverTimestamp()
        ])
        try await conversationRef.setData([
            "lastMessageText": text,
            "lastMessageAt": FieldValue.serverTimestamp()
        ], merge: true)
    }

    private static func user(from document: QueryDocumentSnapshot) -> User? {
        let data = document.data()
        guard let role = Role(rawValue: data["role"] as? String ?? "") else { return nil }
        return User(
            id: document.documentID,
            email: data["email"] as? String ?? "",
            displayName: data["displayName"] as? String ?? "",
            role: role,
            bio: data["bio"] as? String,
            major: data["major"] as? String,
            academicYear: (data["academicYear"] as? String).flatMap(AcademicYear.init(rawValue:)),
            age: data["age"] as? Int
        )
    }

    private static func conversation(from document: QueryDocumentSnapshot) -> Conversation? {
        let data = document.data()
        guard
            let studentID = data["studentID"] as? String,
            let counselorID = data["counselorID"] as? String
        else { return nil }
        return Conversation(
            id: document.documentID,
            studentID: studentID,
            studentName: data["studentName"] as? String ?? "Student",
            counselorID: counselorID,
            counselorName: data["counselorName"] as? String ?? "Counselor",
            lastMessageText: data["lastMessageText"] as? String,
            lastMessageAt: (data["lastMessageAt"] as? Timestamp)?.dateValue(),
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }

    private static func message(from document: QueryDocumentSnapshot, conversationID: String) -> Message? {
        let data = document.data()
        guard
            let senderID = data["senderID"] as? String,
            let text = data["text"] as? String
        else { return nil }
        return Message(
            id: document.documentID,
            conversationID: conversationID,
            senderID: senderID,
            text: text,
            sentAt: (data["sentAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}
