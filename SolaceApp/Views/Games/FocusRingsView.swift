import SwiftUI
import SolaceCore

struct FocusRingsView: View {
    @State private var viewModel = FocusRingsViewModel()
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            Text("Tap the ring when it fully blooms. No penalty for missing.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            ZStack {
                Circle()
                    .stroke(Theme.secondary.opacity(0.25), lineWidth: 4)
                    .frame(width: 220, height: 220)

                Circle()
                    .fill(ringColor)
                    .frame(width: 220, height: 220)
                    .scaleEffect(ringScale)
                    .animation(.linear(duration: 0.05), value: ringScale)
                    .onTapGesture {
                        viewModel.tap()
                    }
            }
            .frame(height: 240)

            Text("Calm streak: \(viewModel.calmStreak)")
                .font(.headline)
                .foregroundStyle(.secondary)

            Button {
                viewModel.isRunning ? viewModel.pause() : viewModel.start()
            } label: {
                Text(viewModel.isRunning ? "Pause" : "Start")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .padding(.horizontal, 40)

            Button("Reset") {
                viewModel.reset()
            }
            .font(.footnote)
        }
        .padding()
        .navigationTitle("Focus Rings")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in
            viewModel.tick(deltaTime: 0.05)
        }
    }

    private var ringScale: CGFloat {
        switch viewModel.phase {
        case .growing: return 0.3 + 0.7 * CGFloat(viewModel.progress)
        case .ready: return 1.0
        case .settling: return 0.3
        }
    }

    private var ringColor: Color {
        switch viewModel.phase {
        case .growing: return Theme.secondary.opacity(0.5)
        case .ready: return Theme.primary
        case .settling: return Theme.secondary.opacity(0.3)
        }
    }
}
