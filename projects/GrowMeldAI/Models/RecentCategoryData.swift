private func generateRecommendations(from quizResults: [QuizResult]) -> [CoachingRecommendation] {
    let recentResults = quizResults
        .sorted { $0.date > $1.date }
        .prefix(20)  // Only keep last 20 attempts
    
    var categoryCounts: [String: RecentCategoryData] = [:]
    
    for result in recentResults {
        categoryCounts[result.categoryId, default: RecentCategoryData(
            categoryName: result.categoryName,
            scores: []
        )].scores.append(result.score)
    }
    
    // ... rest of logic
}

struct RecentCategoryData {
    let categoryName: String
    var scores: [Double]
}