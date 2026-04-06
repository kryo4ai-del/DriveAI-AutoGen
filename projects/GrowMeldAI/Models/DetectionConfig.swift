actor WeaknessDetector {
    struct DetectionConfig: Sendable {
        let errorRateThreshold: Double = 0.30
        let recentErrorThreshold: Int = 3
        let minimumTotalQuestions: Int = 10  // ✅ Add minimum
        let recentQuestionWindow: Int = 10
        let requireBothConditions: Bool = true  // ✅ AND logic
        
        /// For new users (low confidence), be stricter on sample size
        static func strict() -> Self {
            var config = DetectionConfig()
            config.minimumTotalQuestions = 20
            return config
        }
    }
    
    func detectWeaknesses(
        categoryStats: [UUID: CategoryStats],
        errorHistory: [UUID: [Date]],
        config: DetectionConfig = .init()
    ) -> [WeaknessPattern] {
        
        return categoryStats.compactMap { categoryID, stats -> WeaknessPattern? in
            
            // ✅ FIRST GATE: Minimum sample size (eliminate noise)
            let totalQuestions = stats.correctCount + stats.incorrectCount
            guard totalQuestions >= config.minimumTotalQuestions else {
                return nil  // Too few questions, too noisy
            }
            
            // ✅ CONDITION 1: Sustained high error rate
            let hasHighErrorRate = stats.errorRate > config.errorRateThreshold
            
            // ✅ CONDITION 2: Recent errors (pattern)
            let hasRecentErrors = stats.recentErrorCount >= config.recentErrorThreshold
            
            // ✅ GATE 2: Require both conditions (reduces false positives)
            let shouldFlag = config.requireBothConditions
                ? (hasHighErrorRate && hasRecentErrors)
                : (hasHighErrorRate || hasRecentErrors)
            
            guard shouldFlag else {
                return nil
            }
            
            // ✅ Only build pattern if we pass all gates
            let errors = errorHistory[categoryID] ?? []
            let focusLevel: FocusLevel
            
            if stats.errorRate > 0.40 && stats.recentErrorCount > 4 {
                focusLevel = .critical
            } else if stats.errorRate > 0.35 || hasRecentErrors {
                focusLevel = .high
            } else {
                focusLevel = .moderate
            }
            
            return WeaknessPattern(
                categoryID: categoryID,
                categoryName: stats.categoryName,
                errorRate: stats.errorRate,
                lastErrorDate: errors.last ?? Date(),
                errorFrequency: Array(errors.suffix(10)),
                recoveryTime: stats.calculateRecoveryTime(),
                recommendedFocusLevel: focusLevel,
                questionsUnansweredCorrectly: stats.incorrectCount
            )
        }
    }
}