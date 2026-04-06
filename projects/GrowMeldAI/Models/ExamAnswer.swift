struct ExamAnswer: Codable, Identifiable {
    let id: UUID = UUID()
    let questionId: UUID
    let selectedAnswerId: UUID
    let isCorrect: Bool
    let timeSpentSeconds: Int
    let submittedAt: Date
    let wasReviewedAgain: Bool = false
}
