// MetaAdService.swift
import Foundation
import Combine

/// Service for managing Meta ads integration with proper memory management
final class MetaAdService: MetaAdServiceProtocol, ObservableObject {
    @Published private(set) var consentStatus: MetaConsent?
    @Published private(set) var isLoadingAds: Bool = false

    private let userDefaults: UserDefaults
    private let consentKey = "com.driveai.meta.consent"
    private var cancellables = Set<AnyCancellable>()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadSavedConsent()
    }

    // MARK: - Consent Management

    @MainActor
    func saveConsent(_ consent: MetaConsent) async throws {
        let data = try JSONEncoder().encode(consent)
        userDefaults.set(data, forKey: consentKey)
        consentStatus = consent
        trackEvent(.consentSaved)
    }

    private func loadSavedConsent() {
        guard let data = userDefaults.data(forKey: consentKey) else { return }
        do {
            consentStatus = try JSONDecoder().decode(MetaConsent.self, from: data)
        } catch {
            print("Failed to load consent: \(error)")
            userDefaults.removeObject(forKey: consentKey)
        }
    }

    func deferConsentDecision() {
        // Clear any temporary consent state
        userDefaults.removeObject(forKey: consentKey)
        consentStatus = nil
    }

    // MARK: - Ad Loading

    @MainActor
    func loadAdsIfConsented() async {
        guard let consent = consentStatus,
              consent.allowPersonalizedAds || consent.allowAnonymousStats else {
            return
        }

        isLoadingAds = true

        // Simulate ad loading
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        isLoadingAds = false
        trackEvent(.adDisplayed)
    }

    // MARK: - Analytics

    func trackEvent(_ event: MetaAdEvent) {
        // In production, this would send to analytics service
        print("Tracked event: \(event)")
    }

    // MARK: - Memory Management

    deinit {
        cancellables.removeAll()
    }
}