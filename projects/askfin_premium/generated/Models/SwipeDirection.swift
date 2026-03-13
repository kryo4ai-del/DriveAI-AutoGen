import Foundation

/// Maps a physical swipe gesture to answer slot A/B/C/D.
enum SwipeDirection: String, CaseIterable, Codable {
    case right  // A
    case left   // B
    case up     // C
    case down   // D

    /// Spatial hint for card edge display.
    /// - Important: Always apply `.accessibilityHidden(true)` to views
    ///   showing this value — Unicode arrows are meaningless when read aloud.
    var spatialHintLabel: String {
        switch self {
        case .right: return "A →"
        case .left:  return "← B"
        case .up:    return "↑ C"
        case .down:  return "D ↓"
        }
    }

    var answerLetter: String {
        switch self {
        case .right: return "A"
        case .left:  return "B"
        case .up:    return "C"
        case .down:  return "D"
        }
    }
}
