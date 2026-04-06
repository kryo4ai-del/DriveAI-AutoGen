import Foundation

/// Hardcoded static responses for complete service failure
@MainActor
final class StaticProvider: FallbackProvider {
    let name = "Static"
    let priority = 10  // Lowest priority
    let status: AIServiceStatus = .degraded(reason: "Statische Antworten")
    
    private let staticExplanations: [String: String] = [
        "sign_stop": "Das Stoppschild bedeutet vollständiger Halt an der Kreuzung.",
        "speed_limit": "Die angezeigte Geschwindigkeit ist einzuhalten.",
        "right_of_way": "Fahrzeuge von rechts haben Vorrang, wenn nicht anders beschildert."
    ]
    
    func getExplanation(for questionID: String) async throws -> String {
        logAccess("Static explanation for \(questionID)")
        
        return staticExplanations[questionID] ??
            "Diese Frage ist im Offline-Modus leider nicht verfügbar."
    }
    
    func getQuestions(category: String) async throws -> [LocalQuestion] {
        throw FallbackError.notFound("Keine statischen Fragen für \(category)")
    }
    
    func getRandomQuestions(count: Int) async throws -> [LocalQuestion] {
        throw FallbackError.notFound("Statische Fragen nicht verfügbar")
    }
    
    func search(query: String) async throws -> [LocalQuestion] {
        throw FallbackError.notFound("Suche nicht im statischen Modus verfügbar")
    }
}