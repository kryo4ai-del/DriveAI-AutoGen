struct ExamPassConfiguration {
    let minScore: Int = 43
    let maxScore: Int = 50
    
    var passingPercentage: Double {
        Double(minScore) / Double(maxScore) * 100
    }
}

@MainActor
