struct QuizResult {
    let totalQuestions: Int
    let correctAnswers: Int
    var score: Double {
        totalQuestions > 0 ? Double(correctAnswers) / Double(totalQuestions) * 100.0 : 0
    }
}