struct CategoryPerformance: Identifiable, Equatable, Codable {
    let id: String
    let categoryId: String
    let categoryName: String
    let totalQuestions: Int
    let answeredQuestions: Int
    let correctAnswers: Int
    let incorrectAnswers: Int
    let averageScore: Double
    let lastAttemptDate: Date?
    let trend: PerformanceTrend
    
    // Codable will synthesize automatically
}