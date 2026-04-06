import UserNotifications
import Foundation

/// Protocol wrapper for UNUserNotificationCenter to enable testing
protocol UNNotificationCenterProtocol: AnyObject {
    func add(_ request: UNNotificationRequest) async throws
    func removeAllPendingNotificationRequests()
    func getPendingNotificationRequests() async -> [UNNotificationRequest]
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func getNotificationSettings() async -> UNNotificationSettings
}

extension UNUserNotificationCenter: UNNotificationCenterProtocol {}

/// Implementation of notification scheduling using system notifications
final class LocalNotificationService: NotificationService {
    private let notificationCenter: UNNotificationCenterProtocol
    
    /// Identifier for daily reminder notification (ensures no duplicates)
    private static let dailyReminderIdentifier = "com.driveai.daily-reminder"
    
    init(notificationCenter: UNNotificationCenterProtocol = UNUserNotificationCenter.current()) {
        self.notificationCenter = notificationCenter
    }
    
    func scheduleReminder(time: DateComponents, message: String) async throws {
        // Validate time input
        try validateTime(time)
        
        // Ensure authorization before scheduling
        let authorized = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        guard authorized else {
            throw ReminderError.notificationsDenied
        }
        
        // Cancel any existing reminders
        notificationCenter.removeAllPendingNotificationRequests()
        
        // Build notification content
        let content = UNMutableNotificationContent()
        content.body = message
        content.sound = .default
        content.badge = NSNumber(value: 1)  // Fixed badge number
        content.interruptionLevel = .timeSensitive
        
        // Create calendar trigger for daily repeat
        guard let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true) else {
            throw ReminderError.failedToSchedule("Invalid time components")
        }
        
        // Create request with consistent identifier (prevents duplicates)
        let request = UNNotificationRequest(
            identifier: Self.dailyReminderIdentifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
        } catch {
            throw ReminderError.failedToSchedule(error.localizedDescription)
        }
    }
    
    func cancelAllReminders() async throws {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    func getScheduledReminders() async -> [ScheduledReminder] {
        let requests = await notificationCenter.getPendingNotificationRequests()
        return requests.compactMap { ScheduledReminder(from: $0) }
    }
    
    func requestAuthorization() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }
    
    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.getNotificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Private Helpers
    
    private func validateTime(_ components: DateComponents) throws {
        guard let hour = components.hour, let minute = components.minute else {
            throw ReminderError.invalidTime
        }
        guard (0...23).contains(hour) && (0...59).contains(minute) else {
            throw ReminderError.invalidTime
        }
    }
}