// File: Services/PrivacyConsentService.swift
import Foundation
import Combine
import SwiftUI

/// Service for managing user consent for analytics tracking in compliance with GDPR/DSGVO
/// Handles both online and offline consent states with automatic synchronization
final class PrivacyConsentService: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var hasConsent: Bool = false
    @Published private(set) var isSyncing: Bool = false
    @Published private(set) var lastSyncDate: Date?

    // MARK: - Private Properties
    private let userDefaults: UserDefaults
    private let syncQueue = DispatchQueue(label: "com.driveai.consent.sync", qos: .utility)
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadInitialConsentState()
    }

    // MARK: - Consent Management
    func setConsent(_ granted: Bool) {
        guard hasConsent != granted else { return }

        hasConsent = granted
        persistConsentLocally(granted)

        if granted {
            syncWithFirebase()
        } else {
            // Clear any pending analytics data if consent is revoked
            clearPendingAnalyticsData()
        }
    }

    func requestConsent() -> Bool {
        // In a real implementation, this would show a consent dialog
        // For now, return the current state
        return hasConsent
    }

    // MARK: - Sync Mechanism
    private func syncWithFirebase() {
        guard hasConsent else { return }

        isSyncing = true

        syncQueue.async { [weak self] in
            // Simulate network delay
            Thread.sleep(forTimeInterval: 0.5)

            DispatchQueue.main.async { [weak self] in
                self?.isSyncing = false
                self?.lastSyncDate = Date()
                // In a real implementation, this would call Firebase Analytics API
                print("Consent synced with Firebase Analytics")
            }
        }
    }

    private func persistConsentLocally(_ granted: Bool) {
        userDefaults.set(granted, forKey: "analyticsConsentGranted")
    }

    private func loadInitialConsentState() {
        hasConsent = userDefaults.bool(forKey: "analyticsConsentGranted")
    }

    private func clearPendingAnalyticsData() {
        // In a real implementation, this would clear any locally queued analytics events
        print("Clearing pending analytics data due to consent revocation")
    }

    // MARK: - Offline Handling
    func syncPendingConsent() {
        guard hasConsent else { return }
        syncWithFirebase()
    }

    func resetConsent() {
        hasConsent = false
        userDefaults.removeObject(forKey: "analyticsConsentGranted")
        clearPendingAnalyticsData()
    }
}

// MARK: - Preview Provider
struct PrivacyConsentService_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }

    struct PreviewWrapper: View {
        @StateObject private var service = PrivacyConsentService()

        var body: some View {
            VStack(spacing: 20) {
                Text("Privacy Consent Service")
                    .font(.headline)

                Toggle("Analytics Consent", isOn: Binding(
                    get: { service.hasConsent },
                    set: { service.setConsent($0) }
                ))
                .padding()

                if service.isSyncing {
                    ProgressView()
                        .padding()
                }

                if let date = service.lastSyncDate {
                    Text("Last synced: \(date.formatted())")
                        .font(.caption)
                }

                Button("Sync Now") {
                    service.syncPendingConsent()
                }
                .buttonStyle(.bordered)
                .disabled(!service.hasConsent)

                Button("Reset Consent", role: .destructive) {
                    service.resetConsent()
                }
            }
            .padding()
            .frame(maxWidth: 300)
        }
    }
}