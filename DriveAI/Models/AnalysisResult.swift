struct AnalysisResult {
    let question: String
    let userAnswer: String
    let correctAnswer: String
    var isCorrect: Bool {
        userAnswer.lowercased() == correctAnswer.lowercased()
    }

    init(question: String, userAnswer: String, correctAnswer: String) {
        self.question = question
        self.userAnswer = userAnswer
        self.correctAnswer = correctAnswer
    }
}