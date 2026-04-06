struct ExamReadinessVector {
    let passProbability: Double          // 0.60 (60%)
    let contributingFactors: [Factor]    // What's helping?
    let nextLeveragePoint: ActionItem    // What moves the needle?
    let daysToReadiness: Int             // "7 days until 90% ready"
    let userAgency: String               // "You can reach 75% by..."
}

enum Factor {
    case categoryMastery(category: String, accuracy: Double)
    case consistencyImprovement(trendDays: Int)
    case timeUntilExamPressure(urgency: Double)
}

enum ActionItem {
    case focusWeakestCategory(name: String, accuracy: Double, reviewCount: Int)
    case maintainStreak(daysRemaining: Int)
    case practiceUnderTime(seconds: Int)
}