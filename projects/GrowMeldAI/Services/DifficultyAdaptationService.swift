class DifficultyAdaptationService {
    private let aiService: AIServiceProtocol
    
    // PRIMARY: AI recommends difficulty based on performance
    // FALLBACK: Static difficulty buckets (Easy/Medium/Hard)
    // BENEFIT: Exam always proceeds, never blocked
    
    func getDifficultyLevel(
        for category: Category,
        performanceMetrics: ExamProgress
    ) async -> DifficultyLevel {
        do {
            // Try AI adjustment
            return try await aiService.adjustDifficulty(based: performanceMetrics)
        } catch {
            // Fallback: static mapping
            let score = performanceMetrics.categoryScores[category.id] ?? 0
            if score > 80 {
                return .hard
            } else if score > 60 {
                return .medium
            } else {
                return .easy
            }
        }
    }
}
