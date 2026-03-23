// SimulationResult.swift
// Evaluated outcome of a completed ExamSimulation.
//
// Construction invariant: passed == (failureReason == nil).
// Use SimulationResult.build() rather than the memberwise init to enforce this.
//
// ProximityToPass enables differentiated failure framing in SimulationResultView:
// a near-miss (1–3 FP over threshold) warrants different copy than a clear fail
// because the learner's motivational state is different at each margin.

import Foundation

struct SimulationResult: Identifiable, Codable {

    let id: UUID
    let simulationID: UUID
    let completedAt: Date

    // MARK: - Scoring

    let totalFehlerpunkte: Int
    let fehlerpunkteByTopic: [String: Int]   // TopicArea.rawValue → FP
    let vorfahrtErrorCount: Int
    let timeTaken: TimeInterval

    // MARK: - Outcome

    let passed: Bool
    /// nil when passed. Non-nil when failed. Enforced by build().
    let failureReason: FailureReason?

    // MARK: - Readiness Context

    let readinessScoreAtTime: Int
    /// Signed delta vs. readiness score before this simulation. Nil on first run.
    let readinessDelta: Int?

    // MARK: - Per-Question Breakdown

    let questionResults: [QuestionResult]

    // MARK: - Gap Analysis

    /// Topics where errors were made, ranked by FP impact (highest first).
    /// Zero-FP topics are excluded — they appear in topicsWithoutErrors.
    var topicsByFehlerpunkteImpact: [(topicKey: String, fehlerpunkte: Int)] {
        fehlerpunkteByTopic
            .filter { $0.value > 0 }
            .sorted { $0.value > $1.value }
            .map { (topicKey: $0.key, fehlerpunkte: $0.value) }
    }

    /// Topics where the learner made no errors.
    /// Shown in a "Gut gemacht" section — strength acknowledgment reduces
    /// global failure attribution and supports learner retention.
    var topicsWithoutErrors: [String] {
        fehlerpunkteByTopic
            .filter { $0.value == 0 }
            .map { $0.key }
            .sorted {
                let a = TopicArea(rawValue: $0)?.displayName ?? $0
                let b = TopicArea(rawValue: $1)?.displayName ?? $1
                return a.localizedCompare(b) == .orderedAscending
            }
    }

    /// How close to the passing threshold this result landed.
    /// Drives differentiated copy in SimulationResultView.
    var proximityToPass: ProximityToPass {
        guard !passed else { return .passed }

        // Construction invariant: passed=false → failureReason non-nil.
        // If violated, treat as worst case rather than crash.
        guard let reason = failureReason else {
            assertionFailure("SimulationResult: passed=false but failureReason is nil.")
            return .clearFail(fpOver: totalFehlerpunkte)
        }

        switch reason {
        case .vorfahrtInstantFail:
            return .instantFail(reason: reason)
        case .fehlerpunkteExceeded(let total):
            let over = total - FehlerpunkteCategory.failureThreshold
            return over <= 3 ? .nearMiss(fpOver: over) : .clearFail(fpOver: over)
        }
    }
}

// MARK: - Validated Builder

extension SimulationResult {

    /// Builds a SimulationResult, enforcing the passed/failureReason invariant.
    /// ExamSimulationService uses this rather than the memberwise init.
    static func build(
        simulationID: UUID,
        completedAt: Date,
        totalFehlerpunkte: Int,
        fehlerpunkteByTopic: [String: Int],
        vorfahrtErrorCount: Int,
        timeTaken: TimeInterval,
        enforceInstantFail: Bool,
        readinessScoreAtTime: Int,
        readinessDelta: Int?,
        questionResults: [QuestionResult]
    ) -> SimulationResult {

        let failureReason = Self.evaluateFailure(
            totalFehlerpunkte: totalFehlerpunkte,
            vorfahrtErrorCount: vorfahrtErrorCount,
            enforceInstantFail: enforceInstantFail
        )

        return SimulationResult(
            id: UUID(),
            simulationID: simulationID,
            completedAt: completedAt,
            totalFehlerpunkte: totalFehlerpunkte,
            fehlerpunkteByTopic: fehlerpunkteByTopic,
            vorfahrtErrorCount: vorfahrtErrorCount,
            timeTaken: timeTaken,
            passed: failureReason == nil,
            failureReason: failureReason,
            readinessScoreAtTime: readinessScoreAtTime,
            readinessDelta: readinessDelta,
            questionResults: questionResults
        )
    }

    private static func evaluateFailure(
        totalFehlerpunkte: Int,
        vorfahrtErrorCount: Int,
        enforceInstantFail: Bool
    ) -> FailureReason? {
        // Vorfahrt instant-fail takes priority — check first.
        if enforceInstantFail,
           vorfahrtErrorCount >= FehlerpunkteCategory.vorfahrtInstantFailCount {
            return .vorfahrtInstantFail(errorCount: vorfahrtErrorCount)
        }
        if totalFehlerpunkte >= FehlerpunkteCategory.failureThreshold {
            return .fehlerpunkteExceeded(total: totalFehlerpunkte)
        }
        return nil
    }
}

// MARK: - Supporting Types

extension SimulationResult {

    struct QuestionResult: Identifiable, Codable {
        let id: UUID
        let questionID: UUID
        let topicKey: String                 // TopicArea.rawValue
        let category: FehlerpunkteCategory
        let answerStatus: AnswerStatus
        let correctAnswerIndex: Int
        let fehlerpunkteAwarded: Int         // 0 if correct, category.value if wrong/unanswered
        /// Full explanation available post-simulation — the primary learning moment.
        let explanation: String
        /// One-sentence prompt shown before the explanation to activate
        /// elaborative processing (testing effect — Roediger & Karpicke, 2006).
        let elaborationPrompt: String
    }

    enum FailureReason: Codable, Equatable {
        case fehlerpunkteExceeded(total: Int)
        case vorfahrtInstantFail(errorCount: Int)

        /// Empathetic framing — not a system log.
        /// Specifies the margin to support specific (not global) attribution.
        var displayMessage: String {
            switch self {
            case .fehlerpunkteExceeded(let total):
                let over = total - FehlerpunkteCategory.failureThreshold
                let punkteWord = over == 1 ? "Fehlerpunkt" : "Fehlerpunkte"
                return "Noch nicht bestanden — \(over) \(punkteWord) zu viel."
            case .vorfahrtInstantFail(let count):
                return "\(count) Vorfahrt-Fehler – das wäre sofortiges Nichtbestehen. " +
                       "Lass uns das gezielt üben."
            }
        }

        // MARK: Explicit Codable for associated values

        private enum CodingKeys: String, CodingKey {
            case type, total, errorCount
        }
        private enum TypeValue: String, Codable {
            case fehlerpunkteExceeded
            case vorfahrtInstantFail
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .fehlerpunkteExceeded(let total):
                try container.encode(TypeValue.fehlerpunkteExceeded, forKey: .type)
                try container.encode(total, forKey: .total)
            case .vorfahrtInstantFail(let count):
                try container.encode(TypeValue.vorfahrtInstantFail, forKey: .type)
                try container.encode(count, forKey: .errorCount)
            }
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type_ = try container.decode(TypeValue.self, forKey: .type)
            switch type_ {
            case .fehlerpunkteExceeded:
                let total = try container.decode(Int.self, forKey: .total)
                self = .fehlerpunkteExceeded(total: total)
            case .vorfahrtInstantFail:
                let count = try container.decode(Int.self, forKey: .errorCount)
                self = .vorfahrtInstantFail(errorCount: count)
            }
        }
    }

    enum ProximityToPass: Codable, Equatable {
        case passed
        case nearMiss(fpOver: Int)
        case clearFail(fpOver: Int)
        case instantFail(reason: FailureReason)
    }
}