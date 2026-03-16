/// Pure calculation logic (testable, reusable, no dependencies)
struct ScoringCalculator {
    struct Weights {
        let categoryPerformance: Double = 0.40
        let streakScore: Double = 0.25
        let timeInvested: Double = 0.20
        let recentTrend: Double = 0.15
        
        static let `default` = Weights()

        func validate() throws {
            let total = categoryPerformance + streakScore + timeInvested + recentTrend
            guard abs(total - 1.0) < 0.001 else {
                throw WeightingError.doNotSumToOne
            }
        }
    }

    enum WeightingError: Error {
        case doNotSumToOne
    }
    
    static func calculateOverallScore(
        categoryPerformance: Double,
        streakScore: Double,
        timeInvestedScore: Double,
        recentTrendScore: Double,
        using weights: Weights = .default
    ) -> Int {
        let weighted =
            (categoryPerformance * weights.categoryPerformance) +
            (streakScore * weights.streakScore) +
            (timeInvestedScore * weights.timeInvested) +
            (recentTrendScore * weights.recentTrend)
        
        return Int(min(max(weighted, 0), 100))
    }
}