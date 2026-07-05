import SwiftUI
import SwiftData

/// Edits one ingredient line of a recipe. Resolves the ingredient against the
/// shared catalog by name — reusing an existing entry or creating a new one on
/// the fly — and picks a `MeasureUnit` from the shared list.
struct IngredientLineEditView: View {
    @Bindable var line: RecipeIngredient
    var isNew: Bool = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \Ingredient.name) private var catalog: [Ingredient]
    @Query(sort: \MeasureUnit.order) private var units: [MeasureUnit]

    @State private var name: String = ""
    @State private var addingUnit = false

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

    var body: some View {
        Form {
            Section("Ingrédient") {
                TextField("Nom (ex. Farine)", text: $name)
                    #if os(iOS)
                    .textInputAutocapitalization(.sentences)
                    #endif
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
                            Label("Créer « \(trimmedName.capitalizedFirstLetter) »", systemImage: "plus.circle")
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
                    Picker("Unité", selection: unitSelection) {
                        Text("—").tag(Optional<MeasureUnit>.none)
                        ForEach(units) { unit in
                            Text(unit.singular).tag(Optional(unit))
                        }
                    }
                    .labelsHidden()
                }
                Button { addingUnit = true } label: {
                    Label("Ajouter une unité", systemImage: "plus.circle")
                }
            }

            Section("Note") {
                TextField("ex. finement haché", text: $line.note, axis: .vertical)
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
        .sheet(isPresented: $addingUnit) {
            NavigationStack {
                AddUnitView { newUnit in line.unit = newUnit }
            }
        }
        .onAppear {
            name = line.ingredient?.name ?? ""
            if line.unit == nil { line.unit = units.first }
        }
    }

    private var unitSelection: Binding<MeasureUnit?> {
        Binding(get: { line.unit }, set: { line.unit = $0 })
    }

    private func link(_ ing: Ingredient) {
        line.ingredient = ing
        name = ing.name
    }

    private func createAndLink() {
        let ing = Ingredient(name: trimmedName.capitalizedFirstLetter)
        context.insert(ing)
        line.ingredient = ing
        name = ing.name
    }

    private func resolveIngredient() {
        guard !trimmedName.isEmpty else { return }
        if isLinkedToTypedName { return }
        if let existing = catalog.first(where: {
            $0.name.compare(trimmedName, options: .caseInsensitive) == .orderedSame
        }) {
            line.ingredient = existing
        } else {
            let ing = Ingredient(name: trimmedName.capitalizedFirstLetter)
            context.insert(ing)
            line.ingredient = ing
        }
    }

    private func save() {
        resolveIngredient()
        if line.unit == nil { line.unit = units.first }
        dismiss()
    }

    private func cancel() {
        if isNew { context.delete(line) }
        dismiss()
    }
}

/// Small sheet to add a new unit (singular + plural) to the shared list.
struct AddUnitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \MeasureUnit.order) private var units: [MeasureUnit]

    var onCreate: (MeasureUnit) -> Void

    @State private var singular = ""
    @State private var plural = ""

    var body: some View {
        Form {
            Section("Nouvelle unité") {
                TextField("Singulier (ex. pincée)", text: $singular)
                TextField("Pluriel (ex. pincées)", text: $plural)
            }
            Text("Le pluriel est utilisé à partir de 2 (ex. « 3 pincées »).")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Ajouter une unité")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler", role: .cancel) { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Ajouter", action: create)
                    .disabled(singular.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func create() {
        let s = singular.trimmingCharacters(in: .whitespacesAndNewlines)
        let p = plural.trimmingCharacters(in: .whitespacesAndNewlines)
        let unit = MeasureUnit(singular: s, plural: p, order: units.count)
        context.insert(unit)
        onCreate(unit)
        dismiss()
    }
}
