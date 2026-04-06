import Foundation

struct ASORecommendation: Identifiable, Codable, Hashable {
    let id: UUID
    let actionType: ActionType
    let priority: Priority
    let title: String
    let description: String
    let rationale: String
    let estimatedImpact: Impact
    let createdAt: Date
    var isDismissed: Bool = false
    var isImplemented: Bool = false
    var implementedAt: Date?
    
    enum ActionType: String, Codable, Hashable {
        case addKeyword, removeKeyword, improveDescription
        case updateScreenshots, fixCrash, addFeature
        case updatePrice, changeCategory
    }
    
    enum Priority: String, Codable, Hashable {
        case high, medium, low
        
        var score: Int {
            switch self {
            case .high: return 3
            case .medium: return 2
            case .low: return 1
            }
        }
    }
    
    struct Impact: Codable, Hashable {
        let expectedRankingBoost: Int?
        let estimatedDownloadIncrease: Int?
        let estimatedRevenueImpact: String? // Qualitative: "high", "medium"
    }
}