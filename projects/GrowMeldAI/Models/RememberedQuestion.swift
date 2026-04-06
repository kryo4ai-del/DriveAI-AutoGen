import Foundation

/// Immutable domain model for tracking question retention
struct RememberedQuestion: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let questionId: String
    let categoryId: String
    
    let reviewCount: Int
    let correctCount: Int
    let lastReviewDate: Date?
    let nextReviewDate: Date
    let difficulty: Difficulty
    
    let intervalDays: Int
    let easeFactor: Double
    
    let userFlaggedHard: Bool
    let userFlaggedEasy: Bool
    let hasExplanationRead: Bool
    
    enum Difficulty: String, Codable, Sendable {
        case easy, medium, hard
    }
    
    init(questionId: String, categoryId: String) {
        self.id = UUID()
        self.questionId = questionId
        self.categoryId = categoryId
        self.reviewCount = 0
        self.correctCount = 0
        self.lastReviewDate = nil
        self.nextReviewDate = Date()
        self.difficulty = .medium
        self.intervalDays = 1
        self.easeFactor = 2.5
        self.userFlaggedHard = false
        self.userFlaggedEasy = false
        self.hasExplanationRead = false
    }
    
    // MARK: - Immutable Update Methods
    
    func recordCorrectAnswer(explanationViewed: Bool = false) -> RememberedQuestion {
        let newInterval = RetentionEngine().calculateNextInterval(
            currentInterval: intervalDays,
            easeFactor: easeFactor,
            quality: 5  // Perfect
        )
        
        return RememberedQuestion(
            id: id,
            questionId: questionId,
            categoryId: categoryId,
            reviewCount: reviewCount + 1,
            correctCount: correctCount + 1,
            lastReviewDate: Date(),
            nextReviewDate: Calendar.current.date(
                byAdding: .day,
                value: newInterval,
                to: Date()
            ) ?? Date(),
            difficulty: difficulty,
            intervalDays: newInterval,
            easeFactor: RetentionEngine().adjustEaseFactor(5),
            userFlaggedHard: userFlaggedHard,
            userFlaggedEasy: false,
            hasExplanationRead: explanationViewed
        )
    }
    
    func recordIncorrectAnswer() -> RememberedQuestion {
        return RememberedQuestion(
            id: id,
            questionId: questionId,
            categoryId: categoryId,
            reviewCount: reviewCount + 1,
            correctCount: correctCount,  // No increment
            lastReviewDate: Date(),
            nextReviewDate: Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: Date()
            ) ?? Date(),
            difficulty: difficulty,
            intervalDays: 1,  // Reset interval
            easeFactor: RetentionEngine().adjustEaseFactor(2),
            userFlaggedHard: userFlaggedHard,
            userFlaggedEasy: userFlaggedEasy,
            hasExplanationRead: false
        )
    }
    
    func withDifficulty(_ newDifficulty: Difficulty) -> RememberedQuestion {
        return RememberedQuestion(
            id: id,
            questionId: questionId,
            categoryId: categoryId,
            reviewCount: reviewCount,
            correctCount: correctCount,
            lastReviewDate: lastReviewDate,
            nextReviewDate: nextReviewDate,
            difficulty: newDifficulty,
            intervalDays: intervalDays,
            easeFactor: easeFactor,
            userFlaggedHard: newDifficulty == .hard,
            userFlaggedEasy: newDifficulty == .easy,
            hasExplanationRead: hasExplanationRead
        )
    }
    
    func reset() -> RememberedQuestion {
        return RememberedQuestion(questionId: questionId, categoryId: categoryId)
    }
    
    // MARK: - Computed Properties
    
    var accuracy: Double {
        guard reviewCount > 0 else { return 0 }
        return Double(correctCount) / Double(reviewCount)
    }
    
    var daysUntilReview: Int {
        Calendar.current.dateComponents(
            [.day],
            from: Date(),
            to: nextReviewDate
        ).day ?? 0
    }
    
    // MARK: - Hashable (only use id)
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: RememberedQuestion, rhs: RememberedQuestion) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - UI Snapshot

struct RememberedQuestionSnapshot: Identifiable, Sendable {
    let id: UUID
    let questionId: String
    let categoryId: String
    
    let reviewCount: Int
    let correctCount: Int
    let accuracy: Double
    let lastReviewDate: Date?
    let nextReviewDate: Date
    let daysUntilReview: Int
    let difficulty: RememberedQuestion.Difficulty
    let userFlaggedHard: Bool
    let userFlaggedEasy: Bool
    
    init(from question: RememberedQuestion) {
        self.id = question.id
        self.questionId = question.questionId
        self.categoryId = question.categoryId
        self.reviewCount = question.reviewCount
        self.correctCount = question.correctCount
        self.accuracy = question.accuracy
        self.lastReviewDate = question.lastReviewDate
        self.nextReviewDate = question.nextReviewDate
        self.daysUntilReview = question.daysUntilReview
        self.difficulty = question.difficulty
        self.userFlaggedHard = question.userFlaggedHard
        self.userFlaggedEasy = question.userFlaggedEasy
    }
}