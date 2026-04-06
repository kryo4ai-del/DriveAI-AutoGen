// Add to spec: Clarify notification behavior

protocol MaintenanceNotificationService {
    /// Send notification IF user has opted in and frequency limits allow
    func notifyAboutChecks(_ result: MaintenanceCheckResult) async throws
}

struct NotificationPreferences: Codable {
    var notifyOnHighSeverityOnly: Bool = true  // Only notify for "Wichtig"
    var maxNotificationsPerWeek: Int = 1       // Cap at 1/week
    var quietHoursStart: Int = 21               // 9 PM - 9 AM quiet
    var quietHoursEnd: Int = 9
}

// Enforce limits:
nonisolated actor DefaultMaintenanceNotificationService: MaintenanceNotificationService {
    private var notificationCountThisWeek = 0
    
    func notifyAboutChecks(_ result: MaintenanceCheckResult) async throws {
        // Only notify if:
        // 1. User opted in to notifications
        // 2. At least one check is high severity
        // 3. Haven't hit weekly notification cap
        // 4. Outside quiet hours
        
        guard 
            prefs.enableNotifications,
            result.checksPerformed.contains(where: { $0.severity == .high }),
            notificationCountThisWeek < prefs.maxNotificationsPerWeek,
            !isInQuietHours()
        else {
            return  // Silent fail; don't overwhelm user
        }
        
        // Send notification
        let content = UNMutableNotificationContent()
        content.title = "Lernfortschritt überprüft"
        content.body = "1 wichtiges Update zu Deinem Lernplan"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        try UNUserNotificationCenter.current().add(request)
        notificationCountThisWeek += 1
    }
}

// Privacy policy:
/*
Benachrichtigungen
Wenn Sie möchten, benachrichtigen wir Sie wöchentlich über wichtige Lernfortschritte.
Sie können Benachrichtigungen in den iOS-Einstellungen jederzeit deaktivieren.
Wir versenden maximal 1 Benachrichtigung pro Woche zwischen 9:00 und 21:00 Uhr.
*/