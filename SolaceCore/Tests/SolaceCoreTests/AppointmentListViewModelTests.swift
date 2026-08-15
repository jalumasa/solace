import Testing
import Foundation
@testable import SolaceCore

@MainActor
struct AppointmentListViewModelTests {
    private func makeStudent() -> User {
        User(id: "s1", email: "student@b.com", displayName: "Alex", role: .student)
    }

    private func makeCounselor() -> User {
        User(id: "c1", email: "counselor@b.com", displayName: "Dr. Chen", role: .counselor)
    }

    @Test func loadCounselorsNoOpsForCounselorRole() async {
        let messaging = MockMessagingService()
        messaging.counselors = [makeCounselor()]
        let viewModel = AppointmentListViewModel(
            currentUser: makeCounselor(),
            appointmentService: MockAppointmentService(),
            messagingService: messaging
        )

        await viewModel.loadCounselors()

        #expect(viewModel.counselors.isEmpty)
    }

    @Test func loadCounselorsPopulatesForStudent() async {
        let messaging = MockMessagingService()
        messaging.counselors = [makeCounselor()]
        let viewModel = AppointmentListViewModel(
            currentUser: makeStudent(),
            appointmentService: MockAppointmentService(),
            messagingService: messaging
        )

        await viewModel.loadCounselors()

        #expect(viewModel.counselors.count == 1)
    }

    @Test func requestAppointmentCallsServiceForStudent() async {
        let appointmentService = MockAppointmentService()
        let appointment = Appointment(
            id: "a1",
            studentID: "s1",
            studentName: "Alex",
            counselorID: "c1",
            counselorName: "Dr. Chen",
            scheduledAt: Date()
        )
        appointmentService.requestAppointmentResult = .success(appointment)
        let viewModel = AppointmentListViewModel(
            currentUser: makeStudent(),
            appointmentService: appointmentService,
            messagingService: MockMessagingService()
        )

        await viewModel.requestAppointment(with: makeCounselor(), at: Date())

        #expect(viewModel.errorMessage == nil)
    }

    @Test func respondIgnoredForStudentRole() async {
        let appointmentService = MockAppointmentService()
        let appointment = Appointment(
            id: "a1", studentID: "s1", studentName: "Alex",
            counselorID: "c1", counselorName: "Dr. Chen", scheduledAt: Date()
        )
        let viewModel = AppointmentListViewModel(
            currentUser: makeStudent(),
            appointmentService: appointmentService,
            messagingService: MockMessagingService()
        )

        await viewModel.respond(to: appointment, status: .confirmed)

        #expect(appointmentService.updatedStatuses.isEmpty)
    }

    @Test func respondUpdatesStatusForOwningCounselor() async {
        let appointmentService = MockAppointmentService()
        let appointment = Appointment(
            id: "a1", studentID: "s1", studentName: "Alex",
            counselorID: "c1", counselorName: "Dr. Chen", scheduledAt: Date()
        )
        let viewModel = AppointmentListViewModel(
            currentUser: makeCounselor(),
            appointmentService: appointmentService,
            messagingService: MockMessagingService()
        )

        await viewModel.respond(to: appointment, status: .confirmed)

        #expect(appointmentService.updatedStatuses.count == 1)
        #expect(appointmentService.updatedStatuses.first?.status == .confirmed)
    }

    @Test func cancelIgnoredForNonOwningStudent() async {
        let appointmentService = MockAppointmentService()
        let appointment = Appointment(
            id: "a1", studentID: "other-student", studentName: "Jamie",
            counselorID: "c1", counselorName: "Dr. Chen", scheduledAt: Date()
        )
        let viewModel = AppointmentListViewModel(
            currentUser: makeStudent(),
            appointmentService: appointmentService,
            messagingService: MockMessagingService()
        )

        await viewModel.cancel(appointment)

        #expect(appointmentService.updatedStatuses.isEmpty)
    }

    @Test func cancelUpdatesStatusForOwningStudent() async {
        let appointmentService = MockAppointmentService()
        let appointment = Appointment(
            id: "a1", studentID: "s1", studentName: "Alex",
            counselorID: "c1", counselorName: "Dr. Chen", scheduledAt: Date()
        )
        let viewModel = AppointmentListViewModel(
            currentUser: makeStudent(),
            appointmentService: appointmentService,
            messagingService: MockMessagingService()
        )

        await viewModel.cancel(appointment)

        #expect(appointmentService.updatedStatuses.count == 1)
        #expect(appointmentService.updatedStatuses.first?.status == .cancelled)
    }

    @Test func pendingUpcomingPastGroupCorrectly() async {
        let appointmentService = MockAppointmentService()
        let viewModel = AppointmentListViewModel(
            currentUser: makeStudent(),
            appointmentService: appointmentService,
            messagingService: MockMessagingService()
        )
        let future = Date().addingTimeInterval(3600)
        let past = Date().addingTimeInterval(-3600)

        appointmentService.emit([
            Appointment(id: "1", studentID: "s1", studentName: "Alex", counselorID: "c1", counselorName: "Dr. Chen", scheduledAt: future, status: .pending),
            Appointment(id: "2", studentID: "s1", studentName: "Alex", counselorID: "c1", counselorName: "Dr. Chen", scheduledAt: future, status: .confirmed),
            Appointment(id: "3", studentID: "s1", studentName: "Alex", counselorID: "c1", counselorName: "Dr. Chen", scheduledAt: past, status: .confirmed),
            Appointment(id: "4", studentID: "s1", studentName: "Alex", counselorID: "c1", counselorName: "Dr. Chen", scheduledAt: past, status: .declined)
        ])
        await allowStreamDelivery()

        #expect(viewModel.pending.map(\.id) == ["1"])
        #expect(viewModel.upcoming.map(\.id) == ["2"])
        #expect(Set(viewModel.past.map(\.id)) == Set(["3", "4"]))
    }
}
