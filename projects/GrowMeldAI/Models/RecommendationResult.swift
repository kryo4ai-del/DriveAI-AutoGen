enum RecommendationResult {
    case question(Question, reason: RecommendationReason)
    case allAnswered
    case noCategoriesAvailable
    
    enum RecommendationReason: String {
        case weakCategoryReview = "Weak category needs review"
        case unreviewedCategory = "New category to explore"
        case spacedRepetition = "Time to review this category"
        case randomPractice = "Continue practicing"
    }
}

func getNextRecommendedQuestion(
    userProgress: UserProgress
) async throws -> RecommendationResult {
    let config = ExamConfiguration.standard
    let allQuestions = try await loadAllQuestions()
    let unanswered = excludeQuestionIds(allQuestions, ids: userProgress.answeredQuestionIds)
    
    guard !unanswered.isEmpty else {
        return .allAnswered
    }
    
    // Priority 1: Weak categories
    let weakCategories = userProgress.categoryProgress
        .filter { config.weakCategoryThreshold > 0 && $0.value.accuracy < config.weakCategoryThreshold }
        .sorted { $0.value.accuracy < $1.value.accuracy }
        .map { $0.key }
    
    if let weakCategory = weakCategories.first,
       let question = filterByCategory(unanswered, category: weakCategory).randomElement() {
        return .question(question, reason: .weakCategoryReview)
    }
    
    // Priority 2: Unrereviewed categories
    let reviewedCategories = Set(userProgress.categoryProgress.keys)
    let allCategoryNames = Set(try await getAllCategories().map { $0.name })
    let unreviewedCategories = allCategoryNames.subtracting(reviewedCategories)
    
    if !unreviewedCategories.isEmpty,
       let unreviewedCategory = unreviewedCategories.randomElement(),
       let question = filterByCategory(unanswered, category: unreviewedCategory).randomElement() {
        return .question(question, reason: .unreviewedCategory)
    }
    
    // Priority 3: Spaced repetition
    let now = Date()
    let dueForReview = userProgress.categoryProgress
        .filter { (_, progress) in
            progress.nextReviewDate.map { $0 <= now } ?? false
        }
        .map { $0.key }
    
    if let categoryDueForReview = dueForReview.randomElement(),
       let question = filterByCategory(unanswered, category: categoryDueForReview).randomElement() {
        return .question(question, reason: .spacedRepetition)
    }
    
    // Fallback: Random unanswered
    if let question = unanswered.randomElement() {
        return .question(question, reason: .randomPractice)
    }
    
    return .noCategoriesAvailable
}