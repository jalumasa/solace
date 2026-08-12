import SwiftUI
import SolaceCore

struct ProfileView: View {
    let currentUser: User
    @Bindable var authViewModel: AuthViewModel
    @State private var moodViewModel: TodayViewModel

    init(currentUser: User, authViewModel: AuthViewModel) {
        self.currentUser = currentUser
        self.authViewModel = authViewModel
        _moodViewModel = State(initialValue: TodayViewModel(
            currentUser: currentUser,
            moodService: FirestoreMoodService()
        ))
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("Name", value: currentUser.displayName)
                    LabeledContent("Email", value: currentUser.email)
                    LabeledContent("Role", value: currentUser.role == .student ? "Student" : "Counselor")
                }

                Section("Your Progress") {
                    LabeledContent("Current streak", value: "\(moodViewModel.streak) day\(moodViewModel.streak == 1 ? "" : "s")")
                    LabeledContent("Check-ins logged", value: "\(moodViewModel.moodHistory.count)")
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
            .scrollContentBackground(.hidden)
            .background(AmbientBackground(colors: Theme.Ambient.profile))
            .navigationTitle("Profile")
        }
    }
}
