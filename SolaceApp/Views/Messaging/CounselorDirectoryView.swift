import SwiftUI
import SolaceCore

struct CounselorDirectoryView: View {
    let viewModel: ConversationListViewModel
    let currentUser: User
    @Environment(\.dismiss) private var dismiss
    @State private var startedConversation: Conversation?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.counselors.isEmpty {
                    ContentUnavailableView(
                        "No counselors available",
                        systemImage: "person.crop.circle.badge.questionmark"
                    )
                } else {
                    List(viewModel.counselors) { counselor in
                        Button {
                            Task {
                                if let conversation = await viewModel.startConversation(with: counselor) {
                                    startedConversation = conversation
                                }
                            }
                        } label: {
                            VStack(alignment: .leading) {
                                Text(counselor.displayName)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                if let bio = counselor.bio {
                                    Text(bio)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Start a Conversation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                await viewModel.loadCounselors()
            }
            .navigationDestination(item: $startedConversation) { conversation in
                ChatView(conversation: conversation, currentUser: currentUser)
            }
        }
    }
}
