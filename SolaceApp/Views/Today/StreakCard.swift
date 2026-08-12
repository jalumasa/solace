import SwiftUI

struct StreakCard: View {
    let streak: Int

    var body: some View {
        HStack(spacing: Theme.Spacing.small) {
            Image(systemName: "flame.fill")
                .foregroundStyle(Theme.warm)
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(streak)-day streak")
                    .font(.headline)
                Text("Keep checking in to grow it.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .glassCard()
    }
}
