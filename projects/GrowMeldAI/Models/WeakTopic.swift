import Foundation

/// Tracks user's weak topics for follow-up reminders
struct WeakTopic: Identifiable, Codable, Hashable {
    let id: UUID
    let topicId: String
    let topicName: String
    let lastMissedDate: Date
    let missCount: Int
    let category: String

    var priority: Reminder.Priority {
        if missCount >= 5 {
            return .urgent
        } else if missCount >= 3 {
            return .high
        } else if missCount >= 1 {
            return .medium
        }
        return .low
    }

    var daysSinceMissed: Int {
        Calendar.current.dateComponents([.day], from: lastMissedDate, to: Date()).day ?? 0
    }
}