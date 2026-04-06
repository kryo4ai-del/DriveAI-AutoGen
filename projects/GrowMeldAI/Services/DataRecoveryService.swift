import Foundation

@MainActor
class DataRecoveryService {
    private let fileManager = FileManager.default
    private let dbPath: String

    init(dbPath: String = "") {
        self.dbPath = dbPath.isEmpty ? Self.defaultDBPath() : dbPath
    }

    static func defaultDBPath() -> String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("driveai.db").path
    }

    func recoverFromError(_ error: Error) async -> Bool {
        // Attempt basic recovery
        return await resetAndReload()
    }

    private func resetAndReload() async -> Bool {
        do {
            let dbURL = URL(fileURLWithPath: dbPath)
            if fileManager.fileExists(atPath: dbPath) {
                try fileManager.removeItem(at: dbURL)
            }
            return true
        } catch {
            return false
        }
    }
}
