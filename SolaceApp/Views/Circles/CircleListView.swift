import SwiftUI
import SolaceCore

struct CircleListView: View {
    let currentUser: User
    @State private var viewModel: CircleListViewModel

    init(currentUser: User) {
        self.currentUser = currentUser
        _viewModel = State(initialValue: CircleListViewModel(
            currentUserID: currentUser.id,
            circleService: FirestoreCircleService()
        ))
    }

    var body: some View {
        List {
            if !viewModel.myCircles.isEmpty {
                Section("My Circles") {
                    ForEach(viewModel.myCircles) { circle in
                        NavigationLink {
                            CircleChatView(circle: circle, currentUser: currentUser)
                        } label: {
                            CircleRow(circle: circle)
                        }
                        .swipeActions {
                            Button("Leave", role: .destructive) {
                                Task { await viewModel.leave(circle) }
                            }
                        }
                    }
                }
            }

            Section("Browse Circles") {
                if viewModel.availableCircles.isEmpty && viewModel.myCircles.isEmpty {
                    ContentUnavailableView(
                        "No circles yet",
                        systemImage: "person.3",
                        description: Text("Check back soon.")
                    )
                } else if viewModel.availableCircles.isEmpty {
                    Text("You've joined every circle.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.availableCircles) { circle in
                        HStack {
                            CircleRow(circle: circle)
                            Spacer()
                            Button("Join") {
                                Task { await viewModel.join(circle) }
                            }
                            .buttonStyle(.glass)
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AmbientBackground(colors: Theme.Ambient.talk))
        .navigationTitle("Support Circles")
        .navigationBarTitleDisplayMode(.inline)
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

private struct CircleRow: View {
    let circle: SupportCircle

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(circle.name)
                .font(.headline)
            Text(circle.topicDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Text("\(circle.memberIDs.count) member\(circle.memberIDs.count == 1 ? "" : "s")")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }
}
