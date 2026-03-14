init(
    id: UUID = UUID(),
    totalQuestions: Int,
    correctAnswers: Int,
    categoryScores: [CategoryScore],
    completedAt: Date = .now,
    durationSeconds: Int
) throws {
    guard totalQuestions > 0 else {
        throw ValidationError.invalidQuestionCount
    }
    guard correctAnswers >= 0 && correctAnswers <= totalQuestions else {
        throw ValidationError.invalidAnswerCount
    }
    guard durationSeconds >= 0 else {
        throw ValidationError.invalidDuration
    }
    
    self.id = id
    self.totalQuestions = totalQuestions
    self.correctAnswers = correctAnswers
    self.categoryScores = categoryScores
    self.completedAt = completedAt
    self.durationSeconds = durationSeconds
}

enum ValidationError: LocalizedError {
    case invalidQuestionCount
    case invalidAnswerCount
    case invalidDuration
    
    var errorDescription: String? {
        switch self {
        case .invalidQuestionCount:
            return "Die Anzahl der Fragen muss größer als 0 sein."
        case .invalidAnswerCount:
            return "Die Anzahl der korrekten Antworten ist ungültig."
        case .invalidDuration:
            return "Die Dauer muss nicht-negativ sein."
        }
    }
}