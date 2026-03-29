import Foundation

/// Defines a breathing pattern with per-phase durations and cycle count.
///
/// Invariants:
/// - All duration values must be ≥ 0. Negative values are clamped at runtime.
/// - `holdSeconds` may be 0; the hold phase is skipped automatically by the ViewModel.
///   Do not pass `holdSeconds: 0` expecting a `.hold` phase to appear.
/// - `totalCycles` must be ≥ 1.
struct BreathPattern: Equatable {
    let name: String
    let inhaleSeconds: Double
    let holdSeconds: Double
    let exhaleSeconds: Double
    let totalCycles: Int

    var cycleDuration: Double {
        inhaleSeconds + holdSeconds + exhaleSeconds
    }

    // MARK: - Presets

    static let boxBreathing = BreathPattern(
        name: "Box Breathing",
        inhaleSeconds: 4,
        holdSeconds: 4,
        exhaleSeconds: 4,
        totalCycles: 3
    )

    static let relaxed = BreathPattern(
        name: "Entspannung",
        inhaleSeconds: 4,
        holdSeconds: 2,
        exhaleSeconds: 6,
        totalCycles: 3
    )

    /// `holdSeconds` is 1, not 0, to avoid zero-duration hold phase.
    /// See ViewModel invariant note in `advancePhase()`.
    static let quick = BreathPattern(
        name: "Schnell-Focus",
        inhaleSeconds: 3,
        holdSeconds: 1,
        exhaleSeconds: 3,
        totalCycles: 2
    )
}