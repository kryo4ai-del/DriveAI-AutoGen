enum MasteryLevel: String, Codable, Sendable {
    case beginner, intermediate, advanced, expert
    
    var displayName: String {
        switch self {
        case .beginner: return NSLocalizedString("mastery.beginner", 
                                                  defaultValue: "Anfänger", comment: "Mastery level")
        case .intermediate: return NSLocalizedString("mastery.intermediate", 
                                                      defaultValue: "Fortgeschritten", comment: "Mastery level")
        case .advanced: return NSLocalizedString("mastery.advanced", 
                                                  defaultValue: "Experte", comment: "Mastery level")
        case .expert: return NSLocalizedString("mastery.expert", 
                                                defaultValue: "Meister", comment: "Mastery level")
        }
    }
    
    var accessibilityDescription: String {
        switch self {
        case .beginner: return NSLocalizedString("mastery.beginner.description", 
                                                  defaultValue: "Anfänger: 0-50% Genauigkeit", comment: "")
        case .intermediate: return NSLocalizedString("mastery.intermediate.description", 
                                                      defaultValue: "Fortgeschritten: 50-75% Genauigkeit", comment: "")
        case .advanced: return NSLocalizedString("mastery.advanced.description", 
                                                  defaultValue: "Experte: 75-90% Genauigkeit", comment: "")
        case .expert: return NSLocalizedString("mastery.expert.description", 
                                                defaultValue: "Meister: über 90% Genauigkeit", comment: "")
        }
    }
}

// Usage in view:
Text(masteryLevel.displayName)
    .accessibilityLabel("Fertigkeitsstufe")
    .accessibilityValue(masteryLevel.displayName)
    .accessibilityHint(masteryLevel.accessibilityDescription)