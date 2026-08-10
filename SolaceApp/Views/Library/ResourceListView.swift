import SwiftUI
import SolaceCore

struct ResourceListView: View {
    @State private var viewModel = ResourceLibraryViewModel(resourceService: FirestoreResourceService())

    var body: some View {
        NavigationStack {
            List {
                Section("Relaxation Exercises") {
                    ForEach(viewModel.relaxationExercises) { exercise in
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
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        Text("All").tag(ResourceCategory?.none)
                        ForEach(ResourceCategory.allCases, id: \.self) { category in
                            Text(category.displayName).tag(ResourceCategory?.some(category))
                        }
                    }
                    .pickerStyle(.navigationLink)

                    ForEach(viewModel.filteredResources) { resource in
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
            .navigationTitle("Library")
            .task {
                await viewModel.load()
            }
            .refreshable {
                await viewModel.load()
            }
            .overlay {
                if viewModel.isLoading && viewModel.resources.isEmpty {
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

#Preview {
    ResourceListView()
}
