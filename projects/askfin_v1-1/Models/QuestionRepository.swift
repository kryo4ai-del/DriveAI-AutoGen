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

        let questions: [Question] = []  // TODO: Load from bundle
        self.cachedQuestions = questions
        self.cacheLoadDate = Date()
        return questions
    }
    
    private func isCacheValid() -> Bool {
        guard let loadDate = cacheLoadDate else { return false }
        return Date().timeIntervalSince(loadDate) < cacheDuration
    }
    
    func loadQuestions() async throws -> [Question] {
        try await loadQuestions(skipCache: false)
    }

    func getQuestion(by id: String) async throws -> Question {
        let all = try await loadQuestions()
        guard let question = all.first(where: { $0.id.uuidString == id }) else {
            throw LocalDataError.questionNotFound
        }
        return question
    }

    func getQuestions(by category: QuestionCategory) async throws -> [Question] {
        let all = try await loadQuestions()
        return all.filter { $0.categoryId == category.id }
    }

    func getRandomQuestions(count: Int) async throws -> [Question] {
        let all = try await loadQuestions()
        return Array(all.shuffled().prefix(count))
    }

    func invalidateCache() {
        cachedQuestions = nil
        cacheLoadDate = nil
    }
}