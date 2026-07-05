import Foundation
import SwiftData

/// One consumption edge in a recipe's process graph: a `Step` consumes a given
/// `quantity` of a component (a base ingredient or an earlier step's output).
/// Quantity is expressed in the component's own unit.
@Model
final class StepInput {
    var uid: UUID = UUID()
    var quantity: Double = 0

    var step: Step?
    var component: RecipeIngredient?

    init(quantity: Double = 0) {
        self.uid = UUID()
        self.quantity = quantity
    }
}
