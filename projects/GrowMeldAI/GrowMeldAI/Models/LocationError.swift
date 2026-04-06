import Foundation

/// Location-specific errors with user-friendly localization
enum LocationError: LocalizedError, Sendable {
    case geocodingFailed(String)
    case locationServicesDenied
    case locationServicesDisabled
    case invalidPostalCode
    case databaseNotFound
    case postCodeNotInCatalog(String)
    case unexpectedError(String)
    
    var errorDescription: String? {
        switch self {
        case .geocodingFailed(let msg):
            return "Standort konnte nicht ermittelt werden: \(msg)"
        case .locationServicesDenied:
            return "Standortzugriff verweigert."
        case .locationServicesDisabled:
            return "Standortdienste sind deaktiviert."
        case .invalidPostalCode:
            return "Ungültige Postleitzahl."
        case .databaseNotFound:
            return "Postleitzahl-Datenbank konnte nicht geladen werden."
        case .postCodeNotInCatalog(let plz):
            return "Postleitzahl \(plz) nicht im Katalog gefunden."
        case .unexpectedError(let msg):
            return "Fehler: \(msg)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .locationServicesDenied:
            return "Öffnen Sie Einstellungen > DriveAI > Standort und wählen Sie \"Während der Nutzung\"."
        case .locationServicesDisabled:
            return "Aktivieren Sie Standortdienste in Einstellungen > Datenschutz > Standort."
        case .invalidPostalCode:
            return "Überprüfen Sie die Postleitzahl (4–5 Ziffern) und versuchen Sie es erneut."
        case .postCodeNotInCatalog:
            return "Bitte geben Sie Ihre Postleitzahl manuell ein."
        default:
            return nil
        }
    }
}