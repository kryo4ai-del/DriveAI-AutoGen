import Foundation

struct PracticeSession: Identifiable, Codable {
    let id: UUID
    let categoryId: String
    let startedAt: Date
    var currentQuestionIndex: Int
    var answers: [UUID: SelectedAnswer]
    var isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, categoryId, startedAt, currentQuestionIndex, answers, isActive
    }
    
    struct SelectedAnswer: Codable {
        let questionId: UUID
        let selectedIndex: Int
        let isCorrect: Bool
        let timestamp: Date
    }
    
    func score(totalQuestions: Int) -> (correct: Int, percentage: Double) {
        let correctCount = answers.values.filter { $0.isCorrect }.count
        let percentage = totalQuestions > 0 ? Double(correctCount) / Double(totalQuestions) * 100 : 0
        return (correctCount, percentage)
    }
}

struct PremiumQuestion: Identifiable, Codable {
    let id: UUID
    let categoryId: String
    let text: String
    let imagePath: String?
    let options: [String]
    let correctIndex: Int
    let explanation: String
    let difficulty: Int // 1-3
    
    /// The correct answer text for comparison.
    var correctAnswer: String {
        guard correctIndex >= 0, correctIndex < options.count else { return "" }
        return options[correctIndex]
    }
    
    enum CodingKeys: String, CodingKey {
        case id, categoryId, text, imagePath, options, correctIndex, explanation, difficulty
    }
}

struct PremiumCategory: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let questionCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, questionCount
    }
}

struct PracticeSessionResult: Identifiable {
    let id: UUID
    let sessionId: UUID
    let categoryId: String
    let correctCount: Int
    let totalQuestions: Int
    let timeSpent: TimeInterval
    let percentage: Double
    let isPassed: Bool
    
    var passThreshold: Double { 0.75 }
    
    init(session: PracticeSession, totalQuestions: Int, timeSpent: TimeInterval) {
        self.id = UUID()
        self.sessionId = session.id
        self.categoryId = session.categoryId
        self.correctCount = session.answers.values.filter { $0.isCorrect }.count
        self.totalQuestions = totalQuestions
        self.timeSpent = timeSpent
        self.percentage = totalQuestions > 0 ? Double(correctCount) / Double(totalQuestions) : 0
        self.isPassed = percentage >= passThreshold
    }
}
