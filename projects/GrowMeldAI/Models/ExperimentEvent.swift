import Foundation

struct AnyCodableValue: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else {
            value = ""
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let intVal = value as? Int {
            try container.encode(intVal)
        } else if let doubleVal = value as? Double {
            try container.encode(doubleVal)
        } else if let boolVal = value as? Bool {
            try container.encode(boolVal)
        } else if let stringVal = value as? String {
            try container.encode(stringVal)
        }
    }
}

struct ExperimentEvent: Codable, Identifiable {
    let id: UUID
    let experimentId: String
    let variantId: String
    let eventType: EventType
    let timestamp: Date
    let metadata: [String: AnyCodableValue]

    // Accessibility context
    var voiceOverEnabled: Bool?
    var assistiveAccessibilityEnabled: Bool?  // Switch Control, etc.

    enum EventType: String, Codable {
        case questionViewed
        case answerSubmitted
        case feedbackShown
        case examStarted
        case examCompleted
    }
}

#if canImport(UIKit)
import UIKit

class ABTestingService {
    func logAsync(_ event: ExperimentEvent) {}
}

class EventLogger {
    var abTestingService = ABTestingService()

    func logAsync(_ event: ExperimentEvent) {
        var enrichedEvent = event

        // Detect assistive tech
        enrichedEvent.voiceOverEnabled = UIAccessibility.isVoiceOverRunning
        enrichedEvent.assistiveAccessibilityEnabled = UIAccessibility.isAssistiveTouchRunning

        // Log enriched event
        abTestingService.logAsync(enrichedEvent)
    }
}
#endif