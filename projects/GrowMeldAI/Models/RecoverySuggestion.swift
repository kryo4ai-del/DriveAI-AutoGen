// Models/RecoverySuggestion.swift
import Foundation
import SwiftUI

struct RecoverySuggestion {
    let title: String
    let message: String
    let action: RecoveryAction

    static func forError(_ error: ImageRecognitionError) -> RecoverySuggestion {
        switch error {
        case .apiKeyMissing:
            return RecoverySuggestion(
                title: "Plant.id braucht deinen API-Key",
                message: "Gib deinem Schlüssel ein — du bist nur einen Schritt vom Durchstarten entfernt!",
                action: .configureFeature
            )
        case .quotaExceeded(let retryAfter):
            let dateString = retryAfter.map { "um \($0.formatted())" } ?? "in 1 Stunde"
            return RecoverySuggestion(
                title: "Zu viele Anfragen",
                message: "Versuche es \(dateString) nochmal oder nutze Offline-Modus.",
                action: .retryLater(retryAfter ?? Date(timeIntervalSinceNow: 3600))
            )
        case .networkFailure:
            return RecoverySuggestion(
                title: "Keine Internetverbindung",
                message: "Wir zeigen dir das letzte Ergebnis oder du versuchst es später nochmal.",
                action: .useCache
            )
        case .invalidImage(let reason):
            return RecoverySuggestion(
                title: "Bild nicht erkannt",
                message: "Bitte nimm ein klares Foto vom Verkehrszeichen. \(reason)",
                action: .retry
            )
        default:
            return RecoverySuggestion(
                title: "Etwas ist schiefgelaufen",
                message: "Wir helfen dir gerne weiter. Kontaktiere unser Support-Team.",
                action: .contactSupport
            )
        }
    }
}