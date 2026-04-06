// LocationError+Localized.swift
import Foundation

extension LocationError {
    var localizedDescription: String {
        switch self {
        case .invalidFormat(let input):
            return "Die Postleitzahl '\(input)' ist ungültig. Bitte gib eine 5-stellige Zahl ein."
        case .plzNotFound(let plz):
            return "Postleitzahl \(plz) nicht gefunden. Wähle deine Region manuell aus oder überprüfe die Eingabe."
        case .databaseError(let msg):
            return "Datenbankfehler: \(msg)\nBitte starte die App neu."
        case .offlineUnavailable:
            return "Die Datenbank ist noch nicht bereit. Warte einen Moment und versuche es erneut."
        case .networkError(let msg):
            return "Netzwerkproblem: \(msg)\nÜberprüfe deine Internetverbindung."
        case .unknown:
            return "Etwas ist schiefgelaufen. Bitte versuche es später noch einmal."
        }
    }

    var motivationalRecovery: String {
        switch self {
        case .invalidFormat:
            return "Denk dran: 5 Ziffern wie in '10115' für Berlin. Du schaffst das!"
        case .plzNotFound:
            return "Keine Sorge – wähle einfach dein Bundesland und deine Stadt aus dem Menü. Jeder Schritt bringt dich näher zum Ziel!"
        case .databaseError, .offlineUnavailable:
            return "Atme tief durch 🧘‍♂️ – starte die App neu und du bist wieder auf Kurs!"
        case .networkError:
            return "Internetprobleme? Kein Stress! Versuche es mit dem mobilen Datenvolumen oder warte auf besseres WLAN."
        case .unknown:
            return "Fehler sind nur Umwege zum Erfolg. Versuche es einfach nochmal!"
        }
    }
}