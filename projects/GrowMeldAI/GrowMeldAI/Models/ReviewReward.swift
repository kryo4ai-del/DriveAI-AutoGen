enum ReviewReward {
    case confidenceBoost(category: String, percent: Int)    // "92% confident on traffic signs"
    case passProbabilityIncrease(from: Int, to: Int)        // "Exam pass likelihood: 68% → 74%"
    case categoryMilestone(category: String, level: String)  // "Traffic Signs: Mastered! 🎯"
    case readinessThreshold(newLevel: String)                // "Exam Ready! You've hit the 80% threshold"
}

func computeRewardAfterReview(correct: Bool, questionId: UUID) -> ReviewReward {
    let category = memoryService.getCategoryForQuestion(questionId)
    let categoryMastery = computeCategoryMastery(category)
    let newReadiness = computeExamReadinessScore()
    
    // Variable (probabilistic) rewards based on context
    if categoryMastery >= 0.9 && categoryMastery - 0.05 < 0.9 {
        return .categoryMilestone(category: category, level: "Mastered")
    } else if newReadiness >= 0.8 && previousReadiness < 0.8 {
        return .readinessThreshold(newLevel: "Exam Ready")
    } else if newReadiness - previousReadiness > 2 {
        return .passProbabilityIncrease(from: Int(previousReadiness), to: Int(newReadiness))
    } else {
        return .confidenceBoost(category: category, percent: Int(categoryMastery * 100))
    }
}

// Display reward prominently
func showReward(_ reward: ReviewReward) {
    switch reward {
    case .categoryMilestone(let cat, let level):
        showMilestoneAnimation()  // Subtle celebration
        announceToVoiceOver("\(cat) \(level)!")
    case .readinessThreshold:
        showReadinessAnimation()
        announceToVoiceOver("You're exam-ready!")
    case .passProbabilityIncrease(let from, let to):
        showGaugeAnimation(from: CGFloat(from), to: CGFloat(to))
        announceToVoiceOver("Exam pass likelihood: \(from)% to \(to)%")
    case .confidenceBoost(let cat, let percent):
        announceToVoiceOver("\(percent)% confident on \(cat)")
    }
}