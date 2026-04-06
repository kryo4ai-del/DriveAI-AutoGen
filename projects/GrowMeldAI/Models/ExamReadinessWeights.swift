import Foundation

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