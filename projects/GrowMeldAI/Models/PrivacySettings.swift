import Foundation

enum ConsentCategory: String, Codable, Hashable, CaseIterable {
    case essential
    case analytics
    case notifications
}

struct ConsentState: Codable, Equatable {
    var category: ConsentCategory
    var isGranted: Bool
    var grantedAt: Date?

    init(category: ConsentCategory, isGranted: Bool, grantedAt: Date? = nil) {
        self.category = category
        self.isGranted = isGranted
        self.grantedAt = grantedAt
    }
}

struct PrivacySettings: Codable, Equatable {
    var consents: [String: ConsentState]
    var dataRetentionDays: Int
    var allowCrossCategoryAnalytics: Bool
    var lastConsentUpdate: Date

    init(
        consents: [String: ConsentState] = [:],
        dataRetentionDays: Int = 365,
        allowCrossCategoryAnalytics: Bool = false,
        lastConsentUpdate: Date = Date()
    ) {
        self.consents = consents
        self.dataRetentionDays = dataRetentionDays
        self.allowCrossCategoryAnalytics = allowCrossCategoryAnalytics
        self.lastConsentUpdate = lastConsentUpdate
    }

    subscript(category: ConsentCategory) -> ConsentState? {
        get { consents[category.rawValue] }
        set { consents[category.rawValue] = newValue }
    }

    static func `default`() -> PrivacySettings {
        var settings = PrivacySettings()
        settings.consents[ConsentCategory.essential.rawValue] = ConsentState(
            category: .essential,
            isGranted: true,
            grantedAt: Date()
        )
        settings.consents[ConsentCategory.analytics.rawValue] = ConsentState(
            category: .analytics,
            isGranted: false
        )
        settings.consents[ConsentCategory.notifications.rawValue] = ConsentState(
            category: .notifications,
            isGranted: false
        )
        return settings
    }
}