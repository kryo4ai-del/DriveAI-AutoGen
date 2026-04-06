class LocalQuestionRepository: QuestionRepository {
    private var cachedQuestions: [Question]?
    private var cacheLoadedAt: Date?
    private let cacheExpirySeconds: TimeInterval = 3600  // 1 hour
    
    private func loadQuestionsFromBundle() -> [Question] {
        // ✅ Invalidate expired cache
        if let loadedAt = cacheLoadedAt,
           Date().timeIntervalSince(loadedAt) > cacheExpirySeconds {
            cachedQuestions = nil
            cacheLoadedAt = nil
        }
        
        if let cached = cachedQuestions {
            return cached
        }
        
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let questions = try? JSONDecoder().decode([Question].self, from: data) else {
            return []
        }
        
        self.cachedQuestions = questions
        self.cacheLoadedAt = Date()
        return questions
    }
    
    // ✅ Allow explicit cache clearing for testing
    func clearCache() {
        cachedQuestions = nil
        cacheLoadedAt = nil
    }
}