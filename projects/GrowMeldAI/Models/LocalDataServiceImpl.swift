final class LocalDataServiceImpl: LocalDataServiceProtocol {
    private let jsonLoader: JSONDataLoader
    private let persistenceManager: UserDefaultsManager
    
    private var cachedQuestions: [Question]?
    private var cachedCategories: [Category]?
    private let cacheQueue = DispatchQueue(label: "com.driveai.cache", attributes: .concurrent)
    
    init(jsonLoader: JSONDataLoader, persistenceManager: UserDefaultsManager) {
        self.jsonLoader = jsonLoader
        self.persistenceManager = persistenceManager
    }
    
    func fetchQuestions(category: String?) async throws -> [Question] {
        // Try to use cached data
        if let cached = cacheQueue.sync(execute: { cachedQuestions }) {
            return filterByCategory(cached, category: category)
        }
        
        // Load and cache (thread-safe)
        let questions = try await jsonLoader.loadQuestions()
        cacheQueue.async(flags: .barrier) {
            self.cachedQuestions = questions
        }
        
        return filterByCategory(questions, category: category)
    }
    
    func refreshCache() async throws {
        let questions = try await jsonLoader.loadQuestions()
        let categories = try await jsonLoader.loadCategories()
        
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