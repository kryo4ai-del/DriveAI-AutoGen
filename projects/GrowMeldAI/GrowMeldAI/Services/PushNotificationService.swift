class PushNotificationService {
    let repository: NotificationConsentRepository  // ← Make testable
    
    init(repository: NotificationConsentRepository = NotificationConsentRepository()) {
        self.repository = repository
    }
}
