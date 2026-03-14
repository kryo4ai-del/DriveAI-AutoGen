// ReadinessScoreService.swift
// Three-component readiness calculation with stability rules.
//
// Bug fixes applied:
// - Sync methods removed from protocol (Critical Finding 1)
// - baseline loaded async in compute(), passed to applyStabilityRule()
// - loadRecentHistory(limit:) used instead of full history load

import Foundation

protocol ReadinessScoreServiceProtocol {
    func compute() async throws -> ReadinessScore
    func loadLatest() async throws -> ReadinessScore?
}

protocol ReadinessScoreStoreProtocol {
    func save(_ score: ReadinessScore) async throws
    func loadLatest() async throws -> ReadinessScore?
    func loadLastScoreBefore(_ date: Date) async throws -> ReadinessScore?
}

final class ReadinessScoreService: ReadinessScoreServiceProtocol {

    private let topicCompetenceService: TopicCompetenceServiceProtocol
    private let simulationService: ExamSimulationServiceProtocol
    private let activityStore: ActivityStoreProtocol
    private let scoreStore: ReadinessScoreStoreProtocol
    private let calendar: Calendar
    private let now: () -> Date

    init(
        topicCompetenceService: TopicCompetenceServiceProtocol,
        simulationService: ExamSimulationServiceProtocol,
        activityStore: ActivityStoreProtocol,
        scoreStore: ReadinessScoreStoreProtocol,
        calendar: Calendar = .current,
        now: @escaping () -> Date = { Date() }
    ) {
        self.topicCompetenceService = topicCompetenceService
        self.simulationService = simulationService
        self.activityStore = activityStore
        self.scoreStore = scoreStore
        self.calendar = calendar
        self.now = now
    }

    // MARK: - Computation

    func compute() async throws -> ReadinessScore {
        // Load all async dependencies concurrently.
        async let topicComponent       = computeTopicCompetenceComponent()
        async let simulationComponent  = computeSimulationComponent()
        async let consistencyComponent = computeConsistencyComponent()
        async let previous             = loadLatest()
        async let decayRisk            = computeDecayRisk()

        let (topic, simulation, consistency, prev, risk) = try await (
            topicComponent,
            simulationComponent,
            consistencyComponent,
            previous,
            decayRisk
        )

        let components = ReadinessScore.Components(
            topicCompetence: topic,
            simulationPerformance: simulation,
            consistency: consistency
        )
        let rawScore = Int((components.weightedTotal * 100).rounded())

        // Load today's baseline async — no sync I/O on the protocol.
        let todayStart = calendar.startOfDay(for: now())
        let baseline = try await scoreStore.loadLastScoreBefore(todayStart)

        let stabilisedScore = applyStabilityRule(
            rawScore: rawScore,
            previous: prev,
            baseline: baseline
        )

        let delta: Int? = prev.map { stabilisedScore - $0.score }
        let score = ReadinessScore(
            score: stabilisedScore,
            milestone: ReadinessMilestone.milestone(for: stabilisedScore),
            components: components,
            computedAt: now(),
            delta: delta,
            decayRisk: risk
        )

        try await scoreStore.save(score)
        return score
    }

    func loadLatest() async throws -> ReadinessScore? {
        try await scoreStore.loadLatest()
    }

    // MARK: - Components

    private func computeTopicCompetenceComponent() async throws -> Double {
        let competences = try await topicCompetenceService.allTopicCompetences()
        guard !competences.isEmpty else {
            throw ExamSimulationError.noTopicCompetenceData
        }
        let average = competences.values
            .map { $0.normalizedScore }
            .reduce(0.0, +) / Double(competences.count)
        return min(1.0, max(0.0, average))
    }

    private func computeSimulationComponent() async throws -> Double {
        // loadRecentHistory(limit:) avoids deserialising the full history.
        let recent = try await simulationService.loadRecentHistory(limit: 3)
        guard !recent.isEmpty else { return 0.0 }

        // Recency weights: newest = 3, second = 2, third = 1.
        let weights: [Double] = [3.0, 2.0, 1.0]
        var weightedSum = 0.0
        var totalWeight = 0.0

        for (index, result) in recent.enumerated() {
            let w = weights[index]
            weightedSum += performanceScore(for: result) * w
            totalWeight += w
        }
        return totalWeight > 0 ? weightedSum / totalWeight : 0.0
    }

    private func performanceScore(for result: SimulationResult) -> Double {
        if result.passed {
            let fpPenalty = Double(result.totalFehlerpunkte) /
                Double(FehlerpunkteCategory.failureThreshold) * 0.2
            return max(0.8, 1.0 - fpPenalty)
        } else {
            let fpRatio = Double(result.totalFehlerpunkte) /
                Double(FehlerpunkteCategory.failureThreshold * 2)
            return max(0.0, 0.8 - min(0.8, fpRatio))
        }
    }

    private func computeConsistencyComponent() async throws -> Double {
        async let streak  = activityStore.currentStreakDays()
        async let recent  = activityStore.sessionCountInLastDays(7)
        let (streakDays, sessionCount) = try await (streak, recent)

        let streakScore   = min(1.0, Double(streakDays) / 7.0) * 0.6
        let activityScore = min(1.0, Double(sessionCount) / 5.0) * 0.4
        return streakScore + activityScore
    }

    // MARK: - Stability Rule

    /// Clamps daily drops to maxDailyDrop. Rises are uncapped.
    /// All inputs are loaded async before this is called — no I/O here.
    private func applyStabilityRule(
        rawScore: Int,
        previous: ReadinessScore?,
        baseline: ReadinessScore?
    ) -> Int {
        guard let previous else { return rawScore }
        let delta = rawScore - previous.score
        guard delta < 0 else { return rawScore }

        let todayDropSoFar = baseline.map { max(0, $0.score - previous.score) } ?? 0
        let remainingAllowance = max(0, ReadinessScore.maxDailyDrop - todayDropSoFar)
        let dampedDrop = Int((Double(abs(delta)) * ReadinessScore.fallMultiplier).rounded())
        let allowedDrop = min(dampedDrop, remainingAllowance)
        return previous.score - allowedDrop
    }

    // MARK: - Decay Risk

    private func computeDecayRisk() async throws -> [String] {
        guard let cutoff = calendar.date(
            byAdding: .day,
            value: -ReadinessScore.decayRiskThresholdDays,
            to: now()
        ) else { return [] }

        let lastSessions = try await activityStore.lastSessionDatePerTopic()
        return lastSessions
            .filter { $0.value < cutoff }
            .sorted { $0.value < $1.value }   // longest gap first
            .map { $0.key }
    }
}