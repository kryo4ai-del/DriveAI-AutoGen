struct PerformanceSyncRecord: Codable, Identifiable {
    let id: UUID
    let performanceMetric: PerformanceMetric
    var syncStatus: SyncStatus = .pending
    var retryCount: Int = 0
    var lastSyncAttempt: Date?
    let createdAt: Date
    
    enum SyncStatus: String, Codable {
        case pending, synced, failed
    }
    
    mutating func recordSyncAttempt(successful: Bool) {
        lastSyncAttempt = Date()
        
        if successful {
            syncStatus = .synced
            retryCount = 0
        } else {
            retryCount += 1
            if retryCount >= 3 {
                syncStatus = .failed
            }
        }
    }
}