import SwiftUI
import SwiftData

struct StepEditView: View {
    @Bindable var step: Step
    var recipe: Recipe
    var isNew: Bool = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \MeasureUnit.order) private var units: [MeasureUnit]

    private var available: [RecipeFlow.Available] {
        RecipeFlow(recipe: recipe).available(before: step.order)
    }

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
                parameterRow("Température", value: $step.temperatureCelsius, suffix: "°C")
                parameterRow("Durée", value: $step.durationMinutes, suffix: "min")
                HStack {
                    Text("Vitesse / réglage")
                    Spacer()
                    TextField("ex. vitesse 4", text: $step.speed)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section("Ingrédients utilisés (entrées)") {
                if available.isEmpty {
                    Text("Rien de disponible à cette étape. Ajoutez des ingrédients à la recette, ou une étape précédente doit produire un résultat.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(available) { item in
                        inputRow(for: item)
                    }
                }
            }

            Section("Résultat produit (sortie)") {
                Toggle("Cette étape produit un résultat", isOn: outputEnabled)
                if let out = step.output {
                    TextField("Nom (ex. Pâte)", text: producedName(out))
                    HStack {
                        TextField("Quantité", value: quantityBinding(out), format: .number)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                        Picker("Unité", selection: unitBinding(out)) {
                            Text("—").tag(Optional<MeasureUnit>.none)
                            ForEach(units) { unit in Text(unit.singular).tag(Optional(unit)) }
                        }
                        .labelsHidden()
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

    // MARK: Inputs

    @ViewBuilder
    private func inputRow(for item: RecipeFlow.Available) -> some View {
        let comp = item.component
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(comp.displayName)
                Spacer()
                TextField("0", value: consumption(for: comp), format: .number)
                    .multilineTextAlignment(.trailing)
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                    .frame(maxWidth: 70)
                Text(comp.unit?.singular ?? "").foregroundStyle(.secondary)
            }
            Text("disponible : \(remainingText(item))")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    private func remainingText(_ item: RecipeFlow.Available) -> String {
        let r = item.remaining
        let n = r == r.rounded() ? String(Int(r)) : String(format: "%.2f", r)
        return item.component.unit.map { "\(n) \($0.label(for: r))" } ?? n
    }

    private func consumption(for comp: RecipeIngredient) -> Binding<Double?> {
        Binding(
            get: {
                let q = existingInput(comp)?.quantity ?? 0
                return q > 0 ? q : nil
            },
            set: { newValue in setConsumption(comp, newValue ?? 0) }
        )
    }

    private func existingInput(_ comp: RecipeIngredient) -> StepInput? {
        step.inputs?.first { $0.component?.persistentModelID == comp.persistentModelID }
    }

    private func setConsumption(_ comp: RecipeIngredient, _ qty: Double) {
        if let existing = existingInput(comp) {
            if qty <= 0 { context.delete(existing) } else { existing.quantity = qty }
        } else if qty > 0 {
            let input = StepInput(quantity: qty)
            input.step = step
            input.component = comp
            context.insert(input)
        }
    }

    // MARK: Output

    private var outputEnabled: Binding<Bool> {
        Binding(
            get: { step.output != nil },
            set: { on in
                if on, step.output == nil {
                    let out = RecipeIngredient(order: 9999)
                    out.recipe = recipe
                    out.producedByStep = step
                    out.unit = units.first
                    context.insert(out)
                } else if !on, let out = step.output {
                    context.delete(out)
                }
            }
        )
    }

    private func producedName(_ out: RecipeIngredient) -> Binding<String> {
        Binding(get: { out.producedName }, set: { out.producedName = $0 })
    }

    private func quantityBinding(_ out: RecipeIngredient) -> Binding<Double> {
        Binding(get: { out.quantity }, set: { out.quantity = $0 })
    }

    private func unitBinding(_ out: RecipeIngredient) -> Binding<MeasureUnit?> {
        Binding(get: { out.unit }, set: { out.unit = $0 })
    }

    // MARK: Parameters helper

    @ViewBuilder
    private func parameterRow(_ label: String, value: Binding<Int?>, suffix: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("—", value: value, format: .number)
                .multilineTextAlignment(.trailing)
                #if os(iOS)
                .keyboardType(.numberPad)
                #endif
                .frame(maxWidth: 80)
            Text(suffix).foregroundStyle(.secondary)
        }
    }

    private func cancel() {
        if isNew { context.delete(step) }
        dismiss()
    }
}
