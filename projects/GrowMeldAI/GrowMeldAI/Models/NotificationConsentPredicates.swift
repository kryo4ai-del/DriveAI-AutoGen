import Foundation

/// Decision predicates: pure functions that determine when to show consent modal
enum NotificationConsentPredicates {
    
    /// Should we show a consent modal for this trigger?
    static func shouldRequestConsent(
        for trigger: PushNotificationTrigger,
        givenHistory history: NotificationConsent?
    ) -> Bool {
        // If no history, always ask (first time)
        guard let history = history else {
            return true
        }
        
        // If "never ask again" and still valid, don't ask
        guard history.isValid else {
            // Expiry date passed; ask again
            return true
        }
        
        // If decision was "allowed" or "denied", don't keep asking (unless a long time has passed)
        switch history.decision {
        case .allowed:
            // User already granted consent; don't ask again
            return false
        case .denied:
            // User said "not now"; ask again after 7 days
            if let lastAsked = history.decisionDate,
               Date().timeIntervalSince(lastAsked) > ConsentPolicy.minTimeBetweenPrompts {
                return true
            }
            return false
        case .neverAskAgain:
            // Already handled by `history.isValid` check above
            return false
        }
    }
    
    /// Given multiple pending triggers, which one should we show first?
    /// (Priorities: exam-related > streaks > other)
    static func prioritizeTriggers(_ triggers: [PushNotificationTrigger]) -> [PushNotificationTrigger] {
        triggers.sorted { t1, t2 in
            let priority1 = triggerPriority(t1)
            let priority2 = triggerPriority(t2)
            return priority1 > priority2 // Higher priority first
        }
    }
    
    private static func triggerPriority(_ trigger: PushNotificationTrigger) -> Int {
        switch trigger {
        case .examPassed, .examFailed:
            return 100 // Highest: moment of exam completion
        case .streakMilestone:
            return 50
        case .reviewDue:
            return 30
        case .motivationalReminder:
            return 10
        }
    }
}