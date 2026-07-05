import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Bindable var recipe: Recipe
    @Environment(\.modelContext) private var context

    @State private var editingRecipe = false
    @State private var newExperiment: Experiment?
    @State private var editingExperiment: Experiment?

    var body: some View {
        List {
            if !recipe.summary.isEmpty {
                Section { Text(recipe.summary) }
            }
            if !recipe.ingredients.isEmpty {
                Section("Ingredients") { Text(recipe.ingredients) }
            }
            if !recipe.steps.isEmpty {
                Section("Steps") { Text(recipe.steps) }
            }

            Section("Experiments") {
                if recipe.sortedExperiments.isEmpty {
                    Text("No experiments yet. Log a tweak you tried.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(recipe.sortedExperiments) { experiment in
                        Button {
                            editingExperiment = experiment
                        } label: {
                            ExperimentRow(experiment: experiment)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: deleteExperiments)
                }
            }
        }
        .navigationTitle(recipe.title.isEmpty ? "Untitled Recipe" : recipe.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    editingRecipe = true
                } label: {
                    Text("Edit")
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button(action: addExperiment) {
                    Label("Log Experiment", systemImage: "flask")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: addExperiment) {
                Label("Log Experiment", systemImage: "flask")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .sheet(isPresented: $editingRecipe) {
            NavigationStack {
                RecipeEditView(recipe: recipe, isNew: false)
            }
        }
        .sheet(item: $newExperiment) { experiment in
            NavigationStack {
                ExperimentEditView(experiment: experiment, isNew: true)
            }
        }
        .sheet(item: $editingExperiment) { experiment in
            NavigationStack {
                ExperimentEditView(experiment: experiment, isNew: false)
            }
        }
    }

    private func addExperiment() {
        let experiment = Experiment()
        experiment.recipe = recipe
        context.insert(experiment)
        newExperiment = experiment
    }

    private func deleteExperiments(at offsets: IndexSet) {
        let toDelete = offsets.map { recipe.sortedExperiments[$0] }
        for experiment in toDelete {
            context.delete(experiment)
        }
    }
}

private struct ExperimentRow: View {
    let experiment: Experiment

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(experiment.title.isEmpty ? "Untitled tweak" : experiment.title)
                    .font(.headline)
                if experiment.keep {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                }
                Spacer()
                Text(experiment.date, format: .dateTime.day().month().year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if !experiment.notes.isEmpty {
                Text(experiment.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if experiment.rating > 0 {
                Text(String(repeating: "★", count: experiment.rating))
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }
        }
        .contentShape(Rectangle())
    }
}
