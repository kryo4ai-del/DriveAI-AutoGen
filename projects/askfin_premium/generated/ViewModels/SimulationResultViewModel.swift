// SimulationResultViewModel.swift
// Processes a SimulationResult into display-ready data:
//   - Ranked gap analysis with per-topic recommendations
//   - "Gut gemacht" strength acknowledgment
//   - Readiness delta context
//   - ProximityToPass-differentiated messaging

import SwiftUI

@MainActor
final class SimulationResultViewModel: ObservableObject {

    // MARK: - Input

    let result: SimulationResult
    let readinessScore: ReadinessScore

    // MARK: - Gap Analysis

    struct TopicGap: Identifiable {
        let id: String           // TopicArea.rawValue
        let displayName: String
        let fehlerpunkte: Int
        let recommendation: String
    }

    var gapAnalysis: [TopicGap] {
        result.topicsByFehlerpunkteImpact.map { item in
            let topic = TopicArea(rawValue: item.topicKey)
            return TopicGap(
                id: item.topicKey,
                displayName: topic?.displayName ?? item.topicKey,
                fehlerpunkte: item.fehlerpunkte,
                recommendation: recommendation(for: item.topicKey, fp: item.fehlerpunkte)
            )
        }
    }

    var strongTopics: [String] {
        result.topicsWithoutErrors.compactMap { key in
            TopicArea(rawValue: key)?.displayName ?? key
        }
    }

    // MARK: - Result Messaging

    /// Primary headline for the result screen.
    var resultHeadline: String {
        result.passed ? "Bestanden" : "Noch nicht bestanden"
    }

    /// Context-sensitive subheadline based on proximity to pass threshold.
    var resultSubheadline: String {
        switch result.proximityToPass {
        case .passed:
            return readinessScore.milestone.motivationalSubtitle
        case .nearMiss(let fpOver):
            let punkteWord = fpOver == 1 ? "Fehlerpunkt" : "Fehlerpunkte"
            return "Nur \(fpOver) \(punkteWord) zu viel -- das ist kein Wissensproblem, " +
                   "das ist Konzentration. Schau dir die letzte falsche Antwort an."
        case .clearFail:
            return "Gezielte Übung in den markierten Themen bringt dich beim nächsten Mal über die Grenze."
        case .instantFail:
            return "Zwei Vorfahrt-Fehler kosten die Prüfung. Ein gezieltes Training reicht, um das zu lösen."
        }
    }

    /// Readiness delta display string with direction.
    var deltaDescription: String? {
        guard let delta = readinessScore.delta, delta != 0 else { return nil }
        return delta > 0
            ? "Bereitschaft um \(delta) Punkte gestiegen"
            : "Bereitschaft um \(abs(delta)) Punkte gesunken"
    }

    // MARK: - Question Review

    var questionReviewItems: [SimulationResult.QuestionResult] {
        result.questionResults
    }

    // MARK: - Init

    init(result: SimulationResult, readinessScore: ReadinessScore) {
        self.result = result
        self.readinessScore = readinessScore
    }

    // MARK: - Private

    private func recommendation(for topicKey: String, fp: Int) -> String {
        let topic = TopicArea(rawValue: topicKey)
        let name = topic?.displayName ?? topicKey
        if fp >= FehlerpunkteCategory.vorfahrt.fehlerpunkteValue {
            return "\(name): Vorfahrtregeln gezielt wiederholen -- hohe Auswirkung auf das Ergebnis."
        } else if fp >= FehlerpunkteCategory.grundstoff.fehlerpunkteValue {
            return "\(name): Grundregeln festigen."
        } else {
            return "\(name): Ein kurzes Auffrischtraining genügt."
        }
    }
}
