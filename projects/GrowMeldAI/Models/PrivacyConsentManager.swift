// PrivacyConsentManager.swift
import Foundation
import Combine

final class PrivacyConsentManager: ObservableObject {
    @Published private(set) var hasConsent: Bool = false
    @Published private(set) var isConsentRequired: Bool = false
    @Published private(set) var isConsentPending: Bool = true

    private let userDefaults = UserDefaults.standard
    private let consentKey = "privacyConsentGiven"
    private let regionKey = "userRegion"

    init() {
        checkConsentStatus()
        checkRegionRequirements()
    }

    private func checkConsentStatus() {
        hasConsent = userDefaults.bool(forKey: consentKey)
        isConsentPending = !hasConsent
    }

    private func checkRegionRequirements() {
        let region = LocalizationService.shared.regionCode?.lowercased() ?? "us"
        isConsentRequired = region == "au" || region == "ca"
    }

    func giveConsent() {
        userDefaults.set(true, forKey: consentKey)
        hasConsent = true
        isConsentPending = false
    }

    func denyConsent() {
        userDefaults.set(false, forKey: consentKey)
        hasConsent = false
        isConsentPending = false
    }

    func shouldShowConsent() -> Bool {
        isConsentRequired && isConsentPending
    }
}