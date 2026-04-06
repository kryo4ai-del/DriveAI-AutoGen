// Services/Data/SQLiteDatabase.swift
import Foundation
import SQLite3

final class SQLiteDatabase: Sendable {
    private let dbPath: String
    private let dbQueue = DispatchQueue(label: "com.driveai.db", qos: .userInitiated)
    private var db: OpaquePointer?
    private var isInitialized = false

    init(dbPath: String) {
        self.dbPath = dbPath
    }

    deinit {
        closeDatabase()
    }

    func initialize() throws {
        guard !isInitialized else { return }

        dbQueue.sync(flags: .barrier) {
            let fileManager = FileManager.default
            let exists = fileManager.fileExists(atPath: dbPath)

            if sqlite3_open(dbPath, &db) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db))
                throw DriveAIError.databaseUnavailable(reason: errmsg)
            }

            if !exists {
                try createSchema()
                try seedInitialData()
            }

            isInitialized = true
        }
    }

    func closeDatabase() {
        dbQueue.sync(flags: .barrier) {
            if let db = db {
                sqlite3_close(db)
                self.db = nil
            }
            isInitialized = false
        }
    }

    func execute(_ sql: String, parameters: [Any]? = nil) throws {
        try dbQueue.sync {
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }

            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db))
                throw DriveAIError.databaseError(reason: errmsg)
            }

            try bindParameters(stmt, parameters)
            try executePreparedStatement(stmt)
        }
    }

    func query(_ sql: String, parameters: [Any]? = nil) throws -> [[String: Any]] {
        return try dbQueue.sync {
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }

            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db))
                throw DriveAIError.databaseError(reason: errmsg)
            }

            try bindParameters(stmt, parameters)
            return try fetchResults(stmt)
        }
    }

    private func createSchema() throws {
        let schema = """
        CREATE TABLE IF NOT EXISTS questions (
            id INTEGER PRIMARY KEY,
            categoryId INTEGER NOT NULL,
            text TEXT NOT NULL,
            options TEXT NOT NULL,
            correctAnswerIndex INTEGER NOT NULL,
            explanation TEXT NOT NULL,
            imageUrl TEXT,
            difficulty TEXT NOT NULL,
            lastUpdated INTEGER NOT NULL
        );

        CREATE TABLE IF NOT EXISTS categories (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            iconName TEXT NOT NULL,
            questionCount INTEGER NOT NULL
        );

        CREATE TABLE IF NOT EXISTS userProgress (
            userId TEXT NOT NULL,
            categoryId INTEGER NOT NULL,
            correctCount INTEGER NOT NULL DEFAULT 0,
            totalAttempts INTEGER NOT NULL DEFAULT 0,
            lastAttemptDate INTEGER NOT NULL DEFAULT 0,
            PRIMARY KEY (userId, categoryId)
        );

        CREATE TABLE IF NOT EXISTS syncMetadata (
            lastSyncDate INTEGER NOT NULL,
            catalogVersion TEXT NOT NULL,
            questionCountHash TEXT NOT NULL,
            PRIMARY KEY (catalogVersion)
        );
        """

        try execute(schema)
    }

    private func seedInitialData() throws {
        guard let seedURL = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            throw DriveAIError.fileNotFound(filename: "questions.json")
        }

        let seedData = try Data(contentsOf: seedURL)
        let decoder = JSONDecoder()
        let seedQuestions = try decoder.decode([QuestionEntity].self, from: seedData)

        for entity in seedQuestions {
            try insertQuestion(entity)
        }
    }

    private func insertQuestion(_ entity: QuestionEntity) throws {
        let query = """
        INSERT OR REPLACE INTO questions
        (id, categoryId, text, options, correctAnswerIndex, explanation, imageUrl, difficulty, lastUpdated)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """

        let optionsData = try JSONEncoder().encode(entity.options)
        let optionsString = String(data: optionsData, encoding: .utf8) ?? "[]"

        try execute(query, parameters: [
            entity.id,
            entity.categoryId,
            entity.text,
            optionsString,
            entity.correctAnswerIndex,
            entity.explanation,
            entity.imageUrl,
            entity.difficulty,
            entity.lastUpdated
        ])
    }

    private func bindParameters(_ stmt: OpaquePointer?, _ parameters: [Any]?) throws {
        guard let parameters = parameters else { return }

        for (index, param) in parameters.enumerated() {
            let idx = Int32(index + 1)
            switch param {
            case let value as Int:
                sqlite3_bind_int(stmt, idx, Int32(value))
            case let value as String:
                sqlite3_bind_text(stmt, idx, value, -1, SQLITE_TRANSIENT)
            case let value as Double:
                sqlite3_bind_double(stmt, idx, value)
            case let value as Bool:
                sqlite3_bind_int(stmt, idx, value ? 1 : 0)
            case let value as Data:
                value.withUnsafeBytes { bytes in
                    sqlite3_bind_blob(stmt, idx, bytes.baseAddress, Int32(value.count), SQLITE_TRANSIENT)
                }
            default:
                throw DriveAIError.invalidData(field: "Parameter at index \(index)")
            }
        }
    }

    private func executePreparedStatement(_ stmt: OpaquePointer?) throws {
        let result = sqlite3_step(stmt)
        if result != SQLITE_DONE && result != SQLITE_ROW {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw DriveAIError.databaseError(reason: errmsg)
        }
    }

    private func fetchResults(_ stmt: OpaquePointer?) throws -> [[String: Any]] {
        var results = [[String: Any]]()

        while sqlite3_step(stmt) == SQLITE_ROW {
            let columnCount = Int(sqlite3_column_count(stmt))
            var row = [String: Any]()

            for i in 0..<columnCount {
                let columnName = String(cString: sqlite3_column_name(stmt, i))
                let type = sqlite3_column_type(stmt, i)

                switch type {
                case SQLITE_INTEGER:
                    row[columnName] = Int(sqlite3_column_int(stmt, i))
                case SQLITE_FLOAT:
                    row[columnName] = Double(sqlite3_column_double(stmt, i))
                case SQLITE_TEXT:
                    if let text = sqlite3_column_text(stmt, i) {
                        row[columnName] = String(cString: text)
                    }
                case SQLITE_BLOB:
                    if let blob = sqlite3_column_blob(stmt, i) {
                        let size = Int(sqlite3_column_bytes(stmt, i))
                        row[columnName] = Data(bytes: blob, count: size)
                    }
                case SQLITE_NULL:
                    row[columnName] = nil
                default:
                    row[columnName] = nil
                }
            }

            results.append(row)
        }

        return results
    }
}