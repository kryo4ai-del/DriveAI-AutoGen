import Foundation

// MARK: - AnyCodable

enum AnyCodable: Codable, Sendable {
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    indirect case array([AnyCodable])
    indirect case dictionary([String: AnyCodable])
    case null

    // MARK: - Decodable

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let b = try? container.decode(Bool.self) {
            self = .bool(b)
        } else if let i = try? container.decode(Int.self) {
            self = .int(i)
        } else if let d = try? container.decode(Double.self) {
            self = .double(d)
        } else if let s = try? container.decode(String.self) {
            self = .string(s)
        } else if let a = try? container.decode([AnyCodable].self) {
            self = .array(a)
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            self = .dictionary(dict)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "AnyCodable: unsupported type"
            )
        }
    }

    // MARK: - Encodable

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let b):       try container.encode(b)
        case .int(let i):        try container.encode(i)
        case .double(let d):     try container.encode(d)
        case .string(let s):     try container.encode(s)
        case .array(let a):      try container.encode(a)
        case .dictionary(let d): try container.encode(d)
        case .null:              try container.encodeNil()
        }
    }
}

// MARK: - AnyCodable Value Accessors

extension AnyCodable {

    var boolValue: Bool? {
        if case .bool(let b) = self { return b }
        return nil
    }

    var doubleValue: Double? {
        if case .double(let d) = self { return d }
        return nil
    }

    var intValue: Int? {
        if case .int(let i) = self { return i }
        return nil
    }

    var stringValue: String? {
        if case .string(let s) = self { return s }
        return nil
    }

    var arrayValue: [AnyCodable]? {
        if case .array(let a) = self { return a }
        return nil
    }

    var dictionaryValue: [String: AnyCodable]? {
        if case .dictionary(let d) = self { return d }
        return nil
    }

    var isNull: Bool {
        if case .null = self { return true }
        return false
    }

    // MARK: - Convenience Accessors

    func asBool(default defaultValue: Bool = false) -> Bool {
        if let b = boolValue { return b }
        if let s = stringValue, s.lowercased() == "true" { return true }
        if let s = stringValue, s.lowercased() == "false" { return false }
        return defaultValue
    }

    func asPositiveDouble() -> Double? {
        if let d = doubleValue, d > 0 { return d }
        if let i = intValue, i > 0 { return Double(i) }
        if let s = stringValue, let d = Double(s), d > 0 { return d }
        return nil
    }

    func asInt(default defaultValue: Int? = nil) -> Int? {
        if let i = intValue { return i }
        if let d = doubleValue { return Int(d) }
        if let s = stringValue, let i = Int(s) { return i }
        return defaultValue
    }

    func asString(default defaultValue: String? = nil) -> String? {
        if let s = stringValue { return s }
        switch self {
        case .bool(let b):   return String(b)
        case .int(let i):    return String(i)
        case .double(let d): return String(d)
        default:             return defaultValue
        }
    }
}