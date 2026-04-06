public struct ExamResultAnalysis: Sendable {
    public let categoryPerformance: [CategoryScore]
    public let weakestCategory: QuestionCategory?
    public let strongestCategory: QuestionCategory?
    
    public struct CategoryScore: Sendable {
        public let category: QuestionCategory
        public let score: Int
        public let total: Int
        public var accuracy: Double { Double(score) / Double(total) }
        
        public var feedbackMessage: String {
            if accuracy >= 0.8 { return "✓ Stark in \(category.displayName)" }
            if accuracy >= 0.6 { return "△ Mittelmäßig in \(category.displayName)" }
            return "⚠ Schwach in \(category.displayName)"
        }
    }
}

// On ExamSession:
public var analysisAfterCompletion: ExamResultAnalysis? {
    guard completedAt != nil else { return nil }
    let categoryScores = QuestionCategory.allCases.map { category in
        let answers = questionsAnswered.filter { 
            // Parse question ID to determine category
            // (requires question metadata in questionsAnswered or a mapper)
            answeredQuestionCategories[questionId] == category
        }
        return ExamResultAnalysis.CategoryScore(
            category: category,
            score: answers.filter { $0.isCorrect }.count,
            total: answers.count
        )
    }
    return ExamResultAnalysis(categoryPerformance: categoryScores, ...)
}