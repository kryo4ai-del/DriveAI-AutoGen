enum ReminderConstants {
    static let maxPendingNotifications = 64  // iOS system limit
    static let safeThreshold = 60  // Leave buffer for other apps
}

guard pending.count < ReminderConstants.safeThreshold else {
    throw ReminderError.notificationsCapped(
        pending: pending.count,
        maxAllowed: ReminderConstants.maxPendingNotifications
    )
}