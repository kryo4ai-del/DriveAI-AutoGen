struct PersonalizedPlan {
    let primaryAction: RecommendationAction  // "Do THIS next" (1 clear choice)
    let sequenceOfActions: [RecommendationAction]  // Order after primary
    let rationale: String  // Why this sequence?
    let estimatedCompletionTime: Int  // "45 minutes to all recommendations"
}

// Primary action selection logic:
func selectPrimaryAction(
    categoryGaps: [KnowledgeGap],
    streakStatus: Streak,
    daysUntilExam: Int
) -> RecommendationAction {
    // Rule: If exam < 7 days AND streak active → maintain streak (momentum)
    if daysUntilExam < 7 && streak.isActiveToday {
        return RecommendationAction(
            actionType: .focusedPractice,
            categoryId: categoryGaps.first?.categoryId,
            rationale: "Quick win: 3 questions in \(categoryGaps.first!.categoryName). Keeps your streak alive.",
            suggestedQuestionCount: 3,
            estimatedMinutes: 5
        )
    }
    
    // Else: weakest category first (knowledge foundation)
    return RecommendationAction(
        actionType: .studyWeakCategory,
        categoryId: categoryGaps.first?.categoryId,
        rationale: "Your weakest area (\(categoryGaps.first!.categoryName)) needs focus.",
        suggestedQuestionCount: 5,
        estimatedMinutes: 12
    )
}