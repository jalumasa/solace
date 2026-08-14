import SwiftUI
import SolaceCore

struct SignUpView: View {
    @Bindable var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Your details") {
                    TextField("Full name", text: $authViewModel.displayName)
                        .textContentType(.name)
                    TextField("Email", text: $authViewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    SecureField("Password", text: $authViewModel.password)
                        .textContentType(.newPassword)
                }

                Section("I am a...") {
                    Picker("Role", selection: $authViewModel.selectedRole) {
                        Text("Student").tag(Role.student)
                        Text("Counselor").tag(Role.counselor)
                    }
                    .pickerStyle(.segmented)
                }

                if authViewModel.selectedRole == .counselor {
                    Section("Bio") {
                        TextField("A short bio students will see", text: $authViewModel.bio, axis: .vertical)
                            .lineLimit(2...4)
                    }
                }

                if authViewModel.selectedRole == .student {
                    Section("Academic Details") {
                        TextField("Major or field of study", text: $authViewModel.major)
                            .textContentType(.none)

                        Picker("Academic year", selection: $authViewModel.academicYear) {
                            Text("Not set").tag(AcademicYear?.none)
                            ForEach(AcademicYear.allCases, id: \.self) { year in
                                Text(year.label).tag(AcademicYear?.some(year))
                            }
                        }

                        TextField("Age", text: $authViewModel.age)
                            .keyboardType(.numberPad)
                    }
                }

                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }

                Section {
                    Button {
                        Task {
                            await authViewModel.signUp()
                            if case .signedIn = authViewModel.state {
                                dismiss()
                            }
                        }
                    } label: {
                        if authViewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Create Account")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(
                        authViewModel.isLoading
                            || authViewModel.displayName.isEmpty
                            || authViewModel.email.isEmpty
                            || authViewModel.password.isEmpty
                    )
                }
            }
            .scrollContentBackground(.hidden)
            .background(AmbientBackground(colors: Theme.Ambient.today))
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
