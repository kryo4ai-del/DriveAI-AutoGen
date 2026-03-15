import Foundation
@MainActor
final class QuestionRepository: QuestionRepositoryProtocol {
    private var cachedQuestions: [Question]?
    private var cacheLoadDate: Date?
    private let cacheDuration: TimeInterval = 3600 // 1 hour
    
    func loadQuestions(skipCache: Bool = false) async throws -> [Question] {
        if !skipCache, let cached = cachedQuestions, isCacheValid() {
            return cached
        }
        
        // Load from bundle...
        self.cachedQuestions = questions
        self.cacheLoadDate = Date()
        return questions
    }
    
    private func isCacheValid() -> Bool {
        guard let loadDate = cacheLoadDate else { return false }
        return Date().timeIntervalSince(loadDate) < cacheDuration
    }
    
    func invalidateCache() {
        cachedQuestions = nil
        cacheLoadDate = nil
    }
}