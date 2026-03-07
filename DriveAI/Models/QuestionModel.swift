import Foundation

/// Represents a multiple-choice question.
struct QuestionModel: Identifiable {
    /// Unique identifier for the question.
    let id: Int
    /// The text of the question.
    let question: String
    /// An array of possible answers.
    let answers: [AnswerModel]
    /// The index of the correct answer in the answers array.
    let correctAnswerIndex: Int
}

/// Represents an individual answer to a question.
struct AnswerModel: Identifiable {
    /// Unique identifier for the answer.
    let id: Int
    /// The text of the answer.
    let answer: String
}