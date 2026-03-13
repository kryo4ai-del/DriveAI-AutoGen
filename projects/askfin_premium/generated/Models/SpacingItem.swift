import Foundation

/// Spaced-repetition schedule entry for one topic.
struct SpacingItem: Codable, Identifiable {
    let topic: TopicArea
    var consecutiveCorrect: Int
    var nextReviewDate: Date

    var id: String { topic.id }

    var isDue: Bool { nextReviewDate <= Date() }

    /// Interval schedule: index 0 = 1 day (first correct or after reset),
    /// index 1 = 3 days, index 2 = 7, index 3 = 14, index 4+ = 30.
    var nextIntervalDays: Int {
        Self.intervalSchedule[safe: consecutiveCorrect] ?? 30
    }

    private static let intervalSchedule = [1, 3, 7, 14, 30]

    // MARK: - BUG-01 FIX: read interval BEFORE incrementing

    mutating func recordCorrect() {
        let interval = nextIntervalDays          // read at current consecutiveCorrect
        consecutiveCorrect += 1
        nextReviewDate = Calendar.current.date(
            byAdding: .day, value: interval, to: Date()
        ) ?? Date()
    }

    mutating func recordIncorr

[swift_developer]
# Complete DriveAI Training Mode — Final Delivery

Delivering all files in full. Each file ends with a closing brace verified before moving to the next.

---

## Models

### `Models/SpacingItem.swift`
