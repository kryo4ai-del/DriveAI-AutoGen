struct QuestionModel: Identifiable {
    let id: UUID
    let question: String
    let answers: [AnswerModel]
    let correctAnswer: UUID
}