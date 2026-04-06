import Foundation

struct CategoryProgress: Codable {
    let categoryId: String
    let categoryName: String
    var questionsAttempted: Int
    var correctAnswers: Int
    var lastAttemptDate: Date?

    init(categoryId: String, categoryName: String, questionsAttempted: Int = 0, correctAnswers: Int = 0, lastAttemptDate: Date? = nil) {
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.questionsAttempted = questionsAttempted
        self.correctAnswers = correctAnswers
        self.lastAttemptDate = lastAttemptDate
    }
}

struct UserProfile: Codable {
    let id: UUID
    var examDate: Date?
    var totalScore: Int
    var totalQuestionsAnswered: Int
    var currentStreak: Int
    var longestStreak: Int
    var categoryProgress: [String: CategoryProgress]
    var examAttempts: [ExamAttempt]
    var attemptCount: Int

    var averageAccuracy: Double {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return Double(totalScore) / Double(totalQuestionsAnswered)
    }

    init(
        id: UUID = UUID(),
        examDate: Date? = nil,
        totalScore: Int = 0,
        totalQuestionsAnswered: Int = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        categoryProgress: [String: CategoryProgress] = [:],
        examAttempts: [ExamAttempt] = [],
        attemptCount: Int = 0
    ) {
        self.id = id
        self.examDate = examDate
        self.totalScore = totalScore
        self.totalQuestionsAnswered = totalQuestionsAnswered
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.categoryProgress = categoryProgress
        self.examAttempts = examAttempts
        self.attemptCount = attemptCount
    }

    static func empty() -> UserProfile {
        UserProfile()
    }
}

struct ExamAttempt: Codable {
    let id: UUID
    let date: Date
    let score: Int
    let totalQuestions: Int
    let passed: Bool

    init(id: UUID = UUID(), date: Date = Date(), score: Int, totalQuestions: Int, passed: Bool) {
        self.id = id
        self.date = date
        self.score = score
        self.totalQuestions = totalQuestions
        self.passed = passed
    }
}