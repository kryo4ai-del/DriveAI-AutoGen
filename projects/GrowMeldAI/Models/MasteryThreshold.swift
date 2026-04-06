struct MasteryThreshold {
    static let minimumPercentage: Double = 80.0
    static let minimumQuestionsAnswered: Int = 5
}

var isMastered: Bool {
    percentageCorrect >= MasteryThreshold.minimumPercentage &&
    questionsAnswered >= MasteryThreshold.minimumQuestionsAnswered
}