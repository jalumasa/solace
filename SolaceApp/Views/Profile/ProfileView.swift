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
            moodService: FirestoreMoodService(),
            journalService: FirestoreJournalService()
        ))
    }

    private var hasAcademicDetails: Bool {
        currentUser.major != nil || currentUser.academicYear != nil || currentUser.age != nil
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("Name", value: currentUser.displayName)
                    LabeledContent("Email", value: currentUser.email)
                    LabeledContent("Role", value: currentUser.role == .student ? "Student" : "Counselor")
                }

                if currentUser.role == .student, hasAcademicDetails {
                    Section("Academic Details") {
                        if let major = currentUser.major {
                            LabeledContent("Major", value: major)
                        }
                        if let academicYear = currentUser.academicYear {
                            LabeledContent("Academic year", value: academicYear.label)
                        }
                        if let age = currentUser.age {
                            LabeledContent("Age", value: "\(age)")
                        }
                    }
                }

                if currentUser.role == .counselor, let bio = currentUser.bio, !bio.isEmpty {
                    Section("Bio") {
                        Text(bio)
                    }
                }

                Section("Your Progress") {
                    LabeledContent("Current streak", value: "\(moodViewModel.streak) day\(moodViewModel.streak == 1 ? "" : "s")")
                    LabeledContent("Check-ins logged", value: "\(moodViewModel.moodHistory.count)")
                }

                ReminderSettingsSection()

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
