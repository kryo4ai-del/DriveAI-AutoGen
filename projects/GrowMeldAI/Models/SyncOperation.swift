actor SyncQueue {
    private let localCache: LocalDataService
    private var pendingOperations: [SyncOperation] = []
    
    @Published private(set) var syncStatus: SyncStatus = .idle
    @Published private(set) var pendingCount: Int = 0
    
    func enqueue(_ operation: SyncOperation) throws
    func flush(firestore: FirestoreService) async throws
    func isPending(forDocumentID: String, in collection: String) -> Bool
}

struct SyncOperation: Codable, Identifiable {
    let id: String
    let collection: String
    let documentID: String
    let operationType: SyncOperationType
    let data: [String: AnyCodable]?
    let timestamp: Date
}