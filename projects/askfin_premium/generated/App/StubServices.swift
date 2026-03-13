// StubServices.swift
// Minimal stub implementations of service protocols.
//
// These make the app compilable and runnable without real persistence.
// Replace with real implementations (UserDefaults/SwiftData) when ready.
//
// Each stub returns plausible demo data so the UI is not empty on first launch.

import Foundation

// MARK: - ExamSimulationService Stub

final class StubExamSimulationService: ExamSimulationServiceProtocol {

    private var savedResults: [SimulationResult] = []

    func generateQuestions(for config: SimulationConfig) throws -> [ExamQuestion] {
        let topics = TopicArea.allCases
        return (0..<config.questionCount).map { index in
            let topic = topics[index % topics.count]
            return ExamQuestion(
                id: UUID(),
                questionText: "Demo-Frage \(index + 1) zu \(topic.displayName)",
                options: ["Antwort A", "Antwort B", "Antwort C", "Antwort D"],
                correctAnswerIndex: 0,
                topic: topic,
                questionType: .recall,
                fehlerpunkteCategory: topic.fehlerpunkteCategory,
                explanation: "Dies ist eine Demo-Erklärung für \(topic.displayName)."
            )
        }
    }

    func evaluate(
        _ simulation: ExamSimulation,
        previousScore: Int?
    ) async throws -> SimulationResult {
        var fpByTopic: [String: Int] = [:]
        var questionResults: [SimulationResult.QuestionResult] = []
        var totalFP = 0
        var vorfahrtErrors = 0

        for question in simulation.questions {
            let status = simulation.recordedStatus(for: question) ?? .unanswered
            let fp = status.isCorrect ? 0 : question.fehlerpunkteCategory.fehlerpunkteValue

            totalFP += fp
            fpByTopic[question.topic.rawValue, default: 0] += fp

            if !status.isCorrect && question.fehlerpunkteCategory == .vorfahrt {
                vorfahrtErrors += 1
            }

            questionResults.append(SimulationResult.QuestionResult(
                id: UUID(),
                questionID: question.id,
                topicKey: question.topic.rawValue,
                category: question.fehlerpunkteCategory,
                answerStatus: status,
                correctAnswerIndex: question.correctAnswerIndex,
                fehlerpunkteAwarded: fp,
                explanation: question.explanation ?? "",
                elaborationPrompt: ""
            ))
        }

        return SimulationResult.build(
            simulationID: simulation.id,
            completedAt: Date(),
            totalFehlerpunkte: totalFP,
            fehlerpunkteByTopic: fpByTopic,
            vorfahrtErrorCount: vorfahrtErrors,
            timeTaken: simulation.elapsedTime,
            enforceInstantFail: simulation.config.mode == .realistic,
            readinessScoreAtTime: previousScore ?? 50,
            readinessDelta: nil,
            questionResults: questionResults
        )
    }

    func save(_ result: SimulationResult) async throws {
        savedResults.append(result)
    }

    func loadHistory() async throws -> [SimulationResult] {
        savedResults
    }

    func loadRecentHistory(limit: Int) async throws -> [SimulationResult] {
        Array(savedResults.suffix(limit))
    }
}

// MARK: - ReadinessScoreService Stub

final class StubReadinessScoreService: ReadinessScoreServiceProtocol {

    func compute() async throws -> ReadinessScore {
        ReadinessScore(
            score: 50,
            milestone: .aufDemWeg,
            components: .init(topicCompetence: 0.55, simulationPerformance: 0.40, consistency: 0.50),
            computedAt: Date(),
            delta: nil,
            decayRisk: []
        )
    }

    func loadLatest() async throws -> ReadinessScore? {
        try await compute()
    }
}
