import Foundation

// MARK: - Base Protocol

protocol ASOEvent: Codable, Identifiable {
    var id: UUID { get }
    var timestamp: Date { get }
    var eventType: EventType { get }
    var sessionID: UUID { get }
}

// MARK: - DomainEvent

struct DomainEvent: ASOEvent {
    let id: UUID
    let timestamp: Date
    let eventType: EventType
    let sessionID: UUID
    let payload: EventPayload
    
    init(
        type: EventType,
        sessionID: UUID,
        payload: EventPayload = EventPayload(type: "", data: [:]),
        timestamp: Date = Date()
    ) {
        self.id = UUID()
        self.timestamp = timestamp
        self.eventType = type
        self.sessionID = sessionID
        self.payload = payload
    }
}

// MARK: - EventPayload

// MARK: - AnyCodable

// MARK: - Errors

enum EventError: LocalizedError {
    case invalidEventType
    case invalidPayload(String)
    case invalidTimestamp
    
    var errorDescription: String? {
        switch self {
        case .invalidEventType:
            return "Invalid event type"
        case .invalidPayload(let reason):
            return "Invalid payload: \(reason)"
        case .invalidTimestamp:
            return "Event timestamp is invalid"
        }
    }
}