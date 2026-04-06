import Foundation

// MARK: - Policies

/// Mastery achievement thresholds
enum MasteryPolicy: Sendable {
    static let minimumPercentage: Double = 80.0
    static let minimumQuestionsAnswered: Int = 5
}

/// Review scheduling policy

/// Exam passing requirements

// MARK: - Category Progress

/// Tracks user's progress within a specific question category

// MARK: - Exam Result

/// Records the outcome of an exam or quiz session

// MARK: - User Progress

// MARK: - User Statistics

struct UserStatistics: Equatable, Sendable {
    let overallScore: Double
    let categoryBreakdown: [QuestionCategory: Double]
    let streakDays: Int
    let daysUntilExam: Int?
    let lastExamPassed: Bool
    let totalQuestionsAnswered: Int
    let masteredCategoriesCount: Int
    let nextReviewCategories: [QuestionCategory]
    
    init(from progress: UserProgress) {
        self.overallScore = progress.overallScore
        self.streakDays = progress.streakDays
        self.daysUntilExam = progress.daysUntilExam
        self.lastExamPassed = progress.lastExamPassed
        self.totalQuestionsAnswered = progress.totalQuestionsAnswered
        self.masteredCategoriesCount = progress.masteredCategories
        
        self.categoryBreakdown = Dictionary(
            uniqueKeysWithValues: progress.categoryProgresses.map { category, progress in
                (category, progress.percentageCorrect)
            }
        )
        
        self.nextReviewCategories = progress.categoryProgresses
            .filter { $0.value.needsReview && !$0.value.isMastered }
            .map { $0.key }
            .sorted { $0.displayName < $1.displayName }
    }
}