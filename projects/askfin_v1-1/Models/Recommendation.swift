import Foundation

struct Recommendation: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let categoryId: String
    let categoryName: String
    let estimatedMinutes: Int
    let actionType: ActionType
    let priority: Int
    
    enum ActionType: String, Codable {
        case practiceCategory
        case reviewMaterials
        case focusedQuiz
    }
}

struct WeakArea: Identifiable, Codable {
    let id: UUID
    let categoryId: String
    let categoryName: String
    let accuracy: Double
    let priority: Int
    let suggestedQuestionCount: Int
    
    var needsImprovement: Bool {
        accuracy < 70
    }
    
    var improvementGap: Double {
        max(0, 70 - accuracy)
    }
}