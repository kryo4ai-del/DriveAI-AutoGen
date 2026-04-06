// DataLoader.swift
protocol DataLoader: Sendable {
    func loadQuestions() async throws -> [Question]
    func loadCategories() async throws -> [Category]
}

// JSONDataLoader.swift

// AppDelegate: Dependency Injection Root