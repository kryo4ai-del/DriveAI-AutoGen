import Foundation

struct Category: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let icon: String
    let questionCount: Int
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        icon: String,
        questionCount: Int
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.questionCount = questionCount
    }
}

struct CategoryProgress: Codable {
    let categoryId: UUID
    let answeredCount: Int
    let correctCount: Int
    let lastAccessDate: Date
    
    var accuracy: Double {
        guard answeredCount > 0 else { return 0 }
        return Double(correctCount) / Double(answeredCount)
    }
    
    var progressPercentage: Double {
        accuracy * 100
    }
}