// Services/Business/ExamScoringService.swift

class ExamScoringService: ExamScoringServiceProtocol {
    private let passingThreshold: Int = 15  // 50% of 30 questions
    private let totalExamQuestions: Int = 30
    
    func calculateScore(_ answers: [QuestionState]) -> Int {
        answers.reduce(into: 0) { count, state in
            if case .answeredCorrectly = state {
                count += 1
            }
        }
    }
    
    func determinePass(_ score: Int) -> Bool {
        score >= passingThreshold
    }
    
    func generateCategoryBreakdown(_ results: [QuestionState]) -> [Models.CategoryProgress] {
        // Aggregate results by category
        // Return list of CategoryProgress with updated stats
        return []
    }
}