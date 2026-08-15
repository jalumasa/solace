import SwiftUI
import SolaceCore

struct CircleChatView: View {
    let circle: SupportCircle
    let currentUser: User
    @State private var viewModel: CircleChatViewModel

    init(circle: SupportCircle, currentUser: User) {
        self.circle = circle
        self.currentUser = currentUser
        _viewModel = State(initialValue: CircleChatViewModel(
            circleID: circle.id,
            currentUser: currentUser,
            circleService: FirestoreCircleService()
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.messages) { message in
                            CircleMessageBubble(message: message, isFromCurrentUser: viewModel.isFromCurrentUser(message))
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.last?.id) {
                    if let lastID = viewModel.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }

            HStack(spacing: 8) {
                TextField("Message", text: $viewModel.draftText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)

                Button {
                    Task { await viewModel.send() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSending)
            }
            .padding()
        }
        .background(AmbientBackground(colors: Theme.Ambient.talk))
        .navigationTitle(circle.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CircleMessageBubble: View {
    let message: CircleMessage
    let isFromCurrentUser: Bool

    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer(minLength: 40) }
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 2) {
                if !isFromCurrentUser {
                    Text(message.senderName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Group {
                    if isFromCurrentUser {
                        Text(message.text)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Theme.primary)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        Text(message.text)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .foregroundStyle(.primary)
                            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
            }
            if !isFromCurrentUser { Spacer(minLength: 40) }
        }
    }
}
