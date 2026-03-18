import Foundation
// Mock for testing
class MockReadinessCalculationService: ReadinessCalculationService {
    var mockSnapshot: ExamReadinessSnapshot?
    
    override func calculateReadiness(examDate: Date) async throws -> ExamReadinessSnapshot {
        return mockSnapshot ?? .stub()
    }
}

extension ExamReadinessSnapshot {
    static func stub() -> ExamReadinessSnapshot {
        ExamReadinessSnapshot(
            overallReadinessPercentage: 75.0,
            categoryBreakdown: [
                CategoryReadiness(id: "1", name: "Traffic Signs", readinessPercentage: 85, questionsAnswered: 20, correctAnswers: 17)
            ],
            recommendedFocusCategories: [],
            examCountdown: DateComponentsValue(day: 14, hour: 5, minute: 30),
            currentStreak: 5,
            totalQuestionsAnswered: 100,
            estimatedCompletionDays: 7,
            lastUpdated: Date()
        )
    }
}