// Models/MemoryType.swift
enum MemoryType: String, Codable, CaseIterable {
    case correctAnswer
    case perfectScore         // All answers in set correct
    case streakMilestone      // 3, 7, 14, 30-day streaks
    case categoryMastery      // 90%+ in category
    case examPassed
    case personalRecord       // New high score
    
    // MARK: - Display Properties
    var displayName: String {
        switch self {
        case .correctAnswer: return "Richtige Antwort"
        case .perfectScore: return "Perfekte Serie"
        case .streakMilestone: return "Erfolgssträhne"
        case .categoryMastery: return "Kategorie gemeistert"
        case .examPassed: return "Prüfung bestanden"
        case .personalRecord: return "Neuer Rekord"
        }
    }
    
    var icon: String {
        switch self {
        case .correctAnswer: return "checkmark.circle.fill"
        case .perfectScore: return "star.fill"
        case .streakMilestone: return "flame.fill"
        case .categoryMastery: return "crown.fill"
        case .examPassed: return "checkmark.seal.fill"
        case .personalRecord: return "trophy.fill"
        }
    }
    
    var priority: Int {
        switch self {
        case .examPassed: return 5
        case .personalRecord, .categoryMastery: return 4
        case .streakMilestone: return 3
        case .perfectScore: return 2
        case .correctAnswer: return 1
        }
    }
    
    var color: String {
        switch self {
        case .examPassed: return "green"
        case .personalRecord: return "yellow"
        case .categoryMastery: return "purple"
        case .streakMilestone: return "orange"
        case .perfectScore: return "blue"
        case .correctAnswer: return "cyan"
        }
    }
}