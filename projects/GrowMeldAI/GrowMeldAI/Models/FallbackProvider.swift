import Foundation

// MARK: - AIServiceStatus (local definition to resolve ambiguity)

/// Status of an AI/fallback service provider
enum AIServiceStatus: String, Sendable {
    case available
    case unavailable
    case degraded
    case unknown
}

// MARK: - LocalQuestion

/// A locally stored question used by fallback providers
struct LocalQuestion: Identifiable, Sendable {
    let id: String
    let category: String
    let text: String
    let options: [String]
    let correctAnswerIndex: Int
    let explanation: String
    let keywords: [String]

    init(
        id: String = UUID().uuidString,
        category: String,
        text: String,
        options: [String],
        correctAnswerIndex: Int,
        explanation: String,
        keywords: [String] = []
    ) {
        self.id = id
        self.category = category
        self.text = text
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.explanation = explanation
        self.keywords = keywords
    }
}

// MARK: - FallbackProvider Protocol

/// Base protocol for all fallback data providers
protocol FallbackProvider: AnyObject, Sendable {
    /// Priority for selection (lower = higher priority)
    var priority: Int { get }

    /// Human-readable name for debugging
    var name: String { get }

    /// Current status of this provider
    var status: AIServiceStatus { get }

    /// Get explanation for a question
    func getExplanation(for questionID: String) async throws -> String

    /// Get questions by category
    func getQuestions(category: String) async throws -> [LocalQuestion]

    /// Get random questions (for exam simulation)
    func getRandomQuestions(count: Int) async throws -> [LocalQuestion]

    /// Search questions by keyword
    func search(query: String) async throws -> [LocalQuestion]
}

// MARK: - Helper Extension

extension FallbackProvider {
    func logAccess(_ action: String) {
        #if DEBUG
        print("[FallbackProvider] \(name): \(action)")
        #endif
    }
}

// MARK: - Local Data Structure