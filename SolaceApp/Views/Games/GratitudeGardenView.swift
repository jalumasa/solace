import SwiftUI
import SolaceCore

struct GratitudeGardenView: View {
    @State private var viewModel: GratitudeGardenViewModel

    init(currentUserID: String) {
        _viewModel = State(initialValue: GratitudeGardenViewModel(
            currentUserID: currentUserID,
            journalService: FirestoreJournalService()
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.large) {
                GardenIllustration(stage: viewModel.stage)

                VStack(spacing: 4) {
                    Text(viewModel.stage.label)
                        .font(.title2.bold())
                    Text(viewModel.stage.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 8) {
                    TextField("I'm grateful for…", text: $viewModel.draftText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...3)

                    Button {
                        Task { await viewModel.addEntry() }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                    .disabled(
                        viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            || viewModel.isSaving
                    )
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                if !viewModel.entries.isEmpty {
                    VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                        Text("Your entries")
                            .font(.headline)
                        ForEach(viewModel.entries) { entry in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.text)
                                Text(entry.createdAt, style: .date)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .glassCard(cornerRadius: Theme.Radius.control)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Gratitude Garden")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct GardenIllustration: View {
    let stage: GardenStage

    private var leafCount: Int {
        switch stage {
        case .seed: return 1
        case .sprout: return 3
        case .bloom: return 5
        case .flourishing: return 7
        }
    }

    private var iconSize: CGFloat {
        switch stage {
        case .seed: return 28
        case .sprout: return 34
        case .bloom: return 40
        case .flourishing: return 46
        }
    }

    var body: some View {
        HStack(spacing: -8) {
            ForEach(0..<leafCount, id: \.self) { index in
                Image(systemName: "leaf.fill")
                    .font(.system(size: iconSize))
                    .foregroundStyle(Theme.primary.opacity(0.5 + Double(index) * 0.08))
                    .rotationEffect(.degrees(Double(index - leafCount / 2) * 12))
            }
        }
        .frame(height: 80)
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: leafCount)
    }
}
