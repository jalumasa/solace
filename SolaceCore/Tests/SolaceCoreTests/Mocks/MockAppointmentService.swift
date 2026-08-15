import Foundation
@testable import SolaceCore

final class MockAppointmentService: AppointmentServicing, @unchecked Sendable {
    var requestAppointmentResult: Result<Appointment, Error> = .failure(TestError())
    var updateStatusError: Error?
    private(set) var updatedStatuses: [(appointmentID: String, status: AppointmentStatus)] = []

    private let appointmentsStream: AsyncStream<[Appointment]>
    private let appointmentsContinuation: AsyncStream<[Appointment]>.Continuation

    init() {
        (appointmentsStream, appointmentsContinuation) = AsyncStream<[Appointment]>.makeStream()
    }

    func requestAppointment(
        studentID: String,
        studentName: String,
        counselorID: String,
        counselorName: String,
        scheduledAt: Date
    ) async throws -> Appointment {
        try requestAppointmentResult.get()
    }

    func observeAppointments(for userID: String) -> AsyncStream<[Appointment]> {
        appointmentsStream
    }

    func updateStatus(appointmentID: String, status: AppointmentStatus) async throws {
        if let updateStatusError {
            throw updateStatusError
        }
        updatedStatuses.append((appointmentID, status))
    }

    func emit(_ appointments: [Appointment]) {
        appointmentsContinuation.yield(appointments)
    }
}
