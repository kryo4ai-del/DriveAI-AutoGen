// ExamSimulation.swift
// A single simulation session: questions, recorded answers, timing.
//
// Mutation contract:
// - record() and complete() throw ExamSimulationError rather than
//   crashing with precondition — callers can recover gracefully.
// - ExamSimulationViewModel must be @MainActor to serialise the two
//   completion paths (timer expiry + manual submission). Value semantics
//   alone do not prevent both paths completing on separate copies.

import Foundation

struct ExamSimulation: Identifiable {

    let id: UUID
    let config: SimulationConfig
    let questions: [SessionQuestion]
    private(set) var answers: [UUID: AnswerStatus]
    let startedAt: Date
    private(set) var completedAt: Date?

    // MARK: - Init

    init(
        id: UUID = UUID(),
        config: SimulationConfig,
        questions: [SessionQuestion],
        startedAt: Date = Date()
    ) {
        self.id = id
        self.config = config
        self.questions = questions
        self.answers = [:]
        self.startedAt = startedAt
    }

    // MARK: - Derived State

    var isComplete: Bool { completedAt != nil }

    var elapsedTime: TimeInterval {
        guard let completedAt else { return 0 }
        return completedAt.timeIntervalSince(startedAt)
    }

    var answeredCount: Int { answers.count }
    var unansweredCount: Int { questions.count - answeredCount }

    func recordedStatus(for question: SessionQuestion) -> AnswerStatus? {
        answers[question.id]
    }

    // MARK: - Mutation

    /// Records an answer for a question. Overwrites if called again for the same question.
    /// Throws if the simulation is already complete.
    mutating func record(
        answerIndex: Int,
        for question: SessionQuestion
    ) throws {
        guard !isComplete else {
            throw ExamSimulationError.simulationAlreadyComplete
        }
        let isCorrect = answerIndex == question.correctAnswerIndex
        answers[question.id] = isCorrect
            ? .correct
            : .incorrect(selectedIndex: answerIndex)
    }

    /// Finalises the session. Marks unanswered questions as .unanswered,
    /// then seals the session with a completion timestamp.
    /// Throws if already complete — callers handle the timer/submission race.
    mutating func complete(at date: Date = Date()) throws {
        guard !isComplete else {
            throw ExamSimulationError.simulationAlreadyComplete
        }
        for question in questions where answers[question.id] == nil {
            answers[question.id] = .unanswered
        }
        completedAt = date
    }
}

// MARK: - Codable
// Explicit implementation: [UUID: AnswerStatus] requires string keys for
// JSONEncoder. Synthesised Codable would silently fail on UUID dictionary keys.

extension ExamSimulation: Codable {

    private enum CodingKeys: String, CodingKey {
        case id, config, questions, answers, startedAt, completedAt
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(config, forKey: .config)
        try container.encode(questions, forKey: .questions)
        try container.encode(startedAt, forKey: .startedAt)
        try container.encodeIfPresent(completedAt, forKey: .completedAt)

        // Convert UUID keys to strings for JSON compatibility.
        let stringKeyed = Dictionary(
            uniqueKeysWithValues: answers.map { ($0.key.uuidString, $0.value) }
        )
        try container.encode(stringKeyed, forKey: .answers)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        config = try container.decode(SimulationConfig.self, forKey: .config)
        questions = try container.decode([SessionQuestion].self, forKey: .questions)
        startedAt = try container.decode(Date.self, forKey: .startedAt)
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)

        // Restore UUID keys from strings. Skip any malformed keys defensively.
        let stringKeyed = try container.decode([String: AnswerStatus].self, forKey: .answers)
        answers = Dictionary(
            uniqueKeysWithValues: stringKeyed.compactMap { key, value in
                guard let uuid = UUID(uuidString: key) else { return nil }
                return (uuid, value)
            }
        )
    }
}