import Foundation

struct ReadinessScore: Codable {

    let score: Int
    let milestone: ReadinessMilestone
    let components: Components
    let computedAt: Date
    let delta: Int?
    /// Topics not trained in 3+ days, ordered by days since last session (longest first).
    /// Surfaced as a re-engagement signal — not a warning or penalty.
    let decayRisk: [String]

    // MARK: - Derived

    var isExamReady: Bool { milestone == .pruefungsbereit }

    var deltaDisplay: String? {
        guard let delta, delta != 0 else { return nil }
        return delta > 0 ? "+\(delta)" : "\(delta)"
    }

    // MARK: - Components

    struct Components: Codable {
        let topicCompetence: Double
        let simulationPerformance: Double
        let consistency: Double

        var weightedTotal: Double {
            (topicCompetence      * 0.50)
            + (simulationPerformance * 0.30)
            + (consistency           * 0.20)
        }
    }

    // MARK: - Trend

    enum Trend: String, Codable {
        case improving
        case stable
        case declining
    }

    var trend: Trend {
        guard let delta else { return .stable }
        if delta > 0 { return .improving }
        if delta < 0 { return .declining }
        return .stable
    }

    // MARK: - Stability Constants

    /// Maximum points the score may drop within one calendar day.
    static let maxDailyDrop = 5

    /// Score rises without a cap within a day; falls are dampened.
    static let riseMultiplier: Double = 1.0
    static let fallMultiplier: Double  = 0.6

    /// Topics not trained for this many days or more are flagged as decay risk.
    static let decayRiskThresholdDays = 3
}