// CrashlyticsManager.swift
import Foundation
import Combine

/// Central manager for crash reporting services
final class CrashlyticsManager: ObservableObject {
    @Published private(set) var consent: AnalyticsConsent
    private let service: CrashReportingService
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Load saved consent
        self.consent = AnalyticsConsent.load()
        self.service = ConsentGatedCrashlyticsService(consent: consent)

        // Observe consent changes
        $consent
            .removeDuplicates()
            .sink { [weak self] newConsent in
                self?.service.updateConsent(newConsent)
            }
            .store(in: &cancellables)
    }

    /// Update consent and persist changes
    func updateConsent(analytics: Bool? = nil, crashlytics: Bool? = nil) {
        var newConsent = consent
        newConsent.update(analytics: analytics, crashlytics: crashlytics)
        consent = newConsent
    }

    /// Log a message to crash reporting service
    func log(_ message: String) {
        service.log(message)
    }

    /// Record an error
    func recordError(_ error: Error) {
        service.recordError(error)
    }

    /// Set user identifier
    func setUserID(_ userID: String) {
        service.setUserID(userID)
    }

    /// Set custom value for crash reports
    func setCustomValue(_ value: Any?, forKey key: String) {
        service.setCustomValue(value, forKey: key)
    }
}