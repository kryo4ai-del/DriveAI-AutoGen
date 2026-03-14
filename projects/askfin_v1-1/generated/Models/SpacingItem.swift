import Foundation

/// Spaced-repetition schedule entry for one topic.
struct SpacingItem: Codable, Identifiable {
    let topic: TopicArea
    var consecutiveCorrect: Int
    var nextReviewDate: Date

    var id: String { topic.id }
    var isDue: Bool { nextReviewDate <= Date() }

    /// Interval schedule: index corresponds to consecutiveCorrect BEFORE increment.
    /// 0→1 day, 1→3 days, 2→7 days, 3→14 days, 4+→30 days.
    var nextIntervalDays: Int {
        Self.intervalSchedule[safe: consecutiveCorrect] ?? 30
    }

    private static let intervalSchedule = [1, 3, 7, 14, 30]

    // BUG-01 FIX: interval is read before incrementing so index 0 correctly
    // produces a 1-day interval on the first correct answer after a reset.
    mutating func recordCorrect() {
        let interval = nextIntervalDays
        consecutiveCorrect += 1
        nextReviewDate = Calendar.current.date(
            byAdding: .day, value: interval, to: Date()
        ) ?? Date()
    }

    mutating func recordIncorrect() {
        consecutiveCorrect = 0
        nextReviewDate = Calendar.current.date(
            byAdding: .day, value: 1, to: Date()
        ) ?? Date()
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}