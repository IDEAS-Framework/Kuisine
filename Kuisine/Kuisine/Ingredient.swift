import Foundation
import SwiftData

/// A reusable ingredient in the shared catalog. Created on the fly the first
/// time it's used (see `IngredientLineEditView`), then reusable across recipes.
/// Units are chosen per line from the shared `Unit` list, so the catalog entry
/// itself stays simple.
@Model
final class Ingredient {
    /// Stable identity (dedupe + inheritance-ready); not a CloudKit unique constraint.
    var uid: UUID = UUID()
    var name: String = ""
    var category: String = ""

    @Relationship(deleteRule: .nullify, inverse: \RecipeIngredient.ingredient)
    var usages: [RecipeIngredient]? = []

    init(name: String = "", category: String = "") {
        self.uid = UUID()
        self.name = name
        self.category = category
    }
}
