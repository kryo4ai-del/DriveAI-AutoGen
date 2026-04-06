// MARK: - DataSyncService.swift
// Orchestrates bidirectional sync: local ↔ Firebase

@MainActor
class DataSyncService {
    let localDataService: LocalDataService
    let firestoreService: FirestoreService
    let offlineQueueManager: OfflineQueueManager
    let networkMonitor: NetworkConnectivityMonitor
    
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncTime: Date?
    
    func syncUserProgress() async throws {
        syncStatus = .syncing
        defer { syncStatus = .idle }
        
        // 1. Check network connectivity
        guard networkMonitor.isConnected else {
            // Queue changes locally; return without error (offline is OK)
            try localDataService.saveOfflineChanges()
            return
        }
        
        // 2. Upload pending changes (optimistic updates already in local DB)
        do {
            let pendingChanges = try localDataService.fetchPendingSync()
            for change in pendingChanges {
                try await firestoreService.uploadProgress(change)
                try localDataService.markSynced(change.id)
            }
        } catch {
            // Conflict or network error; don't fail—queue for retry
            offlineQueueManager.enqueue(change: pendingChanges)
            throw SyncError.uploadFailed(error)
        }
        
        // 3. Download remote changes (idempotent)
        do {
            let remoteChanges = try await firestoreService.fetchChanges(
                since: lastSyncTime
            )
            try await mergeRemoteChanges(remoteChanges)
            lastSyncTime = Date()
        } catch {
            // Don't fail sync if download fails; local data is source of truth
            logger.warn("Failed to download remote changes: \(error)")
        }
    }
    
    private func mergeRemoteChanges(_ changes: [RemoteChange]) async throws {
        for change in changes {
            do {
                // Conflict detection: check if local version is newer
                let localVersion = try localDataService.fetchVersion(for: change.id)
                
                if localVersion.timestamp > change.timestamp {
                    // Local is newer; keep local (user's device is authoritative)
                    logger.info("Conflict resolved: local version kept for \(change.id)")
                } else {
                    // Remote is newer; merge
                    try localDataService.merge(change)
                }
            } catch {
                // If merge fails, queue for manual resolution
                offlineQueueManager.enqueueMergeConflict(change)
            }
        }
    }
}

enum SyncStatus {
    case idle
    case syncing
    case error(Error)
    case offline
}