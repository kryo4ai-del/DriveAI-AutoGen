final class DatabaseManager {
    static let shared = DatabaseManager.makeShared()
    
    private static func makeShared() -> DatabaseManager {
        // Explicit single initialization point
        let manager = DatabaseManager()
        do {
            try manager.setupDatabase()
        } catch {
            // Log critical error but continue with degraded state
            print("⚠️ Warning: DatabaseManager schema setup failed: \(error)")
            print("   Attempting to continue with existing database...")
        }
        return manager
    }
    
    private let dbPath: String
    private let queue = DispatchQueue(label: "com.driveai.db", attributes: .concurrent)
    private var isSetUp = false
    
    init() {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].path
        self.dbPath = documentsPath + "/driveai.db"
    }
    
    private func setupDatabase() throws {
        guard let db = sqlite3_open_v2(
            dbPath,
            nil,
            SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE,
            nil
        ) == SQLITE_OK else {
            throw DatabaseError.cannotOpenDatabase(dbPath)
        }
        
        defer { sqlite3_close(db) }
        isSetUp = true
    }
}