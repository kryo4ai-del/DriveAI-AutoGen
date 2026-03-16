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

        var systemImage: String {
            switch self {
            case .improving: return "arrow.up.right"
            case .stable: return "arrow.right"
            case .declining: return "arrow.down.right"
            }
        }
    }

    var trend: Trend {
        guard let delta else { return .stable }
        if delta > 0 { return .improving }
        if delta < 0 { return .declining }
        return .stable
    }

    // MARK: - Gauge Support

    /// Score as 0.0-1.0 fraction for gauge display
    var value: Double { Double(score) / 100.0 }

    /// Score as percentage integer
    var percentage: Int { score }

    /// Derived label for gauge display
    var label: ReadinessLabel {
        ReadinessLabel(score: score)
    }

    enum ReadinessLabel: String, CaseIterable, Codable {
        case notReady = "Nicht bereit"
        case developing = "In Entwicklung"
        case almostReady = "Fast bereit"
        case ready = "Bereit"
        case examReady = "Prüfungsbereit"

        init(score: Int) {
            switch score {
            case 0..<30: self = .notReady
            case 30..<55: self = .developing
            case 55..<75: self = .almostReady
            case 75..<90: self = .ready
            default: self = .examReady
            }
        }

        var systemImage: String {
            switch self {
            case .notReady: return "xmark.circle"
            case .developing: return "arrow.up.circle"
            case .almostReady: return "clock.circle"
            case .ready: return "checkmark.circle"
            case .examReady: return "star.circle.fill"
            }
        }

        var colorName: String {
            switch self {
            case .notReady: return "ReadinessRed"
            case .developing: return "ReadinessOrange"
            case .almostReady: return "ReadinessYellow"
            case .ready: return "ReadinessGreen"
            case .examReady: return "ReadinessBlue"
            }
        }
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