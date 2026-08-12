import SwiftUI
import SolaceCore

struct TalkView: View {
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
            List {
                Section {
                    NavigationLink {
                        AIChatView()
                    } label: {
                        HStack(spacing: Theme.Spacing.small) {
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .foregroundStyle(Theme.secondary)
                                .frame(width: 32)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("AI Companion")
                                    .font(.headline)
                                Text("Available 24/7 for general support")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Your Counselors") {
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
                        ForEach(viewModel.conversations) { conversation in
                            NavigationLink {
                                ChatView(conversation: conversation, currentUser: currentUser)
                            } label: {
                                ConversationRow(conversation: conversation, currentUser: currentUser)
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AmbientBackground(colors: Theme.Ambient.talk))
            .navigationTitle("Talk")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    if currentUser.role == .student {
                        Button {
                            showingCounselorDirectory = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                    SOSToolbarButton()
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
