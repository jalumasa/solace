import SwiftUI
import SolaceCore

enum AppTab: Hashable {
    case today
    case talk
    case wellness
    case games
    case profile
}

struct RootTabView: View {
    let currentUser: User
    @Bindable var authViewModel: AuthViewModel
    @State private var selectedTab: AppTab = .today

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Today", systemImage: "sun.max.fill", value: AppTab.today) {
                TodayView(currentUser: currentUser, selectedTab: $selectedTab)
            }

            Tab("Talk", systemImage: "bubble.left.and.bubble.right.fill", value: AppTab.talk) {
                TalkView(currentUser: currentUser)
            }

            Tab("Wellness", systemImage: "leaf.fill", value: AppTab.wellness) {
                WellnessView(currentUser: currentUser)
            }

            Tab("Games", systemImage: "gamecontroller.fill", value: AppTab.games) {
                GamesHomeView(currentUser: currentUser)
            }

            Tab("Profile", systemImage: "person.crop.circle.fill", value: AppTab.profile) {
                ProfileView(currentUser: currentUser, authViewModel: authViewModel)
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}
