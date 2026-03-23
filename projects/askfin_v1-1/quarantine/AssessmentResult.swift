import Foundation

struct AssessmentResult: Identifiable, Codable {
    let id: UUID
    let assessmentId: UUID
    let timestamp: Date
    let overallScore: Double
    let readinessLevel: String
    let categoryScores: [String: Double]
    let weakAreas: [WeakArea]
    let recommendations: [Recommendation]
    
    init(
        assessment: ReadinessAssessment,
        weakAreas: [WeakArea],
        recommendations: [Recommendation]
    ) {
        self.id = UUID()
        self.assessmentId = assessment.id
        self.timestamp = assessment.createdAt
        self.overallScore = assessment.overallScore
        self.readinessLevel = assessment.readinessLevel.rawValue
        self.categoryScores = Dictionary(
            uniqueKeysWithValues: assessment.categoryResults.map {
                ($0.categoryName, $0.accuracy)
            }
        )
        self.weakAreas = weakAreas
        self.recommendations = recommendations
    }
}

// MARK: - Recommendation
