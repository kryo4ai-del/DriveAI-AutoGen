struct UserStatistics: Codable {
    // Atomic counters (stored in Firestore)
    var totalQuestionsAnswered: Int = 0
    var totalCorrectAnswers: Int = 0
    var totalIncorrectAnswers: Int = 0
    
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalExams: Int = 0
    var passedExams: Int = 0
    
    // ✅ Computed properties (never stored, always derived)
    var averageScore: Double {
        let total = totalCorrectAnswers + totalIncorrectAnswers
        guard total > 0 else { return 0.0 }
        return Double(totalCorrectAnswers) / Double(total)
    }
    
    var examPassRate: Double {
        guard totalExams > 0 else { return 0.0 }
        return Double(passedExams) / Double(totalExams)
    }
    
    enum CodingKeys: String, CodingKey {
        case totalQuestionsAnswered, totalCorrectAnswers, totalIncorrectAnswers
        case currentStreak, longestStreak, totalExams, passedExams
        // ✅ averageScore, examPassRate NOT included
    }
}