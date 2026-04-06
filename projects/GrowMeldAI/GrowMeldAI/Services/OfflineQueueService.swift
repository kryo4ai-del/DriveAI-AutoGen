import Foundation
import Combine

final class OfflineQueueService: ObservableObject {
    static let shared = OfflineQueueService()

    @Published private(set) var queuedBackups: [BackupQueueItem] = []
    private let fileManager = FileManager.default
    private let queueDirectory: URL

    private init() {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        queueDirectory = documentsURL.appendingPathComponent("BackupQueue", isDirectory: true)

        try? fileManager.createDirectory(at: queueDirectory, withIntermediateDirectories: true)
        loadQueuedBackups()
    }

    func queueBackupForRetry(_ backup: ProgressSnapshot) {
        let item = BackupQueueItem(backup: backup, timestamp: Date())
        queuedBackups.append(item)
        saveQueuedBackups()
    }

    func processQueue() {
        guard NetworkMonitorService.shared.isConnected else { return }

        for item in queuedBackups {
            Task {
                do {
                    try await CloudKitService().uploadProgress(item.backup)
                    removeQueuedBackup(item)
                } catch {
                    // Exponential backoff
                    if item.retryCount >= 3 {
                        removeQueuedBackup(item)
                    } else {
                        updateQueuedBackup(item.incrementRetry())
                    }
                }
            }
        }
    }

    func clearQueue() {
        queuedBackups.removeAll()
        saveQueuedBackups()
    }

    private func saveQueuedBackups() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let data = try? encoder.encode(queuedBackups)
        fileManager.createFile(atPath: queueDirectory.appendingPathComponent("queue.json").path,
                              contents: data)
    }

    private func loadQueuedBackups() {
        let fileURL = queueDirectory.appendingPathComponent("queue.json")
        guard let data = fileManager.contents(atPath: fileURL.path) else { return }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        queuedBackups = (try? decoder.decode([BackupQueueItem].self, from: data)) ?? []
    }

    private func removeQueuedBackup(_ item: BackupQueueItem) {
        queuedBackups.removeAll { $0.id == item.id }
        saveQueuedBackups()
    }

    private func updateQueuedBackup(_ item: BackupQueueItem) {
        if let index = queuedBackups.firstIndex(where: { $0.id == item.id }) {
            queuedBackups[index] = item
            saveQueuedBackups()
        }
    }
}

struct BackupQueueItem: Codable, Identifiable {
    let id = UUID()
    let backup: ProgressSnapshot
    let timestamp: Date
    var retryCount: Int = 0

    func incrementRetry() -> BackupQueueItem {
        var newItem = self
        newItem.retryCount += 1
        return newItem
    }
}