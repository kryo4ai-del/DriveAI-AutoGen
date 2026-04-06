// Features/LocationPicker/Models/LocationPickerModels.swift
enum LocationPickerError: LocalizedError {
    case invalidPLZ(String)
    case regionNotFound
    case databaseError(String)
    case networkTimeout
    
    var errorDescription: String? {
        switch self {
        case .invalidPLZ(let input):
            return String(localized: "location_error_invalid_plz_\(input)", bundle: .main)
        case .regionNotFound:
            return String(localized: "location_error_not_found", bundle: .main)
        case .databaseError:
            return String(localized: "location_error_database", bundle: .main)
        case .networkTimeout:
            return String(localized: "location_error_timeout", bundle: .main)
        }
    }
    
    var recoveryMessageGerman: String {
        switch self {
        case .invalidPLZ(let input):
            return "PLZ \(input) nicht gefunden? Versuchen Sie die nächst größere Stadt oder schauen Sie auf der Karte."
        case .regionNotFound:
            return "Keine Ergebnisse. Probieren Sie einen anderen Stadtnamen."
        case .databaseError:
            return "Datenfehler. Bitte starten Sie die App neu."
        case .networkTimeout:
            return "Zeitüberschreitung. Überprüfen Sie Ihre Internetverbindung."
        }
    }
}

// Localization
// Localizable.strings (German):
"location_error_invalid_plz_12345" = "PLZ 12345 nicht gefunden?";
"location_error_not_found" = "Keine Region gefunden.";
"location_placeholder" = "PLZ oder Stadt eingeben";
"location_recent_header" = "Zuletzt gewählt";
"location_empty_state" = "Geben Sie Ihre PLZ oder Stadt ein, um zu beginnen.";