@MainActor
final class NotificationScheduler {
    static func scheduleReviewReminder(
        questionId: String,
        dueDate: Date,
        categoryName: String
    ) {
        let trigger = UNCalendarNotificationTrigger(
            matching: Calendar.current.dateComponents([.year, .month, .day, .hour], from: dueDate),
            repeats: false
        )
        
        let content = UNMutableNotificationContent()
        content.title = "Zeit zum Üben"  // "Time to practice"
        content.body = "Wiederholen Sie: \(categoryName)"  // "Review: [category]"
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        content.sound = .default
        
        // Tie to domain: show a traffic sign emoji
        content.launchImageName = "notification-traffic-sign"
        
        let request = UNNotificationRequest(identifier: questionId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                NSLog("❌ Failed to schedule notification: \(error)")
            }
        }
    }
}