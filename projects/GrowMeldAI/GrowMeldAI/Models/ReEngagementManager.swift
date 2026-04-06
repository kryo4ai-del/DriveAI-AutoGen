// In AppDelegate or background task:
class ReEngagementManager {
    func scheduleReturnReminder(userLastAnsweredAt: Date) {
        let daysSinceActivity = Calendar.current.dateComponents([.day], from: userLastAnsweredAt, to: Date()).day ?? 0
        
        // Optimal reminder: 1 day after last session (Ebbinghaus forgetting curve)
        // Users forget ~50% after 1 day without review
        if daysSinceActivity == 1 {
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString(
                "return.title",
                value: "Deine Fragen warten auf Wiederholung",
                comment: "Spaced repetition reminder"
            )
            content.body = String(
                format: NSLocalizedString(
                    "return.body",
                    value: "Du hast gestern %@ Fragen beantwortet. Heute ist die beste Zeit, sie zu wiederholen (Retention +50%%).",
                    comment: ""
                ),
                yesterdayCount
            )
            content.sound = .default
            content.badge = NSNumber(value: 1)
            
            // Link directly to weak category from yesterday
            var userInfo: [AnyHashable: Any] = ["type": "return_to_study"]
            if let weakCategory = learningAnalytics.yesterdaysWeakestCategory {
                userInfo["category"] = weakCategory
            }
            content.userInfo = userInfo
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
            let request = UNNotificationRequest(identifier: "spaced_reminder", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule reminder: \(error)")
                }
            }
        }
    }
}