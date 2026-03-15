private func calculateCategoryReadiness(
    categoryId: String,
    categoryName: String
) async throws -> CategoryReadiness {
    let progress = try await progressService.getProgressForCategory(categoryId)
    let totalQuestions = try await questionService.getQuestionCountForCategory(categoryId)
    
    let readinessPercentage: Double
    if totalQuestions > 0 {
        let raw = Double(progress.correctAnswers) / Double(totalQuestions) * 100.0
        // ✅ Round to 2 decimal places for consistency
        readinessPercentage = (raw * 100).rounded(.toNearestOrEven) / 100
    } else {
        readinessPercentage = 0.0
    }
    
    return CategoryReadiness(
        id: categoryId,
        name: categoryName,
        readinessPercentage: clamp(readinessPercentage, min: 0.0, max: 100.0),
        questionsAnswered: progress.answeredCount,
        correctAnswers: progress.correctAnswers
    )
}

// ❌ ALSO FIX: isMastered should use rounded value consistently
extension CategoryReadiness {
    var isMastered: Bool {
        // ✅ Compare rounded values
        return (readinessPercentage * 100).rounded() >= (masteryThreshold * 100).rounded()
    }
}