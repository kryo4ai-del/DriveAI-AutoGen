/// Represents a quiz question.
struct Question {
    let id: UUID
    let text: String
    let correctAnswer: String
    let options: [String]
}

/// Represents a user's answer to a question.
struct UserAnswer {
    let question: Question
    let selectedOption: String
}

/// Represents the result of analyzing a user's answer.
struct AnalysisResult {
    let correct: Bool
    let feedback: String
}