import SwiftUI
import SwiftData

/// Edits one ingredient line of a recipe. Resolves the ingredient against the
/// shared catalog by name — reusing an existing entry or creating a new one on
/// the fly — and lets you tune which units that catalog entry allows.
struct IngredientLineEditView: View {
    @Bindable var line: RecipeIngredient
    var isNew: Bool = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \Ingredient.name) private var catalog: [Ingredient]

    @State private var name: String = ""

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isLinkedToTypedName: Bool {
        guard let ing = line.ingredient else { return false }
        return ing.name.compare(trimmedName, options: .caseInsensitive) == .orderedSame
    }

    private var suggestions: [Ingredient] {
        guard !trimmedName.isEmpty, !isLinkedToTypedName else { return [] }
        return catalog
            .filter { $0.name.localizedCaseInsensitiveContains(trimmedName) }
            .prefix(6)
            .map { $0 }
    }

    private var exactExists: Bool {
        catalog.contains { $0.name.compare(trimmedName, options: .caseInsensitive) == .orderedSame }
    }

    private var unitOptions: [MeasurementUnit] {
        if let ing = line.ingredient, isLinkedToTypedName, !ing.availableUnits.isEmpty {
            return ing.availableUnits
        }
        return MeasurementUnit.allCases
    }

    var body: some View {
        Form {
            Section("Ingrédient") {
                TextField("Nom (ex. Farine)", text: $name)
            }

            if !suggestions.isEmpty || (!trimmedName.isEmpty && !exactExists && !isLinkedToTypedName) {
                Section("Choisir dans le catalogue") {
                    ForEach(suggestions) { ing in
                        Button { link(ing) } label: {
                            HStack {
                                Text(ing.name)
                                Spacer()
                                if line.ingredient?.persistentModelID == ing.persistentModelID {
                                    Image(systemName: "checkmark").foregroundStyle(.tint)
                                }
                            }
                        }
                    }
                    if !trimmedName.isEmpty && !exactExists {
                        Button { createAndLink() } label: {
                            Label("Créer « \(trimmedName) »", systemImage: "plus.circle")
                        }
                    }
                }
            }

            Section("Quantité") {
                HStack {
                    TextField("Quantité", value: $line.quantity, format: .number)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                    Picker("Unité", selection: Binding(get: { line.unit }, set: { line.unit = $0 })) {
                        ForEach(unitOptions) { unit in
                            Text(unit.shortName).tag(unit)
                        }
                    }
                    .labelsHidden()
                }
            }

            Section("Note") {
                TextField("ex. finement haché", text: $line.note, axis: .vertical)
            }

            if let ing = line.ingredient, isLinkedToTypedName {
                Section("Unités possibles pour « \(ing.name) »") {
                    Toggle("Poids (g, kg)", isOn: bind(\.allowsWeight, on: ing))
                    Toggle("Volume (mL, L)", isOn: bind(\.allowsVolume, on: ing))
                    Toggle("Volumes standards (c. à s., c. à c., tasse)", isOn: bind(\.allowsCustomaryVolume, on: ing))
                        .disabled(!ing.allowsVolume)
                    Toggle("Compte (pièce, gousse…)", isOn: bind(\.allowsCount, on: ing))
                }
            }
        }
        .navigationTitle(isNew ? "Nouvel ingrédient" : "Modifier l'ingrédient")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler", role: .cancel, action: cancel)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Enregistrer", action: save).disabled(trimmedName.isEmpty)
            }
        }
        .onAppear { name = line.ingredient?.name ?? "" }
    }

    private func bind(_ keyPath: ReferenceWritableKeyPath<Ingredient, Bool>, on ing: Ingredient) -> Binding<Bool> {
        Binding(get: { ing[keyPath: keyPath] }, set: { ing[keyPath: keyPath] = $0 })
    }

    private func link(_ ing: Ingredient) {
        line.ingredient = ing
        name = ing.name
        clampUnit()
    }

    private func createAndLink() {
        let ing = Ingredient(name: trimmedName)
        context.insert(ing)
        line.ingredient = ing
        clampUnit()
    }

    private func clampUnit() {
        guard let ing = line.ingredient else { return }
        if !ing.availableUnits.contains(line.unit), let first = ing.availableUnits.first {
            line.unit = first
        }
    }

    private func resolveIngredient() {
        guard !trimmedName.isEmpty else { return }
        if isLinkedToTypedName { return }
        if let existing = catalog.first(where: {
            $0.name.compare(trimmedName, options: .caseInsensitive) == .orderedSame
        }) {
            line.ingredient = existing
        } else {
            let ing = Ingredient(name: trimmedName)
            context.insert(ing)
            line.ingredient = ing
        }
        clampUnit()
    }

    private func save() {
        resolveIngredient()
        dismiss()
    }

    private func cancel() {
        if isNew { context.delete(line) }
        dismiss()
    }
}
