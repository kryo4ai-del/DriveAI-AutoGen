import Foundation

@MainActor
final class DataStore {
    static let shared = DataStore()

    private let userDefaultsKey = "DataStore_UserData"

    private init() {}

    // MARK: - DSGVO Article 17: Complete Erasure
    nonisolated func deleteAllUserData(userId: UUID) async throws {
        let key = "user_\(userId.uuidString)"
        await MainActor.run {
            UserDefaults.standard.removeObject(forKey: key)
            UserDefaults.standard.removeObject(forKey: "quiz_progress_\(userId.uuidString)")
            UserDefaults.standard.synchronize()
        }

        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let userDir = docs.appendingPathComponent(userId.uuidString)
        if FileManager.default.fileExists(atPath: userDir.path) {
            try FileManager.default.removeItem(at: userDir)
        }
    }
}