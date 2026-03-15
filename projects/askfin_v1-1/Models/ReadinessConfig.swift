import Foundation

struct ReadinessConfig {
    // Readiness score thresholds
    static let weakAreaThreshold: Double = 70.0
    static let strongAreaThreshold: Double = 80.0
    
    // Urgency thresholds (days to exam)
    static let criticalDaysThreshold = 7
    static let highPriorityDaysThreshold = 14
    static let moderateDaysThreshold = 30
    
    // Weak area priority thresholds (score %)
    static let criticalScoreThreshold: Double = 50.0
    static let highScoreThreshold: Double = 65.0
    
    // Weak area recommendations
    struct WeakAreaRecommendations {
        static let criticalQuestions = 20
        static let highQuestions = 15
        static let mediumQuestions = 10
        static let minutesPerQuestion = 2
    }
    
    // Trend analysis
    struct TrendAnalysis {
        static let windowSize = 10
        static let minimumDataPointsForTrend = 3
        static let improvementThreshold: Double = 5.0
        static let declineThreshold: Double = -5.0
    }
    
    // Prediction engine
    struct Prediction {
        static let baselineProbability: Double = 0.6
        static let maxAdjustmentFactor: Double = 0.25
        static let minProbability: Double = 0.01
        static let maxProbability: Double = 0.99
        
        struct TimeAdjustments {
            static let veryHighTimeBonus: Double = 1.0    // >= 14 days
            static let highTimeBonus: Double = 0.9        // 7-13 days
            static let lowTimeBonus: Double = 0.7         // < 7 days
            static let unknownTimeBonus: Double = 0.8
        }
    }
}
