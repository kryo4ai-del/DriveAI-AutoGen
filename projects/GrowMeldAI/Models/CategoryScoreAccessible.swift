struct CategoryScoreAccessible {
    let categoryID: String
    let categoryName: String  // Localized
    let score: Double
    let attemptCount: Int
    
    var accessibilityLabel: String {
        String(format: NSLocalizedString(
            "category.score.label",
            value: "%@ exam preparation: %d percent correct",
            comment: "Category performance"
        ), categoryName, Int(score))
    }
    
    var accessibilityHint: String {
        String(format: NSLocalizedString(
            "category.score.hint",
            value: "Attempted %d questions in this category",
            comment: "Attempt count"
        ), attemptCount)
    }
}