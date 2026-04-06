import Foundation

// MARK: - AnyCodable (local minimal implementation to avoid ambiguity)

struct AnyEncodableValue: Codable {
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
        } else if let arrayVal = try? container.decode([AnyEncodableValue].self) {
            value = arrayVal.map { $0.value }
        } else if let dictVal = try? container.decode([String: AnyEncodableValue].self) {
            value = dictVal.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let intVal as Int:
            try container.encode(intVal)
        case let doubleVal as Double:
            try container.encode(doubleVal)
        case let boolVal as Bool:
            try container.encode(boolVal)
        case let stringVal as String:
            try container.encode(stringVal)
        case let arrayVal as [Any]:
            let wrapped = arrayVal.map { AnyEncodableValue($0) }
            try container.encode(wrapped)
        case let dictVal as [String: Any]:
            let wrapped = dictVal.mapValues { AnyEncodableValue($0) }
            try container.encode(wrapped)
        default:
            try container.encodeNil()
        }
    }
}

// MARK: - AppEventDTO

/// DTO layer for serialization — convert AppEvent → AppEventDTO before queueing
struct AppEventDTO: Codable {
    let eventType: String
    let timestamp: Foundation.Date
    let userId: String?
    let properties: [String: AnyEncodableValue]?

    init(
        eventType: String,
        timestamp: Foundation.Date = Foundation.Date(),
        userId: String? = nil,
        properties: [String: AnyEncodableValue]? = nil
    ) {
        self.eventType = eventType
        self.timestamp = timestamp
        self.userId = userId
        self.properties = properties
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case eventType
        case timestamp
        case userId
        case properties
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        eventType = try container.decode(String.self, forKey: .eventType)
        timestamp = try container.decode(Foundation.Date.self, forKey: .timestamp)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        properties = try container.decodeIfPresent([String: AnyEncodableValue].self, forKey: .properties)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(eventType, forKey: .eventType)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(userId, forKey: .userId)
        try container.encodeIfPresent(properties, forKey: .properties)
    }
}