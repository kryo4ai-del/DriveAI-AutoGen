import Foundation

struct ExamAnswer: Codable, Identifiable {
    let id: UUID
    let questionId: UUID
    let selectedAnswerId: UUID
    let isCorrect: Bool
    let timeSpentSeconds: Int
    let submittedAt: Date
    let wasReviewedAgain: Bool

    init(
        id: UUID = UUID(),
        questionId: UUID,
        selectedAnswerId: UUID,
        isCorrect: Bool,
        timeSpentSeconds: Int,
        submittedAt: Date = Date(),
        wasReviewedAgain: Bool = false
    ) {
        self.id = id
        self.questionId = questionId
        self.selectedAnswerId = selectedAnswerId
        self.isCorrect = isCorrect
        self.timeSpentSeconds = timeSpentSeconds
        self.submittedAt = submittedAt
        self.wasReviewedAgain = wasReviewedAgain
    }
}