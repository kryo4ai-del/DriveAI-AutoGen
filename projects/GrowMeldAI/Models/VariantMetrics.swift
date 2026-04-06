import Foundation

enum AnyCodable: Codable {
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let b = try? container.decode(Bool.self) {
            self = .bool(b)
        } else if let i = try? container.decode(Int.self) {
            self = .int(i)
        } else if let d = try? container.decode(Double.self) {
            self = .double(d)
        } else if let s = try? container.decode(String.self) {
            self = .string(s)
        } else {
            self = .null
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let b): try container.encode(b)
        case .int(let i): try container.encode(i)
        case .double(let d): try container.encode(d)
        case .string(let s): try container.encode(s)
        case .null: try container.encodeNil()
        }
    }

    var boolValue: Bool? {
        if case .bool(let b) = self { return b }
        return nil
    }

    var doubleValue: Double? {
        if case .double(let d) = self { return d }
        return nil
    }

    var stringValue: String? {
        if case .string(let s) = self { return s }
        return nil
    }
}

enum ExperimentEventType: String, Codable {
    case answerSubmitted = "answer_submitted"
    case sessionStarted = "session_started"
    case sessionEnded = "session_ended"
}

struct ExperimentEvent: Codable {
    let eventType: ExperimentEventType
    let metadata: [String: AnyCodable]
}

struct VariantMetrics: Codable {
    let variantId: String
    let totalEvents: Int
    let correctAnswerRate: Double
    let avgTimeToAnswer: Double
    let engagementScore: Double

    init(variantId: String, events: [ExperimentEvent]) {
        self.variantId = variantId
        self.totalEvents = events.count

        let submittedEvents = events.filter { $0.eventType == .answerSubmitted }
        let correctCount = submittedEvents.filter { event -> Bool in
            if let boolVal = event.metadata["correct"]?.boolValue {
                return boolVal
            }
            if let stringVal = event.metadata["correct"]?.stringValue {
                return stringVal.lowercased() == "true"
            }
            return false
        }.count

        let correctAnswerRate = submittedEvents.isEmpty
            ? 0.0
            : Double(correctCount) / Double(submittedEvents.count)
        self.correctAnswerRate = correctAnswerRate

        let validTimings = events.compactMap { event -> Double? in
            guard let timeStr = event.metadata["timeToAnswer"]?.stringValue,
                  let time = Double(timeStr),
                  time >= 0,
                  time <= 3600
            else {
                return nil
            }
            return time
        }

        self.avgTimeToAnswer = validTimings.isEmpty
            ? 0.0
            : validTimings.reduce(0, +) / Double(validTimings.count)

        self.engagementScore = Double(events.count) * max(correctAnswerRate, 0.0)
    }
}