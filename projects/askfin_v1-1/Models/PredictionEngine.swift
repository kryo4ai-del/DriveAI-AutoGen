import Foundation
@MainActor
class PredictionEngine: ObservableObject {
    private let readinessCalculator: ReadinessCalculator
    private let trendAnalyzer: TrendAnalyzer
    
    init(readinessCalculator: ReadinessCalculator,
         trendAnalyzer: TrendAnalyzer) {
        self.readinessCalculator = readinessCalculator
        self.trendAnalyzer = trendAnalyzer
    }
    
    func predictPassProbability() async -> ReadinessPrediction {
        let readinessResult = await readinessCalculator.calculateReadiness()
        let trends = await trendAnalyzer.analyzeTrends()
        
        let factors = computeFactors(readiness: readinessResult.score, trends: trends)
        let probability = calculateProbability(factors: factors)
        let confidence = determineConfidence(probability: probability)
        
        return ReadinessPrediction(
            id: UUID(),
            passProbability: probability,
            confidenceLevel: confidence,
            recommendation: generateRecommendation(probability: probability),
            predictedAt: Date(),
            factors: factors
        )
    }
    
    private func computeFactors(
        readiness: ReadinessScore,
        trends: [PerformanceTrend]
    ) -> [PredictionFactor] {
        var factors: [PredictionFactor] = []
        
        // Score impact: -0.5 to +0.5
        let scoreImpact = (readiness.overallScore / 100.0) - 0.5
        factors.append(PredictionFactor(
            name: "Overall Score",
            impact: scoreImpact,
            description: "Score: \(Int(readiness.overallScore))%"
        ))
        
        // Trend impact
        let improvingCount = trends.filter { $0.trend == .improving }.count
        let trendImpact = trends.isEmpty ? 0 : (Double(improvingCount) / Double(trends.count)) - 0.5
        factors.append(PredictionFactor(
            name: "Improvement Trend",
            impact: trendImpact,
            description: "\(improvingCount)/\(trends.count) categories improving"
        ))
        
        // Time urgency impact
        let urgencyImpact: Double = {
            switch readiness.urgencyLevel {
            case .critical: return -0.3
            case .high: return -0.1
            case .moderate: return 0.05
            case .comfortable: return 0.2
            }
        }()
        factors.append(PredictionFactor(
            name: "Time Before Exam",
            impact: urgencyImpact,
            description: readiness.daysToExam.map { "\($0) days left" } ?? "Date not set"
        ))
        
        return factors
    }
    
    private func calculateProbability(factors: [PredictionFactor]) -> Double {
        guard !factors.isEmpty else { return 0.5 }
        
        // Baseline: 60% chance with all factors neutral
        let baseline = 0.6
        let adjustmentSum = factors.map { $0.impact }.reduce(0, +)
        let averageAdjustment = adjustmentSum / Double(factors.count)
        
        // Each factor can shift by ±25%
        let probability = baseline + (averageAdjustment * 0.25)
        return max(0.01, min(0.99, probability))
    }
    
    private func determineConfidence(probability: Double) -> ReadinessPrediction.ConfidenceLevel {
        switch probability {
        case 0.85...: return .veryHigh
        case 0.7..<0.85: return .high
        case 0.5..<0.7: return .moderate
        default: return .low
        }
    }
    
    private func generateRecommendation(probability: Double) -> String {
        switch probability {
        case 0.85...:
            return "You're very well prepared. Maintain your study routine."
        case 0.75..<0.85:
            return "You're on track. Focus final prep on weak categories."
        case 0.6..<0.75:
            return "More practice needed. Intensify work on problem areas."
        default:
            return "Significant preparation required. Start intensive study plan."
        }
    }
}