import Foundation
import SQLite3

enum DatabaseError: LocalizedError {
    case cannotOpenDatabase(String)
    case setupFailed(String)

    var errorDescription: String? {
        switch self {
        case .cannotOpenDatabase(let path):
            return "Cannot open database at path: \(path)"
        case .setupFailed(let reason):
            return "Database setup failed: \(reason)"
        }
    }
}

final class DatabaseManager {
    static let shared = DatabaseManager.makeShared()

    private static func makeShared() -> DatabaseManager {
        let manager = DatabaseManager()
        do {
            try manager.setupDatabase()
        } catch {
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
        var db: OpaquePointer?
        let result = sqlite3_open_v2(
            dbPath,
            &db,
            SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE,
            nil
        )
        guard result == SQLITE_OK else {
            throw DatabaseError.cannotOpenDatabase(dbPath)
        }
        defer { sqlite3_close(db) }
        isSetUp = true
    }
}