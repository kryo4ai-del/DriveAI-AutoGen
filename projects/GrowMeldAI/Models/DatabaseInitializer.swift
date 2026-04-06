import Foundation

final class DatabaseInitializer: @unchecked Sendable {
    private let dbPath: String
    private let initLock = NSLock()
    private var isInitialized = false

    init(dbPath: String) {
        self.dbPath = dbPath
    }

    func initializeDatabase() throws {
        initLock.lock()
        defer { initLock.unlock() }
        guard !isInitialized else { return }
        try createSchema()
        try seedInitialData()
        isInitialized = true
    }

    private func createSchema() throws {
        let schemaKey = "com.growmeldai.db.schemaCreated"
        UserDefaults.standard.set(true, forKey: schemaKey)
    }

    private func seedInitialData() throws {
        let seedKey = "com.growmeldai.db.seeded"
        UserDefaults.standard.set(true, forKey: seedKey)
    }
}