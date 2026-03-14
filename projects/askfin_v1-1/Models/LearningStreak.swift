// LearningStreak.swift
// Tracks consecutive learning days for motivation and consistency scoring.
//
// Pure value type — no display logic. View-layer extensions live in
// LearningStreak+Display.swift.
//
// Used by:
//   - ReadinessScoreService (consistency component)
//   - SessionSummaryView (streak counter)

import Foundation

struct LearningStreak: Codable, Equatable, Sendable {

    var currentStreak: Int
    var longestStreak: Int
    var lastSessionDate: Date?
    var totalActiveDays: Int

    // MARK: - Derived State

    /// Whether the streak is still alive (session within last 24h).
    var isAlive: Bool {
        guard let lastDate = lastSessionDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
            || Calendar.current.isDateInYesterday(lastDate)
    }

    /// Whether a session has already been completed today.
    var completedToday: Bool {
        guard let lastDate = lastSessionDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }

    // MARK: - Mutation

    /// Returns a new LearningStreak with today's activity recorded.
    /// If the streak was broken (last session > 1 day ago), resets to 1.
    func withActivityRecorded(at date: Date = Date()) -> LearningStreak {
        let calendar = Calendar.current

        // Already recorded today — no change.
        if let last = lastSessionDate, calendar.isDate(last, inSameDayAs: date) {
            return self
        }

        var updated = self
        updated.lastSessionDate = date
        updated.totalActiveDays += 1

        if let last = lastSessionDate, calendar.isDateInYesterday(last) {
            // Consecutive day — extend streak.
            updated.currentStreak += 1
        } else {
            // Streak broken or first session — reset to 1.
            updated.currentStreak = 1
        }

        updated.longestStreak = max(updated.longestStreak, updated.currentStreak)
        return updated
    }

    // MARK: - Factory

    static let empty = LearningStreak(
        currentStreak: 0,
        longestStreak: 0,
        lastSessionDate: nil,
        totalActiveDays: 0
    )
}
