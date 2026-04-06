// Define all service protocols NOW (even though camera isn't used yet)
protocol DataServiceType {
    func fetchQuestions(category: String) async throws -> [Question]
    func fetchCategories() async throws -> [Category]
}

protocol UserProgressServiceType {
    func recordAnswer(questionId: String, isCorrect: Bool) async throws
    func getProgress(category: String) async throws -> CategoryProgress
    func getStreak() async -> Int
}

protocol LocalStorageServiceType {
    func save<T: Codable>(_ object: T, forKey: String) async throws
    func load<T: Codable>(forKey: String) -> T?
    func delete(forKey: String) async throws
}

// Camera protocol added LATER when feature is approved