import Foundation

/// Atomic snapshot of the current breath phase and its progress.
///
/// Published as a single value so views never observe a frame where
/// phase and progress are temporarily out of sync.
struct BreathState: Equatable {
    let phase: BreathPhase
    /// Progress through the current phase: 0.0 → 1.0
    let progress: Double

    static let initial = BreathState(phase: .inhale, progress: 0)
}