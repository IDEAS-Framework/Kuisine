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
            if recipe.isVariant, let parent = recipe.parent {
                Section {
                    Label("Variante de « \(parent.title.isEmpty ? "Recette sans titre" : parent.title) »",
                          systemImage: "arrow.triangle.branch")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if !recipe.summary.isEmpty {
                Section { Text(recipe.summary) }
            }

            Section("Ingrédients") {
                if recipe.sortedIngredients.isEmpty {
                    Text("Aucun ingrédient.").foregroundStyle(.secondary)
                } else {
                    ForEach(recipe.sortedIngredients) { line in
                        IngredientLineRow(line: line)
                    }
                }
            }

            Section("Étapes") {
                if recipe.sortedSteps.isEmpty {
                    Text("Aucune étape.").foregroundStyle(.secondary)
                } else {
                    ForEach(Array(recipe.sortedSteps.enumerated()), id: \.element.id) { index, step in
                        StepRow(index: index + 1, step: step)
                    }
                }
            }

            Section("Expériences") {
                if recipe.sortedExperiments.isEmpty {
                    Text("Aucune expérience. Notez un ajustement que vous avez tenté.")
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

            if let variants = recipe.variants, !variants.isEmpty {
                Section("Variantes") {
                    ForEach(variants) { variant in
                        NavigationLink(value: variant) {
                            Text(variant.title.isEmpty ? "Recette sans titre" : variant.title)
                        }
                    }
                }
            }
        }
        .navigationTitle(recipe.title.isEmpty ? "Recette sans titre" : recipe.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button { editingRecipe = true } label: {
                        Label("Modifier la recette", systemImage: "pencil")
                    }
                    Button(action: addExperiment) {
                        Label("Noter une expérience", systemImage: "flask")
                    }
                    Button(action: makeVariant) {
                        Label("Créer une variante", systemImage: "arrow.triangle.branch")
                    }
                } label: {
                    Label("Actions", systemImage: "ellipsis.circle")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: addExperiment) {
                Label("Noter une expérience", systemImage: "flask")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .sheet(isPresented: $editingRecipe) {
            NavigationStack { RecipeEditView(recipe: recipe, isNew: false) }
        }
        .sheet(item: $newExperiment) { experiment in
            NavigationStack { ExperimentEditView(experiment: experiment, recipe: recipe, isNew: true) }
        }
        .sheet(item: $editingExperiment) { experiment in
            NavigationStack { ExperimentEditView(experiment: experiment, recipe: recipe, isNew: false) }
        }
    }

    private func addExperiment() {
        let experiment = Experiment()
        experiment.recipe = recipe
        context.insert(experiment)
        newExperiment = experiment
    }

    private func makeVariant() {
        recipe.makeVariant(in: context)
    }

    private func deleteExperiments(at offsets: IndexSet) {
        let toDelete = offsets.map { recipe.sortedExperiments[$0] }
        for experiment in toDelete { context.delete(experiment) }
    }
}

private struct IngredientLineRow: View {
    let line: RecipeIngredient

    var body: some View {
        HStack {
            Text(line.displayName)
            Spacer()
            Text(line.quantityText)
                .foregroundStyle(.secondary)
        }
        if !line.note.isEmpty {
            Text(line.note)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}

private struct StepRow: View {
    let index: Int
    let step: Step

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text("\(index).").foregroundStyle(.secondary)
                if step.action != .none {
                    Label(step.action.displayName, systemImage: step.action.symbolName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .labelStyle(.titleAndIcon)
                }
                Spacer()
                if let params = parameterText {
                    Text(params).font(.caption).foregroundStyle(.tertiary)
                }
            }
            if !step.text.isEmpty { Text(step.text) }
            if !inputsText.isEmpty {
                Label(inputsText, systemImage: "arrow.down.to.line")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            if let out = step.output, !out.displayName.isEmpty {
                Label("Produit : \(out.displayName) (\(out.quantityText))", systemImage: "arrow.up.forward")
                    .font(.caption)
                    .foregroundStyle(.tint)
            }
        }
    }

    private var inputsText: String {
        step.sortedInputs.compactMap { input -> String? in
            guard let comp = input.component else { return nil }
            let q = input.quantity
            let n = q == q.rounded() ? String(Int(q)) : String(format: "%.2f", q)
            let unit = comp.unit.map { " \($0.label(for: q))" } ?? ""
            return "\(comp.displayName) (\(n)\(unit))"
        }
        .joined(separator: ", ")
    }

    private var parameterText: String? {
        var parts: [String] = []
        if let t = step.temperatureCelsius { parts.append("\(t) °C") }
        if let d = step.durationMinutes { parts.append("\(d) min") }
        if !step.speed.isEmpty { parts.append(step.speed) }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}

private struct ExperimentRow: View {
    let experiment: Experiment

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(experiment.title.isEmpty ? "Ajustement" : experiment.title)
                    .font(.headline)
                if experiment.keep {
                    Image(systemName: "star.fill").foregroundStyle(.yellow).font(.caption)
                }
                Spacer()
                Text(experiment.date, format: .dateTime.day().month().year())
                    .font(.caption).foregroundStyle(.secondary)
            }
            if let target = targetText {
                Text(target).font(.caption).foregroundStyle(.tertiary)
            }
            if !experiment.notes.isEmpty {
                Text(experiment.notes).font(.subheadline).foregroundStyle(.secondary)
            }
            if experiment.rating > 0 {
                Text(String(repeating: "★", count: experiment.rating))
                    .font(.caption).foregroundStyle(.yellow)
            }
        }
        .contentShape(Rectangle())
    }

    private var targetText: String? {
        if let ing = experiment.targetIngredient { return "Concerne : \(ing.displayName)" }
        if let step = experiment.targetStep {
            let label = step.action != .none ? step.action.displayName : "étape"
            return "Concerne : \(label)"
        }
        return nil
    }
}
