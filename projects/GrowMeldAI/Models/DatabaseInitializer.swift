final class DatabaseInitializer: Sendable {
    private let dbPath: String
    private let initLock = NSLock()
    private var db: OpaquePointer?
    private var isInitialized = false
    
    func initializeDatabase() throws {
        try initLock.withLock {
            guard !isInitialized else { return }
            
            guard sqlite3_open(dbPath.cString(using: .utf8), &db) == SQLITE_OK else {
                throw DriveAIError.databaseUnavailable
            }
            
            try createSchema()
            try seedInitialData()
            isInitialized = true
        }
    }
    
    deinit {
        try? initLock.withLock {
            if let db = db {
                sqlite3_close(db)
            }
        }
    }
}