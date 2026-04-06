// Features/NotificationConsent/Services/NotificationConsentService.swift
import Foundation

protocol NotificationConsentServiceProtocol {
    func saveConsent(_ decision: ConsentDecision) throws
    func loadConsent() -> ConsentDecision?
    func clearConsent() throws
}
