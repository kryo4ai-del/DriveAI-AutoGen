import Foundation

enum DatabaseValue: Sendable {
    case null
    case integer(Int)
    case real(Double)
    case text(String)
    case blob(Data)
}

enum DatabaseError: Error, LocalizedError {
    case missingColumn(String)
    case typeMismatch(column: String, expected: String, got: String)
    case invalidUUID(String)
    case invalidDate(String)

    var errorDescription: String? {
        switch self {
        case .missingColumn(let col):
            return "Missing column: \(col)"
        case .typeMismatch(let col, let expected, let got):
            return "Type mismatch in column '\(col)': expected \(expected), got \(got)"
        case .invalidUUID(let str):
            return "Invalid UUID string: \(str)"
        case .invalidDate(let str):
            return "Invalid date string: \(str)"
        }
    }
}

struct DatabaseRow: Sendable {
    private let dict: [String: DatabaseValue]
    private let rowIndex: Int

    init(dict: [String: DatabaseValue], rowIndex: Int = 0) {
        self.dict = dict
        self.rowIndex = rowIndex
    }

    func string(_ key: String, default defaultValue: String? = nil) throws -> String {
        guard let value = dict[key] else {
            if let d = defaultValue { return d }
            throw DatabaseError.missingColumn(key)
        }
        guard case let .text(str) = value else {
            throw DatabaseError.typeMismatch(column: key, expected: "String", got: describeType(value))
        }
        return str
    }

    func int(_ key: String, default defaultValue: Int? = nil) throws -> Int {
        guard let value = dict[key] else {
            if let d = defaultValue { return d }
            throw DatabaseError.missingColumn(key)
        }
        guard case let .integer(int) = value else {
            throw DatabaseError.typeMismatch(column: key, expected: "Int", got: describeType(value))
        }
        return int
    }

    func double(_ key: String, default defaultValue: Double? = nil) throws -> Double {
        guard let value = dict[key] else {
            if let d = defaultValue { return d }
            throw DatabaseError.missingColumn(key)
        }
        switch value {
        case .real(let dbl):
            return dbl
        case .integer(let int):
            return Double(int)
        default:
            throw DatabaseError.typeMismatch(column: key, expected: "Double", got: describeType(value))
        }
    }

    func uuid(_ key: String) throws -> UUID {
        let str = try string(key)
        guard let id = UUID(uuidString: str) else {
            throw DatabaseError.invalidUUID(str)
        }
        return id
    }

    func date(_ key: String) throws -> Date {
        let str = try string(key)
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        guard let date = formatter.date(from: str) else {
            throw DatabaseError.invalidDate(str)
        }
        return date
    }

    func bool(_ key: String, default defaultValue: Bool = false) throws -> Bool {
        guard let value = dict[key] else {
            return defaultValue
        }
        switch value {
        case .integer(let int):
            return int != 0
        case .text(let str):
            return str.lowercased() == "true" || str == "1"
        default:
            throw DatabaseError.typeMismatch(column: key, expected: "Bool", got: describeType(value))
        }
    }

    func optional<T>(_ key: String, _ parser: (String) throws -> T) throws -> T? {
        guard let value = dict[key] else { return nil }
        if case .null = value { return nil }
        guard case let .text(str) = value else { return nil }
        return try parser(str)
    }

    private func describeType(_ value: DatabaseValue) -> String {
        switch value {
        case .null: return "null"
        case .integer: return "Int"
        case .real: return "Double"
        case .text: return "String"
        case .blob: return "Data"
        }
    }
}