import Foundation

/// Features gated by freemium tier
enum FreemiumFeature: Hashable {
    case questionsUnlimited
    case allCategories
    case examSimulation
    case weakAreaDrills
    case customLearningPath
    case offlineSync
    
    /// Is this feature available in a given tier config?
    func isAvailable(in config: FreemiumTierConfig) -> Bool {
        switch self {
        case .questionsUnlimited:
            return config.questionsPerDay == .max
        case .allCategories:
            return config.categoriesUnlocked == .max
        case .examSimulation:
            return config.examAttemptsPerDay > 0
        case .weakAreaDrills:
            return config.canAccessWeakAreaDrills
        case .customLearningPath:
            return config.canAccessCustomLearningPath
        case .offlineSync:
            return config.canAccessOfflineSync
        }
    }
    
    /// Localized feature name (German)
    var displayName: String {
        switch self {
        case .questionsUnlimited:
            return "Unbegrenzte Fragen"
        case .allCategories:
            return "Alle Kategorien"
        case .examSimulation:
            return "Prüfungssimulation"
        case .weakAreaDrills:
            return "Schwachstellen-Drills"
        case .customLearningPath:
            return "Personalisierter Lernpfad"
        case .offlineSync:
            return "Offline-Synchronisation"
        }
    }
}