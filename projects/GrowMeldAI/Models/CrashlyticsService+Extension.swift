import Foundation

actor CrashlyticsService {
    private let privacyService: PrivacyService
    private let maxBreadcrumbs: Int
    private var breadcrumbs: [String] = []

    init(privacyService: PrivacyService, maxBreadcrumbs: Int = 50) {
        self.privacyService = privacyService
        self.maxBreadcrumbs = maxBreadcrumbs
    }

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

    private func appendBreadcrumb(_ crumb: String) {
        breadcrumbs.append(crumb)
        if breadcrumbs.count > maxBreadcrumbs {
            breadcrumbs.removeFirst()
        }
    }

    static func createMock() -> CrashlyticsService {
        CrashlyticsService(privacyService: PrivacyService.mock, maxBreadcrumbs: 10)
    }
}

final class PrivacyService: Sendable {
    static let mock = PrivacyService()
    let analyticsEnabled: Bool

    init(analyticsEnabled: Bool = true) {
        self.analyticsEnabled = analyticsEnabled
    }
}