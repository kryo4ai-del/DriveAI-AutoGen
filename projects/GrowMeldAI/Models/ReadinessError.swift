enum ReadinessError: LocalizedError {
    case insufficientData(reason: String)
    
    var errorDescription: String? {
        switch self {
        case .insufficientData(let reason):
            return "Nicht genug Daten: \(reason)"
        }
    }
}

func estimateExamPassProbability(
    categoryScores: [QuestionDomain.QuestionCategory: (correct: Int, total: Int)]
) throws -> Double {
    guard !categoryScores.isEmpty else {
        throw ReadinessError.insufficientData(reason: "Keine Kategorien vorhanden")
    }
    
    let totalAttempts = categoryScores.values.reduce(0) { $0 + $1.total }
    guard totalAttempts > 0 else {
        throw ReadinessError.insufficientData(reason: "Keine Fragen beantwortet")
    }
    
    // Safe to proceed...
    let totalCorrect = categoryScores.values.reduce(0) { $0 + $1.correct }
    return Double(totalCorrect) / Double(totalAttempts)
}