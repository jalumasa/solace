import SwiftUI
import SolaceCore

struct QuickActionsGrid: View {
    @Binding var selectedTab: AppTab
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        GlassCardContainer {
            LazyVGrid(columns: columns, spacing: Theme.Spacing.small) {
                Button { selectedTab = .talk } label: {
                    QuickActionLabel(title: "Talk", systemImage: "bubble.left.and.bubble.right.fill", tint: Theme.sky)
                }
                .buttonStyle(.glass)
                .tint(Theme.sky)

                Button { selectedTab = .wellness } label: {
                    QuickActionLabel(title: "Wellness", systemImage: "leaf.fill", tint: Theme.leaf)
                }
                .buttonStyle(.glass)
                .tint(Theme.leaf)

                Button { selectedTab = .games } label: {
                    QuickActionLabel(title: "Games", systemImage: "gamecontroller.fill", tint: Theme.secondary)
                }
                .buttonStyle(.glass)
                .tint(Theme.secondary)

                NavigationLink {
                    BreathingSessionView(
                        exercise: RelaxationExercise.breathingExercises[0],
                        pattern: .box
                    )
                } label: {
                    QuickActionLabel(title: "Breathe", systemImage: "wind", tint: Theme.coral)
                }
                .buttonStyle(.glass)
                .tint(Theme.coral)
            }
        }
    }
}

private struct QuickActionLabel: View {
    let title: String
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(tint)
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 64)
    }
}
