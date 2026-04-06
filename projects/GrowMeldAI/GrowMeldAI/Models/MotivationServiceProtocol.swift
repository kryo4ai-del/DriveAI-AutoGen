protocol MotivationServiceProtocol {
    func recordCorrectAnswer(category: String) async -> EmotionalState
    func calculateStreakBonus() -> Int
    func getEncouragingMessage(context: AnswerContext) -> String
}