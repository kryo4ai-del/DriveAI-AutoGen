struct CategoryResult: Codable, Sendable {
    let questionsAttempted: Int
    let questionsCorrect: Int
    let questionsTotal: Int
    let scorePercentage: Double
    let lastAttemptDate: Date?
    
    /// Factory to compute from raw attempts
    static func from(
        categoryId: String,
        attempts: [QuestionAttempt]
    ) -> CategoryResult {
        let correct = attempts.filter { $0.isCorrect }.count
        let total = attempts.count
        
        let percentage: Double = total > 0
            ? Double(correct) / Double(total) * 100
            : 0.0  // ✅ Safe default
        
        return CategoryResult(
            questionsAttempted: attempts.count,
            questionsCorrect: correct,
            questionsTotal: total,
            scorePercentage: percentage,
            lastAttemptDate: attempts.map { $0.timestamp }.max()
        )
    }
}