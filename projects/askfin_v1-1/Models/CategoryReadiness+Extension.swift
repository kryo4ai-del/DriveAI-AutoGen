// [FK-019 sanitized] private func calculateCategoryReadiness(
// [FK-019 sanitized]     categoryId: String,
// [FK-019 sanitized]     categoryName: String
// [FK-019 sanitized] ) async throws -> CategoryReadiness {
// [FK-019 sanitized]     let progress = try await progressService.getProgressForCategory(categoryId)
// [FK-019 sanitized]     let totalQuestions = try await questionService.getQuestionCountForCategory(categoryId)
    
// [FK-019 sanitized]     let readinessPercentage: Double
// [FK-019 sanitized]     if totalQuestions > 0 {
// [FK-019 sanitized]         let raw = Double(progress.correctAnswers) / Double(totalQuestions) * 100.0
        // ✅ Round to 2 decimal places for consistency
// [FK-019 sanitized]         readinessPercentage = (raw * 100).rounded(.toNearestOrEven) / 100
// [FK-019 sanitized]     } else {
// [FK-019 sanitized]         readinessPercentage = 0.0
    }
    
// [FK-019 sanitized]     return CategoryReadiness(
// [FK-019 sanitized]         id: categoryId,
// [FK-019 sanitized]         name: categoryName,
// [FK-019 sanitized]         readinessPercentage: clamp(readinessPercentage, min: 0.0, max: 100.0),
// [FK-019 sanitized]         questionsAnswered: progress.answeredCount,
// [FK-019 sanitized]         correctAnswers: progress.correctAnswers
// [FK-019 sanitized]     )
}

// ❌ ALSO FIX: isMastered should use rounded value consistently
extension CategoryReadiness {
    var isMastered: Bool {
        // ✅ Compare rounded values
        return (readinessPercentage * 100).rounded() >= (masteryThreshold * 100).rounded()
    }
}