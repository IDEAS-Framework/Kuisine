import Foundation

/// The kind of action a recipe step performs. Drives an icon and helps
/// experiments and (later) scaling reason about what a step does.
enum StepAction: String, Codable, CaseIterable, Identifiable {
    case none
    case prep       // préparer
    case preheat    // préchauffer
    case cook       // cuire
    case heat       // chauffer
    case simmer     // mijoter
    case fry        // faire revenir
    case mix        // mélanger
    case whisk      // battre
    case knead      // pétrir
    case fold        // incorporer
    case blend      // mixer
    case chop       // hacher
    case cool       // refroidir
    case rest       // reposer

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return "Autre"
        case .prep: return "Préparer"
        case .preheat: return "Préchauffer"
        case .cook: return "Cuire"
        case .heat: return "Chauffer"
        case .simmer: return "Mijoter"
        case .fry: return "Faire revenir"
        case .mix: return "Mélanger"
        case .whisk: return "Battre"
        case .knead: return "Pétrir"
        case .fold: return "Incorporer"
        case .blend: return "Mixer"
        case .chop: return "Hacher"
        case .cool: return "Refroidir"
        case .rest: return "Reposer"
        }
    }

    var symbolName: String {
        switch self {
        case .none: return "circle"
        case .prep: return "hand.raised"
        case .preheat: return "thermometer.high"
        case .cook: return "flame"
        case .heat: return "thermometer.sun"
        case .simmer: return "flame"
        case .fry: return "frying.pan"
        case .mix: return "arrow.trianglehead.2.clockwise.rotate.90"
        case .whisk: return "tornado"
        case .knead: return "hands.and.sparkles"
        case .fold: return "arrow.turn.down.right"
        case .blend: return "waveform"
        case .chop: return "scissors"
        case .cool: return "snowflake"
        case .rest: return "clock"
        }
    }

    /// Actions where a temperature usually matters — used to surface the field first.
    var usuallyHasTemperature: Bool {
        switch self {
        case .preheat, .cook, .heat, .simmer, .fry, .cool: return true
        default: return false
        }
    }
}
