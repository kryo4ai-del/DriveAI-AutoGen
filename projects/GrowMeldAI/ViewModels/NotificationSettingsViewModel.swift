@MainActor
class NotificationSettingsViewModel: ObservableObject {
    private let repository: NotificationConsentRepositoryProtocol
    
    init(repository: NotificationConsentRepositoryProtocol = NotificationConsentRepository()) {
        self.repository = repository
    }
    
    func isConsentGranted(for trigger: PushNotificationTrigger) -> Bool {
        do {
            guard let consent = try repository.getConsent(for: trigger.identifier) else {
                return false
            }
            return consent.decision == .allowed
        } catch {
            return false // Treat decode errors as "not granted"
        }
    }
    
    func resetConsentFor(triggerId: String) throws {
        try repository.deleteConsent(for: triggerId)
    }
    
    func deleteAllConsents() throws {
        try repository.deleteAllConsents()
    }
}