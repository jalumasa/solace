import SwiftUI
import SolaceCore

struct RootTabView: View {
    let currentUser: User
    @Bindable var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            ConversationListView(currentUser: currentUser)
                .tabItem { Label("Messages", systemImage: "bubble.left.and.bubble.right") }

            ResourceListView()
                .tabItem { Label("Library", systemImage: "book") }

            AIChatView()
                .tabItem { Label("Support Chat", systemImage: "sparkles") }

            ProfileView(currentUser: currentUser, authViewModel: authViewModel)
                .tabItem { Label("Profile", systemImage: "person.circle") }
        }
    }
}
