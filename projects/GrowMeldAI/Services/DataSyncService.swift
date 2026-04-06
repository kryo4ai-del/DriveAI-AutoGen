import Foundation
import Combine

// MARK: - Supporting Types

struct PendingChange: Identifiable {
    let id: String
    let timestamp: Date
    let payload: [String: String]
}

struct RemoteChange: Identifiable {
    let id: String
    let timestamp: Date
    let payload: [String: String]
}

struct LocalVersion {
    let id: String
    let timestamp: Date
}

// MARK: - Sync Error

enum SyncError: LocalizedError {
    case uploadFailed(Error)
    case downloadFailed(Error)
    case mergeFailed(Error)

    var errorDescription: String? {
        switch self {
        case .uploadFailed(let error):
            return "Upload failed: \(error.localizedDescription)"
        case .downloadFailed(let error):
            return "Download failed: \(error.localizedDescription)"
        case .mergeFailed(let error):
            return "Merge failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Sync Status

enum SyncStatus {
    case idle
    case syncing
    case error(Error)
    case offline
}

// MARK: - Protocol Stubs

protocol LocalDataServiceProtocol {
    func saveOfflineChanges() throws
    func fetchPendingSync() throws -> [PendingChange]
    func markSynced(_ id: String) throws
    func fetchVersion(for id: String) throws -> LocalVersion
    func merge(_ change: RemoteChange) throws
}

protocol FirestoreServiceProtocol {
    func uploadProgress(_ change: PendingChange) async throws
    func fetchChanges(since date: Date?) async throws -> [RemoteChange]
}

protocol OfflineQueueManagerProtocol {
    func enqueue(changes: [PendingChange])
    func enqueueMergeConflict(_ change: RemoteChange)
}

protocol NetworkConnectivityMonitorProtocol {
    var isConnected: Bool { get }
}

// MARK: - Concrete Stubs

final class LocalDataService: LocalDataServiceProtocol {
    private let defaults = UserDefaults.standard
    private let pendingKey = "pendingChanges"
    private let syncedKey = "syncedIDs"

    func saveOfflineChanges() throws {}

    func fetchPendingSync() throws -> [PendingChange] {
        return []
    }

    func markSynced(_ id: String) throws {
        var synced = defaults.stringArray(forKey: syncedKey) ?? []
        synced.append(id)
        defaults.set(synced, forKey: syncedKey)
    }

    func fetchVersion(for id: String) throws -> LocalVersion {
        return LocalVersion(id: id, timestamp: Date.distantPast)
    }

    func merge(_ change: RemoteChange) throws {}
}

final class FirestoreService: FirestoreServiceProtocol {
    func uploadProgress(_ change: PendingChange) async throws {}

    func fetchChanges(since date: Date?) async throws -> [RemoteChange] {
        return []
    }
}

final class OfflineQueueManager: OfflineQueueManagerProtocol {
    private var queue: [PendingChange] = []
    private var conflictQueue: [RemoteChange] = []

    func enqueue(changes: [PendingChange]) {
        queue.append(contentsOf: changes)
    }

    func enqueueMergeConflict(_ change: RemoteChange) {
        conflictQueue.append(change)
    }
}

final class NetworkConnectivityMonitor: NetworkConnectivityMonitorProtocol {
    var isConnected: Bool {
        return true
    }
}

// MARK: - DataSyncService

@MainActor
final class DataSyncService: ObservableObject {
    let localDataService: LocalDataService
    let firestoreService: FirestoreService
    let offlineQueueManager: OfflineQueueManager
    let networkMonitor: NetworkConnectivityMonitor

    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncTime: Date?

    private let logger = Logger(category: "DataSyncService")

    init(
        localDataService: LocalDataService = LocalDataService(),
        firestoreService: FirestoreService = FirestoreService(),
        offlineQueueManager: OfflineQueueManager = OfflineQueueManager(),
        networkMonitor: NetworkConnectivityMonitor = NetworkConnectivityMonitor()
    ) {
        self.localDataService = localDataService
        self.firestoreService = firestoreService
        self.offlineQueueManager = offlineQueueManager
        self.networkMonitor = networkMonitor
    }

    func syncUserProgress() async throws {
        syncStatus = .syncing
        defer { syncStatus = .idle }

        guard networkMonitor.isConnected else {
            try localDataService.saveOfflineChanges()
            syncStatus = .offline
            return
        }

        var pendingChanges: [PendingChange] = []
        do {
            pendingChanges = try localDataService.fetchPendingSync()
            for change in pendingChanges {
                try await firestoreService.uploadProgress(change)
                try localDataService.markSynced(change.id)
            }
        } catch {
            offlineQueueManager.enqueue(changes: pendingChanges)
            throw SyncError.uploadFailed(error)
        }

        do {
            let remoteChanges = try await firestoreService.fetchChanges(since: lastSyncTime)
            try await mergeRemoteChanges(remoteChanges)
            lastSyncTime = Date()
        } catch {
            logger.warn("Failed to download remote changes: \(error.localizedDescription)")
        }
    }

    private func mergeRemoteChanges(_ changes: [RemoteChange]) async throws {
        for change in changes {
            do {
                let localVersion = try localDataService.fetchVersion(for: change.id)
                if localVersion.timestamp > change.timestamp {
                    logger.info("Conflict resolved: local version kept for \(change.id)")
                } else {
                    try localDataService.merge(change)
                }
            } catch {
                offlineQueueManager.enqueueMergeConflict(change)
            }
        }
    }
}

// MARK: - Logger Stub

private struct Logger {
    let category: String

    func info(_ message: String) {
        print("[INFO][\(category)] \(message)")
    }

    func warn(_ message: String) {
        print("[WARN][\(category)] \(message)")
    }

    func error(_ message: String) {
        print("[ERROR][\(category)] \(message)")
    }
}