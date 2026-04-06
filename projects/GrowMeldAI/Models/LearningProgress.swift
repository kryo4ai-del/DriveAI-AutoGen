struct LearningProgress {
    let questionsAnswered: Int
    let questionsCorrect: Int
    let categoriesStarted: Int
    let categoriesCompleted: Int
    
    /// Learning readiness (not time readiness)
    var competencyPercent: Int {
        if questionsAnswered == 0 { return 0 }
        let accuracy = Double(questionsCorrect) / Double(questionsAnswered)
        let coverage = Double(categoriesCompleted) / 15  // Assuming 15 official categories
        return Int(((accuracy * 0.6) + (coverage * 0.4)) * 100)
    }
}

// Enum TrialStatus declared in Models/FreemiumQuestionLimit.swift
