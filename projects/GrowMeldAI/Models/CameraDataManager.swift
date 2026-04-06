import Foundation

@MainActor
final class CameraDataManager {
    private let imageDirectoryName = "CameraImages"

    private var imageDirectoryURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(imageDirectoryName)
    }

    func deleteCameraDataForUser(_ userID: String) async throws {
        let fm = FileManager.default
        let userDir = imageDirectoryURL.appendingPathComponent(userID)
        if fm.fileExists(atPath: userDir.path) {
            try fm.removeItem(at: userDir)
        }
        deleteProcessingLogs(for: userID)
    }

    private func deleteProcessingLogs(for userID: String) {
        let key = "processingLogs_\(userID)"
        UserDefaults.standard.removeObject(forKey: key)
    }
}