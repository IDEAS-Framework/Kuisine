import Foundation

/// The kind of measure a unit represents. Kept for grouping and future
/// volume↔weight conversion; not surfaced heavily in the UI.
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

extension String {
    /// Sentence-case: capitalize only the first letter, leave the rest as typed
    /// (so "huile d'olive" → "Huile d'olive", not "Huile D'Olive").
    var capitalizedFirstLetter: String {
        guard let first else { return self }
        return first.uppercased() + dropFirst()
    }
}
