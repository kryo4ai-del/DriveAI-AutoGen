// StubServices.swift
// Minimal stub implementations of service protocols.
//
// These make the app compilable and runnable without real persistence.
// Replace with real implementations (UserDefaults/SwiftData) when ready.
//
// Each stub returns plausible demo data so the UI is not empty on first launch.

import Foundation
import Combine

// MARK: - ExamSimulationService Stub

final class StubExamSimulationService: ExamSimulationServiceProtocol {

    private var savedResults: [SimulationResult] = []
    var historyStore: SessionHistoryStore?

    init(historyStore: SessionHistoryStore? = nil) {
        self.historyStore = historyStore
    }


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
        historyStore?.addResult(result)
    }

    func loadHistory() async throws -> [SimulationResult] {
        savedResults
    }

    func loadRecentHistory(limit: Int) async throws -> [SimulationResult] {
        Array(savedResults.suffix(limit))
    }
}

// MARK: - InMemoryPersistenceStore

final class InMemoryPersistenceStore: PersistenceStore {
    private var competences: [TopicArea: TopicCompetence] = [:]
    private var queue: [TopicArea: SpacingItem] = [:]

    func loadCompetences() -> [TopicArea: TopicCompetence] { competences }
    func loadSpacingQueue() -> [TopicArea: SpacingItem] { queue }
    func save(competences: [TopicArea: TopicCompetence]) { self.competences = competences }
    func save(spacingQueue: [TopicArea: SpacingItem]) { self.queue = spacingQueue }
}

// MARK: - MockQuestionBank

final class MockQuestionBank: QuestionBankProtocol {
    func randomQuestion(for topic: TopicArea, revealMode: RevealMode) -> SessionQuestion? {
        if let real = QuestionLoader.shared.sessionQuestion(for: topic, revealMode: revealMode) {
            return real
        }
        return SessionQuestion(
            text: "Demo-Frage zu \(topic.displayName)",
            options: SwipeDirection.allCases.enumerated().map { index, dir in
                AnswerOption(text: "Antwort \(dir.answerLetter)", swipeDirection: dir)
            },
            correctIndex: 0,
            topic: topic,
            questionType: .recall,
            explanation: "Demo-Erklärung",
            revealMode: revealMode
        )
    }
    
    func questions(for topic: TopicArea) -> [SessionQuestion] {
        (0..<5).compactMap { _ in randomQuestion(for: topic, revealMode: .immediate) }
    }
}

// MARK: - SystemHapticFeedback

typealias SystemHapticFeedback = HapticFeedback

// MARK: - DashboardDataService

final class DashboardDataService {
    static let shared = DashboardDataService()

    func fetchDashboardContent() -> AnyPublisher<DashboardContent, Error> {
        Just(DashboardContent(
            examCountdown: ExamCountdown(
                daysRemaining: 30,
                examDate: Date().addingTimeInterval(30 * 86400),
                status: .upcoming
            ),
            progressSummary: ProgressSummary(
                totalCategories: 12,
                completedCategories: 0,
                averageScore: 0,
                questionsAnswered: 0,
                correctAnswers: 0
            ),
            streakData: StreakData(
                currentStreak: 0,
                longestStreak: 0,
                lastActivityDate: nil
            ),
            resumableQuiz: nil
        ))
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }

    func fetchDashboardContentAsync() async throws -> DashboardContent {
        DashboardContent(
            examCountdown: ExamCountdown(
                daysRemaining: 30,
                examDate: Date().addingTimeInterval(30 * 86400),
                status: .upcoming
            ),
            progressSummary: ProgressSummary(
                totalCategories: 12,
                completedCategories: 0,
                averageScore: 0,
                questionsAnswered: 0,
                correctAnswers: 0
            ),
            streakData: StreakData(
                currentStreak: 0,
                longestStreak: 0,
                lastActivityDate: nil
            ),
            resumableQuiz: nil
        )
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
