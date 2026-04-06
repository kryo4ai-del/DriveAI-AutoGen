import Foundation

@MainActor
final class CameraDataManager {
    private let imageDirectoryName = "CameraImages"

    private var imageDirectory: String {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(imageDirectoryName).path
    }

    func deleteCameraDataForUser(_ userID: String) async throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: imageDirectory) {
            try fileManager.removeItem(atPath: imageDirectory)
        }
        let logsKey = "camera_logs_\(userID)"
        UserDefaults.standard.removeObject(forKey: logsKey)
    }
}