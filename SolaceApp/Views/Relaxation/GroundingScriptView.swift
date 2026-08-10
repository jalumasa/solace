import SwiftUI
import SolaceCore

struct GroundingScriptView: View {
    let exercise: RelaxationExercise
    let steps: [String]
    @State private var currentStepIndex = 0

    var body: some View {
        VStack(spacing: 24) {
            Text(exercise.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Text(steps[currentStepIndex])
                .font(.title2.weight(.medium))
                .multilineTextAlignment(.center)
                .padding()
                .id(currentStepIndex)
                .transition(.opacity)

            Spacer()

            Text("Step \(currentStepIndex + 1) of \(steps.count)")
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack {
                Button("Back") {
                    withAnimation { currentStepIndex = max(0, currentStepIndex - 1) }
                }
                .disabled(currentStepIndex == 0)

                Spacer()

                Button("Next") {
                    withAnimation { currentStepIndex = min(steps.count - 1, currentStepIndex + 1) }
                }
                .buttonStyle(.borderedProminent)
                .disabled(currentStepIndex == steps.count - 1)
            }
        }
        .padding()
        .navigationTitle(exercise.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
