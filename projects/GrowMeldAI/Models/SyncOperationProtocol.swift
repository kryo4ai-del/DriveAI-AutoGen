// Type-erased wrapper
protocol SyncOperationProtocol: Identifiable {
    var id: String { get }
    func execute() async throws
}

struct AnySyncOperation<T>: SyncOperationProtocol {
    let id: String
    let operation: () async throws -> T
    let onSuccess: (T) async -> Void
    
    func execute() async throws {
        let result = try await operation()
        await onSuccess(result)
    }
}

actor SyncQueue {
    private var operations: [AnyHashable: AnySyncOperation<Void>] = [:]
    
    func add<T>(_ id: String, operation: @escaping () async throws -> T) {
        let op = AnySyncOperation(
            id: id,
            operation: operation,
            onSuccess: { _ in }
        )
        operations[id] = op as? AnySyncOperation<Void>
    }
}