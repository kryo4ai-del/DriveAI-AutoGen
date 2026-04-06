struct NextReviewSuggestion: Equatable, Identifiable {
    let id: UUID = UUID()
    let categoryName: String
    let focusLevel: FocusLevel
    let recommendedQuestionCount: Int
    let estimatedMinutes: Int
    let nextReviewDate: Date
    let urgencyReason: String
    
    // Date comparison with tolerance to avoid constant re-renders
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.categoryName == rhs.categoryName &&
        lhs.focusLevel == rhs.focusLevel &&
        lhs.recommendedQuestionCount == rhs.recommendedQuestionCount &&
        lhs.estimatedMinutes == rhs.estimatedMinutes &&
        abs(lhs.nextReviewDate.timeIntervalSince(rhs.nextReviewDate)) < 1 &&
        lhs.urgencyReason == rhs.urgencyReason
    }
}