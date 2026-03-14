import Foundation

/// Represents the user's overall readiness to pass the driving exam.
/// Scores are computed from category performance using weighted averaging.
struct ExamReadiness: Codable {
    let score: Double  // 0–100
    let categoryScores: [String: Double]  // categoryId → 0–100
    let calculatedAt: Date
    
    /// Categorizes readiness into human-readable levels.
    var level: String {
        switch score {
        case 0..<40: return "Not Ready"
        case 40..<60: return "Developing"
        case 60..<80: return "Proficient"
        case 80...100: return "Expert"
        default: return "Unknown"
        }
    }
    
    /// Categories where the user is weakest (correctRate < 70%).
    var weakCategories: [String] {
        categoryScores
            .filter { $0.value < 70 }
            .keys
            .sorted()
    }
    
    /// Categories where the user is strongest (correctRate >= 80%).
    var strongCategories: [String] {
        categoryScores
            .filter { $0.value >= 80 }
            .keys
            .sorted()
    }
    
    // MARK: - Initialization
    
    init(score: Double, categoryScores: [String: Double] = [:], calculatedAt: Date = .now) {
        self.score = max(0, min(100, score))  // Clamp to [0, 100]
        self.categoryScores = categoryScores
        self.calculatedAt = calculatedAt
    }
    
    // MARK: - Calculation
    
    /// Calculates exam readiness from category progress snapshots.
    /// Uses weighted averaging based on exam topic distribution.
    /// 
    /// - Parameter categoryProgress: Dictionary of category ID → ProgressSnapshot
    /// - Returns: ExamReadiness with calculated score and per-category breakdowns
    /// 
    /// Safety: Handles zero-denominator edge cases with safe division guards.
    /// If no categories are provided, returns a score of 0.
    static func calculate(from categoryProgress: [String: ProgressSnapshot]) -> ExamReadiness {
        guard !categoryProgress.isEmpty else {
            return ExamReadiness(score: 0, categoryScores: [:])
        }
        
        var scores: [String: Double] = [:]
        var weightedSum: Double = 0
        var totalWeight: Double = 0
        
        for (categoryId, progress) in categoryProgress {
            // SAFE DIVISION: Compute correct rate with zero-denominator guard
            let rate = ProgressCalculations.correctRate(
                correct: progress.correctCount,
                attempts: progress.attemptCount
            )
            
            let weight = ProgressConfig.categoryWeights[categoryId]
                ?? ProgressConfig.defaultCategoryWeight
            
            // Convert rate [0, 1] to percentage [0, 100]
            let percentage = rate * 100
            scores[categoryId] = percentage
            
            // Accumulate weighted score
            weightedSum += percentage * weight
            totalWeight += weight
        }
        
        // SAFE DIVISION: Guard against zero total weight
        let finalScore = totalWeight > 0 ? (weightedSum / totalWeight) : 0
        
        return ExamReadiness(
            score: finalScore,
            categoryScores: scores,
            calculatedAt: .now
        )
    }
}

// MARK: - Centralized Calculations

/// Utility functions for progress calculations.
/// Provides safe division and mathematical operations with edge-case handling.
enum ProgressCalculations {
    /// Computes the correct answer rate safely.
    /// - Parameters:
    ///   - correct: Number of correct answers
    ///   - attempts: Total number of attempts
    /// - Returns: Rate in [0, 1] range; returns 0 if attempts is 0
    static func correctRate(correct: Int, attempts: Int) -> Double {
        guard attempts > 0 else { return 0 }
        return Double(correct) / Double(attempts)
    }
    
    /// Computes the completion percentage relative to a target.
    /// - Parameters:
    ///   - attempts: Current number of attempts
    ///   - target: Target number of attempts (default: 50)
    /// - Returns: Percentage in [0, 100] range (capped at 100)
    static func completionPercentage(attempts: Int, target: Int = 50) -> Double {
        guard target > 0 else { return 0 }
        let percentage = Double(attempts) / Double(target) * 100
        return min(100, percentage)
    }
    
    /// Determines if a category meets readiness thresholds.
    /// - Parameters:
    ///   - correctRate: Rate in [0, 1] range
    ///   - attempts: Total attempts for the category
    /// - Returns: True if rate >= 80% AND attempts >= 10
    static func readinessLevel(correctRate: Double, attempts: Int) -> Bool {
        correctRate >= 0.8 && attempts >= 10
    }
}

// MARK: - Configuration

/// Centralized configuration for progress tracking thresholds and weights.
struct ProgressConfig {
    /// Minimum attempts required for a category to be marked "ready"
    static let minAttemptsForReady: Int = 10
    
    /// Minimum correct rate (0–1) required for a category to be marked "ready"
    static let minCorrectRateForReady: Double = 0.8
    
    /// Target number of questions per category for completion tracking
    static let questionsPerCategory: Int = 50
    
    /// Category weights for weighted average exam readiness scoring.
    /// Weights reflect the DACH driving exam topic distribution.
    /// Sum of weights should equal 1.0 (or close to it).
    static let categoryWeights: [String: Double] = [
        "Verkehrsregeln": 0.3,          // Traffic regulations (30%)
        "Fahrzeugtechnik": 0.2,         // Vehicle technology (20%)
        "Gefahrenerkennung": 0.3,       // Hazard recognition (30%)
        "Umweltbewusstsein": 0.2,       // Environmental awareness (20%)
    ]
    
    /// Default weight for unknown categories
    static let defaultCategoryWeight: Double = 0.1
    
    /// Motivation scoring configuration
    struct Motivation {
        static let streakMultiplier: Double = 0.5
        static let streakMaxPoints: Double = 30
        static let accuracyMaxPoints: Double = 40
        static let completionMaxPoints: Double = 30
    }
}