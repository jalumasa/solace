import SwiftUI
import SolaceCore

struct AppointmentListView: View {
    let currentUser: User
    @State private var viewModel: AppointmentListViewModel
    @State private var isPresentingRequestSheet = false

    init(currentUser: User) {
        self.currentUser = currentUser
        _viewModel = State(initialValue: AppointmentListViewModel(
            currentUser: currentUser,
            appointmentService: FirestoreAppointmentService(),
            messagingService: FirestoreMessagingService()
        ))
    }

    private var isEmpty: Bool {
        viewModel.pending.isEmpty && viewModel.upcoming.isEmpty && viewModel.past.isEmpty
    }

    var body: some View {
        List {
            if isEmpty {
                ContentUnavailableView(
                    "No appointments yet",
                    systemImage: "calendar",
                    description: Text(
                        currentUser.role == .student
                            ? "Request a time with a counselor to get started."
                            : "Appointment requests from students will appear here."
                    )
                )
            }

            if !viewModel.pending.isEmpty {
                Section("Pending") {
                    ForEach(viewModel.pending) { appointment in
                        AppointmentRow(appointment: appointment, currentUser: currentUser)
                        pendingActions(for: appointment)
                    }
                }
            }

            if !viewModel.upcoming.isEmpty {
                Section("Upcoming") {
                    ForEach(viewModel.upcoming) { appointment in
                        AppointmentRow(appointment: appointment, currentUser: currentUser)
                        if currentUser.role == .student {
                            Button("Cancel", role: .destructive) {
                                Task { await viewModel.cancel(appointment) }
                            }
                        }
                    }
                }
            }

            if !viewModel.past.isEmpty {
                Section("Past") {
                    ForEach(viewModel.past) { appointment in
                        AppointmentRow(appointment: appointment, currentUser: currentUser)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AmbientBackground(colors: Theme.Ambient.talk))
        .navigationTitle("Appointments")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if currentUser.role == .student {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isPresentingRequestSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isPresentingRequestSheet) {
            RequestAppointmentView(viewModel: viewModel)
        }
        .alert(
            "Something went wrong",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in if !isPresented { viewModel.clearError() } }
            )
        ) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    @ViewBuilder
    private func pendingActions(for appointment: Appointment) -> some View {
        if currentUser.role == .counselor {
            HStack {
                Button("Decline", role: .destructive) {
                    Task { await viewModel.respond(to: appointment, status: .declined) }
                }
                Spacer()
                Button("Confirm") {
                    Task { await viewModel.respond(to: appointment, status: .confirmed) }
                }
                .buttonStyle(.glassProminent)
            }
        } else {
            Button("Cancel request", role: .destructive) {
                Task { await viewModel.cancel(appointment) }
            }
        }
    }
}

private struct AppointmentRow: View {
    let appointment: Appointment
    let currentUser: User

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(appointment.otherParticipantName(currentUserID: currentUser.id))
                .font(.headline)
            Text(Self.dateFormatter.string(from: appointment.scheduledAt))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if appointment.status != .pending {
                Text(statusLabel)
                    .font(.caption)
                    .foregroundStyle(statusColor)
            }
        }
        .padding(.vertical, 2)
    }

    private var statusLabel: String {
        switch appointment.status {
        case .pending: "Pending"
        case .confirmed: "Confirmed"
        case .declined: "Declined"
        case .cancelled: "Cancelled"
        }
    }

    private var statusColor: Color {
        switch appointment.status {
        case .pending: Theme.warm
        case .confirmed: Theme.leaf
        case .declined, .cancelled: Theme.coral
        }
    }
}
