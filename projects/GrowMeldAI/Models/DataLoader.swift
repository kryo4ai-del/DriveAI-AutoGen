import Foundation

protocol DataLoader: Sendable {
    func loadQuestions() async throws -> [AppQuestion]
    func loadCategories() async throws -> [AppCategory]
}

struct AppQuestion: Codable, Sendable {
    let id: Int
    let text: String
    let options: [String]
    let correctIndex: Int
    let categoryId: String
}

struct AppCategory: Codable, Sendable {
    let id: String
    let name: String
    let description: String
}

final class JSONDataLoader: DataLoader {
    func loadQuestions() async throws -> [AppQuestion] {
        return []
    }

    func loadCategories() async throws -> [AppCategory] {
        return []
    }
}