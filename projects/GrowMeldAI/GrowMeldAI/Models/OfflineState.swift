import Foundation

struct OfflineState: Equatable {
    let isOffline: Bool
    let hasActiveSync: Bool
    let lastSyncTime: Date?
    let pendingOperations: Int
}

struct SyncStatus: Identifiable {
    let id: String
    let isInProgress: Bool
    let lastAttempt: Date?
    let nextRetry: Date?
}