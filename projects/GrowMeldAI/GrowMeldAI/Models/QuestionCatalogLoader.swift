import Foundation

/// Handles efficient loading of question catalog with lazy initialization
@MainActor
final class QuestionCatalogLoader {
    private var cachedQuestions: [Question]?
    private var isLoading = false
    
    /// Load all questions from bundled JSON catalog
    func loadAllQuestions() async -> [Question] {
        // Return cache if available
        if let cached = cachedQuestions {
            return cached
        }
        
        // Prevent duplicate loads
        if isLoading {
            while cachedQuestions == nil && isLoading {
                try? await Task.sleep(nanoseconds: 100_000_000)  // 100ms
            }
            return cachedQuestions ?? []
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // Load from bundle
        if let questions = loadFromBundle() {
            cachedQuestions = questions
            return questions
        }
        
        // Fallback to seeded data
        let seeded = seedQuestions()
        cachedQuestions = seeded
        return seeded
    }
    
    /// Load filtered questions for specific category
    func loadQuestions(category: QuestionCategory) async -> [Question] {
        let all = await loadAllQuestions()
        return all.filter { $0.category == category }
    }
    
    private func loadFromBundle() -> [Question]? {
        guard let url = Bundle.main.url(forResource: "questions_catalog", withExtension: "json") else {
            AppLogger.warn("questions_catalog.json not found in bundle")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let questions = try decoder.decode([Question].self, from: data)
            AppLogger.info("Loaded \(questions.count) questions from bundle")
            return questions
        } catch {
            AppLogger.error("Failed to decode questions_catalog.json: \(error)")
            return nil
        }
    }
    
    /// Seed fallback questions (for MVP testing)
    private func seedQuestions() -> [Question] {
        var questions: [Question] = []
        
        // Example: 10 traffic sign questions
        for i in 0..<10 {
            questions.append(
                Question(
                    id: UUID(),
                    text: "Verkehrszeichen \(i): Was bedeutet dieses Zeichen?",
                    options: ["Option A", "Option B", "Option C", "Option D"],
                    correctAnswerIndex: i % 4,
                    explanation: "Dies ist die korrekte Erklärung.",
                    category: .trafficSigns,
                    difficulty: (i % 5) + 1,
                    imageUrl: nil
                )
            )
        }
        
        AppLogger.warn("Using seeded questions (no bundle data)")
        return questions
    }
}