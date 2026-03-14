struct SimulationResult: Codable, Identifiable {
    let id: UUID
    let totalQuestions: Int
    let correctAnswers: Int
    let categoryScores: [CategoryScore]
    let completedAt: Date
    let durationSeconds: Int
    
    init(
        id: UUID = UUID(),
        totalQuestions: Int,
        correctAnswers: Int,
        categoryScores: [CategoryScore],
        completedAt: Date = .now,
        durationSeconds: Int
    ) throws {
        guard totalQuestions > 0 else {
            throw ValidationError.invalidQuestionCount("totalQuestions muss > 0 sein")
        }
        guard correctAnswers >= 0 && correctAnswers <= totalQuestions else {
            throw ValidationError.invalidAnswerCount(
                "correctAnswers (\(correctAnswers)) außerhalb 0...\(totalQuestions)"
            )
        }
        guard durationSeconds >= 0 else {
            throw ValidationError.invalidDuration("durationSeconds darf nicht negativ sein")
        }
        
        let categoryTotal = categoryScores.reduce(0) { $0 + $1.total }
        guard categoryTotal == totalQuestions else {
            throw ValidationError.categoryMismatch(
                "Category total (\(categoryTotal)) ≠ totalQuestions (\(totalQuestions))"
            )
        }
        
        self.id = id
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.categoryScores = categoryScores
        self.completedAt = completedAt
        self.durationSeconds = durationSeconds
    }
    
    enum ValidationError: LocalizedError {
        case invalidQuestionCount(String)
        case invalidAnswerCount(String)
        case invalidDuration(String)
        case categoryMismatch(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidQuestionCount(let msg):
                return msg
            case .invalidAnswerCount(let msg):
                return msg
            case .invalidDuration(let msg):
                return msg
            case .categoryMismatch(let msg):
                return msg
            }
        }
    }
}