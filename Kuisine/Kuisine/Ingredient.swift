import Foundation
import SwiftData

/// A reusable ingredient in the shared catalog. Created on the fly the first
/// time it's used, then reusable across recipes. Its allowed measurement
/// dimensions declare which units a recipe may express it in.
@Model
final class Ingredient {
    /// Stable identity (dedupe + inheritance-ready); not a CloudKit unique constraint.
    var uid: UUID = UUID()
    var name: String = ""
    var category: String = ""

    // What this ingredient can be measured in.
    var allowsWeight: Bool = true
    var allowsVolume: Bool = true
    var allowsCount: Bool = true
    /// Whether spoons/cup (cuillères, tasse) are offered in addition to mL/L.
    var allowsCustomaryVolume: Bool = true

    @Relationship(deleteRule: .nullify, inverse: \RecipeIngredient.ingredient)
    var usages: [RecipeIngredient]? = []

    init(name: String = "", category: String = "") {
        self.uid = UUID()
        self.name = name
        self.category = category
    }

    /// Units offered for this ingredient, based on its allowed dimensions.
    var availableUnits: [MeasurementUnit] {
        MeasurementUnit.allCases.filter { unit in
            switch unit.dimension {
            case .weight: return allowsWeight
            case .volume: return allowsVolume && (!unit.isCustomaryVolume || allowsCustomaryVolume)
            case .count: return allowsCount
            }
        }
    }
}
