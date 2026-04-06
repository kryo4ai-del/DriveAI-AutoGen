import Foundation

enum MaintenanceMetadata: Codable, Equatable {
    case string(String)
    case integer(Int)
    case double(Double)
    case date(Date)
    case boolean(Bool)
    case array([MaintenanceMetadata])
    case dictionary([String: MaintenanceMetadata])

    static func daysAgo(_ days: Int) -> Self {
        .integer(days)
    }

    static func percentageCompletion(_ rate: Double) -> Self {
        .double(rate)
    }

    enum CodingKeys: String, CodingKey {
        case type, value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "string":
            self = .string(try container.decode(String.self, forKey: .value))
        case "integer":
            self = .integer(try container.decode(Int.self, forKey: .value))
        case "double":
            self = .double(try container.decode(Double.self, forKey: .value))
        case "date":
            self = .date(try container.decode(Date.self, forKey: .value))
        case "boolean":
            self = .boolean(try container.decode(Bool.self, forKey: .value))
        case "array":
            self = .array(try container.decode([MaintenanceMetadata].self, forKey: .value))
        case "dictionary":
            self = .dictionary(try container.decode([String: MaintenanceMetadata].self, forKey: .value))
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type: \(type)")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .string(let v):
            try container.encode("string", forKey: .type)
            try container.encode(v, forKey: .value)
        case .integer(let v):
            try container.encode("integer", forKey: .type)
            try container.encode(v, forKey: .value)
        case .double(let v):
            try container.encode("double", forKey: .type)
            try container.encode(v, forKey: .value)
        case .date(let v):
            try container.encode("date", forKey: .type)
            try container.encode(v, forKey: .value)
        case .boolean(let v):
            try container.encode("boolean", forKey: .type)
            try container.encode(v, forKey: .value)
        case .array(let v):
            try container.encode("array", forKey: .type)
            try container.encode(v, forKey: .value)
        case .dictionary(let v):
            try container.encode("dictionary", forKey: .type)
            try container.encode(v, forKey: .value)
        }
    }
}