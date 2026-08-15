import Foundation
import FirebaseFirestore
import SolaceCore

/// Firebase-backed implementation of `AppointmentServicing`. Appointment
/// documents store both participant IDs (for querying, same idiom as
/// `Conversation`) and their display names, denormalized at request time.
final class FirestoreAppointmentService: AppointmentServicing, @unchecked Sendable {
    private let firestore = Firestore.firestore()

    func requestAppointment(
        studentID: String,
        studentName: String,
        counselorID: String,
        counselorName: String,
        scheduledAt: Date
    ) async throws -> Appointment {
        let reference = firestore.collection("appointments").document()
        try await reference.setData([
            "studentID": studentID,
            "studentName": studentName,
            "counselorID": counselorID,
            "counselorName": counselorName,
            "participantIDs": [studentID, counselorID],
            "scheduledAt": Timestamp(date: scheduledAt),
            "status": AppointmentStatus.pending.rawValue,
            "createdAt": FieldValue.serverTimestamp()
        ])
        return Appointment(
            id: reference.documentID,
            studentID: studentID,
            studentName: studentName,
            counselorID: counselorID,
            counselorName: counselorName,
            scheduledAt: scheduledAt
        )
    }

    func observeAppointments(for userID: String) -> AsyncStream<[Appointment]> {
        AsyncStream { continuation in
            nonisolated(unsafe) let listener = firestore.collection("appointments")
                .whereField("participantIDs", arrayContains: userID)
                .order(by: "scheduledAt")
                .addSnapshotListener { snapshot, _ in
                    guard let snapshot else { return }
                    continuation.yield(snapshot.documents.compactMap(Self.appointment(from:)))
                }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    func updateStatus(appointmentID: String, status: AppointmentStatus) async throws {
        try await firestore.collection("appointments").document(appointmentID).setData([
            "status": status.rawValue
        ], merge: true)
    }

    private static func appointment(from document: QueryDocumentSnapshot) -> Appointment? {
        let data = document.data()
        guard
            let studentID = data["studentID"] as? String,
            let counselorID = data["counselorID"] as? String,
            let scheduledAt = (data["scheduledAt"] as? Timestamp)?.dateValue(),
            let status = AppointmentStatus(rawValue: data["status"] as? String ?? "")
        else { return nil }
        return Appointment(
            id: document.documentID,
            studentID: studentID,
            studentName: data["studentName"] as? String ?? "Student",
            counselorID: counselorID,
            counselorName: data["counselorName"] as? String ?? "Counselor",
            scheduledAt: scheduledAt,
            status: status,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}
