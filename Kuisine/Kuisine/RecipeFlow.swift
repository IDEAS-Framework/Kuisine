import Foundation
import SwiftData

/// Derives the state of a recipe's process graph — what's available, and in what
/// remaining quantity — at each step. Availability is always recomputed from the
/// steps rather than stored, so it can't drift.
struct RecipeFlow {
    let recipe: Recipe

    struct Available: Identifiable {
        let component: RecipeIngredient
        let remaining: Double
        var id: PersistentIdentifier { component.persistentModelID }
    }

    /// Components available to a step at position `order`: base ingredients plus
    /// intermediates produced by earlier steps, each minus what earlier steps
    /// consumed. Quantities are in each component's own unit. A step never sees
    /// its own output. Only components with a positive remainder are returned.
    func available(before order: Int) -> [Available] {
        let steps = recipe.sortedSteps

        var remaining: [PersistentIdentifier: Double] = [:]
        var component: [PersistentIdentifier: RecipeIngredient] = [:]

        for base in recipe.sortedIngredients {
            remaining[base.persistentModelID] = base.quantity
            component[base.persistentModelID] = base
        }
        for step in steps where step.order < order {
            if let out = step.output {
                remaining[out.persistentModelID] = out.quantity
                component[out.persistentModelID] = out
            }
        }
        for step in steps where step.order < order {
            for input in (step.inputs ?? []) {
                guard let comp = input.component else { continue }
                remaining[comp.persistentModelID, default: 0] -= input.quantity
            }
        }

        return component.values
            .compactMap { comp -> Available? in
                let left = remaining[comp.persistentModelID] ?? 0
                guard left > 0.0001 else { return nil }
                return Available(component: comp, remaining: left)
            }
            .sorted { $0.component.order < $1.component.order }
    }
}
