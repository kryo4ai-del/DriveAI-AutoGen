// PrivacySettings.swift
import Foundation

struct PrivacySettings: Codable, Equatable {
    var consents: [ConsentCategory: ConsentState] = [:]
    var dataRetentionDays: Int = 365
    var allowCrossCategoryAnalytics: Bool = false
    var lastConsentUpdate: Date = Date()

    static func `default`() -> PrivacySettings {
        var settings = PrivacySettings()
        settings.consents[.essential] = ConsentState(
            category: .essential,
            isGranted: true,
            grantedAt: Date()
        )
        settings.consents[.analytics] = ConsentState(
            category: .analytics,
            isGranted: false
        )
        settings.consents[.notifications] = ConsentState(
            category: .notifications,
            isGranted: false
        )
        return settings
    }
}