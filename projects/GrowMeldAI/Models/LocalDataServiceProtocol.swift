// Protocol requires async
protocol LocalDataServiceProtocol {
    func fetchQuestions(category: String?) async throws -> [Question]
}

// Mock doesn't use async