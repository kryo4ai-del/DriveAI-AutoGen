// ✅ REFACTORED: All dependencies injectable

protocol NotificationConsentRepositoryProtocol {
    func getConsent(for triggerId: String) throws -> NotificationConsent?
    func saveConsent(_ consent: NotificationConsent) throws
    func deleteAllConsents() throws
    func shouldAskForConsent(triggerId: String) -> Bool
}

@MainActor