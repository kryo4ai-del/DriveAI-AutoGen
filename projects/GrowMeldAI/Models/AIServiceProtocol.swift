import Foundation

/// Protocol defining the AI service interface
protocol AIServiceProtocol: AnyObject, Sendable {
    /// Get explanation for a specific question
    func getExplanation(for questionID: String) async throws -> String
    
    /// Get all questions in a category
    func getQuestions(category: String) async throws -> [LocalQuestion]
    
    /// Get random questions (typically for exam simulation)
    func getRandomQuestions(count: Int) async throws -> [LocalQuestion]
    
    /// Search questions by keyword
    func search(query: String) async throws -> [LocalQuestion]
}