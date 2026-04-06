import Foundation

struct CategoryStat: Identifiable, Codable {
    let id: String = UUID().uuidString
    let category: String
    let questionsAnswered: Int
    let correctAnswers: Int
    let lastAttempted: Date?
    
    var score: Double {
        questionsAnswered == 0 ? 0 : Double(correctAnswers) / Double(questionsAnswered)
    }
}

@MainActor

extension UserProfile: Codable {
    enum CodingKeys: String, CodingKey {
        case examDate, totalQuestionsAnswered, correctAnswers, 
             currentStreak, longestStreak, categoryProgress
    }
}