public struct ExperimentWinner: Codable {
    public let recommendation: Recommendation // Structured enum
    public let performanceLift: Double
    public let confidenceLevel: Double
}