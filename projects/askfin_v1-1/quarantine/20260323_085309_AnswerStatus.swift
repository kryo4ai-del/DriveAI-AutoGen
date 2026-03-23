// AnswerStatus.swift
// How a learner responded to a single simulation question.
//
// Replaces nullable selectedAnswerIndex from the generated design.
// The .incorrect / .unanswered distinction is a meaningful learning signal:
//   .incorrect  → knowledge gap → train the specific topic
//   .unanswered → time management issue → adjust simulation pacing
// Conflating them (both just "wrong") loses the intervention signal.
//
// Codable implementation is explicit to avoid Swift's unstable synthesised
// encoding for enums with associated values and to ensure [UUID: AnswerStatus]
// dictionaries survive JSON round-trips.

enum AnswerStatus: Equatable {
    case correct
    case incorrect(selectedIndex: Int)
    case unanswered

    // MARK: - Derived State

    var isCorrect: Bool {
        if case .correct = self { return true }
        return false
    }

    /// The index the learner tapped. Nil for .correct and .unanswered.
    var selectedIndex: Int? {
        if case .incorrect(let index) = self { return index }
        return nil
    }

    /// Both incorrect and unanswered award Fehlerpunkte.
    var awardsFP: Bool { !isCorrect }
}

// MARK: - Codable

// Explicit implementation: synthesised Codable for associated-value enums
// is unstable across Swift versions and produces opaque JSON.

extension AnswerStatus: Codable {

    private enum CodingKeys: String, CodingKey {
        case type
        case selectedIndex
    }

    private enum TypeValue: String, Codable {
        case correct
        case incorrect
        case unanswered
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .correct:
            try container.encode(TypeValue.correct, forKey: .type)
        case .incorrect(let index):
            try container.encode(TypeValue.incorrect, forKey: .type)
            try container.encode(index, forKey: .selectedIndex)
        case .unanswered:
            try container.encode(TypeValue.unanswered, forKey: .type)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeValue = try container.decode(TypeValue.self, forKey: .type)
        switch typeValue {
        case .correct:
            self = .correct
        case .unanswered:
            self = .unanswered
        case .incorrect:
            let index = try container.decode(Int.self, forKey: .selectedIndex)
            self = .incorrect(selectedIndex: index)
        }
    }
}

// MARK: - View Layer Extensions
// UI copy lives here, not on the model itself, so the model stays
// locale-agnostic and testable without SwiftUI imports.

extension AnswerStatus {

    /// Label for the question review list shown after simulation ends.
    var reviewLabel: String {
        switch self {
        case .correct:    "Richtig beantwortet"
        case .incorrect:  "Falsch beantwortet"
        case .unanswered: "Nicht beantwortet — Zeitdruck?"
        }
    }

    /// Directs the learner toward the appropriate corrective action.
    /// Nil for correct answers — no action needed.
    var reviewActionPrompt: String? {
        switch self {
        case .correct:    nil
        case .incorrect:  "Dieses Thema gezielt üben"
        case .unanswered: "Tempo in der nächsten Generalprobe beobachten"
        }
    }
}