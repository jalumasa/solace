import SwiftUI
import SolaceCore

struct RequestAppointmentView: View {
    let viewModel: AppointmentListViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCounselorID: String?
    @State private var scheduledDate = Date().addingTimeInterval(3600)
    @State private var isSubmitting = false

    private var selectedCounselor: User? {
        viewModel.counselors.first { $0.id == selectedCounselorID }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Counselor") {
                    if viewModel.counselors.isEmpty {
                        ProgressView()
                    } else {
                        ForEach(viewModel.counselors) { counselor in
                            Button {
                                selectedCounselorID = counselor.id
                            } label: {
                                HStack {
                                    Text(counselor.displayName)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if selectedCounselorID == counselor.id {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Theme.primary)
                                    }
                                }
                            }
                        }
                    }
                }

                Section("Date & Time") {
                    DatePicker(
                        "When",
                        selection: $scheduledDate,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                Section {
                    Button {
                        submit()
                    } label: {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Request Appointment")
                        }
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(selectedCounselor == nil || isSubmitting)
                }
            }
            .navigationTitle("Request Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                await viewModel.loadCounselors()
            }
        }
    }

    private func submit() {
        guard let selectedCounselor else { return }
        isSubmitting = true
        Task {
            await viewModel.requestAppointment(with: selectedCounselor, at: scheduledDate)
            isSubmitting = false
            dismiss()
        }
    }
}
