import Foundation

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

enum ConsentCategory: String, CaseIterable, Codable, Hashable {
    case essential
    case analytics
    case notifications

    var isRequired: Bool {
        self == .essential
    }

    var displayName: String {
        switch self {
        case .essential:
            return "Notwendige Funktionen"
        case .analytics:
            return "Lernfortschritt & Analyse"
        case .notifications:
            return "Erinnerungen & Benachrichtigungen"
        }
    }

    var description: String {
        switch self {
        case .essential:
            return "Erforderlich für die App-Funktionalität. Wir speichern nur deine Antworten zur Verbesserung deiner Lernfortschritte."
        case .analytics:
            return "Hilft uns, deine Lernmuster zu verstehen und die App besser zu machen. Deine Daten bleiben privat und werden nicht verkauft."
        case .notifications:
            return "Erinnert dich an dein Lernziel und wichtige Prüfungstermine. Du kannst diese jederzeit deaktivieren."
        }
    }

    var icon: String {
        switch self {
        case .essential:
            return "lock.fill"
        case .analytics:
            return "chart.bar.fill"
        case .notifications:
            return "bell.fill"
        }
    }
}

struct PrivacySettings: Equatable {
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

extension PrivacySettings: Codable {
    enum CodingKeys: String, CodingKey {
        case consents
        case dataRetentionDays
        case allowCrossCategoryAnalytics
        case lastConsentUpdate
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let consentsArray = consents.map { ConsentEntry(key: $0.key, value: $0.value) }
        try container.encode(consentsArray, forKey: .consents)
        try container.encode(dataRetentionDays, forKey: .dataRetentionDays)
        try container.encode(allowCrossCategoryAnalytics, forKey: .allowCrossCategoryAnalytics)
        try container.encode(lastConsentUpdate, forKey: .lastConsentUpdate)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let consentsArray = try container.decode([ConsentEntry].self, forKey: .consents)
        consents = Dictionary(uniqueKeysWithValues: consentsArray.map { ($0.key, $0.value) })
        dataRetentionDays = try container.decode(Int.self, forKey: .dataRetentionDays)
        allowCrossCategoryAnalytics = try container.decode(Bool.self, forKey: .allowCrossCategoryAnalytics)
        lastConsentUpdate = try container.decode(Date.self, forKey: .lastConsentUpdate)
    }

    private struct ConsentEntry: Codable {
        let key: ConsentCategory
        let value: ConsentState
    }
}