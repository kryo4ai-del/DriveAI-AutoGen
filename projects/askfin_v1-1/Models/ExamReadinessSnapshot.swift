import Foundation
actor RecommendationEngineService: Sendable {
    func generateRecommendations(
        snapshot: ExamReadinessSnapshot
    ) async -> [StudyRecommendation] {
        var recommendations: [StudyRecommendation] = []
        
        // ✅ Safe iteration with guard
        for categoryId in snapshot.recommendedFocusCategories {
            guard let category = snapshot.categoryBreakdown.first(where: { $0.id == categoryId })
            else {
                // ❌ Log error but don't crash
                print("⚠️ Category \(categoryId) not found in breakdown")
                continue
            }
            
            // ... rest
        }
        
        return recommendations
    }
}

// ✅ Also validate snapshot integrity:
struct ExamReadinessSnapshot {
    let overallReadinessPercentage: Double
    let categoryBreakdown: [CategoryReadiness]
    let recommendedFocusCategories: [Any]
    let examCountdown: DateComponentsValue
    let currentStreak: Int
    let totalQuestionsAnswered: Int
    let estimatedCompletionDays: Int
    let lastUpdated: Date
    let score: ReadinessScore
    let contextualStatement: String
    let examHasPassed: Bool
    let daysUntilExam: Int?
    let topRecommendations: [Recommendation]

    func validate() throws {
        if categoryBreakdown.isEmpty {
            throw SnapshotError.noCategories
        }
        
        let recommendedIds = Set(recommendedFocusCategories)
        let availableIds = Set(categoryBreakdown.map { $0.id })
        
        let missingIds = recommendedIds.subtracting(availableIds)
        if !missingIds.isEmpty {
            throw SnapshotError.inconsistentRecommendations(missing: missingIds)
        }
    }
    
    enum SnapshotError: LocalizedError {
        case noCategories
        case inconsistentRecommendations(missing: Set<String>)
        
        var errorDescription: String? {
            switch self {
            case .noCategories:
                return "No categories available – check data sync"
            case .inconsistentRecommendations(let missing):
                return "Recommendations reference missing categories: \(missing)"
            }
        }
    }
}