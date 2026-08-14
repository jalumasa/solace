import SwiftUI
import SolaceCore

/// Write down a worry, then let it go — a small CBT-style externalization
/// exercise. Nothing is saved or judged; only a session-local count of how
/// many worries have been released.
struct WorryJarView: View {
    @State private var viewModel = WorryJarViewModel()
    @State private var floatOffset: CGFloat = 0
    @State private var floatOpacity: Double = 1

    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            Text("Write down what's weighing on you, then let it go.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            ZStack {
                RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                    .fill(Theme.secondary.opacity(0.12))
                    .frame(height: 200)

                if viewModel.draftText.isEmpty {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Theme.secondary.opacity(0.4))
                } else {
                    Text(viewModel.draftText)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(Theme.Spacing.large)
                        .offset(y: floatOffset)
                        .opacity(floatOpacity)
                }
            }
            .padding(.horizontal)

            TextField("I'm worried about…", text: $viewModel.draftText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)
                .padding(.horizontal)
                .disabled(viewModel.isReleasing)

            Button {
                releaseWorry()
            } label: {
                Text("Let it go")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .padding(.horizontal, Theme.Spacing.xLarge)
            .disabled(!viewModel.canRelease)

            Text("\(viewModel.releasedCount) worr\(viewModel.releasedCount == 1 ? "y" : "ies") released this session")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.top)
        .navigationTitle("Worry Jar")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func releaseWorry() {
        viewModel.release()
        withAnimation(.easeIn(duration: 0.9)) {
            floatOffset = -140
            floatOpacity = 0
        }
        Task {
            try? await Task.sleep(for: .seconds(0.9))
            viewModel.finishRelease()
            floatOffset = 0
            floatOpacity = 1
        }
    }
}
