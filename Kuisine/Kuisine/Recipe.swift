import Foundation
import SwiftData

/// A recipe the user stores and iterates on over time.
///
/// The base fields plus structured `recipeIngredients` and `steps` hold the
/// "current best" version. `experiments` records tweaks tried along the way,
/// and `parent`/`variants` capture forked variants (inheritance-ready).
///
/// All properties have defaults and relationships are optional, as required by
/// CloudKit-backed SwiftData.
@Model
final class Recipe {
    var uid: UUID = UUID()
    var title: String = ""
    var summary: String = ""

    /// Personal by default. Later drives the private vs. shared family split.
    var isShared: Bool = false

    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    // Variant lineage. A variant is a fork-copy that links back to its parent.
    var parent: Recipe?
    @Relationship(deleteRule: .nullify, inverse: \Recipe.parent)
    var variants: [Recipe]? = []

    @Relationship(deleteRule: .cascade, inverse: \RecipeIngredient.recipe)
    var recipeIngredients: [RecipeIngredient]? = []

    @Relationship(deleteRule: .cascade, inverse: \Step.recipe)
    var steps: [Step]? = []

    @Relationship(deleteRule: .cascade, inverse: \Experiment.recipe)
    var experiments: [Experiment]? = []

    init(title: String = "", summary: String = "") {
        self.uid = UUID()
        self.title = title
        self.summary = summary
        self.createdAt = .now
        self.updatedAt = .now
    }

    /// Base ingredients only (intermediates produced by steps are excluded here;
    /// they appear as step outputs in the process graph).
    var sortedIngredients: [RecipeIngredient] {
        (recipeIngredients ?? [])
            .filter { $0.producedByStep == nil }
            .sorted { $0.order < $1.order }
    }

    var sortedSteps: [Step] {
        (steps ?? []).sorted { $0.order < $1.order }
    }

    var sortedExperiments: [Experiment] {
        (experiments ?? []).sorted { $0.date > $1.date }
    }

    var isVariant: Bool { parent != nil }

    /// Fork-copy this recipe into a new variant linked to it. Ingredients share
    /// the same catalog entries; steps remap their used-ingredient links to the
    /// copied lines. Experiments are not copied — a variant starts fresh.
    @discardableResult
    func makeVariant(in context: ModelContext) -> Recipe {
        let copy = Recipe(title: title, summary: summary)
        copy.parent = self
        context.insert(copy)

        // Base ingredients, keyed by original id so step inputs can remap.
        var componentMap: [PersistentIdentifier: RecipeIngredient] = [:]
        for line in sortedIngredients {
            let newLine = RecipeIngredient(quantity: line.quantity, note: line.note, order: line.order)
            newLine.ingredient = line.ingredient
            newLine.unit = line.unit
            newLine.recipe = copy
            context.insert(newLine)
            componentMap[line.persistentModelID] = newLine
        }

        // Steps in order, so an intermediate exists before a later step consumes it.
        for step in sortedSteps {
            let newStep = Step(order: step.order, text: step.text, action: step.action)
            newStep.durationMinutes = step.durationMinutes
            newStep.temperatureCelsius = step.temperatureCelsius
            newStep.speed = step.speed
            newStep.recipe = copy
            context.insert(newStep)

            if let out = step.output {
                let newOut = RecipeIngredient(quantity: out.quantity, note: out.note, order: out.order)
                newOut.producedName = out.producedName
                newOut.unit = out.unit
                newOut.recipe = copy
                newOut.producedByStep = newStep
                context.insert(newOut)
                componentMap[out.persistentModelID] = newOut
            }

            for input in step.sortedInputs {
                guard let comp = input.component,
                      let mapped = componentMap[comp.persistentModelID] else { continue }
                let newInput = StepInput(quantity: input.quantity)
                newInput.step = newStep
                newInput.component = mapped
                context.insert(newInput)
            }
        }

        return copy
    }
}
