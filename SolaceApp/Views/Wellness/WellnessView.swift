import SwiftUI
import SolaceCore

struct WellnessView: View {
    let currentUser: User
    @State private var resourceViewModel = ResourceLibraryViewModel(resourceService: FirestoreResourceService())
    @State private var moodViewModel: TodayViewModel

    init(currentUser: User) {
        self.currentUser = currentUser
        _moodViewModel = State(initialValue: TodayViewModel(
            currentUser: currentUser,
            moodService: FirestoreMoodService(),
            journalService: FirestoreJournalService()
        ))
    }

    var body: some View {
        NavigationStack {
            List {
                if !moodViewModel.moodHistory.isEmpty {
                    Section("Mood Insights") {
                        MoodHistoryChart(entries: moodViewModel.moodHistory)
                    }
                }

                Section("Relaxation Exercises") {
                    ForEach(resourceViewModel.relaxationExercises) { exercise in
                        NavigationLink {
                            destination(for: exercise)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(exercise.title).font(.headline)
                                Text(exercise.description)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Articles") {
                    Picker("Category", selection: $resourceViewModel.selectedCategory) {
                        Text("All").tag(ResourceCategory?.none)
                        ForEach(ResourceCategory.allCases, id: \.self) { category in
                            Text(category.displayName).tag(ResourceCategory?.some(category))
                        }
                    }
                    .pickerStyle(.navigationLink)

                    ForEach(resourceViewModel.filteredResources) { resource in
                        NavigationLink {
                            ResourceDetailView(resource: resource)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(resource.title).font(.headline)
                                Text(resource.summary)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                    }
                }

                Section {
                    CrisisResourceBanner()
                }
            }
            .scrollContentBackground(.hidden)
            .background(AmbientBackground(colors: Theme.Ambient.wellness))
            .navigationTitle("Wellness")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    SOSToolbarButton()
                }
            }
            .task {
                await resourceViewModel.load()
            }
            .refreshable {
                await resourceViewModel.load()
            }
            .overlay {
                if resourceViewModel.isLoading && resourceViewModel.resources.isEmpty {
                    ProgressView()
                }
            }
        }
    }

    @ViewBuilder
    private func destination(for exercise: RelaxationExercise) -> some View {
        switch exercise.kind {
        case .breathing(let pattern):
            BreathingSessionView(exercise: exercise, pattern: pattern)
        case .groundingScript(let steps):
            GroundingScriptView(exercise: exercise, steps: steps)
        }
    }
}
