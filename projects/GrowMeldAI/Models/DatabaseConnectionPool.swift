import SQLite3
import Foundation

/// Thread-safe, single-connection pool for SQLite
final class DatabaseConnectionPool: Sendable {
    private let dbPath: String
    private let accessQueue = DispatchQueue(
        label: "com.driveai.db.pool",
        attributes: []  // Serial queue
    )
    
    private var dbConnection: OpaquePointer?
    private var isInitialized = false
    
    init(databasePath: String) {
        self.dbPath = databasePath
    }
    
    /// Initialize the connection pool (call once at app startup)
    func initialize() throws {
        try accessQueue.sync {
            guard !isInitialized else { return }
            
            var db: OpaquePointer?
            
            guard sqlite3_open(dbPath.cString(using: .utf8), &db) == SQLITE_OK else {
                throw DriveAIError.databaseUnavailable
            }
            
            guard let db = db else {
                throw DriveAIError.databaseUnavailable
            }
            
            // Apply optimal settings before any operations
            try DatabaseConfiguration.applyOptimalSettings(to: db)
            
            self.dbConnection = db
            self.isInitialized = true
        }
    }
    
    /// Execute a closure with exclusive access to the database connection
    /// - Warning: Never call sqlite3_close on the connection; pool manages lifetime
    func withConnection<T>(_ block: (OpaquePointer) throws -> T) throws -> T {
        return try accessQueue.sync {
            guard let db = dbConnection, isInitialized else {
                throw DriveAIError.databaseUnavailable
            }
            
            return try block(db)
        }
    }
    
    deinit {
        // Safe to call: serial queue guarantees single thread
        if let db = dbConnection {
            sqlite3_close(db)
            dbConnection = nil
        }
    }
}