import Foundation

struct CategoryProgress: Codable, Identifiable {
    let id: String
    let categoryName: String
    let totalQuestionsAnswered: Int
    let correctCount: Int
    var lastUpdated: Date

    init(id: String = UUID().uuidString,
         categoryName: String,
         totalQuestionsAnswered: Int = 0,
         correctCount: Int = 0,
         lastUpdated: Date = Date()) {
        self.id = id
        self.categoryName = categoryName
        self.totalQuestionsAnswered = totalQuestionsAnswered
        self.correctCount = correctCount
        self.lastUpdated = lastUpdated
    }
}