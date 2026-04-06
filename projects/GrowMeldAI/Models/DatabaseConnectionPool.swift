import Foundation
import SQLite3

final class DatabaseConnectionPool: @unchecked Sendable {
    private let dbPath: String
    private let accessQueue = DispatchQueue(
        label: "com.driveai.db.pool",
        attributes: []
    )

    private var dbConnection: OpaquePointer?
    private var isInitialized = false

    init(databasePath: String) {
        self.dbPath = databasePath
    }

    func initialize() throws {
        try accessQueue.sync {
            guard !isInitialized else { return }

            var db: OpaquePointer?
            let result = sqlite3_open(dbPath, &db)

            guard result == SQLITE_OK, let openedDB = db else {
                if let openedDB = db {
                    sqlite3_close(openedDB)
                }
                throw DatabaseConnectionPoolError.connectionFailed
            }

            self.dbConnection = openedDB
            self.isInitialized = true
        }
    }

    func withConnection<T>(_ block: (OpaquePointer) throws -> T) throws -> T {
        return try accessQueue.sync {
            guard let db = dbConnection, isInitialized else {
                throw DatabaseConnectionPoolError.connectionFailed
            }
            return try block(db)
        }
    }

    deinit {
        if let db = dbConnection {
            sqlite3_close(db)
            dbConnection = nil
        }
    }
}

enum DatabaseConnectionPoolError: Error, LocalizedError {
    case connectionFailed
    case notInitialized

    var errorDescription: String? {
        switch self {
        case .connectionFailed:
            return "Failed to open SQLite database connection."
        case .notInitialized:
            return "Database connection pool has not been initialized."
        }
    }
}