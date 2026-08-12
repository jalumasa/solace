import SwiftUI
import SolaceCore

struct MoodCheckInCard: View {
    let viewModel: TodayViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            if viewModel.hasCheckedInToday {
                Label("You checked in today", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(Theme.primary)
            } else {
                Text("How are you feeling today?")
                    .font(.headline)

                GlassCardContainer {
                    HStack(spacing: Theme.Spacing.small) {
                        ForEach(MoodLevel.allCases, id: \.self) { mood in
                            Button {
                                Task { await viewModel.logMood(mood) }
                            } label: {
                                VStack(spacing: 4) {
                                    Text(mood.emoji).font(.system(size: 26))
                                    Text(mood.label).font(.caption2)
                                }
                                .frame(maxWidth: .infinity, minHeight: 56)
                            }
                            .buttonStyle(.glass)
                            .tint(mood.color)
                        }
                    }
                }

                if viewModel.isSubmittingMood {
                    ProgressView()
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .glassCard()
    }
}
