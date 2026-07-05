import Foundation

/// The kind of measurement an ingredient can be expressed in.
enum MeasurementDimension: String, Codable, CaseIterable, Identifiable {
    case weight   // poids
    case volume   // volume
    case count    // compte

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .weight: return "Poids"
        case .volume: return "Volume"
        case .count: return "Compte"
        }
    }
}

/// A concrete unit a quantity can be given in. French-first, metric + customary.
enum MeasurementUnit: String, Codable, CaseIterable, Identifiable {
    // Poids
    case gram, kilogram
    // Volume métrique
    case milliliter, liter
    // Volume coutumier
    case cuillereACafe, cuillereASoupe, tasse
    // Compte
    case piece, pincee, gousse, botte

    var id: String { rawValue }

    var dimension: MeasurementDimension {
        switch self {
        case .gram, .kilogram: return .weight
        case .milliliter, .liter, .cuillereACafe, .cuillereASoupe, .tasse: return .volume
        case .piece, .pincee, .gousse, .botte: return .count
        }
    }

    /// True for spoons/cup — the "standard volumes" that are opt-in per ingredient.
    var isCustomaryVolume: Bool {
        switch self {
        case .cuillereACafe, .cuillereASoupe, .tasse: return true
        default: return false
        }
    }

    /// Short label shown next to a quantity.
    var shortName: String {
        switch self {
        case .gram: return "g"
        case .kilogram: return "kg"
        case .milliliter: return "mL"
        case .liter: return "L"
        case .cuillereACafe: return "c. à c."
        case .cuillereASoupe: return "c. à s."
        case .tasse: return "tasse"
        case .piece: return "pièce"
        case .pincee: return "pincée"
        case .gousse: return "gousse"
        case .botte: return "botte"
        }
    }

    var longName: String {
        switch self {
        case .gram: return "gramme"
        case .kilogram: return "kilogramme"
        case .milliliter: return "millilitre"
        case .liter: return "litre"
        case .cuillereACafe: return "cuillère à café"
        case .cuillereASoupe: return "cuillère à soupe"
        case .tasse: return "tasse"
        case .piece: return "pièce"
        case .pincee: return "pincée"
        case .gousse: return "gousse"
        case .botte: return "botte"
        }
    }
}
