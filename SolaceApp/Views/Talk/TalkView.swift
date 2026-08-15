import SwiftUI
import SolaceCore

struct TalkView: View {
    let currentUser: User
    @State private var viewModel: ConversationListViewModel
    @State private var activeConversation: Conversation?

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

                Section("Connect") {
                    NavigationLink {
                        AppointmentListView(currentUser: currentUser)
                    } label: {
                        ConnectRow(title: "Appointments", subtitle: "Schedule time with a counselor", systemImage: "calendar", tint: Theme.sky)
                    }
                    NavigationLink {
                        CircleListView(currentUser: currentUser)
                    } label: {
                        ConnectRow(title: "Support Circles", subtitle: "Join a peer group on a shared topic", systemImage: "person.3.fill", tint: Theme.leaf)
                    }
                }

                if currentUser.role == .student {
                    Section("Counselors") {
                        if viewModel.isLoading && viewModel.counselors.isEmpty {
                            ProgressView()
                        } else if viewModel.counselors.isEmpty {
                            ContentUnavailableView(
                                "No counselors available",
                                systemImage: "person.crop.circle.badge.questionmark"
                            )
                        } else {
                            ForEach(viewModel.counselors) { counselor in
                                Button {
                                    Task { await selectCounselor(counselor) }
                                } label: {
                                    CounselorRow(
                                        counselor: counselor,
                                        conversation: conversation(with: counselor)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                } else {
                    Section("Conversations") {
                        if viewModel.conversations.isEmpty {
                            ContentUnavailableView(
                                "No conversations yet",
                                systemImage: "bubble.left.and.bubble.right",
                                description: Text("Conversations from students will appear here.")
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
            }
            .scrollContentBackground(.hidden)
            .background(AmbientBackground(colors: Theme.Ambient.talk))
            .navigationTitle("Talk")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    SOSToolbarButton()
                }
            }
            .task {
                await viewModel.loadCounselors()
            }
            .navigationDestination(item: $activeConversation) { conversation in
                ChatView(conversation: conversation, currentUser: currentUser)
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

    private func conversation(with counselor: User) -> Conversation? {
        viewModel.conversations.first { $0.counselorID == counselor.id }
    }

    private func selectCounselor(_ counselor: User) async {
        if let existing = conversation(with: counselor) {
            activeConversation = existing
        } else if let started = await viewModel.startConversation(with: counselor) {
            activeConversation = started
        }
    }
}

private struct ConnectRow: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: Theme.Spacing.small) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(tint)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct CounselorRow: View {
    let counselor: User
    let conversation: Conversation?

    /// The initial shown in the avatar circle, skipping common honorifics so
    /// e.g. "Dr. Maya Chen" and "Dr. Priya Nair" don't both show "D".
    private var avatarInitial: String {
        var name = counselor.displayName
        for prefix in ["Dr. ", "Dr ", "Mr. ", "Mrs. ", "Ms. "] where name.hasPrefix(prefix) {
            name.removeFirst(prefix.count)
            break
        }
        return String(name.prefix(1))
    }

    var body: some View {
        HStack(spacing: Theme.Spacing.small) {
            Circle()
                .fill(Theme.secondary.opacity(0.25))
                .frame(width: 40, height: 40)
                .overlay {
                    Text(avatarInitial)
                        .font(.headline)
                        .foregroundStyle(Theme.secondary)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(counselor.displayName)
                    .font(.headline)
                    .foregroundStyle(.primary)

                if let lastMessage = conversation?.lastMessageText {
                    Text(lastMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else if let bio = counselor.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                } else {
                    Text("Tap to start a conversation")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
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
