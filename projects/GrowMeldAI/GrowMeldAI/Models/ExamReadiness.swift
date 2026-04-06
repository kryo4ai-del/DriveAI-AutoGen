struct ExamReadiness: Sendable {
    let totalQuestionsToReview: Int
    let totalQuestionsInCatalog: Int
    let questionsReviewedThisWeek: Int
    let estimatedDaysToReadiness: Int
    let currentMasteryPercentage: Double
    let readinessMessage: String
    
    var percentageOfCatalogReviewed: Double {
        guard totalQuestionsInCatalog > 0 else { return 0 }
        return Double(totalQuestionsToReview) / Double(totalQuestionsInCatalog) * 100
    }
}