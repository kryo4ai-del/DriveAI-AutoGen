// Immutable state structure
struct QuestionUIState: Equatable {
    let currentQuestion: Question
    let questionIndex: Int
    let totalQuestions: Int
    let selectedAnswerIndex: Int?
    let isAnswerCorrect: Bool?
    let showFeedback: Bool
    let userAnswers: [Int?]  // Track all answers in session
    
    mutating func selectAnswer(_ index: Int) {
        selectedAnswerIndex = index
        isAnswerCorrect = (index == currentQuestion.correctAnswerIndex)
        showFeedback = true
    }
}

// ViewModel handles state changes