// Services/Database/DatabaseRow.swift
struct DatabaseRow: Sendable {
    private let dict: [String: DatabaseValue]
    private let rowIndex: Int
    
    init(dict: [String: DatabaseValue], rowIndex: Int = 0) {
        self.dict = dict
        self.rowIndex = rowIndex
    }
    
    // Getters with proper error handling
    func string(_ key: String, default: String? = nil) throws -> String {
        guard let value = dict[key] else {
            if let defaultValue = `default` {
                return defaultValue
            }
            throw DatabaseError.missingColumn(key)
        }
        
        guard case let .text(str) = value else {
            throw DatabaseError.typeMismatch(
                column: key,
                expected: "String",
                got: describeType(value)
            )
        }
        return str
    }
    
    func int(_ key: String, default: Int? = nil) throws -> Int {
        guard let value = dict[key] else {
            if let defaultValue = `default` {
                return defaultValue
            }
            throw DatabaseError.missingColumn(key)
        }
        
        guard case let .integer(int) = value else {
            throw DatabaseError.typeMismatch(
                column: key,
                expected: "Int",
                got: describeType(value)
            )
        }
        return int
    }
    
    func double(_ key: String, default: Double? = nil) throws -> Double {
        guard let value = dict[key] else {
            if let defaultValue = `default` {
                return defaultValue
            }
            throw DatabaseError.missingColumn(key)
        }
        
        switch value {
        case .real(let dbl):
            return dbl
        case .integer(let int):
            return Double(int)  // Coerce integer to double
        default:
            throw DatabaseError.typeMismatch(
                column: key,
                expected: "Double",
                got: describeType(value)
            )
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
    
    func bool(_ key: String, default: Bool = false) throws -> Bool {
        guard let value = dict[key] else {
            return `default`
        }
        
        switch value {
        case .integer(let int):
            return int != 0
        case .text(let str):
            return str.lowercased() == "true" || str == "1"
        default:
            throw DatabaseError.typeMismatch(
                column: key,
                expected: "Bool",
                got: describeType(value)
            )
        }
    }
    
    func optional<T>(_ key: String, _ parser: (String) throws -> T) throws -> T? {
        guard let value = dict[key], case .null = value else {
            return nil
        }
        
        guard case let .text(str) = value else {
            return nil
        }
        
        return try parser(str)
    }
    
    // MARK: - Private
    
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