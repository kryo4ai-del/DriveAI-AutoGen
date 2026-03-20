import Foundation

// ============================================================================
// TYPES
// ============================================================================

public enum ReadinessTier: String, Codable, Hashable {
    case novice
    case beginner
    case intermediate
    case advanced
    case expert
}

public struct ReadinessMilestone: Identifiable, Codable, Hashable {
    public let id: UUID
    public let tier: ReadinessTier
    public let minScore: Int
    public let maxScore: Int
    public let label: String
    /// Semantic meaning: what this tier means for exam readiness
    public let contextualDescription: String
    /// The exam-critical threshold
    public let isCritical: Bool

    public init(
        tier: ReadinessTier,
        minScore: Int,
        maxScore: Int,
        label: String,
        contextualDescription: String,
        isCritical: Bool
    ) {
        self.id = UUID()
        self.tier = tier
        self.minScore = minScore
        self.maxScore = maxScore
        self.label = label
        self.contextualDescription = contextualDescription
        self.isCritical = isCritical
    }

    enum CodingKeys: String, CodingKey {
        case tier, minScore, maxScore, label, contextualDescription, isCritical
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tier, forKey: .tier)
        try container.encode(minScore, forKey: .minScore)
        try container.encode(maxScore, forKey: .maxScore)
        try container.encode(label, forKey: .label)
        try container.encode(contextualDescription, forKey: .contextualDescription)
        try container.encode(isCritical, forKey: .isCritical)
    }
}

public struct ReadinessTrend: Identifiable, Codable {
    public let id: UUID
    public let timestamp: Date
    public let score: Int
    public let milestone: ReadinessMilestone
    /// Momentum: points per day (can be negative)
    public let velocity: Double?
    /// ML-fitted projection: when will user hit critical milestone?
    public let projectedReadinessDate: Date?
    /// If score dropped, explain the regression
    public let regressionContext: RegressionContext?

    public struct RegressionContext: Codable {
        public let likelyWeakArea: String
        public let recommendedFocus: String

        public init(likelyWeakArea: String, recommendedFocus: String) {
            self.likelyWeakArea = likelyWeakArea
            self.recommendedFocus = recommendedFocus
        }
    }

    public init(
        timestamp: Date,
        score: Int,
        milestone: ReadinessMilestone,
        velocity: Double? = nil,
        projectedReadinessDate: Date? = nil,
        regressionContext: RegressionContext? = nil
    ) {
        self.id = UUID()
        self.timestamp = timestamp
        self.score = score
        self.milestone = milestone
        self.velocity = velocity
        self.projectedReadinessDate = projectedReadinessDate
        self.regressionContext = regressionContext
    }
}

public struct ReadinessState {
    public let currentScore: Int
    public let currentMilestone: ReadinessMilestone
    public let trend: [ReadinessTrend]
    public let lastUpdated: Date
    public let isLoading: Bool
    public let error: Error?

    public init(
        currentScore: Int = 0,
        currentMilestone: ReadinessMilestone = ReadinessScore.MILESTONES[0],
        trend: [ReadinessTrend] = [],
        lastUpdated: Date = Date(),
        isLoading: Bool = false,
        error: Error? = nil
    ) {
        self.currentScore = currentScore
        self.currentMilestone = currentMilestone
        self.trend = trend
        self.lastUpdated = lastUpdated
        self.isLoading = isLoading
        self.error = error
    }

    /// Creates a new state with updated fields
    func updating(
        currentScore: Int? = nil,
        currentMilestone: ReadinessMilestone? = nil,
        trend: [ReadinessTrend]? = nil,
        lastUpdated: Date? = nil,
        isLoading: Bool? = nil,
        error: Error? = nil
    ) -> ReadinessState {
        ReadinessState(
            currentScore: currentScore ?? self.currentScore,
            currentMilestone: currentMilestone ?? self.currentMilestone,
            trend: trend ?? self.trend,
            lastUpdated: lastUpdated ?? self.lastUpdated,
            isLoading: isLoading ?? self.isLoading,
            error: error ?? self.error
        )
    }
}

// ============================================================================
// CONFIG
// ============================================================================

public struct ReadinessScore {
    public static let MILESTONES: [ReadinessMilestone] = [
        ReadinessMilestone(
            tier: .novice,
            minScore: 0,
            maxScore: 25,
            label: "Novice",
            contextualDescription:
                "Starting your journey. Focus on foundational road signs and basic rules. You are building core knowledge.",
            isCritical: false
        ),
        ReadinessMilestone(
            tier: .beginner,
            minScore: 26,
            maxScore: 50,
            label: "Beginner",
            contextualDescription:
                "You can identify most road signs and know basic rules. Now focus on hazard perception and decision-making in complex scenarios.",
            isCritical: false
        ),
        ReadinessMilestone(
            tier: .intermediate,
            minScore: 51,
            maxScore: 74,
            label: "Intermediate",
            contextualDescription:
                "Solid grasp of core concepts. Weak areas: rural driving, adverse weather, and emergency procedures. Target these to reach exam readiness.",
            isCritical: false
        ),
        ReadinessMilestone(
            tier: .advanced,
            minScore: 75,
            maxScore: 89,
            label: "Advanced",
            contextualDescription:
                "✓ Exam-Ready. You have demonstrated readiness for the driving theory test. Continue practicing edge cases and complex scenarios to maximize your score.",
            isCritical: true
        ),
        ReadinessMilestone(
            tier: .expert,
            minScore: 90,
            maxScore: 100,
            label: "Expert",
            contextualDescription:
                "Mastery achieved. You are performing at the highest level. Use this time to refine weak areas and help others learn.",
            isCritical: true
        ),
    ]

    public static let CRITICAL_MILESTONE: Int = 75
    public static let REFRESH_INTERVAL: TimeInterval = 5 * 60 // 5 minutes
    public static let HISTORY_LIMIT: Int = 50

    /// Get milestone for a score in range [0, 100]
    public static func getMilestone(for score: Int) -> ReadinessMilestone {
        let clamped = max(0, min(100, score))
        return MILESTONES.first { clamped >= $0.minScore && clamped <= $0.maxScore }
            ?? MILESTONES[0]
    }
}