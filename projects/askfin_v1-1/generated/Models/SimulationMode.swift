// SimulationMode.swift
// Behavioral contract for a simulation session.
//
// Realistic (Generalprobe): mirrors official exam — no feedback,
// strict timing, Vorfahrt instant-fail enforced.
// Practice (Übungsmodus): relaxed — feedback after each answer,
// instant-fail disabled, extended time limit.

enum SimulationMode: String, Codable, CaseIterable {
    case realistic
    case practice

    var displayName: String {
        switch self {
        case .realistic: "Generalprobe"
        case .practice:  "Übungsmodus"
        }
    }

    /// Whether the learner sees correct/incorrect feedback after each answer.
    var allowsFeedback: Bool {
        self == .practice
    }

    /// Whether the Vorfahrt instant-fail rule applies.
    /// Kept as a named property (not inlined as `self == .realistic`) so
    /// adding a third mode (e.g. .timed) only requires updating this switch,
    /// not a codebase-wide search for `self == .realistic`.
    var enforceInstantFail: Bool {
        switch self {
        case .realistic: true
        case .practice:  false
        }
    }
}