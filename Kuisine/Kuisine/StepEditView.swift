import SwiftUI
import SwiftData

struct StepEditView: View {
    @Bindable var step: Step
    var recipe: Recipe
    var isNew: Bool = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    private var canSave: Bool {
        !step.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || step.action != .none
    }

    var body: some View {
        Form {
            Section("Action") {
                Picker("Type", selection: Binding(get: { step.action }, set: { step.action = $0 })) {
                    ForEach(StepAction.allCases) { action in
                        Label(action.displayName, systemImage: action.symbolName).tag(action)
                    }
                }
            }

            Section("Instruction") {
                TextField("Décrivez l'étape…", text: $step.text, axis: .vertical)
                    .lineLimit(2...)
            }

            Section("Paramètres") {
                HStack {
                    Text("Température")
                    Spacer()
                    TextField("—", value: $step.temperatureCelsius, format: .number)
                        .multilineTextAlignment(.trailing)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .frame(maxWidth: 80)
                    Text("°C").foregroundStyle(.secondary)
                }
                HStack {
                    Text("Durée")
                    Spacer()
                    TextField("—", value: $step.durationMinutes, format: .number)
                        .multilineTextAlignment(.trailing)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .frame(maxWidth: 80)
                    Text("min").foregroundStyle(.secondary)
                }
                HStack {
                    Text("Vitesse / réglage")
                    Spacer()
                    TextField("ex. vitesse 4", text: $step.speed)
                        .multilineTextAlignment(.trailing)
                }
            }

            if !recipe.sortedIngredients.isEmpty {
                Section("Ingrédients utilisés") {
                    ForEach(recipe.sortedIngredients) { line in
                        Button { toggle(line) } label: {
                            HStack {
                                Text(line.displayName)
                                Spacer()
                                if isUsed(line) {
                                    Image(systemName: "checkmark").foregroundStyle(.tint)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle(isNew ? "Nouvelle étape" : "Modifier l'étape")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler", role: .cancel, action: cancel)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Enregistrer") { dismiss() }.disabled(!canSave)
            }
        }
    }

    private func isUsed(_ line: RecipeIngredient) -> Bool {
        step.usedIngredients?.contains { $0.persistentModelID == line.persistentModelID } ?? false
    }

    private func toggle(_ line: RecipeIngredient) {
        var used = step.usedIngredients ?? []
        if let index = used.firstIndex(where: { $0.persistentModelID == line.persistentModelID }) {
            used.remove(at: index)
        } else {
            used.append(line)
        }
        step.usedIngredients = used
    }

    private func cancel() {
        if isNew { context.delete(step) }
        dismiss()
    }
}
