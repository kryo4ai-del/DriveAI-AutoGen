static let enabledTriggersForMVP: [PushNotificationTrigger] = [
    .examPassed(score: 0),
    .examFailed,
    .streakMilestone(days: 7),
    .streakMilestone(days: 14),
    .streakMilestone(days: 30)
]

// Type-safe helper:
extension PushNotificationTrigger {
    var isEnabledInMVP: Bool {
        ConsentPolicy.enabledTriggersForMVP
            .map { $0.identifier }
            .contains(self.identifier)
    }
}