import Foundation

/// Represents the focus/concentration level of a user session
enum FocusLevel: String, Codable, CaseIterable, Identifiable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case deep = "deep"

    var id: String { rawValue }

    // MARK: - Display Properties

    var displayName: String {
        switch self {
        case .low:    return "Low"
        case .medium: return "Medium"
        case .high:   return "High"
        case .deep:   return "Deep Focus"
        }
    }

    // MARK: - Numeric Representation

    /// Numeric score 1–4 for comparisons and analytics
    var score: Int {
        switch self {
        case .low:    return 1
        case .medium: return 2
        case .high:   return 3
        case .deep:   return 4
        }
    }

    /// Normalised value in [0.0, 1.0]
    var normalised: Double {
        Double(score) / Double(Self.allCases.count)
    }

    // MARK: - Initialisation Helpers

    /// Create a FocusLevel from a numeric score (1–4). Returns nil for out-of-range values.
    init?(score: Int) {
        switch score {
        case 1: self = .low
        case 2: self = .medium
        case 3: self = .high
        case 4: self = .deep
        default: return nil
        }
    }

    /// Create a FocusLevel from a normalised value in [0.0, 1.0].
    init(normalised value: Double) {
        let clamped = min(max(value, 0.0), 1.0)
        let score = Int((clamped * Double(Self.allCases.count - 1)).rounded()) + 1
        self = Self(score: score) ?? .medium
    }
}

// MARK: - Comparable

extension FocusLevel: Comparable {
    static func < (lhs: FocusLevel, rhs: FocusLevel) -> Bool {
        lhs.score < rhs.score
    }
}

// MARK: - CustomStringConvertible

extension FocusLevel: CustomStringConvertible {
    var description: String {
        switch self {
        case .low:
            return "Light engagement, easily distracted"
        case .medium:
            return "Moderate focus with occasional distractions"
        case .high:
            return "Strong concentration on the task"
        case .deep:
            return "Full immersion, maximum productivity"
        }
    }
}