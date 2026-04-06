import Foundation

/// Provides simplified responses when services are degraded
@MainActor
final class DegradedModeProvider: FallbackProvider {
    let name = "DegradedMode"
    let priority = 5
    let status: AIServiceStatus = .degraded(reason: "Vereinfachte Antworten")
    
    private let localProvider: LocalOfflineProvider
    
    init(localProvider: LocalOfflineProvider) {
        self.localProvider = localProvider
    }
    
    func getExplanation(for questionID: String) async throws -> String {
        do {
            let explanation = try await localProvider.getExplanation(for: questionID)
            return "⚠️ Vereinfachte Antwort:\n\n\(explanation)"
        } catch {
            return "Erklärung im Degraded-Modus nicht verfügbar."
        }
    }
    
    func getQuestions(category: String) async throws -> [LocalQuestion] {
        // Return subset of questions
        let allQuestions = try await localProvider.getQuestions(category: category)
        return Array(allQuestions.prefix(10))  // Limit to 10
    }
    
    func getRandomQuestions(count: Int) async throws -> [LocalQuestion] {
        let limited = min(count, 15)  // Max 15 in degraded mode
        return try await localProvider.getRandomQuestions(count: limited)
    }
    
    func search(query: String) async throws -> [LocalQuestion] {
        let results = try await localProvider.search(query: query)
        return Array(results.prefix(5))  // Limit results
    }
}