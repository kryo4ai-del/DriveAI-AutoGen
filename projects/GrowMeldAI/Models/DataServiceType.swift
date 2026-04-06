import Foundation

protocol DataServiceType {
    func fetchQuestions(category: String) async throws -> [GrowMeldQuestion]
    func fetchCategories() async throws -> [GrowMeldCategory]
}

protocol UserProgressServiceType {
    func recordAnswer(questionId: String, isCorrect: Bool) async throws
    func getProgress(category: String) async throws -> GrowMeldCategoryProgress
    func getStreak() async -> Int
}

protocol LocalStorageServiceType {
    func save<T: Codable>(_ object: T, forKey: String) async throws
    func load<T: Codable>(forKey: String) -> T?
    func delete(forKey: String) async throws
}

struct GrowMeldQuestion: Codable, Identifiable {
    let id: String
    let text: String
    let category: String
    let options: [String]
    let correctAnswer: String
}

struct GrowMeldCategory: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
}

struct GrowMeldCategoryProgress: Codable {
    let category: String
    let totalAnswered: Int
    let correctAnswers: Int
    var accuracy: Double {
        guard totalAnswered > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(totalAnswered)
    }
}