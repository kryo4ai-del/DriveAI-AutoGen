import Foundation

enum RecommendationPriority: Int, Codable, Comparable {
    case low = 0
    case medium = 1
    case high = 2
    
    var displayName: String {
        switch self {
        case .low: return NSLocalizedString("readiness.priority.low", comment: "")
        case .medium: return NSLocalizedString("readiness.priority.medium", comment: "")
        case .high: return NSLocalizedString("readiness.priority.high", comment: "")
        }
    }
    
    var badgeColor: Color {
        switch self {
        case .low: return Color(.systemGray)
        case .medium: return Color(.systemOrange)
        case .high: return Color(.systemRed)
        }
    }
    
    static func < (lhs: RecommendationPriority, rhs: RecommendationPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct StudyRecommendation: Identifiable, Codable {
    let id: String
    let categoryId: String
    let categoryName: String
    let priority: RecommendationPriority
    let estimatedHours: Int
    let focusAreas: [String]
    let priorityScore: Double
    let createdAt: Date
    
    var isDismissible: Bool {
        priority == .low
    }
    
    init(
        categoryId: String,
        categoryName: String,
        priority: RecommendationPriority,
        estimatedHours: Int,
        focusAreas: [String],
        priorityScore: Double,
        createdAt: Date = Date()
    ) {
        self.id = UUID().uuidString
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.priority = priority
        self.estimatedHours = estimatedHours
        self.focusAreas = focusAreas
        self.priorityScore = priorityScore
        self.createdAt = createdAt
    }
}