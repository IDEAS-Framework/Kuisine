import SwiftUI
import SwiftData

struct RecipeEditView: View {
    @Bindable var recipe: Recipe
    var isNew: Bool = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var newLine: RecipeIngredient?
    @State private var editingLine: RecipeIngredient?
    @State private var newStep: Step?
    @State private var editingStep: Step?

    private var canSave: Bool {
        !recipe.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section("Recette") {
                TextField("Titre", text: $recipe.title)
                TextField("Brève description", text: $recipe.summary, axis: .vertical)
            }

            Section("Ingrédients") {
                ForEach(recipe.sortedIngredients) { line in
                    Button { editingLine = line } label: {
                        IngredientLineLabel(line: line)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: deleteIngredients)

                Button(action: addIngredient) {
                    Label("Ajouter un ingrédient", systemImage: "plus")
                }
            }

            Section("Étapes") {
                ForEach(Array(recipe.sortedSteps.enumerated()), id: \.element.id) { index, step in
                    Button { editingStep = step } label: {
                        StepLabel(index: index + 1, step: step)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: deleteSteps)

                Button(action: addStep) {
                    Label("Ajouter une étape", systemImage: "plus")
                }
            }
        }
        .navigationTitle(isNew ? "Nouvelle recette" : "Modifier la recette")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler", role: .cancel, action: cancel)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Enregistrer", action: save).disabled(!canSave)
            }
        }
        .sheet(item: $newLine) { line in
            NavigationStack { IngredientLineEditView(line: line, isNew: true) }
        }
        .sheet(item: $editingLine) { line in
            NavigationStack { IngredientLineEditView(line: line, isNew: false) }
        }
        .sheet(item: $newStep) { step in
            NavigationStack { StepEditView(step: step, recipe: recipe, isNew: true) }
        }
        .sheet(item: $editingStep) { step in
            NavigationStack { StepEditView(step: step, recipe: recipe, isNew: false) }
        }
    }

    private func addIngredient() {
        let line = RecipeIngredient(order: (recipe.recipeIngredients?.count ?? 0))
        line.recipe = recipe
        context.insert(line)
        newLine = line
    }

    private func addStep() {
        let step = Step(order: (recipe.steps?.count ?? 0))
        step.recipe = recipe
        context.insert(step)
        newStep = step
    }

    private func deleteIngredients(at offsets: IndexSet) {
        let lines = recipe.sortedIngredients
        for index in offsets { context.delete(lines[index]) }
    }

    private func deleteSteps(at offsets: IndexSet) {
        let steps = recipe.sortedSteps
        for index in offsets { context.delete(steps[index]) }
    }

    private func save() {
        recipe.updatedAt = .now
        dismiss()
    }

    private func cancel() {
        if isNew { context.delete(recipe) }
        dismiss()
    }
}

private struct IngredientLineLabel: View {
    let line: RecipeIngredient
    var body: some View {
        HStack {
            Text(line.ingredient?.name.isEmpty == false ? line.ingredient!.name : "Nouvel ingrédient")
                .foregroundStyle(line.ingredient?.name.isEmpty == false ? .primary : .secondary)
            Spacer()
            if line.quantity > 0 {
                let qty = line.quantity
                let number = qty == qty.rounded() ? String(Int(qty)) : String(format: "%.2f", qty)
                Text("\(number) \(line.unit.shortName)").foregroundStyle(.secondary)
            }
        }
    }
}

private struct StepLabel: View {
    let index: Int
    let step: Step
    var body: some View {
        HStack {
            Text("\(index).").foregroundStyle(.secondary)
            if step.action != .none {
                Image(systemName: step.action.symbolName).foregroundStyle(.secondary)
            }
            Text(step.text.isEmpty ? "Nouvelle étape" : step.text)
                .foregroundStyle(step.text.isEmpty ? .secondary : .primary)
                .lineLimit(1)
            Spacer()
        }
    }
}
