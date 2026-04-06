// Data/Persistence/QuestionCacheActor.swift
import Foundation

/// Thread-safe, singleton question cache using Swift actor
nonisolated actor QuestionCacheActor {
    static let shared = QuestionCacheActor()
    
    private var cachedQuestions: [Question]?
    private var cacheLoadError: Error?
    
    /// Load questions (called once, then cached)
    func loadQuestions(from loader: () async throws -> [Question]) async throws -> [Question] {
        if let cached = cachedQuestions {
            return cached
        }
        
        if let error = cacheLoadError {
            throw error
        }
        
        do {
            let questions = try await loader()
            self.cachedQuestions = questions
            return questions
        } catch {
            self.cacheLoadError = error
            throw error
        }
    }
    
    /// Get cached questions (or nil if not loaded)
    func getCachedQuestions() -> [Question]? {
        cachedQuestions
    }
    
    /// Clear cache (for testing)
    func clearCache() {
        cachedQuestions = nil
        cacheLoadError = nil
    }
}

// Data/Persistence/SQLiteDataStore.swift
final class SQLiteDataStore: LocalDataService {
    private let cacheActor = QuestionCacheActor.shared
    
    nonisolated func fetchAllQuestions() async throws -> [Question] {
        // ✅ Load once, cache indefinitely (no leak risk)
        try await cacheActor.loadQuestions {
            try Self.loadQuestionsFromJSON()
        }
    }
    
    nonisolated func fetchQuestionsByCategory(
        _ categoryID: String,
        limit: Int? = nil
    ) async throws -> [Question] {
        let allQuestions = try await fetchAllQuestions()
        var filtered = allQuestions.filter { $0.categoryID == categoryID }
        
        if let limit = limit {
            filtered = Array(filtered.shuffled().prefix(limit))
        }
        
        return filtered
    }
    
    private static func loadQuestionsFromJSON() throws -> [Question] {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            throw DataError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode([Question].self, from: data)
    }
}