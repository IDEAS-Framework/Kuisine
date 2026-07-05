import Foundation
import SwiftData

/// A component of a recipe. Either a **base ingredient** (linked to a catalog
/// `Ingredient`, with a quantity + `MeasureUnit`) or an **intermediate** produced
/// by a step (e.g. « Pâte »), identified by `producedName` and `producedByStep`.
@Model
final class RecipeIngredient {
    /// Stable element identity (inheritance-ready).
    var uid: UUID = UUID()
    var quantity: Double = 0
    /// Free note, e.g. "finement haché".
    var note: String = ""
    var order: Int = 0

    /// Set for base ingredients (nil for intermediates).
    var ingredient: Ingredient?
    /// Set for intermediates produced by a step (nil for base ingredients).
    var producedName: String = ""

    var unit: MeasureUnit?
    var recipe: Recipe?

    /// The step that produces this component, if it's an intermediate.
    var producedByStep: Step?

    /// Step inputs that consume this component.
    @Relationship(inverse: \StepInput.component)
    var consumedByInputs: [StepInput]? = []

    /// Experiments that target this specific component.
    @Relationship(inverse: \Experiment.targetIngredient)
    var targetingExperiments: [Experiment]? = []

    init(quantity: Double = 0, note: String = "", order: Int = 0) {
        self.uid = UUID()
        self.quantity = quantity
        self.note = note
        self.order = order
    }

    var isIntermediate: Bool { producedByStep != nil }

    var displayName: String {
        if let name = ingredient?.name, !name.isEmpty { return name }
        if !producedName.isEmpty { return producedName }
        return "Ingrédient"
    }

    /// "200 grammes", "3 pincées", or just the number if no unit is set.
    var quantityText: String {
        let number = quantity == quantity.rounded()
            ? String(Int(quantity))
            : String(format: "%.2f", quantity)
        if let unit { return "\(number) \(unit.label(for: quantity))" }
        return number
    }
}
