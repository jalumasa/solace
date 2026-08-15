import Foundation

/// Abstracts appointment scheduling between students and counselors.
public protocol AppointmentServicing: Sendable {
    func requestAppointment(
        studentID: String,
        studentName: String,
        counselorID: String,
        counselorName: String,
        scheduledAt: Date
    ) async throws -> Appointment

    func observeAppointments(for userID: String) -> AsyncStream<[Appointment]>

    func updateStatus(appointmentID: String, status: AppointmentStatus) async throws
}
