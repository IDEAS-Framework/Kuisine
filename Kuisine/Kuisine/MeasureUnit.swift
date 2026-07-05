import Foundation
import SwiftData

/// A measurement unit in the shared, extensible list. Stores singular and
/// plural forms so quantities read correctly ("1 pincée", "3 pincées").
///
/// Named `MeasureUnit` to avoid colliding with Foundation's `Unit`.
@Model
final class MeasureUnit {
    var uid: UUID = UUID()
    var singular: String = ""
    var plural: String = ""
    var order: Int = 0
    /// Kept for future conversion/grouping; defaults to count.
    var dimensionRaw: String = MeasurementDimension.count.rawValue

    @Relationship(inverse: \RecipeIngredient.unit)
    var usages: [RecipeIngredient]? = []

    init(singular: String = "", plural: String = "", order: Int = 0,
         dimension: MeasurementDimension = .count) {
        self.uid = UUID()
        self.singular = singular
        self.plural = plural.isEmpty ? singular : plural
        self.order = order
        self.dimensionRaw = dimension.rawValue
    }

    var dimension: MeasurementDimension {
        get { MeasurementDimension(rawValue: dimensionRaw) ?? .count }
        set { dimensionRaw = newValue.rawValue }
    }

    /// French pluralization: singular for |q| < 2, plural otherwise.
    func label(for quantity: Double) -> String {
        abs(quantity) < 2 ? singular : (plural.isEmpty ? singular : plural)
    }

    /// Seed the default French units the first time the app runs.
    static func seedDefaultsIfNeeded(in context: ModelContext) {
        let existing = (try? context.fetchCount(FetchDescriptor<MeasureUnit>())) ?? 0
        guard existing == 0 else { return }

        let defaults: [(String, String, MeasurementDimension)] = [
            ("gramme", "grammes", .weight),
            ("kilogramme", "kilogrammes", .weight),
            ("millilitre", "millilitres", .volume),
            ("litre", "litres", .volume),
            ("cuillère à café", "cuillères à café", .volume),
            ("cuillère à soupe", "cuillères à soupe", .volume),
            ("tasse", "tasses", .volume),
            ("pièce", "pièces", .count),
            ("pincée", "pincées", .count),
            ("gousse", "gousses", .count),
            ("botte", "bottes", .count),
        ]
        for (index, def) in defaults.enumerated() {
            context.insert(MeasureUnit(singular: def.0, plural: def.1, order: index, dimension: def.2))
        }
    }
}
