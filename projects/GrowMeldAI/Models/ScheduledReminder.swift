import UserNotifications

struct ScheduledReminder: Identifiable, Codable {
    let id: String
    let hour: Int
    let minute: Int
    let message: String
    let repeats: Bool
    
    init?(from request: UNNotificationRequest) {
        guard let trigger = request.trigger as? UNCalendarNotificationTrigger else {
            return nil
        }
        
        self.id = request.identifier
        self.hour = trigger.dateComponents.hour ?? 0
        self.minute = trigger.dateComponents.minute ?? 0
        self.message = request.content.body
        self.repeats = trigger.repeats
    }
    
    init(id: String, hour: Int, minute: Int, message: String, repeats: Bool = true) {
        self.id = id
        self.hour = hour
        self.minute = minute
        self.message = message
        self.repeats = repeats
    }
    
    func toDateComponents() -> DateComponents {
        DateComponents(hour: hour, minute: minute)
    }
    
    func formattedTime() -> String {
        String(format: "%02d:%02d", hour, minute)
    }
}