import SwiftUI
import SolaceCore

struct ProfileView: View {
    let currentUser: User
    @Bindable var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("Name", value: currentUser.displayName)
                    LabeledContent("Email", value: currentUser.email)
                    LabeledContent("Role", value: currentUser.role == .student ? "Student" : "Counselor")
                }

                Section("Crisis Support") {
                    CrisisResourceBanner()
                }

                Section {
                    Button("Sign Out", role: .destructive) {
                        authViewModel.signOut()
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}
