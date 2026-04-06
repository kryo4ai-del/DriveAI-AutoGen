protocol SpacedRepetitionServiceProtocol {
    func calculateNextReview(for questionId: String, isCorrect: Bool) async -> Date
}

@MainActor
final class SpacedRepetitionService: SpacedRepetitionServiceProtocol {
    static let shared = SpacedRepetitionService()
    
    // SM-2 Algorithm or simplified:
    // Correct: Review in 3 days
    // Incorrect: Review in 1 day
    // Track repetition count for future enhancements
    
    private let database: DatabaseServiceProtocol
    
    func calculateNextReview(for questionId: String, isCorrect: Bool) async -> Date {
        // Query history, calculate interval
        // Return next review date
    }
}