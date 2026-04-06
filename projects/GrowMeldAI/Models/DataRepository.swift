import Foundation

protocol DataRepository {
    func fetchQuestions(categoryID: String) async -> [AppQuestion]
    func fetchCategories() async -> [AppCategory]
    func getQuestion(id: String) async -> AppQuestion?
}

struct AppQuestion: Identifiable, Codable {
    let id: String
    let categoryID: String
    let text: String
    let answer: String
}

struct AppCategory: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
}