import Foundation

enum NotificationContext {
    case examCompletion
    case streakMilestone(days: Int)
    case categoryMilestone(category: String)
    case dailyReminder
}
