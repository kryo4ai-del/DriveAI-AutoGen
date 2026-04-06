// ✅ Correct
struct ExamPassingRequirements {
    let minimumCorrectAnswers: Int = 27  // 90% of 30
    let minimumPercentage: Double = 0.90
}

var isPassed: Bool {
    correctAnswersCount >= ExamPassingRequirements().minimumCorrectAnswers
}