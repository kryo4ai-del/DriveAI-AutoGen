// Models/CrashlyticsService+Extension.swift

import Foundation
import Combine

/// Thread-safe, privacy-respecting Crashlytics wrapper
/// Uses actor isolation to guarantee thread safety without `nonisolated(unsafe)`

// MARK: - Minimal CrashlyticsService (no FirebaseCrashlytics dependency)

/// Minimal PrivacyService mock for use when Firebase is unavailable
final class PrivacyService: Sendable {
    static let mock = PrivacyService()
    let analyticsEnabled: Bool

    init(analyticsEnabled: Bool = true) {
        self.analyticsEnabled = analyticsEnabled
    }
}

/// Lightweight Crashlytics wrapper that compiles without FirebaseCrashlytics
actor CrashlyticsService {
    // MARK: - Properties

    private let privacyService: PrivacyService
    private let maxBreadcrumbs: Int
    private var breadcrumbs: [String] = []

    // MARK: - Init

    init(privacyService: PrivacyService, maxBreadcrumbs: Int = 50) {
        self.privacyService = privacyService
        self.maxBreadcrumbs = maxBreadcrumbs
    }

    // MARK: - Public API

    func record(error: Error, context: [String: String] = [:]) {
        guard privacyService.analyticsEnabled else { return }
        #if DEBUG
        print("[Crashlytics] Recording error: \(error.localizedDescription), context: \(context)")
        #endif
    }

    func log(_ message: String) {
        guard privacyService.analyticsEnabled else { return }
        appendBreadcrumb(message)
        #if DEBUG
        print("[Crashlytics] \(message)")
        #endif
    }

    func setUserID(_ userID: String) {
        guard privacyService.analyticsEnabled else { return }
        #if DEBUG
        print("[Crashlytics] Set user ID: \(userID)")
        #endif
    }

    func setCustomKey(_ key: String, value: String) {
        guard privacyService.analyticsEnabled else { return }
        #if DEBUG
        print("[Crashlytics] Custom key '\(key)': \(value)")
        #endif
    }

    func recordBreadcrumb(_ crumb: String) {
        appendBreadcrumb(crumb)
    }

    // MARK: - Private

    private func appendBreadcrumb(_ crumb: String) {
        breadcrumbs.append(crumb)
        if breadcrumbs.count > maxBreadcrumbs {
            breadcrumbs.removeFirst()
        }
    }
}

// MARK: - Test Support

extension CrashlyticsService {
    // For synchronous mock access in tests
    static func createMock() -> CrashlyticsService {
        CrashlyticsService(privacyService: .mock, maxBreadcrumbs: 10)
    }
}

// MARK: - Bundle Extensions

extension Bundle {
    var appVersion: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildNumber: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }
}