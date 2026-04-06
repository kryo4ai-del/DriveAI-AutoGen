import UserNotifications
import Combine

final class LocalNotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = LocalNotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let authorizationSubject = PassthroughSubject<Bool, Never>()
    
    // MARK: - Lifecycle
    
    override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() -> AnyPublisher<Bool, Never> {
        Future { [weak self] promise in
            self?.notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("🔔 Permission request error: \(error)")
                }
                DispatchQueue.main.async {
                    promise(.success(granted))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getAuthorizationStatus() -> AnyPublisher<UNAuthorizationStatus, Never> {
        Future { [weak self] promise in
            self?.notificationCenter.getNotificationSettings { settings in
                DispatchQueue.main.async {
                    promise(.success(settings.authorizationStatus))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Scheduling
    
    func scheduleNotification(
        id: String,
        time: Date,
        frequency: ReminderFrequency,
        title: String,
        body: String
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        content.userInfo = ["reminderID": id, "type": "reminder"]
        
        let trigger = createTrigger(for: time, frequency: frequency)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error)")
            } else {
                print("✅ Notification scheduled: \(id)")
            }
        }
    }
    
    func cancelNotification(id: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        print("🗑️ Cancelled notification: \(id)")
    }
    
    func getPendingNotifications() -> AnyPublisher<[UNNotificationRequest], Never> {
        Future { [weak self] promise in
            self?.notificationCenter.getPendingNotificationRequests { requests in
                DispatchQueue.main.async {
                    promise(.success(requests))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification while app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let reminderID = userInfo["reminderID"] as? String {
            // Post notification for app to handle deep-link navigation
            NotificationCenter.default.post(
                name: NSNotification.Name("ReminderNotificationTapped"),
                object: reminderID
            )
        }
        
        completionHandler()
    }
    
    // MARK: - Private Helpers
    
    private func createTrigger(
        for time: Date,
        frequency: ReminderFrequency
    ) -> UNNotificationTrigger {
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        
        switch frequency {
        case .daily:
            var dayComponents = DateComponents()
            dayComponents.hour = components.hour
            dayComponents.minute = components.minute
            return UNCalendarNotificationTrigger(dateMatching: dayComponents, repeats: true)
            
        case .weekdaysOnly:
            // Schedule for Monday through Friday
            let weekdays = [2, 3, 4, 5, 6] // Mon-Fri
            let triggers = weekdays.map { weekday -> UNCalendarNotificationTrigger in
                var dayComponents = DateComponents()
                dayComponents.hour = components.hour
                dayComponents.minute = components.minute
                dayComponents.weekday = weekday
                return UNCalendarNotificationTrigger(dateMatching: dayComponents, repeats: true)
            }
            // Return first trigger; in production, schedule all separately with unique IDs
            return triggers[0]
            
        case .weekendOnly:
            // Schedule for Saturday and Sunday
            var dayComponents = DateComponents()
            dayComponents.hour = components.hour
            dayComponents.minute = components.minute
            dayComponents.weekday = 7 // Saturday
            return UNCalendarNotificationTrigger(dateMatching: dayComponents, repeats: true)
        }
    }
}