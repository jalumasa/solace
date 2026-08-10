import SwiftUI
import SolaceCore

struct ConversationListView: View {
    let currentUser: User
    @State private var viewModel: ConversationListViewModel
    @State private var showingCounselorDirectory = false

    init(currentUser: User) {
        self.currentUser = currentUser
        _viewModel = State(initialValue: ConversationListViewModel(
            currentUser: currentUser,
            messagingService: FirestoreMessagingService()
        ))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.conversations.isEmpty {
                    ContentUnavailableView(
                        "No conversations yet",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text(
                            currentUser.role == .student
                                ? "Start a conversation with a counselor."
                                : "Conversations from students will appear here."
                        )
                    )
                } else {
                    List(viewModel.conversations) { conversation in
                        NavigationLink {
                            ChatView(conversation: conversation, currentUser: currentUser)
                        } label: {
                            ConversationRow(conversation: conversation, currentUser: currentUser)
                        }
                    }
                }
            }
            .navigationTitle("Messages")
            .toolbar {
                if currentUser.role == .student {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingCounselorDirectory = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCounselorDirectory) {
                CounselorDirectoryView(viewModel: viewModel, currentUser: currentUser)
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
    }
}

private struct ConversationRow: View {
    let conversation: Conversation
    let currentUser: User

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(conversation.otherParticipantName(currentUserID: currentUser.id))
                .font(.headline)
            if let lastMessage = conversation.lastMessageText {
                Text(lastMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            } else {
                Text("No messages yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ConversationListView(currentUser: User(id: "1", email: "a@b.com", displayName: "Alex", role: .student))
}
