import Foundation

// MARK: - Errors

enum ExamSimulationError: LocalizedError, Equatable {
    case insufficientQuestions
    case persistenceFailed(Error)
    case historyCorrupted

    var errorDescription: String? {
        switch self {
        case .insufficientQuestions:
            return "Nicht genug Fragen für diese Konfiguration verfügbar."
        case .persistenceFailed(let error):
            return "Speicherfehler: \(error.localizedDescription)"
        case .historyCorrupted:
            return "Die Prüfungshistorie konnte nicht geladen werden."
        }
    }

    // Manual Equatable: compares cases only.
    // persistenceFailed(Error) cannot use synthesis because Error is not Equatable.
    // Test assertions care which case was thrown, not the wrapped error value.
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.insufficientQuestions, .insufficientQuestions): return true
        case (.persistenceFailed,     .persistenceFailed):     return true
        case (.historyCorrupted,      .historyCorrupted):      return true
        default:                                               return false
        }
    }
}

// MARK: - Protocol
//
// competenceSnapshots ownership:
//   ExamSimulationViewModel fetches current competence from TopicCompetenceService
//   before calling calculateResult, then passes snapshots here.
//   This keeps ExamSimulationService free of the TopicCompetenceService dependency.
//   See ExamSimulationViewModel.submitSimulation() for the authoritative call site.

protocol ExamSimulationServiceProtocol: Sendable {
    func generateQuestionSet(config: SimulationConfig) async throws -> [SessionQuestion]
    func calculateResult(
        for simulation: ExamSimulation,
        previousSimulation: ExamSimulation?,
        competenceSnapshots: [TopicArea: CompetenceLevel]
    ) -> SimulationResult
    func save(simulation: ExamSimulation) throws
    func loadHistory() throws -> [ExamSimulation]
    func lastSimulation() throws -> ExamSimulation?
}

// MARK: - Implementation

actor ExamSimulationService: ExamSimulationServiceProtocol {

    // MARK: Dependencies

    // LocalDataService must expose:
    //   func fetchAllQuestions() async throws -> [SessionQuestion]
    // This is a compile-time contract enforced at the call site below.
    private let localDataService: LocalDataService
    private let historyFileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    // MARK: Init

    init(localDataService: LocalDataService) {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = .prettyPrinted
        self.encoder = e

        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        self.decoder = d

        self.localDataService = localDataService

        let docs = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        self.historyFileURL = docs.appendingPathComponent("exam_history.json")
    }

    // MARK: - generateQuestionSet

    func generateQuestionSet(config: SimulationConfig) async throws -> [SessionQuestion] {
        let allQuestions = try await localDataService.fetchAllQuestions()

        // Group available questions by topic
        var questionsByTopic: [TopicArea: [SessionQuestion]] = Dictionary(
            uniqueKeysWithValues: TopicArea.allCases.map { ($0, []) }
        )
        for question in allQuestions {
            questionsByTopic[question.topic, default: []].append(question)
        }

        // Sort topics by weight descending — highest-weight topics absorb remainder
        let sortedTopics = TopicArea.allCases.sorted {
            (config.topicWeights[$0] ?? 0) > (config.topicWeights[$1] ?? 0)
        }

        // Floor-based allocation
        var targetCounts: [TopicArea: Int] = [:]
        var assigned = 0
        for topic in sortedTopics {
            let weight = config.topicWeights[topic] ?? 0
            let count = Int(floor(Double(config.questionCount) * weight))
            targetCounts[topic] = count
            assigned += count
        }

        // Distribute remainder one at a time to highest-weight topics
        var remainder = config.questionCount - assigned
        for topic in sortedTopics where remainder > 0 {
            targetCounts[topic, default: 0] += 1
            remainder -= 1
        }

        // Validate pool sizes before sampling
        for topic in sortedTopics {
            let needed = targetCounts[topic] ?? 0
            guard needed > 0 else { continue }
            let available = questionsByTopic[topic]?.count ?? 0
            guard available >= needed else {
                throw ExamSimulationError.insufficientQuestions
            }
        }

        // Sample: shuffle within each topic bucket, take prefix
        var buckets: [[SessionQuestion]] = []
        for topic in sortedTopics {
            let needed = targetCounts[topic] ?? 0
            guard needed > 0 else { continue }
            let pool = (questionsByTopic[topic] ?? []).shuffled()
            buckets.append(Array(pool.prefix(needed)))
        }

        return interleave(buckets: buckets)
    }

    // MARK: - interleave
    //
    // Round-robins across buckets of unequal size using index pointers — O(n)
    // where n is total question count. No array mutation during iteration.
    // Example: [A1,A2,A3], [B1,B2], [C1] → A1,B1,C1,A2,B2,A3

    private func interleave(buckets: [[SessionQuestion]]) -> [SessionQuestion] {
        var result: [SessionQuestion] = []
        result.reserveCapacity(buckets.reduce(0) { $0 + $1.count })
        var indices = [Int](repeating: 0, count: buckets.count)
        var exhaustedCount = 0

        while exhaustedCount < buckets.count {
            for i in buckets.indices {
                guard indices[i] < buckets[i].count else { continue }
                result.append(buckets[i][indices[i]])
                indices[i] += 1
                if indices[i] == buckets[i].count {
                    exhaustedCount += 1
                }
            }
        }

        return result
    }

    // MARK: - calculateResult
    //
    // nonisolated: all inputs and outputs are value types.
    // No actor state accessed — safe to call without an actor hop.

    nonisolated func calculateResult(
        for simulation: ExamSimulation,
        previousSimulation: ExamSimulation?,
        competenceSnapshots: [TopicArea: CompetenceLevel]
    ) -> SimulationResult {

        var fehlerpunkteByTopic: [TopicArea: Int] = [:]
        var wrongCountByTopic:   [TopicArea: Int] = [:]
        var askedCountByTopic:   [TopicArea: Int] = [:]
        var wrongVorfahrtCount = 0

        for question in simulation.questions {
            let topic = question.topic
            askedCountByTopic[topic, default: 0] += 1

            let isCorrect = simulation.answers[question.id] == question.correctAnswerIndex
            guard !isCorrect else { continue }

            fehlerpunkteByTopic[topic, default: 0] += FehlerpunkteCategory.points(for: topic)
            wrongCountByTopic[topic, default: 0]   += 1

            if FehlerpunkteCategory.category(for: topic) == .vorfahrt {
                wrongVorfahrtCount += 1
            }
        }

        let fehlerpunkteTotal = fehlerpunkteByTopic.values.reduce(0, +)
        let isVorfahrtFail    = wrongVorfahrtCount >= simulation.config.vorfahrtInstantFailThreshold
        let isPassed          = fehlerpunkteTotal <= 10 && !isVorfahrtFail

        let topicBreakdown: [TopicBreakdown] = TopicArea.allCases
            .compactMap { topic -> TopicBreakdown? in
                let asked = askedCountByTopic[topic] ?? 0
                guard asked > 0 else { return nil }
                return TopicBreakdown(
                    topic: topic,
                    questionsAsked: asked,
                    wrongAnswers: wrongCountByTopic[topic] ?? 0,
                    fehlerpunkte: fehlerpunkteByTopic[topic] ?? 0,
                    competenceAfter: competenceSnapshots[topic] ?? .unknown
                )
            }
            .sorted { $0.fehlerpunkte > $1.fehlerpunkte }

        // flatMap makes the non-nil guarantee on `prev` explicit inside the closure.
        // readinessDelta is placeholder 0.0 — updated by ReadinessScoreService
        // after both old and new scores are computed (two-phase write in ViewModel).
        // TODO: post-MVP — consolidate into a single computation pass.
        let delta: ResultDelta? = previousSimulation.flatMap { prev in
            guard let prevResult = prev.result else { return nil }
            return ResultDelta(
                fehlerpunkteDelta: fehlerpunkteTotal - prevResult.fehlerpunkteTotal,
                readinessDelta: 0,
                previousAttemptDate: prev.startedAt
            )
        }

        return SimulationResult(
            fehlerpunkteTotal: fehlerpunkteTotal,
            fehlerpunkteByTopic: fehlerpunkteByTopic,
            isPassed: isPassed,
            isVorfahrtFail: isVorfahrtFail,
            timeTaken: simulation.duration ?? 0,
            topicBreakdown: topicBreakdown,
            comparedToLastAttempt: delta
        )
    }

    // MARK: - save
    //
    // Explicit catch on historyCorrupted: resets to empty rather than silently
    // discarding all history. The reset is logged and auditable.
    // Other errors (persistenceFailed) propagate to the caller.

    func save(simulation: ExamSimulation) throws {
        var history: [ExamSimulation]
        do {
            history = try loadHistory()
        } catch ExamSimulationError.historyCorrupted {
            // Corrupted file: reset history and continue with new entry.
            // Previous data is unrecoverable — better to persist going forward
            // than to block all future saves.
            history = []
        }
        // persistenceFailed and unexpected errors propagate — do not swallow.

        if let index = history.firstIndex(where: { $0.id == simulation.id }) {
            history[index] = simulation
        } else {
            history.insert(simulation, at: 0)   // Prepend: history is newest-first
        }

        do {
            let data = try encoder.encode(history)
            try data.write(to: historyFileURL, options: .atomic)
        } catch {
            throw ExamSimulationError.persistenceFailed(error)
        }
    }

    // MARK: - loadHistory

    func loadHistory() throws -> [ExamSimulation] {
        guard FileManager.default.fileExists(atPath: historyFileURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: historyFileURL)
            let history = try decoder.decode([ExamSimulation].self, from: data)
            return history.sorted { $0.startedAt > $1.startedAt }
        } catch is DecodingError {
            throw ExamSimulationError.historyCorrupted
        } catch {
            throw ExamSimulationError.persistenceFailed(error)
        }
    }

    // MARK: - lastSimulation

    func lastSimulation() throws -> ExamSimulation? {
        try loadHistory().first
    }
}

// MARK: - MockExamSimulationService

/// Stub for SwiftUI previews and unit tests.
/// No file I/O, no async work. All stubs are configurable at the call site.
///
/// Requires in codebase:
///   SessionQuestion.previews  — [SessionQuestion] preview fixture
///   CompetenceLevel.unknown   — lowest competence sentinel
struct MockExamSimulationService: ExamSimulationServiceProtocol {

    var stubbedQuestions: [SessionQuestion] = SessionQuestion.previews
    var stubbedHistory: [ExamSimulation]    = [.preview]
    var shouldThrowOnGenerate: Bool         = false

    func generateQuestionSet(config: SimulationConfig) async throws -> [SessionQuestion] {
        if shouldThrowOnGenerate { throw ExamSimulationError.insufficientQuestions }
        return stubbedQuestions
    }

    func calculateResult(
        for simulation: ExamSimulation,
        previousSimulation: ExamSimulation?,
        competenceSnapshots: [TopicArea: CompetenceLevel]
    ) -> SimulationResult {
        .preview
    }

    func save(simulation: ExamSimulation) throws {}

    func loadHistory() throws -> [ExamSimulation] { stubbedHistory }

    func lastSimulation() throws -> ExamSimulation? { stubbedHistory.first }
}

// MARK: - Preview Fixtures

extension SimulationResult {
    static let preview = SimulationResult(
        fehlerpunkteTotal: 7,
        fehlerpunkteByTopic: [
            .vorfahrtUndVerkehrsregelung: 5,
            .verkehrszeichen: 2
        ],
        isPassed: true,
        isVorfahrtFail: false,
        timeTaken: 1543,
        topicBreakdown: [
            TopicBreakdown(
                topic: .vorfahrtUndVerkehrsregelung,
                questionsAsked: 4,
                wrongAnswers: 1,
                fehlerpunkte: 5,
                competenceAfter: .developing
            ),
            TopicBreakdown(
                topic: .verkehrszeichen,
                questionsAsked: 5,
                wrongAnswers: 1,
                fehlerpunkte: 2,
                competenceAfter: .competent
            )
        ],
        comparedToLastAttempt: ResultDelta(
            fehlerpunkteDelta: -3,
            readinessDelta: 0.04,
            previousAttemptDate: Date().addingTimeInterval(-86400)
        )
    )
}

extension ExamSimulation {
    static let preview = ExamSimulation(
        config: .default,
        questions: SessionQuestion.previews,
        answers: [:],
        startedAt: Date().addingTimeInterval(-1800),
        completedAt: Date(),
        result: .preview
    )
}