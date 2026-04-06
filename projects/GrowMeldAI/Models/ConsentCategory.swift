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

// Struct PrivacySettings declared in Models/PrivacySettings.swift
