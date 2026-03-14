import Foundation

/// Represents exam readiness score (0–100%) with per-category breakdown.
/// Thread-safe immutable value type.
struct ExamReadiness: Codable {
    let score: Double  // 0–100
    let categoryScores: [String: Double]  // categoryId → 0–100
    let calculatedAt: Date
    
    // MARK: - Computed Properties
    
    var level: String {
        switch score {
        case 0..<40:
            return NSLocalizedString("not_ready", comment: "")
        case 40..<60:
            return NSLocalizedString("partially_ready", comment: "")
        case 60..<80:
            return NSLocalizedString("almost_ready", comment: "")
        case 80...100:
            return NSLocalizedString("exam_ready", comment: "")
        default:
            return "Unknown"
        }
    }
    
    /// Categories where user is weak (<60% readiness).
    var weakCategories: [String] {
        categoryScores
            .filter { $0.value < 60 }
            .sorted { $0.value < $1.value }
            .map { $0.key }
    }
    
    /// Categories where user is strong (≥80% readiness).
    var strongCategories: [String] {
        categoryScores
            .filter { $0.value >= 80 }
            .sorted { $0.value > $1.value }
            .map { $0.key }
    }
    
    // MARK: - Factory (calculate from progress)
    
    static func calculate(
        from categoryProgress: [String: ProgressSnapshot],
        with weights: [String: Double] = ExamReadinessConfig.defaultWeights
    ) -> ExamReadiness {
        guard !categoryProgress.isEmpty else {
            return ExamReadiness(score: 0, categoryScores: [:], calculatedAt: .now)
        }
        
        var scores: [String: Double] = [:]
        var weightedSum: Double = 0
        var totalWeight: Double = 0
        
        for (categoryId, progress) in categoryProgress {
            let rate = progress.correctRate
            scores[categoryId] = rate
            
            let weight = weights[categoryId] ?? ExamReadinessConfig.defaultWeight
            weightedSum += rate * weight
            totalWeight += weight
        }
        
        let finalScore = totalWeight > 0 ? (weightedSum / totalWeight) : 0
        
        return ExamReadiness(
            score: min(finalScore, 100),
            categoryScores: scores,
            calculatedAt: .now
        )
    }
    
    // MARK: - Initializers
    
    init(
        score: Double = 0,
        categoryScores: [String: Double] = [:],
        calculatedAt: Date = .now
    ) {
        precondition(score >= 0 && score <= 100, "Readiness score must be 0–100")
        self.score = score
        self.categoryScores = categoryScores
        self.calculatedAt = calculatedAt
    }
}

// MARK: - Config

struct ExamReadinessConfig {
    // Default weights (assumes ~equal importance, tunable)
    static let defaultWeights: [String: Double] = [
        "verkehrszeichen": 0.25,        // Traffic signs (high importance)
        "vorfahrt": 0.25,               // Right-of-way (high importance)
        "verkehrsregeln": 0.20,         // Traffic rules
        "gebuehren": 0.15,              // Fines & fees
        "fahrtechniken": 0.10,          // Driving techniques
        "umweltschutz": 0.05            // Environmental protection
    ]
    
    static let defaultWeight: Double = 0.1  // For unknown categories
}

// MARK: - Preview

#if DEBUG
extension ExamReadiness {
    static let preview = ExamReadiness(
        score: 75,
        categoryScores: [
            "verkehrszeichen": 82,
            "vorfahrt": 68,
            "verkehrsregeln": 75,
            "gebuehren": 71
        ],
        calculatedAt: .now
    )
    
    static let notReady = ExamReadiness(
        score: 35,
        categoryScores: [
            "verkehrszeichen": 45,
            "vorfahrt": 28,
            "verkehrsregeln": 38
        ],
        calculatedAt: .now
    )
    
    static let readyForExam = ExamReadiness(
        score: 92,
        categoryScores: [
            "verkehrszeichen": 95,
            "vorfahrt": 90,
            "verkehrsregeln": 92,
            "gebuehren": 88
        ],
        calculatedAt: .now
    )
}
#endif