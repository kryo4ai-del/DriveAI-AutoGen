import Foundation

protocol ProgressTrackerProtocol {
    func updateProgress(from result: ExamResult, profile: inout UserProfile)
    func calculateStreak(lastActivityDate: Date?, currentDate: Date) -> Int
    func calculateCategoryStats(progress: CategoryProgress) -> CategoryStats
    func resetProgress(profile: inout UserProfile)
}

struct ExamResult: Codable {
    let id: String
    let date: Date
    let score: Double
    let totalQuestions: Int
    let correctAnswers: Int
    let categoryResults: [String: CategoryResult]

    init(id: String = UUID().uuidString,
         date: Date = Date(),
         score: Double,
         totalQuestions: Int,
         correctAnswers: Int,
         categoryResults: [String: CategoryResult] = [:]) {
        self.id = id
        self.date = date
        self.score = score
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.categoryResults = categoryResults
    }
}

struct CategoryResult: Codable {
    let categoryId: String
    let correct: Int
    let total: Int

    var accuracy: Double {
        guard total > 0 else { return 0 }
        return Double(correct) / Double(total)
    }
}

struct CategoryProgress: Codable {
    let categoryId: String
    let totalAttempts: Int
    let correctAttempts: Int
    let lastAttemptDate: Date?
    let history: [CategoryResult]

    var accuracy: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(correctAttempts) / Double(totalAttempts)
    }
}

struct CategoryStats: Codable {
    let categoryId: String
    let accuracy: Double
    let totalAttempts: Int
    let correctAttempts: Int
    let trend: Double
    let lastAttemptDate: Date?
}

struct UserProfile: Codable {
    var id: String
    var name: String
    var email: String
    var examResults: [ExamResult]
    var categoryProgress: [String: CategoryProgress]
    var currentStreak: Int
    var longestStreak: Int
    var lastActivityDate: Date?
    var createdAt: Date

    init(id: String = UUID().uuidString,
         name: String = "",
         email: String = "",
         examResults: [ExamResult] = [],
         categoryProgress: [String: CategoryProgress] = [:],
         currentStreak: Int = 0,
         longestStreak: Int = 0,
         lastActivityDate: Date? = nil,
         createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.email = email
        self.examResults = examResults
        self.categoryProgress = categoryProgress
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastActivityDate = lastActivityDate
        self.createdAt = createdAt
    }
}