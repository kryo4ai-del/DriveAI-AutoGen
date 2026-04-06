import Foundation
import Combine

enum SyncStatus: Equatable {
    case idle
    case syncing
    case success(Date)
    case partialSuccess(Date, [String])
    case offline
    case error(Error)
    case conflict([String])

    var isSyncing: Bool {
        if case .syncing = self { return true }
        return false
    }

    var lastSyncTime: Date? {
        switch self {
        case .success(let date), .partialSuccess(let date, _): return date
        default: return nil
        }
    }
}
