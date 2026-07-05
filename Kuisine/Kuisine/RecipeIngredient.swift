import Foundation
import SwiftData

/// One ingredient line inside a recipe: a link to the catalog `Ingredient`
/// plus the quantity and unit for this particular recipe.
@Model
final class RecipeIngredient {
    /// Stable element identity (inheritance-ready — a variant's line can be
    /// matched back to the parent's line it descends from).
    var uid: UUID = UUID()
    var quantity: Double = 0
    var unitRaw: String = MeasurementUnit.gram.rawValue
    /// Free note, e.g. "finement haché".
    var note: String = ""
    var order: Int = 0

    var ingredient: Ingredient?
    var recipe: Recipe?

    /// Steps that consume this ingredient (many-to-many).
    @Relationship(inverse: \Step.usedIngredients)
    var steps: [Step]? = []

    /// Experiments that target this specific line.
    @Relationship(inverse: \Experiment.targetIngredient)
    var targetingExperiments: [Experiment]? = []

    init(quantity: Double = 0, unit: MeasurementUnit = .gram, note: String = "", order: Int = 0) {
        self.uid = UUID()
        self.quantity = quantity
        self.unitRaw = unit.rawValue
        self.note = note
        self.order = order
    }

    var unit: MeasurementUnit {
        get { MeasurementUnit(rawValue: unitRaw) ?? .gram }
        set { unitRaw = newValue.rawValue }
    }

    var displayName: String {
        ingredient?.name.isEmpty == false ? ingredient!.name : "Ingrédient"
    }
}
