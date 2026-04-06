import Foundation

/// Final results and statistical analysis of a completed experiment
public struct ExperimentResult: Identifiable, Codable {
    public let id: String
    public let experimentID: String
    
    public let variantMetrics: [AggregatedVariantMetrics]
    public let statisticalAnalysis: StatisticalAnalysis
    public let winner: ExperimentWinner?
    
    public let completedAt: Date
    
    public init(
        id: String = UUID().uuidString,
        experimentID: String,
        variantMetrics: [AggregatedVariantMetrics],
        statisticalAnalysis: StatisticalAnalysis,
        winner: ExperimentWinner? = nil,
        completedAt: Date = Date()
    ) {
        self.id = id
        self.experimentID = experimentID
        self.variantMetrics = variantMetrics
        self.statisticalAnalysis = statisticalAnalysis
        self.winner = winner
        self.completedAt = completedAt
    }
}

// MARK: - Statistical Analysis
public struct StatisticalAnalysis: Codable {
    /// P-value from statistical test (< 0.05 = significant)
    public let pValue: Double
    
    /// Confidence level (typically 0.95 = 95%)
    public let confidenceLevel: Double
    
    /// Confidence interval for the difference
    public let confidenceInterval: (lower: Double, upper: Double)
    
    /// Effect size (Cohen's d or similar)
    public let effectSize: Double
    
    public let testType: String // "ttest", "chisquare", etc.
    public let isSignificant: Bool
    
    public init(
        pValue: Double,
        confidenceLevel: Double = 0.95,
        confidenceInterval: (lower: Double, upper: Double),
        effectSize: Double,
        testType: String,
        isSignificant: Bool
    ) {
        self.pValue = pValue
        self.confidenceLevel = confidenceLevel
        self.confidenceInterval = confidenceInterval
        self.effectSize = effectSize
        self.testType = testType
        self.isSignificant = isSignificant
    }
}

// MARK: - Winner Determination