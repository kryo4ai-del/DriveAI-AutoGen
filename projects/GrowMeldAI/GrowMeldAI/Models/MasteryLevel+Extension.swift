// MARK: - Models/MasteryLevel+Accessibility.swift

extension MasteryLevel {
    /// Localized label for display and accessibility
    var accessibilityLabel: String {
        switch self {
        case .novice:
            return NSLocalizedString("accessibility.masteryLevel.novice", value: "Anfänger", comment: "Mastery level: beginner")
        case .intermediate:
            return NSLocalizedString("accessibility.masteryLevel.intermediate", value: "Fortgeschritten", comment: "Mastery level: intermediate")
        case .proficient:
            return NSLocalizedString("accessibility.masteryLevel.proficient", value: "Kompetent", comment: "Mastery level: proficient")
        case .expert:
            return NSLocalizedString("accessibility.masteryLevel.expert", value: "Experte", comment: "Mastery level: expert")
        }
    }
    
    /// Detailed description for VoiceOver
    var accessibilityDescription: String {
        switch self {
        case .novice:
            return "Anfänger: Weniger als 40 Prozent Genauigkeit"
        case .intermediate:
            return "Fortgeschritten: 40 bis 69 Prozent Genauigkeit"
        case .proficient:
            return "Kompetent: 70 bis 89 Prozent Genauigkeit"
        case .expert:
            return "Experte: 90 Prozent oder mehr"
        }
    }
}

// MARK: - Models/GapSeverity+Accessibility.swift

extension GapSeverity {
    var accessibilityLabel: String {
        switch self {
        case .critical:
            return NSLocalizedString("accessibility.gapSeverity.critical", value: "Kritisch", comment: "Gap severity: critical")
        case .moderate:
            return NSLocalizedString("accessibility.gapSeverity.moderate", value: "Mittel", comment: "Gap severity: moderate")
        case .minor:
            return NSLocalizedString("accessibility.gapSeverity.minor", value: "Gering", comment: "Gap severity: minor")
        }
    }
    
    var accessibilityDescription: String {
        switch self {
        case .critical:
            return "Kritische Lücke: Weniger als 40 Prozent Genauigkeit. Sofort trainieren empfohlen."
        case .moderate:
            return "Mittlere Lücke: 40 bis 69 Prozent Genauigkeit. Weitere Übung benötigt."
        case .minor:
            return "Geringe Lücke: 70 bis 89 Prozent Genauigkeit. Gut gemacht!"
        }
    }
}