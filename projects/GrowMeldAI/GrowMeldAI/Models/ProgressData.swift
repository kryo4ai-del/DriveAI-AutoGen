struct ProgressData: Codable {
    let categoryId: QuestionCategory
    let totalQuestions: Int
    let answeredQuestions: Int
    let correctAnswers: Int
    let incorrectAnswers: Int
    let recentAttempts: [UserAnswer]  // Last 10 attempts
    let wrongQuestionIds: [UUID]      // For "review weak areas"
    
    var weakAreas: [UUID] {
        // Questions user got wrong multiple times
        recentAttempts
            .filter { !$0.isCorrect }
            .reduce(into: [:]) { counts, attempt in
                counts[attempt.questionId, default: 0] += 1
            }
            .filter { $0.value >= 2 }  // Got it wrong 2+ times
            .keys
            .map { UUID(uuidString: String($0)) ?? UUID() }
    }
}