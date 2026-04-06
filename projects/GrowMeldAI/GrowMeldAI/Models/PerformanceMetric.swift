import Foundation

// MARK: - Core Performance Metrics

/// Single question attempt record
struct PerformanceMetric: Codable, Identifiable, Sendable {
    let id: UUID
    let questionId: String
    let categoryId: String
    let isCorrect: Bool
    let timestamp: Date
    let timeTaken: TimeInterval
    let userAnswer: String
    let correctAnswer: String
    
    init(
        questionId: String,
        categoryId: String,
        isCorrect: Bool,
        timeTaken: TimeInterval,
        userAnswer: String,
        correctAnswer: String,
        timestamp: Date = Date()
    ) {
        precondition(timeTaken >= 0, "Time taken cannot be negative")
        precondition(timestamp <= Date(), "Timestamp cannot be in the future")
        precondition(!questionId.trimmingCharacters(in: .whitespaces).isEmpty, "Question ID cannot be empty")
        
        self.id = UUID()
        self.questionId = questionId
        self.categoryId = categoryId
        self.isCorrect = isCorrect
        self.timestamp = timestamp
        self.timeTaken = timeTaken
        self.userAnswer = userAnswer
        self.correctAnswer = correctAnswer
    }
}

// MARK: - Category-Level Progress

// MARK: - Exam Configuration (German Standards)

// MARK: - User Streak Tracking

/// Thread-safe streak management should use UserStreakManager actor
struct UserStreak: Codable, Sendable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastQuizDate: Date?
    var totalDaysActive: Int = 0
    
    mutating func recordQuizAttempt(on date: Date = Date()) {
        let today = Calendar.current.startOfDay(for: date)
        let lastQuizDay = lastQuizDate.map { Calendar.current.startOfDay(for: $0) }
        
        // Already quizzed today
        if lastQuizDay == today {
            return
        }
        
        // Calculate days since last quiz
        let daysSinceLastQuiz: Int
        if let lastDay = lastQuizDay {
            daysSinceLastQuiz = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
        } else {
            daysSinceLastQuiz = 1 // First quiz ever
        }
        
        // Update streak
        if daysSinceLastQuiz == 1 {
            // Consecutive day
            currentStreak += 1
            longestStreak = max(longestStreak, currentStreak)
        } else if daysSinceLastQuiz > 1 {
            // Streak broken, restart
            currentStreak = 1
        } else {
            // First quiz
            currentStreak = 1
        }
        
        lastQuizDate = date
        totalDaysActive += 1
    }
    
    mutating func reset() {
        currentStreak = 0
        longestStreak = 0
        lastQuizDate = nil
        totalDaysActive = 0
    }
}

// MARK: - Exam Simulation Results (Aggregate Root)

struct QuestionAttemptRecord: Codable, Sendable {
    let questionId: String
    let categoryId: String
    let isCorrect: Bool
    let timeTaken: TimeInterval
    let userAnswer: String
    let correctAnswer: String
}

struct CategoryAttemptSummary: Codable, Sendable {
    let categoryId: String
    let categoryName: String
    let correctCount: Int
    let totalCount: Int
    
    var accuracy: Double {
        guard totalCount > 0 else { return 0 }
        return Double(correctCount) / Double(totalCount)
    }
}

// MARK: - Exam Feedback (Localized)

// MARK: - Overall Statistics

struct OverallStats: Codable, Sendable {
    let totalQuestionsAnswered: Int
    let totalCorrect: Int
    let overallAccuracy: Double
    let categoryStats: [CategoryProgress]
    let userStreak: UserStreak
    let examResults: [ExamSimulationResult]
    
    var averageAccuracyByCategory: Double {
        let totalQuestions = categoryStats.reduce(0) { $0 + $1.totalQuestionsAnswered }
        guard totalQuestions > 0 else { return 0 }
        
        let weightedSum = categoryStats.reduce(0) { sum, category in
            sum + (category.accuracy * Double(category.totalQuestionsAnswered))
        }
        
        return weightedSum / Double(totalQuestions)
    }
    
    var lastExamResult: ExamSimulationResult? {
        examResults.sorted { $0.timestamp > $1.timestamp }.first
    }
}