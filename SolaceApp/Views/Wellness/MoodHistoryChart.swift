import SwiftUI
import Charts
import SolaceCore

struct MoodHistoryChart: View {
    let entries: [MoodEntry]

    /// `entries` arrives most-recent-first (see `MoodServicing`'s contract);
    /// take the most recent two weeks and reverse for chronological display.
    private var recentEntries: [MoodEntry] {
        Array(entries.prefix(14).reversed())
    }

    var body: some View {
        Chart(recentEntries) { entry in
            LineMark(
                x: .value("Date", entry.createdAt, unit: .day),
                y: .value("Mood", entry.mood.rawValue)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(Theme.primary)

            PointMark(
                x: .value("Date", entry.createdAt, unit: .day),
                y: .value("Mood", entry.mood.rawValue)
            )
            .foregroundStyle(Theme.primary)
        }
        .chartYScale(domain: 1...5)
        .chartYAxis {
            AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                AxisValueLabel {
                    if let mood = value.as(Int.self), let level = MoodLevel(rawValue: mood) {
                        Text(level.emoji)
                    }
                }
            }
        }
        .frame(height: 160)
        .padding(.vertical, Theme.Spacing.small)
    }
}
