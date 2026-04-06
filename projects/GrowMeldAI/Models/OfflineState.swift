import Foundation

struct OfflineState: Equatable {
    let isOffline: Bool
    let hasActiveSync: Bool
    let lastSyncTime: Date?
    let pendingOperations: Int
}

// Struct SyncStatus declared in Models/SyncStatus.swift
