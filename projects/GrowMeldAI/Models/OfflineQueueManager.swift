// Services/Firestore/OfflineQueueManager.swift
final class OfflineQueueManager {
    private let fileURL: URL
    private var queue: [PendingWrite] = []
    
    struct PendingWrite: Codable {
        let id: UUID
        let operation: WriteOperation  // .create, .update, .delete
        let collection: String
        let documentId: String
        let data: [String: AnyCodable]
        let createdAt: Date
    }
    
    func enqueue(_ write: PendingWrite) throws {
        queue.append(write)
        try persist()  // Write to disk immediately
    }
    
    func flushQueue(service: FirestoreServiceProtocol) async throws -> [UUID] {
        var flushedIds: [UUID] = []
        for write in queue {
            try await execute(write, service: service)
            flushedIds.append(write.id)
        }
        queue.removeAll { flushedIds.contains($0.id) }
        try persist()
        return flushedIds
    }
}