import Foundation

/// Spaced-repetition schedule entry.
struct SpacingItem: Codable, Identifiable {
    let id: String
    let topic: TopicArea
    var consecutiveCorrect: Int
    var nextReviewDate: Date
    var reviewCount: Int

    var isDue: Bool { nextReviewDate <= Date() }

    /// Interval schedule: index corresponds to consecutiveCorrect BEFORE increment.
    /// 0→1 day, 1→3 days, 2→7 days, 3→14 days, 4+→30 days.
    var nextIntervalDays: Int {
        Self.intervalSchedule[safe: consecutiveCorrect] ?? 30
    }

    private static let intervalSchedule = [1, 3, 7, 14, 30]

    static func nextInterval(after correctCount: Int) -> Int {
        intervalSchedule[safe: correctCount] ?? 30
    }

    mutating func recordCorrect() {
        let interval = nextIntervalDays
        consecutiveCorrect += 1
        reviewCount += 1
        nextReviewDate = Calendar.current.date(
            byAdding: .day, value: interval, to: Date()
        ) ?? Date()
    }

    mutating func recordIncorrect() {
        consecutiveCorrect = 0
        reviewCount += 1
        nextReviewDate = Calendar.current.date(
            byAdding: .day, value: 1, to: Date()
        ) ?? Date()
    }

    init(
        id: String,
        topic: TopicArea,
        consecutiveCorrect: Int = 0,
        nextReviewDate: Date = Date(),
        reviewCount: Int = 0
    ) {
        self.id = id
        self.topic = topic
        self.consecutiveCorrect = consecutiveCorrect
        self.nextReviewDate = nextReviewDate
        self.reviewCount = reviewCount
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
