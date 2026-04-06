import Foundation

@MainActor
class DataRecoveryService {
    private let dataService: LocalDataService
    private let fileManager = FileManager.default
    private let dbPath: String
    
    init(dataService: LocalDataService, dbPath: String = "") {
        self.dataService = dataService
        self.dbPath = dbPath.isEmpty ? Self.defaultDBPath() : dbPath
    }
    
    static func defaultDBPath() -> String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("driveai.db").path
    }
    
    // MARK: - Recovery Methods
    
    func recoverFromError(_ error: DataError) async -> Bool {
        switch error {
        case .databaseUnavailable:
            return await reinitializeDatabase()
        case .corruptedData:
            return await resetAndReload()
        case .concurrencyTimeout:
            return true // Transient, user should retry
        default:
            return false
        }
    }
    
    private func reinitializeDatabase() async -> Bool {
        do {
            // Attempt to close current connection
            if let service = dataService as? SQLiteDataService {
                // Graceful shutdown (implementation in SQLiteDataService)
                try await service.closeConnection()
            }
            
            // Recreate database
            sleep(1) // Brief delay for file system
            let dbURL = URL(fileURLWithPath: dbPath)
            if fileManager.fileExists(atPath: dbPath) {
                try fileManager.removeItem(at: dbURL)
            }
            
            // Reinitialize
            _ = try await dataService.verifyDatabaseIntegrity()
            return true
        } catch {
            return false
        }
    }
    
    private func resetAndReload() async -> Bool {
        do {
            // Delete database file
            let dbURL = URL(fileURLWithPath: dbPath)
            if fileManager.fileExists(atPath: dbPath) {
                try fileManager.removeItem(at: dbURL)
            }
            
            // Reinitialize from bundled data
            _ = try await dataService.verifyDatabaseIntegrity()
            
            // Reload all questions from bundle
            if let bundledQuestionsURL = Bundle.main.url(forResource: "questions", withExtension: "json") {
                let data = try Data(contentsOf: bundledQuestionsURL)
                let decoder = JSONDecoder()
                let questions = try decoder.decode([Question].self, from: data)
                // TODO: Batch insert questions
                _ = questions
            }
            
            return true
        } catch {
            return false
        }
    }
}