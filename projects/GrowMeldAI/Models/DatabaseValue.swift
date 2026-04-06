// Services/Database/SQLiteConnection.swift
import SQLite3

actor SQLiteConnection: Sendable {
    private var dbPointer: OpaquePointer?
    private let dbPath: String
    private let logger: Logger
    
    init(dbPath: String = Self.defaultPath) async throws {
        self.dbPath = dbPath
        self.logger = Logger(subsystem: "com.driveai.memory", category: "database")
        try await openDatabase()
    }
    
    private func openDatabase() async throws {
        var pointer: OpaquePointer?
        let rc = sqlite3_open_v2(
            dbPath,
            &pointer,
            SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE,
            nil
        )
        
        guard rc == SQLITE_OK, let ptr = pointer else {
            throw DatabaseError.openFailed(reason: errmsg(pointer))
        }
        
        self.dbPointer = ptr
        sqlite3_busy_timeout(ptr, 5000)
        sqlite3_extended_result_codes(ptr, 1)
        
        // Enable WAL for better concurrency
        var statement: OpaquePointer?
        defer { sqlite3_finalize(statement) }
        sqlite3_prepare_v2(ptr, "PRAGMA journal_mode = WAL;", -1, &statement, nil)
        sqlite3_step(statement)
        
        logger.debug("Database opened: \(self.dbPath)")
    }
    
    // Type-safe execute (for INSERT/UPDATE/DELETE)
    func execute(_ sql: String, params: [DatabaseValue] = []) async throws {
        guard let db = dbPointer else { throw DatabaseError.closed }
        
        var statement: OpaquePointer?
        defer { sqlite3_finalize(statement) }
        
        let rc = sqlite3_prepare_v2(db, sql, -1, &statement, nil)
        guard rc == SQLITE_OK else {
            throw DatabaseError.prepareFailed(sql: sql, reason: errmsg(db))
        }
        
        try bind(statement, with: params)
        
        let stepRc = sqlite3_step(statement)
        guard stepRc == SQLITE_DONE else {
            throw DatabaseError.executionFailed(reason: errmsg(db))
        }
    }
    
    // Type-safe query (for SELECT)
    func query(_ sql: String, params: [DatabaseValue] = []) async throws -> [DatabaseRow] {
        guard let db = dbPointer else { throw DatabaseError.closed }
        
        var statement: OpaquePointer?
        defer { sqlite3_finalize(statement) }
        
        let rc = sqlite3_prepare_v2(db, sql, -1, &statement, nil)
        guard rc == SQLITE_OK else {
            throw DatabaseError.prepareFailed(sql: sql, reason: errmsg(db))
        }
        
        try bind(statement, with: params)
        
        var rows: [DatabaseRow] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            rows.append(extractRow(statement!))
        }
        
        return rows
    }
    
    // Transaction support
    func transaction<T>(_ block: @escaping () async throws -> T) async throws -> T {
        try await execute("BEGIN TRANSACTION")
        do {
            let result = try await block()
            try await execute("COMMIT")
            return result
        } catch {
            try? await execute("ROLLBACK")
            throw error
        }
    }
    
    // MARK: - Private Helpers
    
    private func bind(_ statement: OpaquePointer, with params: [DatabaseValue]) throws {
        for (index, param) in params.enumerated() {
            let bindIdx = Int32(index + 1)
            
            switch param {
            case .null:
                sqlite3_bind_null(statement, bindIdx)
            case .integer(let value):
                sqlite3_bind_int64(statement, bindIdx, Int64(value))
            case .real(let value):
                sqlite3_bind_double(statement, bindIdx, value)
            case .text(let value):
                sqlite3_bind_text(statement, bindIdx, value, -1, SQLITE_TRANSIENT)
            case .blob(let data):
                data.withUnsafeBytes { buffer in
                    sqlite3_bind_blob(statement, bindIdx, buffer.baseAddress, Int32(data.count), SQLITE_STATIC)
                }
            }
        }
    }
    
    private func extractRow(_ statement: OpaquePointer) -> DatabaseRow {
        let columnCount = sqlite3_column_count(statement)
        var dict: [String: DatabaseValue] = [:]
        
        for col in 0..<columnCount {
            let name = String(cString: sqlite3_column_name(statement, col))
            let value = extractValue(statement, columnIndex: col)
            dict[name] = value
        }
        
        return DatabaseRow(dict: dict)
    }
    
    private func extractValue(_ statement: OpaquePointer, columnIndex: Int32) -> DatabaseValue {
        let type = sqlite3_column_type(statement, columnIndex)
        
        switch type {
        case SQLITE_NULL:
            return .null
        case SQLITE_INTEGER:
            return .integer(Int(sqlite3_column_int64(statement, columnIndex)))
        case SQLITE_FLOAT:
            return .real(sqlite3_column_double(statement, columnIndex))
        case SQLITE_TEXT:
            let cStr = sqlite3_column_text(statement, columnIndex)
            return .text(String(cString: cStr!))
        case SQLITE_BLOB:
            let blob = sqlite3_column_blob(statement, columnIndex)
            let size = sqlite3_column_bytes(statement, columnIndex)
            return .blob(Data(bytes: blob!, count: Int(size)))
        default:
            return .null
        }
    }
    
    private func errmsg(_ db: OpaquePointer?) -> String {
        guard let db = db else { return "Unknown error" }
        return String(cString: sqlite3_errmsg(db))
    }
    
    static var defaultPath: String {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("driveai.db").path
    }
    
    deinit {
        if let db = dbPointer {
            sqlite3_close(db)
        }
    }
}

enum DatabaseValue: Sendable {
    case null
    case integer(Int)
    case real(Double)
    case text(String)
    case blob(Data)
}

enum DatabaseError: LocalizedError {
    case closed
    case openFailed(reason: String)
    case prepareFailed(sql: String, reason: String)
    case executionFailed(reason: String)
    case typeMismatch(column: String, expected: String, got: String)
    case missingColumn(String)
    case invalidUUID(String)
    case invalidDate(String)
    
    var errorDescription: String? {
        switch self {
        case .closed:
            return "Database connection is closed"
        case .openFailed(let reason):
            return "Failed to open database: \(reason)"
        case .prepareFailed(let sql, let reason):
            return "Failed to prepare statement: \(reason)\n\(sql)"
        case .executionFailed(let reason):
            return "Query execution failed: \(reason)"
        case .typeMismatch(let col, let expected, let got):
            return "Column '\(col)' expected \(expected), got \(got)"
        case .missingColumn(let col):
            return "Missing required column: \(col)"
        case .invalidUUID(let str):
            return "Invalid UUID format: \(str)"
        case .invalidDate(let str):
            return "Invalid date format: \(str)"
        }
    }
}