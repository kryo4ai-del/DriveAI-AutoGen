// Services/QuestionSelectionService.swift
class InterleavedQuestionSelector {
    /// Generate interleaved question sequence from weak categories
    func generateMixedReviewSession(
        weakCategories: [String],
        questionCount: Int = 15
    ) async -> [Question] {
        var questions: [Question] = []
        var categoryIndex = 0
        
        for _ in 0..<questionCount {
            // Round-robin across weak categories
            let category = weakCategories[categoryIndex % weakCategories.count]
            let question = try? await questionService.getRandomQuestion(
                from: category,
                excludePreviously: questions.map { $0.id }
            )
            
            if let q = question {
                questions.append(q)
            }
            
            categoryIndex += 1
        }
        
        return questions
    }
}

// In QuestionScreenViewModel
func startMixedReview(from weakCategories: [String]) async {
    let interleaved = await InterleavedQuestionSelector()
        .generateMixedReviewSession(weakCategories: weakCategories)
    
    currentQuestions = interleaved
    
    // Track that this is an interleaved session
    await analyticsService.track(
        .interleavedSessionStarted(
            categories: weakCategories,
            questionCount: interleaved.count
        )
    )
}