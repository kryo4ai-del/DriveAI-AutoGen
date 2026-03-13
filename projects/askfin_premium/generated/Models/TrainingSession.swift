import Foundation

// MARK: - Training Session

struct TrainingSession: Identifiable, Codable {
    let id: UUID
    let categoryId: String
    let categoryName: String
    let startedAt: Date
    var completedQuestions: [CompletedQuestion] = []
    var currentQuestionIndex: Int = 0
    var isCompleted: Bool = false
    
    // MARK: - Computed Properties
    
    var totalQuestions: Int {
        completedQuestions.count + (isCompleted ? 0 : 1)
    }
    
    var correctAnswerCount: Int {
        completedQuestions.filter { $0.isCorrect }.count
    }
    
    var scorePercentage: Double {
        guard !completedQuestions.isEmpty else { return 0 }
        return (Double(correctAnswerCount) / Double(completedQuestions.count)) * 100
    }
    
    var totalTimeSpent: TimeInterval {
        completedQuestions.reduce(0) { $0 + $1.timeSpent }
    }
    
    var averageTimePerQuestion: TimeInterval {
        guard !completedQuestions.isEmpty else { return 0 }
        return totalTimeSpent / Double(completedQuestions.count)
    }
    
    // MARK: - Pure Functions (Immutable Updates)
    
    /// Returns new session with completed question appended
    func withCompletedQuestion(_ question: CompletedQuestion) -> TrainingSession {
        var updated = self
        updated.completedQuestions.append(question)
        updated.currentQuestionIndex += 1
        return updated
    }
    
    /// Returns new session marked as completed
    func markCompleted() -> TrainingSession {
        var updated = self
        updated.isCompleted = true
        return updated
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id, categoryId, categoryName, startedAt
        case completedQuestions = "completed_questions"
        case currentQuestionIndex = "current_question_index"
        case isCompleted = "is_completed"
    }
}

// MARK: - Completed Question Record

struct CompletedQuestion: Codable, Hashable {
    let questionId: String
    let selectedAnswer: String
    let isCorrect: Bool
    let timeSpent: TimeInterval
    let explanationRead: Bool
    let completedAt: Date
    
    init(
        questionId: String,
        selectedAnswer: String,
        isCorrect: Bool,
        timeSpent: TimeInterval,
        explanationRead: Bool = false,
        completedAt: Date = Date()
    ) {
        self.questionId = questionId
        self.selectedAnswer = selectedAnswer
        self.isCorrect = isCorrect
        self.timeSpent = timeSpent
        self.explanationRead = explanationRead
        self.completedAt = completedAt
    }
}

// MARK: - Training Result

struct TrainingResult: Identifiable, Codable {
    let id: UUID
    let sessionId: UUID
    let categoryName: String
    let totalQuestions: Int
    let correctAnswers: Int
    let scorePercentage: Double
    let averageTimePerQuestion: TimeInterval
    let completedAt: Date
    let failedQuestionIds: [String]
    
    // MARK: - Computed Properties
    
    var passingScore: Bool {
        scorePercentage >= 75.0
    }
    
    var motivationalMessage: String {
        switch scorePercentage {
        case 90...:
            return NSLocalizedString("excellent_score_message", comment: "Excellent performance")
        case 75..<90:
            return NSLocalizedString("good_score_message", comment: "Good performance")
        case 60..<75:
            return NSLocalizedString("fair_score_message", comment: "Fair performance")
        default:
            return NSLocalizedString("try_again_message", comment: "Keep practicing")
        }
    }
    
    var formattedTotalTime: String {
        let interval = TimeInterval(totalQuestions) * averageTimePerQuestion
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var formattedAverageTime: String {
        let seconds = Int(averageTimePerQuestion)
        let millis = Int((averageTimePerQuestion - Double(seconds)) * 100)
        return String(format: "%d,%02d s", seconds, millis)
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id, sessionId, categoryName
        case totalQuestions = "total_questions"
        case correctAnswers = "correct_answers"
        case scorePercentage = "score_percentage"
        case averageTimePerQuestion = "average_time_per_question"
        case completedAt = "completed_at"
        case failedQuestionIds = "failed_question_ids"
    }
}

// MARK: - Question with Category Context

struct QuestionWithCategory {
    let question: Question
    let categoryName: String
    let questionNumber: Int
    let totalQuestions: Int
    
    var progress: Double {
        Double(questionNumber) / Double(totalQuestions)
    }
}

// MARK: - Category Statistics

struct CategoryStats: Codable {
    let categoryId: String
    let categoryName: String
    let totalAttempts: Int
    let averageScore: Double
    let bestScore: Double
    let lastAttemptDate: Date?
    let totalQuestionsAvailable: Int
    
    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id"
        case categoryName = "category_name"
        case totalAttempts = "total_attempts"
        case averageScore = "average_score"
        case bestScore = "best_score"
        case lastAttemptDate = "last_attempt_date"
        case totalQuestionsAvailable = "total_questions_available"
    }
}