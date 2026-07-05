import Foundation
import SwiftData

/// One ingredient line inside a recipe: a link to the catalog `Ingredient`
/// plus the quantity and `Unit` for this particular recipe.
@Model
final class RecipeIngredient {
    /// Stable element identity (inheritance-ready).
    var uid: UUID = UUID()
    var quantity: Double = 0
    /// Free note, e.g. "finement haché".
    var note: String = ""
    var order: Int = 0

    var ingredient: Ingredient?
    var unit: MeasureUnit?
    var recipe: Recipe?

    /// Steps that consume this ingredient (many-to-many).
    @Relationship(inverse: \Step.usedIngredients)
    var steps: [Step]? = []

    /// Experiments that target this specific line.
    @Relationship(inverse: \Experiment.targetIngredient)
    var targetingExperiments: [Experiment]? = []

    init(quantity: Double = 0, note: String = "", order: Int = 0) {
        self.uid = UUID()
        self.quantity = quantity
        self.note = note
        self.order = order
    }

    var displayName: String {
        ingredient?.name.isEmpty == false ? ingredient!.name : "Ingrédient"
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
