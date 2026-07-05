import Foundation
import SwiftData

/// A single recorded change or experiment tried on a `Recipe` — the heart of
/// Kuisine's "improve your recipes over time" idea. An experiment can point at
/// a specific ingredient line or step it concerns.
@Model
final class Experiment {
    var uid: UUID = UUID()
    var title: String = ""
    /// What was changed (more garlic, longer proof, swapped butter for oil…).
    var notes: String = ""
    /// How it turned out.
    var outcome: String = ""
    /// 0 = unrated, otherwise 1...5.
    var rating: Int = 0
    /// Marked as a keeper — a change worth folding back into the base recipe.
    var keep: Bool = false
    var date: Date = Date.now

    var recipe: Recipe?

    // Optional target this experiment concerns.
    var targetIngredient: RecipeIngredient?
    var targetStep: Step?

    init(title: String = "", notes: String = "", outcome: String = "", rating: Int = 0, keep: Bool = false) {
        self.uid = UUID()
        self.title = title
        self.notes = notes
        self.outcome = outcome
        self.rating = rating
        self.keep = keep
        self.date = .now
    }
}
