import Foundation
import Observation

@MainActor
@Observable
public final class AppointmentListViewModel {
    public private(set) var appointments: [Appointment] = []
    public private(set) var counselors: [User] = []
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?

    private let currentUser: User
    private let appointmentService: AppointmentServicing
    private let messagingService: MessagingServicing
    @ObservationIgnored
    private nonisolated(unsafe) var observationTask: Task<Void, Never>?

    public init(currentUser: User, appointmentService: AppointmentServicing, messagingService: MessagingServicing) {
        self.currentUser = currentUser
        self.appointmentService = appointmentService
        self.messagingService = messagingService
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await appointments in appointmentService.observeAppointments(for: currentUser.id) {
                self.appointments = appointments
            }
        }
    }

    deinit {
        observationTask?.cancel()
    }

    public func clearError() {
        errorMessage = nil
    }

    public var pending: [Appointment] {
        appointments.filter { $0.status == .pending }
    }

    public var upcoming: [Appointment] {
        appointments.filter { $0.status == .confirmed && $0.scheduledAt >= Date() }
    }

    public var past: [Appointment] {
        appointments.filter { $0.status != .pending && ($0.status != .confirmed || $0.scheduledAt < Date()) }
    }

    public func loadCounselors() async {
        guard currentUser.role == .student else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            counselors = try await messagingService.fetchCounselors()
        } catch {
            errorMessage = "Couldn't load counselors. Please try again."
        }
    }

    public func requestAppointment(with counselor: User, at date: Date) async {
        guard currentUser.role == .student else { return }
        do {
            _ = try await appointmentService.requestAppointment(
                studentID: currentUser.id,
                studentName: currentUser.displayName,
                counselorID: counselor.id,
                counselorName: counselor.displayName,
                scheduledAt: date
            )
        } catch {
            errorMessage = "Couldn't request that appointment. Please try again."
        }
    }

    public func respond(to appointment: Appointment, status: AppointmentStatus) async {
        guard currentUser.role == .counselor, appointment.counselorID == currentUser.id else { return }
        do {
            try await appointmentService.updateStatus(appointmentID: appointment.id, status: status)
        } catch {
            errorMessage = "Couldn't update that appointment. Please try again."
        }
    }

    public func cancel(_ appointment: Appointment) async {
        guard appointment.studentID == currentUser.id else { return }
        do {
            try await appointmentService.updateStatus(appointmentID: appointment.id, status: .cancelled)
        } catch {
            errorMessage = "Couldn't cancel that appointment. Please try again."
        }
    }
}
