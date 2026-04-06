@MainActor
final class RemindersService: RemindersService {
    static let shared = RemindersService()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {
        notificationCenter.delegate = AppNotificationDelegate.shared
    }
    
    func requestAuthorization() async throws -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
        } catch {
            throw AppError(
                title: NSLocalizedString("error.notif.authFailed.title", comment: ""),
                message: NSLocalizedString("error.notif.authFailed.msg", comment: ""),
                code: .notificationError
            )
        }
    }
    
    func scheduleReviewReminder(categoryID: String, for date: Date) async throws {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("reminder.title", comment: "")
        content.body = String(format: NSLocalizedString("reminder.body", comment: ""), categoryID)
        content.sound = .default
        content.userInfo = ["categoryID": categoryID]
        
        let trigger = UNCalendarNotificationTrigger(
            matching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: date
            ),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "review_\(categoryID)_\(UUID())",
            content: content,
            trigger: trigger
        )
        
        try await notificationCenter.add(request)
    }
    
    func cancelReminder(categoryID: String) async throws {
        let pending = await notificationCenter.pendingNotificationRequests()
        let toCancel = pending
            .filter { $0.identifier.hasPrefix("review_\(categoryID)") }
            .map { $0.identifier }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: toCancel)
    }
    
    func getScheduledReminders() async throws -> [String: Date] {
        let pending = await notificationCenter.pendingNotificationRequests()
        var result: [String: Date] = [:]
        
        for request in pending where request.identifier.hasPrefix("review_") {
            guard let categoryID = request.content.userInfo["categoryID"] as? String,
                  let trigger = request.trigger as? UNCalendarNotificationTrigger,
                  let nextDate = trigger.nextTriggerDate() else { continue }
            result[categoryID] = nextDate
        }
        
        return result
    }
}

@MainActor
final class AppNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = AppNotificationDelegate()
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound, .badge]
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard let categoryID = response.notification.request.content.userInfo["categoryID"] as? String else { return }
        
        // Post to app coordinator for navigation
        NotificationCenter.default.post(
            name: NSNotification.Name("ReminderTapped"),
            object: nil,
            userInfo: ["categoryID": categoryID]
        )
    }
}