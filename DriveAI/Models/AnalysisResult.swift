struct AnalysisResult {
    let question: String
    let userAnswer: String
    let correctAnswer: String
    let detectedCategory: QuestionCategory
    let categoryConfidence: Double
    var isCorrect: Bool {
        userAnswer.lowercased() == correctAnswer.lowercased()
    }

    init(question: String,
         userAnswer: String,
         correctAnswer: String,
         detectedCategory: QuestionCategory = .general,
         categoryConfidence: Double = 0) {
        self.question = question
        self.userAnswer = userAnswer
        self.correctAnswer = correctAnswer
        self.detectedCategory = detectedCategory
        self.categoryConfidence = categoryConfidence
    }
}
