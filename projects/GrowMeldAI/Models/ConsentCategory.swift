import Foundation

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

struct PrivacySettings: Codable, Equatable {
    var consents: [ConsentCategory: ConsentState] = [:]
    var dataRetentionDays: Int = 365
    var allowCrossCategoryAnalytics: Bool = false
    var lastConsentUpdate: Date = Date()
    
    static func `default`() -> PrivacySettings {
        var settings = PrivacySettings()
        // Essential is auto-granted
        settings.consents[.essential] = ConsentState(
            category: .essential,
            isGranted: true,
            grantedAt: Date()
        )
        // Others default to not granted (user must opt-in)
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