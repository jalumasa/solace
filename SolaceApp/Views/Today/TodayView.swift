import SwiftUI
import SolaceCore

struct TodayView: View {
    let currentUser: User
    @Binding var selectedTab: AppTab
    @State private var viewModel: TodayViewModel

    init(currentUser: User, selectedTab: Binding<AppTab>) {
        self.currentUser = currentUser
        self._selectedTab = selectedTab
        _viewModel = State(initialValue: TodayViewModel(
            currentUser: currentUser,
            moodService: FirestoreMoodService()
        ))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                    Text(viewModel.greeting)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.secondary)

                    MoodCheckInCard(viewModel: viewModel)

                    if viewModel.streak > 0 {
                        StreakCard(streak: viewModel.streak)
                    }

                    QuickActionsGrid(selectedTab: $selectedTab)
                }
                .padding()
            }
            .background(AmbientBackground(colors: Theme.Ambient.today))
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    SOSToolbarButton()
                }
            }
        }
    }
}
