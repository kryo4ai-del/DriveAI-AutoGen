struct ExamReadinessBreakdown {
    let overallPercent: Int
    let components: [ReadinessComponent]
    let passProbability: Int  // Estimated likelihood to pass (85%+ = likely pass)
    let daysUntilExam: Int
    let recommendedDailyMinimum: Int  // To reach 85% by exam
}

struct ReadinessComponent {
    let categoryName: String  // "Traffic signs", "Right-of-way"
    let yourAccuracy: Int  // 82%
    let examRequirement: Int  // 75% (typical passing threshold)
    let status: String  // "On track", "Needs work", "Exceeds"
}

// In TrialPeriod:
func getExamReadinessBreakdown(now: Date, userMetrics: UserMetrics) -> ExamReadinessBreakdown {
    let categoryScores = userMetrics.categoryAccuracies  // [("Signs", 82), ("RoW", 68)]
    let examMinimum = 75
    
    let components = categoryScores.map { name, accuracy in
        ReadinessComponent(
            categoryName: name,
            yourAccuracy: accuracy,
            examRequirement: examMinimum,
            status: accuracy >= examMinimum ? "On track" : "Needs work"
        )
    }
    
    let averageAccuracy = categoryScores.map(\.1).reduce(0, +) / categoryScores.count
    let daysLeft = daysUntilExam(now: now)
    
    // Logistic regression estimate: passing likelihood
    let passProbability = estimatePassProbability(accuracy: averageAccuracy, daysLeft: daysLeft)
    
    return ExamReadinessBreakdown(
        overallPercent: averageAccuracy,
        components: components,
        passProbability: passProbability,
        daysUntilExam: daysLeft,
        recommendedDailyMinimum: calculateRecommendedDailyMinimum(daysLeft, currentAccuracy: averageAccuracy)
    )
}

private func estimatePassProbability(accuracy: Int, daysLeft: Int) -> Int {
    // Calibrated to German driving theory exam (typically 75% pass threshold)
    // Returns 0-100 likelihood
    let baseProb = max(0, min(100, accuracy))
    let timeBoost = min(10, daysLeft / 3)  // More time = slight boost
    return min(100, baseProb + timeBoost)
}