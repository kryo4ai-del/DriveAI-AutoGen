struct SessionAnswer: Identifiable, Codable, Equatable, Hashable, Sendable {
    let id: UUID
    let questionId: UUID
    let selectedAnswerId: UUID
    let timestamp: Date
    let isCorrect: Bool
    let explanation: String
    
    init(
        questionId: UUID,
        selectedAnswerId: UUID,
        isCorrect: Bool,
        explanation: String,
        id: UUID = UUID(),
        timestamp: Date = Date()
    ) throws {
        guard !explanation.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw DomainError.validationError(
                field: "explanation",
                reason: "Erklärung darf nicht leer sein"
            )
        }
        self.id = id
        self.questionId = questionId
        self.selectedAnswerId = selectedAnswerId
        self.isCorrect = isCorrect
        self.explanation = explanation
        self.timestamp = timestamp
    }
}
