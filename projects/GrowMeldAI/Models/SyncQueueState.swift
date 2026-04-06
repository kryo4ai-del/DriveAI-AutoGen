// SyncQueueState.swift
import Foundation

enum SyncQueueState: Equatable {
    case idle(pendingCount: Int)
    case syncing(currentIndex: Int, totalCount: Int, currentSubmissionID: UUID)
    case succeeded(syncedCount: Int)
    case failed(error: CloudFunctionError, failedCount: Int)

    var pendingCount: Int {
        if case .idle(let count) = self {
            return count
        }
        return 0
    }

    var isSyncing: Bool {
        if case .syncing = self { return true }
        return false
    }
}