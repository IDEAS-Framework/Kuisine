import SwiftUI
import SwiftData

struct ExperimentEditView: View {
    @Bindable var experiment: Experiment
    var recipe: Recipe
    var isNew: Bool = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    private var canSave: Bool {
        !experiment.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section("Qu'avez-vous tenté ?") {
                TextField("Titre (ex. Plus d'ail)", text: $experiment.title)
                TextField("Notes — ce que vous avez changé", text: $experiment.notes, axis: .vertical)
                    .lineLimit(3...)
            }

            Section("Élément concerné") {
                Picker("Ingrédient", selection: ingredientSelection) {
                    Text("Aucun").tag(Optional<RecipeIngredient>.none)
                    ForEach(recipe.sortedIngredients) { line in
                        Text(line.displayName).tag(Optional(line))
                    }
                }
                Picker("Étape", selection: stepSelection) {
                    Text("Aucune").tag(Optional<Step>.none)
                    ForEach(Array(recipe.sortedSteps.enumerated()), id: \.element.id) { index, step in
                        Text(stepLabel(index: index + 1, step: step)).tag(Optional(step))
                    }
                }
            }

            Section("Résultat") {
                TextField("Comment est-ce ?", text: $experiment.outcome, axis: .vertical)
                    .lineLimit(2...)
                Stepper(value: $experiment.rating, in: 0...5) {
                    HStack {
                        Text("Note")
                        Spacer()
                        Text(experiment.rating == 0 ? "—" : String(repeating: "★", count: experiment.rating))
                            .foregroundStyle(.secondary)
                    }
                }
                Toggle("À conserver — intégrer à la recette", isOn: $experiment.keep)
            }

            Section {
                DatePicker("Date", selection: $experiment.date, displayedComponents: .date)
            }
        }
        .navigationTitle(isNew ? "Nouvelle expérience" : "Modifier l'expérience")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler", role: .cancel, action: cancel)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Enregistrer") { dismiss() }.disabled(!canSave)
            }
        }
    }

    private var ingredientSelection: Binding<RecipeIngredient?> {
        Binding(get: { experiment.targetIngredient }, set: { experiment.targetIngredient = $0 })
    }

    private var stepSelection: Binding<Step?> {
        Binding(get: { experiment.targetStep }, set: { experiment.targetStep = $0 })
    }

    private func stepLabel(index: Int, step: Step) -> String {
        let base = step.action != .none ? step.action.displayName : "Étape"
        return "\(index). \(base)"
    }

    private func cancel() {
        if isNew { context.delete(experiment) }
        dismiss()
    }
}
