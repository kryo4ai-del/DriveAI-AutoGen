enum ReadinessLevel: String, Codable {
    case excellent
    case good
    case fair
    case needsWork
    
    var localized: String {
        NSLocalizedString(
            "readiness.\(self.rawValue)",
            bundle: Bundle.main,
            value: self.rawValue,
            comment: ""
        )
    }
}

// In Localizable.strings:
// "readiness.excellent" = "Ausgezeichnet";
// "readiness.good" = "Gut";