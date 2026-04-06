import Foundation

struct LearningPlan: Codable, Identifiable {
    let id: UUID
    let createdDate: Date
    let expiryDate: Date
    let weakCategories: [WeakCategory]
    let status: PlanStatus

    enum PlanStatus: String, Codable {
        case active, completed, expired
    }
}

struct WeakCategory: Codable, Identifiable {
    let id: UUID
    let categoryId: String
    let categoryName: String
    let accuracyPercentage: Double
    let questionsAttempted: Int
    let urgencyScore: Double

    var isWeakly: Bool { accuracyPercentage < 0.70 }
}

struct RecommendedQuestion: Codable, Identifiable {
    let id: UUID
    let questionId: String
    let reason: RecommendationReason
    let priority: Int

    enum RecommendationReason: String, Codable {
        case lowAccuracy = "Niedrige Genauigkeit in dieser Kategorie"
        case neverAttempted = "Kategorie noch nicht trainiert"
        case recencyDecay = "Lange nicht geübt"
    }
}