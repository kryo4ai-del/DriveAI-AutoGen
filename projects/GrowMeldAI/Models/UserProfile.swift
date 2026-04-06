import Foundation

struct UserProfile: Codable {
    let id: UUID
    let examDate: Date?
    let totalScore: Int
    let totalQuestionsAnswered: Int
    let currentStreak: Int
    let longestStreak: Int
    let categoryProgress: [CategoryProgress]
    
    var averageAccuracy: Double {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return Double(totalScore) / Double(totalQuestionsAnswered)
    }
    
    var daysUntilExam: Int? {
        guard let examDate = examDate else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: examDate)
        return components.day
    }
    
    init(
        id: UUID = UUID(),
        examDate: Date? = nil,
        totalScore: Int = 0,
        totalQuestionsAnswered: Int = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        categoryProgress: [CategoryProgress] = []
    ) {
        self.id = id
        self.examDate = examDate
        self.totalScore = totalScore
        self.totalQuestionsAnswered = totalQuestionsAnswered
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.categoryProgress = categoryProgress
    }
}
