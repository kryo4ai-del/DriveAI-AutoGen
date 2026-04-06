import Foundation

@MainActor
class DataRecoveryService {
    private let dataService: AppDataService
    private let fileManager = FileManager.default
    private let dbPath: String

    init(dataService: AppDataService, dbPath: String = "") {
        self.dataService = dataService
        self.dbPath = dbPath.isEmpty ? Self.defaultDBPath() : dbPath
    }

    static func defaultDBPath() -> String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("driveai.db").path
    }

    // MARK: - Recovery Methods

    func recoverFromError(_ error: AppDataError) async -> Bool {
        switch error {
        case .databaseUnavailable:
            return await reinitializeDatabase()
        case .corruptedData:
            return await resetAndReload()
        case .concurrencyTimeout:
            return true
        default:
            return false
        }
    }

    private func reinitializeDatabase() async -> Bool {
        do {
            let dbURL = URL(fileURLWithPath: dbPath)
            if fileManager.fileExists(atPath: dbPath) {
                try fileManager.removeItem(at: dbURL)
            }
            try await dataService.verifyDatabaseIntegrity()
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
            try await dataService.verifyDatabaseIntegrity()
            return true
        } catch {
            return false
        }
    }
}

// MARK: - AppDataError

enum AppDataError: Error {
    case databaseUnavailable
    case corruptedData
    case concurrencyTimeout
    case unknown(Error)
}

// MARK: - AppDataService Protocol

protocol AppDataService {
    func verifyDatabaseIntegrity() async throws
}