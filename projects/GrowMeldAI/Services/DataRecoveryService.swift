import Foundation

enum DataError: LocalizedError {
    case databaseUnavailable
    case corruptedData
    case concurrencyTimeout
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .databaseUnavailable:
            return "Database is unavailable."
        case .corruptedData:
            return "Data is corrupted."
        case .concurrencyTimeout:
            return "Concurrency timeout occurred."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

protocol LocalDataService: AnyObject {
    func verifyDatabaseIntegrity() async throws -> Bool
}

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
            return true
        case .unknown:
            return false
        }
    }

    private func reinitializeDatabase() async -> Bool {
        do {
            let dbURL = URL(fileURLWithPath: dbPath)
            if fileManager.fileExists(atPath: dbPath) {
                try fileManager.removeItem(at: dbURL)
            }
            _ = try await dataService.verifyDatabaseIntegrity()
            return true
        } catch {
            return false
        }
    }

    private func resetAndReload() async -> Bool {
        do {
            let dbURL = URL(fileURLWithPath: dbPath)
            if fileManager.fileExists(atPath: dbPath) {
                try fileManager.removeItem(at: dbURL)
            }
            _ = try await dataService.verifyDatabaseIntegrity()
            return true
        } catch {
            return false
        }
    }
}