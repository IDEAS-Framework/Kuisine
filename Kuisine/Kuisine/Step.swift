import Foundation
import SwiftData

/// One step in a recipe's method. Structured so experiments can target it and
/// so the process graph can track what it consumes and produces.
@Model
final class Step {
    /// Stable element identity (inheritance-ready).
    var uid: UUID = UUID()
    var order: Int = 0
    var text: String = ""
    var actionRaw: String = StepAction.none.rawValue

    /// Optional parameters — nil means "not specified".
    var durationMinutes: Int?
    var temperatureCelsius: Int?
    /// Free-form speed/setting, e.g. "vitesse 4" for a blender/Thermomix.
    var speed: String = ""

    var recipe: Recipe?

    /// What this step consumes (base ingredients and/or earlier outputs).
    @Relationship(deleteRule: .cascade, inverse: \StepInput.step)
    var inputs: [StepInput]? = []

    /// The intermediate component this step produces, if any (recipe-local).
    @Relationship(deleteRule: .cascade, inverse: \RecipeIngredient.producedByStep)
    var output: RecipeIngredient?

    /// Experiments targeting this specific step.
    @Relationship(inverse: \Experiment.targetStep)
    var targetingExperiments: [Experiment]? = []

    init(order: Int = 0, text: String = "", action: StepAction = .none) {
        self.uid = UUID()
        self.order = order
        self.text = text
        self.actionRaw = action.rawValue
    }

    var action: StepAction {
        get { StepAction(rawValue: actionRaw) ?? .none }
        set { actionRaw = newValue.rawValue }
    }

    var sortedInputs: [StepInput] {
        (inputs ?? []).sorted { ($0.component?.order ?? 0) < ($1.component?.order ?? 0) }
    }
}
