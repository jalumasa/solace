import SwiftUI
import UIKit
import SolaceCore

struct AIChatView: View {
    @State private var viewModel = AIChatViewModel(chatService: CloudFunctionAIChatService())
    @State private var showingCrisisResources = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(viewModel.messages) { message in
                                AIChatBubble(message: message)
                                    .id(message.id)
                            }
                            if viewModel.isLoading {
                                HStack {
                                    ProgressView()
                                    Text("Thinking…")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
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
                    TextField("Share what's on your mind…", text: $viewModel.draftText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...4)

                    Button {
                        Task { await viewModel.send() }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                    .disabled(
                        viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            || viewModel.isLoading
                    )
                }
                .padding()
            }
            .navigationTitle("Support Chat")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCrisisResources = true
                    } label: {
                        Image(systemName: "exclamationmark.heart")
                    }
                }
            }
            .sheet(isPresented: $showingCrisisResources) {
                NavigationStack {
                    List {
                        CrisisResourceBanner()
                    }
                    .navigationTitle("Crisis Support")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .presentationDetents([.medium])
            }
        }
    }
}

private struct AIChatBubble: View {
    let message: AIChatMessage

    var isUser: Bool { message.role == .user }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 40) }
            Text(message.text)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isUser ? Color.accentColor : Color(.secondarySystemBackground))
                .foregroundStyle(isUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            if !isUser { Spacer(minLength: 40) }
        }
    }
}

#Preview {
    AIChatView()
}
