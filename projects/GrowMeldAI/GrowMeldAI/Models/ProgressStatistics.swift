import Foundation

public struct ProgressStatistics: Sendable {
    public let totalQuestionsAnswered: Int
    public let overallAccuracy: Double
    public let categoryProgress: [CategoryProgress]
    public let currentStreak: Int
    public let longestStreak: Int
    public let totalExamsPassed: Int
    public let totalExamAttempts: Int
    
    public init(
        totalQuestionsAnswered: Int,
        overallAccuracy: Double,
        categoryProgress: [CategoryProgress],
        currentStreak: Int,
        longestStreak: Int,
        totalExamsPassed: Int,
        totalExamAttempts: Int
    ) {
        self.totalQuestionsAnswered = totalQuestionsAnswered
        self.overallAccuracy = overallAccuracy
        self.categoryProgress = categoryProgress
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalExamsPassed = totalExamsPassed
        self.totalExamAttempts = totalExamAttempts
    }
    
    public struct CategoryProgress: Sendable {
        public let category: QuestionCategory
        public let accuracy: Double
        public let totalAnswers: Int
        public let mastered: Bool
        
        public init(
            category: QuestionCategory,
            accuracy: Double,
            totalAnswers: Int,
            mastered: Bool
        ) {
            self.category = category
            self.accuracy = accuracy
            self.totalAnswers = totalAnswers
            self.mastered = mastered
        }
        
        public var displayProgress: String {
            let percentage = Int(accuracy * 100)
            return "\(percentage)%"
        }
    }
    
    public var masteredCategories: Int {
        categoryProgress.filter { $0.mastered }.count
    }
    
    public var passRate: Double {
        guard totalExamAttempts > 0 else { return 0 }
        return Double(totalExamsPassed) / Double(totalExamAttempts)
    }
}