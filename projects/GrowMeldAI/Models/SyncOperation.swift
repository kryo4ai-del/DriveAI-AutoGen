import Foundation

struct AnyCodable: Codable {
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
        } else if let arrayVal = try? container.decode([AnyCodable].self) {
            value = arrayVal.map { $0.value }
        } else if let dictVal = try? container.decode([String: AnyCodable].self) {
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
            let wrapped = arrayVal.map { AnyCodable($0) }
            try container.encode(wrapped)
        case let dictVal as [String: Any]:
            let wrapped = dictVal.mapValues { AnyCodable($0) }
            try container.encode(wrapped)
        default:
            try container.encodeNil()
        }
    }
}

struct SyncOperation: Codable, Identifiable {
    let id: String
    let collection: String
    let documentID: String
    let operationType: SyncOperationType
    let data: [String: AnyCodable]?
    let timestamp: Date

    init(
        id: String = UUID().uuidString,
        collection: String,
        documentID: String,
        operationType: SyncOperationType,
        data: [String: AnyCodable]? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.collection = collection
        self.documentID = documentID
        self.operationType = operationType
        self.data = data
        self.timestamp = timestamp
    }
}