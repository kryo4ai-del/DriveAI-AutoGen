import Foundation
import os.log

private let logger = Logger(subsystem: "com.driveai.fallback", category: "local")

/// Pre-bundled offline provider with official DACH question catalog
@MainActor
final class LocalOfflineProvider: FallbackProvider {
    let name = "LocalOffline"
    let priority = 1
    let status: AIServiceStatus = .offline
    
    private var questionCache: [LocalQuestion] = []
    private var categoryIndex: [String: [LocalQuestion]] = [:]
    private var loadTask: Task<Void, Error>?
    
    let bundle: Bundle
    
    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }
    
    // MARK: - Loading (Thread-Safe)
    
    func ensureLoaded() async throws {
        // Return if already loaded or loading
        if !questionCache.isEmpty {
            return
        }
        
        // Wait for existing load task
        if let existingTask = loadTask {
            try await existingTask.value
            return
        }
        
        let task = Task {
            try await performLoad()
        }
        
        loadTask = task
        try await task.value
    }
    
    private func performLoad() async throws {
        guard let url = bundle.url(
            forResource: "question_catalog",
            withExtension: "json"
        ) else {
            logger.error("question_catalog.json not found in bundle")
            throw FallbackError.resourceNotFound("question_catalog.json")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            self.questionCache = try decoder.decode([LocalQuestion].self, from: data)
            self.categoryIndex = Dictionary(grouping: self.questionCache, by: { $0.category })
            logger.info("Loaded \(self.questionCache.count) questions from catalog")
        } catch let decodingError as DecodingError {
            logger.error("Failed to decode question_catalog.json: \(decodingError)")
            
            // Fallback to minimal hardcoded questions
            self.questionCache = Self.createMinimalFallback()
            self.categoryIndex = Dictionary(grouping: self.questionCache, by: { $0.category })
            logger.warning("Using minimal fallback questions (\(self.questionCache.count))")
        }
    }
    
    // MARK: - FallbackProvider Protocol
    
    func getExplanation(for questionID: String) async throws -> String {
        try await ensureLoaded()
        
        guard let question = questionCache.first(where: { $0.id == questionID }) else {
            throw FallbackError.notFound("Question \(questionID)")
        }
        
        return question.explanation
    }
    
    func getQuestions(category: String) async throws -> [LocalQuestion] {
        try await ensureLoaded()
        
        guard let questions = categoryIndex[category], !questions.isEmpty else {
            throw FallbackError.notFound("Category \(category)")
        }
        
        return questions
    }
    
    func getRandomQuestions(count: Int) async throws -> [LocalQuestion] {
        try await ensureLoaded()
        
        let shuffled = questionCache.shuffled()
        let limited = Array(shuffled.prefix(count))
        
        if limited.isEmpty {
            throw FallbackError.notFound("No questions available")
        }
        
        return limited
    }
    
    func search(query: String) async throws -> [LocalQuestion] {
        try await ensureLoaded()
        
        let lowercaseQuery = query.lowercased()
        let results = questionCache.filter { question in
            question.question.lowercased().contains(lowercaseQuery) ||
            question.keywords.contains { $0.lowercased().contains(lowercaseQuery) }
        }
        
        if results.isEmpty {
            throw FallbackError.notFound("No results for '\(query)'")
        }
        
        return results
    }
    
    // MARK: - Fallback Questions
    
    private static func createMinimalFallback() -> [LocalQuestion] {
        [
            LocalQuestion(
                id: "emergency_1",
                question: "Was bedeutet ein rotes Stoppschild?",
                answers: [
                    "Vollständiger Halt erforderlich",
                    "Bremsen und Schauen",
                    "Vorsicht, Vorrang beachten"
                ],
                correctIndex: 0,
                explanation: "Das rote Stoppschild (Achteck) fordert einen vollständigen Halt auf.",
                category: "Verkehrszeichen",
                difficulty: 1,
                keywords: ["Stop", "Halt", "Schild"]
            ),
            LocalQuestion(
                id: "emergency_2",
                question: "Wer hat Vorrang bei zwei Fahrzeugen an einer Kreuzung?",
                answers: [
                    "Fahrzeug von rechts",
                    "Fahrzeug von links",
                    "Fahrzeug das zuerst kam"
                ],
                correctIndex: 0,
                explanation: "Bei Kreuzungen ohne Beschilderung hat das Fahrzeug von rechts Vorrang.",
                category: "Vorfahrtsregeln",
                difficulty: 1,
                keywords: ["Vorrang", "Vorfahrt", "Kreuzung"]
            )
        ]
    }
}
