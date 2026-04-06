/// Provides read access to the question database.
/// 
/// Implementations must load questions from local storage (JSON/SQLite).
/// All methods are thread-safe for concurrent access.
protocol QuestionDataProvider: Sendable {
    /// - Parameters:
    ///   - categoryId: The UUID of the category to filter by
    /// - Returns: Array of questions in the category
    /// - Throws: `ServiceError.questionsNotFound` if category doesn't exist
    func fetchQuestions(categoryId: UUID) async throws -> [Question]
}