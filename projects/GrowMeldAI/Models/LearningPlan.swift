import Foundation
// Models/LearningPlan/LearningPlan.swift
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
    let urgencyScore: Double  // 0.0–1.0 for ranking
    
    var isWeakly: Bool { accuracyPercentage < 0.70 }
}

// Struct RecommendedQuestion declared in Models/RecommendedQuestion.swift
