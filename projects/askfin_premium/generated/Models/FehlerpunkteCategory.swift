// FehlerpunkteCategory.swift
// Official German driving exam Fehlerpunkte categories.
//
// Scoring mirrors TÜV/DEKRA specification:
//   Vorfahrt (right of way) — 5 FP
//   Grundstoff (core knowledge) — 3 FP
//   Standard — 2 FP
//
// Passing rule: totalFP < failureThreshold (strict less-than).
//   FP = 9  → pass
//   FP = 10 → fail   ← boundary is a fail
//   FP = 11 → fail
//
// Instant-fail rule (realistic mode only):
//   2 or more Vorfahrt errors = automatic fail regardless of total FP.

enum FehlerpunkteCategory: String, Codable, CaseIterable {
    case vorfahrt
    case grundstoff
    case standard

    var fehlerpunkteValue: Int {
        switch self {
        case .vorfahrt:   5
        case .grundstoff: 3
        case .standard:   2
        }
    }

    var displayName: String {
        switch self {
        case .vorfahrt:   "Vorfahrt"
        case .grundstoff: "Grundstoff"
        case .standard:   "Standardfragen"
        }
    }
}

// MARK: - Exam Thresholds

extension FehlerpunkteCategory {

    /// Passing condition: totalFehlerpunkte < failureThreshold
    /// FP = 9 passes. FP = 10 fails. FP = 11 fails.
    /// Named "failure" threshold, not "passing" threshold, to make the
    /// boundary direction unambiguous at the call site.
    static let failureThreshold = 10

    /// Vorfahrt errors at or above this count trigger an instant fail
    /// in realistic mode, regardless of total FP.
    static let vorfahrtInstantFailCount = 2
}