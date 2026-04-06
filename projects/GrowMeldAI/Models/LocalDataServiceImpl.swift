import Foundation

final class LocalDataServiceImpl: LocalDataServiceProtocol {
    private let persistenceManager: UserDefaultsManager

    private var cachedQuestions: [Question]?
    private var cachedCategories: [Category]?
    private let cacheQueue = DispatchQueue(label: "com.driveai.cache", attributes: .concurrent)

    init(persistenceManager: UserDefaultsManager) {
        self.persistenceManager = persistenceManager
    }

    func fetchQuestions(category: String?) async throws -> [Question] {
        if let cached = cacheQueue.sync(execute: { cachedQuestions }) {
            return filterByCategory(cached, category: category)
        }

        let questions = try await LocalDataServiceImplementation().fetchRandomQuestions(count: Int.max)
        cacheQueue.async(flags: .barrier) {
            self.cachedQuestions = questions
        }

        return filterByCategory(questions, category: category)
    }

    func refreshCache() async throws {
        let impl = LocalDataServiceImplementation()
        let categories = try await impl.fetchAllCategories()
        let questions = try await impl.fetchRandomQuestions(count: Int.max)

        cacheQueue.async(flags: .barrier) {
            self.cachedQuestions = questions
            self.cachedCategories = categories
        }
    }

    private func filterByCategory(_ questions: [Question], category: String?) -> [Question] {
        guard let category = category else { return questions }
        return questions.filter { $0.categoryId == category }
    }
}