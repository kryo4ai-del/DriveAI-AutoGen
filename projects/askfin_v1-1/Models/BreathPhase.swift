import Foundation

/// Represents the current phase of a breath cycle.
/// Presentation-layer mappings (SF Symbols, copy) live in BreathPhaseDisplayInfo.
enum BreathPhase: String, CaseIterable, Equatable {
    case idle     = "Bereit"
    case inhale   = "Einatmen"
    case hold     = "Halten"
    case exhale   = "Ausatmen"
    case complete = "Fertig"
}