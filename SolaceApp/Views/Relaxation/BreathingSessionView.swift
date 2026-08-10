import SwiftUI
import SolaceCore

struct BreathingSessionView: View {
    let exercise: RelaxationExercise
    @State private var viewModel: BreathingSessionViewModel

    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    init(exercise: RelaxationExercise, pattern: BreathingPattern) {
        self.exercise = exercise
        _viewModel = State(initialValue: BreathingSessionViewModel(pattern: pattern))
    }

    var body: some View {
        VStack(spacing: 32) {
            Text(exercise.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.25))
                    .frame(width: 220, height: 220)
                    .scaleEffect(circleScale)
                    .animation(.linear(duration: 0.05), value: circleScale)

                VStack(spacing: 4) {
                    Text(viewModel.phase.label)
                        .font(.title2.bold())
                    Text("\(Int(viewModel.timeRemainingInPhase.rounded(.up)))")
                        .font(.title.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 260)

            Text("Cycles completed: \(viewModel.completedCycles)")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Button {
                viewModel.isRunning ? viewModel.pause() : viewModel.start()
            } label: {
                Text(viewModel.isRunning ? "Pause" : "Start")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 40)

            Button("Reset") {
                viewModel.reset()
            }
            .font(.footnote)
        }
        .padding()
        .navigationTitle(exercise.title)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in
            viewModel.tick(deltaTime: 0.05)
        }
    }

    /// Interpolates the circle's scale across the current phase's duration
    /// directly from `timeRemainingInPhase`, so pausing the session freezes
    /// the animation exactly where it was (rather than an implicit SwiftUI
    /// animation that would keep running after a pause).
    private var circleScale: CGFloat {
        let start = startScale(for: viewModel.phase)
        let end = endScale(for: viewModel.phase)
        let total = viewModel.phase.duration(for: viewModel.pattern)
        guard total > 0 else { return end }
        let progress = 1 - (viewModel.timeRemainingInPhase / total)
        return start + (end - start) * CGFloat(progress)
    }

    private func startScale(for phase: BreathingPhase) -> CGFloat {
        switch phase {
        case .inhale, .holdAfterExhale: return 0.6
        case .hold, .exhale: return 1.0
        }
    }

    private func endScale(for phase: BreathingPhase) -> CGFloat {
        switch phase {
        case .inhale, .hold: return 1.0
        case .exhale, .holdAfterExhale: return 0.6
        }
    }
}
