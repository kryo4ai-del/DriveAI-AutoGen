import Foundation

enum MaintenanceCheckType: String, Codable, CaseIterable {
    case staleCategoryAlert
    case lowCompletionRate
    case streakReset
    case outdatedQuestionCatalog
    case cacheCleanup
    
    var localizedDescription: String {
        switch self {
        case .staleCategoryAlert:
            return "Kategorie nicht geübt"
        case .lowCompletionRate:
            return "Niedrige Erfolgsquote"
        case .streakReset:
            return "Serie unterbrochen"
        case .outdatedQuestionCatalog:
            return "Katalog veraltet"
        case .cacheCleanup:
            return "Speicher aufräumen"
        }
    }
}