import Foundation

/// Anxiety self-report scale used before and after a BreathFlow session.
///
/// Cases are declared highest→lowest so `allCases` iterates in that order.
/// UI that renders left-to-right (nervous → calm) should use `allCases` directly.
/// UI that renders calm → nervous should use `allCases.reversed()`.
enum AnxietyLevel: Int, CaseIterable, Identifiable {
    case veryHigh = 5
    case high     = 4
    case medium   = 3
    case low      = 2
    case veryLow  = 1

    var id: Int { rawValue }

    var emoji: String {
        switch self {
        case .veryHigh: return "😰"
        case .high:     return "😟"
        case .medium:   return "😐"
        case .low:      return "🙂"
        case .veryLow:  return "😌"
        }
    }

    var label: String {
        switch self {
        case .veryHigh: return "Sehr nervös"
        case .high:     return "Nervös"
        case .medium:   return "Neutral"
        case .low:      return "Ruhig"
        case .veryLow:  return "Sehr ruhig"
        }
    }

    /// Explicit VoiceOver description — not emoji-dependent.
    var accessibleDescription: String { label }
}