// ✅ Type-erased operation wrapper
protocol SyncableOperation {
    associatedtype Output
    func execute() async throws -> Output
}

struct AnySyncOperation {
    let id: String
    let execute: () async throws -> Void
    let onSuccess: (() async -> Void)?
    let onFailure: ((Error) async -> Void)?
}

extension AnySyncOperation {
    init<T>(
        id: String,
        operation: @escaping () async throws -> T,
        onSuccess: @escaping (T) async -> Void = { _ in },
        onFailure: @escaping (Error) async -> Void = { _ in }
    ) {
        self.id = id
        self.execute = {
            do {
                let result = try await operation()
                await onSuccess(result)
            } catch {
                await onFailure(error)
            }
        }
        self.onSuccess = nil  // Captured in execute closure
        self.onFailure = nil
    }
}

actor SyncQueue {
    private var operations: [String: AnySyncOperation] = [:]
    
    func add<T>(
        id: String,
        operation: @escaping () async throws -> T,
        onSuccess: @escaping (T) async -> Void = { _ in }
    ) {
        let syncOp = AnySyncOperation(
            id: id,
            operation: operation,
            onSuccess: onSuccess
        )
        operations[id] = syncOp
    }
    
    func processAll() async -> (succeeded: Int, failed: Int) {
        var succeeded = 0
        var failed = 0
        
        for (id, operation) in operations {
            do {
                try await operation.execute()
                succeeded += 1
            } catch {
                failed += 1
                logger.log(.error, "Sync failed: \(id). Error: \(error)")
            }
        }
        
        operations.removeAll()
        return (succeeded, failed)
    }
}

// Usage:
await syncQueue.add(
    id: "sync-exam-score",
    operation: { try await api.submitScore(92) },
    onSuccess: { newScore in
        await examViewModel.updateScore(newScore)
    }
)