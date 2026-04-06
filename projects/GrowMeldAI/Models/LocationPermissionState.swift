enum LocationPermissionState: String, Codable, Equatable {
    case notDetermined
    case requestingConsent
    case authorized
    case denied
    case restricted
    
    // ✅ Add accessibility-friendly description
    var accessibilityDescription: String {
        switch self {
        case .notDetermined:
            return "Sie haben noch nicht entschieden, ob Sie den Standort freigeben möchten"
        case .requestingConsent:
            return "Wir fragen nach der Standortberechtigung"
        case .authorized:
            return "Sie haben den Standortzugriff gewährt"
        case .denied:
            return "Sie haben den Standortzugriff verweigert"
        case .restricted:
            return "Der Standortzugriff ist eingeschränkt (möglicherweise durch Kindersicherung)"
        }
    }
    
    // ✅ User-friendly status for UI display
    var userFacingStatus: String {
        switch self {
        case .notDetermined:
            return "Nicht entschieden"
        case .requestingConsent:
            return "Anfrage läuft..."
        case .authorized:
            return "Gewährt"
        case .denied:
            return "Verweigert"
        case .restricted:
            return "Eingeschränkt"
        }
    }
}

// Usage:
Text(locationPermissionState.userFacingStatus)
    .accessibilityLabel("Standortzugriff-Status")
    .accessibilityValue(locationPermissionState.accessibilityDescription)