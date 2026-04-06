// ❌ CURRENT (MISSING OFFLINE QUEUE)
class SyncManager {
    private var pendingOperations: [SyncOperation] = []  // In-memory! Lost on restart
    
    func syncProgress() async throws {
        if !NetworkMonitor.isOnline {
            pendingOperations.append(SyncOperation(...))  // Will be lost if app crashes!
        }
    }
}

// ✅ REQUIRED (Persistent offline queue)
actor PersistentSyncQueue {
    private let db: LocalDatabase
    
    init(database: LocalDatabase) {
        self.db = database
    }
    
    func enqueue(_ operation: SyncOperation) async throws {
        // Persist to SQLite with transaction
        try await db.execute("""
            INSERT INTO sync_queue (id, operation, createdAt, status)
            VALUES (?, ?, ?, 'pending')
        """, parameters: [UUID().uuidString, operation.encoded(), Date()])
    }
    
    func dequeue() async throws -> [SyncOperation] {
        // Fetch all pending operations
        let operations = try await db.fetch(SyncOperation.self, where: "status = ?", ["pending"])
        return operations
    }
    
    func markSuccess(_ operationId: String) async throws {
        try await db.execute("""
            UPDATE sync_queue SET status = 'completed', completedAt = ?
            WHERE id = ?
        """, parameters: [Date(), operationId])
    }
    
    func markFailure(_ operationId: String, error: String) async throws {
        try await db.execute("""
            UPDATE sync_queue SET status = 'failed', error = ?, failedAt = ?
            WHERE id = ?
        """, parameters: [error, Date(), operationId])
    }
}

// Usage:
@MainActor
class SyncManager {
    private let queue: PersistentSyncQueue
    
    func syncPending() async throws {
        let operations = try await queue.dequeue()
        
        for operation in operations {
            do {
                try await executeSyncOperation(operation)
                try await queue.markSuccess(operation.id)
            } catch {
                try await queue.markFailure(operation.id, error: error.localizedDescription)
            }
        }
    }
}