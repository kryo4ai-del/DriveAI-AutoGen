import Foundation

struct ConsentPolicy {
    static let neverAskAgainDuration: TimeInterval = 90 * 24 * 3600
    static let minTimeBetweenRetries: TimeInterval = 7 * 24 * 3600

    /// MVP-enabled triggers (type-safe, not strings)
    static let enabledTriggersForMVP: [PushNotificationTrigger] = [
        .examPassed(score: 0),
        .examFailed,
        .streakMilestone(days: 7),
        .streakMilestone(days: 14),
        .streakMilestone(days: 30)
    ]

    static func neverAskAgainExpiry(from date: Date = Date()) -> Date {
        date.addingTimeInterval(neverAskAgainDuration)
    }
}

extension PushNotificationTrigger {
    var isEnabledInMVP: Bool {
        ConsentPolicy.enabledTriggersForMVP
            .map { $0.identifier }
            .contains(self.identifier)
    }
}