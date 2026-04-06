// Services/Business/QuestionService.swift
final class QuestionService {
    private let localDataService: LocalDataService
    private let syncService: SyncService
    
    func getQuestion(id: Int) async throws -> Question {
        // 1️⃣ Primary: Local SQLite (instant, no network)
        do {
            return try localDataService.fetchQuestion(byId: id)
        } catch {
            // 2️⃣ Fallback: Check if database needs repair
            try? localDataService.validateDatabaseIntegrity()
            throw error
        }
    }
    
    // [Future] ML-powered explanation fallback
    func getExplanation(for questionId: Int) async -> String {
        // Try AI service; fallback to stored text
        do {
            return try await aiExplanationService.generate(questionId: questionId)
        } catch {
            // Graceful degradation: use pre-written explanation
            return try localDataService.fetchExplanation(questionId: questionId)
        }
    }
}