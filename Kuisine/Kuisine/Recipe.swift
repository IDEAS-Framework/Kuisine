import Foundation
import SwiftData

/// A recipe the user stores and iterates on over time.
///
/// The base fields hold the "current best" version of the recipe, while
/// `experiments` records the changes and tweaks tried along the way — the
/// core idea of Kuisine is that a recipe is a living, evolving thing.
///
/// All properties have defaults and relationships are optional, as required by
/// CloudKit-backed SwiftData.
@Model
final class Recipe {
    var title: String = ""
    var summary: String = ""
    var ingredients: String = ""
    var steps: String = ""

    /// Personal by default. Later this drives whether the recipe lives in the
    /// private store or the shared family collection (see backlog: sharing model).
    var isShared: Bool = false

    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \Experiment.recipe)
    var experiments: [Experiment]? = []

    init(title: String = "", summary: String = "", ingredients: String = "", steps: String = "") {
        self.title = title
        self.summary = summary
        self.ingredients = ingredients
        self.steps = steps
        self.createdAt = .now
        self.updatedAt = .now
    }

    /// Experiments newest-first, for display.
    var sortedExperiments: [Experiment] {
        (experiments ?? []).sorted { $0.date > $1.date }
    }
}
