import SwiftUI
import UIKit
import SolaceCore

struct BubblePopView: View {
    @State private var viewModel = BubblePopViewModel()
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            Text("Tap to pop. No rush, no score.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(0..<viewModel.bubbleCount, id: \.self) { index in
                    Circle()
                        .fill(viewModel.isPopped(index) ? Color(.systemGray5) : Theme.primary.opacity(0.35))
                        .overlay {
                            if viewModel.isPopped(index) {
                                Circle().strokeBorder(Color(.systemGray4), lineWidth: 1)
                            }
                        }
                        .scaleEffect(viewModel.isPopped(index) ? 0.85 : 1)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: viewModel.isPopped(index))
                        .onTapGesture {
                            guard !viewModel.isPopped(index) else { return }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            viewModel.pop(at: index)
                        }
                }
            }
            .padding()

            if viewModel.isComplete {
                VStack(spacing: Theme.Spacing.small) {
                    Text("All popped. Nice work.")
                        .font(.headline)
                    Button("Reset") {
                        viewModel.reset()
                    }
                    .buttonStyle(.glassProminent)
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Bubble Pop")
        .navigationBarTitleDisplayMode(.inline)
    }
}
