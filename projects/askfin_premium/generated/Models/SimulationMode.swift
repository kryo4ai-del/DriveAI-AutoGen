import Foundation

// MARK: - SimulationMode

enum SimulationMode: String, Codable, CaseIterable, Equatable {
    case realistic  // No feedback, timed — exam conditions
    case practice   // Future: with feedback (modelled, UI not yet implemented)
}

// MARK: - SimulationConfig

struct SimulationConfig: Codable, Equatable {
    var questionCount: Int = 30
    var timeLimit: TimeInterval = 2700  // 45 minutes in seconds
    var mode: SimulationMode = .realistic
    /// TopicArea is a String-backed enum — Hashable conformance is synthesised.
    /// This dictionary is safe as a key type.
    var topicWeights: [TopicArea: Double]
    var vorfahrtInstantFailThreshold: Int = 2

    // MARK: Official DACH exam topic weight distribution
    // Sum must equal 1.0 — validated by assertion below.
    static let officialTopicWeights: [TopicArea: Double] = {
        let weights: [TopicArea: Double] = [
            .vorfahrtUndVerkehrsregelung:  0.15,
            .verkehrszeichen:              0.18,
            .grundstoffUndGefahrenlehre:   0.20,
            .verhaltenImStrassenverkehr:   0.12,
            .umweltschutzUndEnergiesparen: 0.05,
            .technikUndSicherheit:         0.08,
            .gefahrenlehre:                0.07,
            .rechtlicheGrundlagen:         0.05,
            .personenschaeden:             0.03,
            .lastenUndAnhaenger:           0.02,
            .autobahn:                     0.02,
            .nachtUndSchlechtwetter:       0.03,
            .strassenbahnUndBus:           0.02,
            .bahnuebergaenge:              0.02,
            .schutzPersonen:               0.03,
            .sonstige:                     0.03
        ]
        let sum = weights.values.reduce(0, +)
        assert(
            abs(sum - 1.0) < 0.001,
            "officialTopicWeights must sum to 1.0 — current sum: \(sum)"
        )
        return weights
    }()

    static let `default` = SimulationConfig(
        topicWeights: SimulationConfig.officialTopicWeights
    )
}

// MARK: - ExamSimulation

/// Mutation note: `answers`, `completedAt`, and `result` are `var` by design.
/// The only authorised mutation sites are:
///   - `ExamSimulationViewModel.recordAnswer()` — updates `answers`
///   - `ExamSimulationViewModel.submitSimulation()` — sets `completedAt` + `result`
/// All other consumers should hold `let` bindings.
struct ExamSimulation: Codable, Identifiable, Equatable {
    let id: UUID
    let config: SimulationConfig
    let questions: [SessionQuestion]   // Ordered, exactly config.questionCount items
    var answers: [UUID: Int]           // questionId → chosen answer index (0-based)
    let startedAt: Date
    var completedAt: Date?
    var result: SimulationResult?

    init(
        id: UUID = UUID(),
        config: SimulationConfig,
        questions: [SessionQuestion],
        answers: [UUID: Int] = [:],
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        result: SimulationResult? = nil
    ) {
        self.id = id
        self.config = config
        self.questions = questions
        self.answers = answers
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.result = result
    }

    // MARK: Computed

    var duration: TimeInterval? {
        completedAt.map { $0.timeIntervalSince(startedAt) }
    }

    var isComplete: Bool {
        completedAt != nil
    }

    var answeredCount: Int {
        answers.count
    }

    var unansweredQuestions: [SessionQuestion] {
        questions.filter { answers[$0.id] == nil }
    }
}

// MARK: - SimulationResult

struct SimulationResult: Codable, Equatable {
    let fehlerpunkteTotal: Int
    let fehlerpunkteByTopic: [TopicArea: Int]
    let isPassed: Bool
    /// True when the Vorfahrt instant-fail rule was triggered
    /// (>= config.vorfahrtInstantFailThreshold wrong Vorfahrt answers).
    let isVorfahrtFail: Bool
    let timeTaken: TimeInterval
    /// Sorted by fehlerpunkte descending — highest impact first.
    let topicBreakdown: [TopicBreakdown]
    let comparedToLastAttempt: ResultDelta?
}

// MARK: - TopicBreakdown

struct TopicBreakdown: Codable, Identifiable, Equatable {
    let id: UUID
    let topic: TopicArea
    let questionsAsked: Int
    let wrongAnswers: Int
    let fehlerpunkte: Int
    /// Competence snapshot captured at result calculation time.
    let competenceAfter: CompetenceLevel

    init(
        id: UUID = UUID(),
        topic: TopicArea,
        questionsAsked: Int,
        wrongAnswers: Int,
        fehlerpunkte: Int,
        competenceAfter: CompetenceLevel
    ) {
        self.id = id
        self.topic = topic
        self.questionsAsked = questionsAsked
        self.wrongAnswers = wrongAnswers
        self.fehlerpunkte = fehlerpunkte
        self.competenceAfter = competenceAfter
    }
}

// MARK: - ResultDelta

struct ResultDelta: Codable, Equatable {
    /// Negative value = improvement (fewer Fehlerpunkte than previous attempt).
    let fehlerpunkteDelta: Int
    /// Change in readiness score. Positive = improvement.
    let readinessDelta: Double
    let previousAttemptDate: Date
}

// MARK: - FehlerpunkteCategory

/// Official scoring categories.
/// Mapping is explicit — no switch `default` to avoid silent misclassification.
enum FehlerpunkteCategory: Equatable {
    case vorfahrt    // 5 FP — instant-fail risk
    case grundstoff  // 3 FP
    case standard    // 2 FP

    var points: Int {
        switch self {
        case .vorfahrt:   return 5
        case .grundstoff: return 3
        case .standard:   return 2
        }
    }

    static func category(for topic: TopicArea) -> FehlerpunkteCategory {
        switch topic {
        case .vorfahrtUndVerkehrsregelung:
            return .vorfahrt

        case .grundstoffUndGefahrenlehre,
             .gefahrenlehre,
             .personenschaeden:
            return .grundstoff

        case .verkehrszeichen:            return .standard
        case .verhaltenImStrassenverkehr: return .standard
        case .umweltschutzUndEnergiesparen: return .standard
        case .technikUndSicherheit:       return .standard
        case .rechtlicheGrundlagen:       return .standard
        case .lastenUndAnhaenger:         return .standard
        case .autobahn:                   return .standard
        case .nachtUndSchlechtwetter:     return .standard
        case .strassenbahnUndBus:         return .standard
        case .bahnuebergaenge:            return .standard
        case .schutzPersonen:             return .standard
        case .sonstige:                   return .standard
        }
    }

    static func points(for topic: TopicArea) -> Int {
        category(for: topic).points
    }
}