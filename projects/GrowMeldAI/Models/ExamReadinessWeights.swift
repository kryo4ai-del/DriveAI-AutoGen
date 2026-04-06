struct ExamReadinessWeights {
    let categoryCompletion: Double = 0.30
    let averageAccuracy: Double = 0.40
    let recencyOfPractice: Double = 0.20
    let confidenceConsistency: Double = 0.10
    
    var total: Double {
        categoryCompletion + averageAccuracy + recencyOfPractice + confidenceConsistency
    }
    
    func validate() throws {
        let sum = total
        guard abs(sum - 1.0) < 0.001 else {
            throw ReadinessError.calculationFailed(
                reason: "Weights sum to \(sum), not 1.0"
            )
        }
    }
}

func calculate(attempts: [QuizAttempt]) -> ExamReadinessScore {
    try weights.validate()  // Fail early
    
    let completionScore = max(0, min(1, calculateCompletion(attempts)))
    let accuracyScore = max(0, min(1, calculateAccuracy(attempts)))
    let recencyScore = max(0, min(1, calculateRecency(attempts)))
    let confidenceScore = max(0, min(1, calculateConfidence(attempts)))
    
    let weightedSum = (
        completionScore * weights.categoryCompletion +
        accuracyScore * weights.averageAccuracy +
        recencyScore * weights.recencyOfPractice +
        confidenceScore * weights.confidenceConsistency
    )
    
    // Result is guaranteed 0.0-1.0
    let overall = max(0, min(1, weightedSum / weights.total))
    
    return ExamReadinessScore(overall: overall, ...)
}