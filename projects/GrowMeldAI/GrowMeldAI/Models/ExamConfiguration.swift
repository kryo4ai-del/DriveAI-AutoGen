// Models/ExamConfiguration.swift
struct ExamConfiguration: Codable {
    // German regulation (TÜV/Dekra official)
    static let germanDefault = ExamConfiguration(
        totalQuestions: 30,
        passingScorePercentage: 0.80,
        maxErrors: 10
    )
    
    let totalQuestions: Int
    let passingScorePercentage: Double
    let maxErrors: Int  // Alternative representation
    
    var passingScore: Int {
        Int(ceil(Double(totalQuestions) * passingScorePercentage))
    }
    
    func isScorePassing(_ score: Int) -> Bool {
        score >= passingScore
    }
}

// Models/ExamSimulationResult.swift