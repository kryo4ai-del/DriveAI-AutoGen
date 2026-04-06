import Foundation

extension PushNotificationTrigger {
    var isEnabledInMVP: Bool {
        let enabledTriggers: [PushNotificationTrigger] = [
            .examPassed(score: 0),
            .examFailed,
            .streakMilestone(days: 7),
            .streakMilestone(days: 14),
            .streakMilestone(days: 30)
        ]
        return enabledTriggers
            .map { $0.identifier }
            .contains(self.identifier)
    }
}