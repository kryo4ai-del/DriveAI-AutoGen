import Foundation

final class CloudKitService {
    func uploadProgress(_ data: ProgressSnapshot) async throws {
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(data)
        let url = getLocalStorageURL()
        try encoded.write(to: url)
    }

    func downloadLatestProgress() async throws -> ProgressSnapshot? {
        let url = getLocalStorageURL()
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(ProgressSnapshot.self, from: data)
    }

    func syncOnChange() {
        // No-op: local file sync does not require observation
    }

    func handleConflicts() {
        // No-op: last-write-wins strategy
    }

    private func getLocalStorageURL() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("progress_snapshot.json")
    }
}