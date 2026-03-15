// MARK: - Features/ExamReadiness/Models/StudyRecommendation.swift

import Foundation

struct StudyRecommendation: Identifiable, Codable, Hashable {
    let id: UUID
    let categoryId: String
    let categoryName: String
    let reason: String
    let priority: PriorityLevel
    let suggestedQuestionsCount: Int
    let confidence: Double
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: StudyRecommendation, rhs: StudyRecommendation) -> Bool {
        lhs.id == rhs.id
    }
}