import SwiftUI
import SolaceCore

struct GamesHomeView: View {
    let currentUser: User

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("A few calm, no-pressure activities — no scores, no losing.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                NavigationLink {
                    BubblePopView()
                } label: {
                    GameRow(
                        title: "Bubble Pop",
                        subtitle: "Pop a grid of bubbles for quick stress relief",
                        systemImage: "circle.grid.3x3.fill",
                        tint: Theme.sky
                    )
                }

                NavigationLink {
                    GratitudeGardenView(currentUserID: currentUser.id)
                } label: {
                    GameRow(
                        title: "Gratitude Garden",
                        subtitle: "Grow a garden by noting what you're grateful for",
                        systemImage: "leaf.fill",
                        tint: Theme.leaf
                    )
                }

                NavigationLink {
                    FocusRingsView()
                } label: {
                    GameRow(
                        title: "Focus Rings",
                        subtitle: "A gentle tap-when-ready attention exercise",
                        systemImage: "circle.dashed",
                        tint: Theme.secondary
                    )
                }

                NavigationLink {
                    ZenGardenView()
                } label: {
                    GameRow(
                        title: "Zen Garden",
                        subtitle: "Rake calming patterns into sand — nothing to get wrong",
                        systemImage: "water.waves",
                        tint: Theme.sun
                    )
                }

                NavigationLink {
                    WorryJarView()
                } label: {
                    GameRow(
                        title: "Worry Jar",
                        subtitle: "Write down a worry, then let it go",
                        systemImage: "wind",
                        tint: Theme.coral
                    )
                }
            }
            .scrollContentBackground(.hidden)
            .background(AmbientBackground(colors: Theme.Ambient.games))
            .navigationTitle("Games")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    SOSToolbarButton()
                }
            }
        }
    }
}

private struct GameRow: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: Theme.Spacing.small) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(tint)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
