protocol BatchWriteOperation {
    var collection: String { get }
    var documentID: String { get }
    func execute(on batch: WriteBatch) throws
}

struct SetBatchOperation<T: Encodable>: BatchWriteOperation {
    let collection: String
    let documentID: String
    let data: T
    let merge: Bool
    
    func execute(on batch: WriteBatch) throws {
        let ref = Firestore.firestore().collection(collection).document(documentID)
        do {
            let encoded = try Firestore.Encoder().encode(data)
            batch.setData(encoded, forDocument: ref, merge: merge)
        } catch {
            throw FirestoreError.encodingFailed(underlying: error)
        }
    }
}

struct UpdateBatchOperation: BatchWriteOperation {
    let collection: String
    let documentID: String
    let fields: [String: Any]
    
    func execute(on batch: WriteBatch) throws {
        let ref = Firestore.firestore().collection(collection).document(documentID)
        batch.updateData(fields, forDocument: ref)
    }
}

struct DeleteBatchOperation: BatchWriteOperation {
    let collection: String
    let documentID: String
    
    func execute(on batch: WriteBatch) throws {
        let ref = Firestore.firestore().collection(collection).document(documentID)
        batch.deleteDocument(ref)
    }
}

func batchWrite(_ operations: [BatchWriteOperation]) async throws {
    let batch = db.batch()
    
    for operation in operations {
        try operation.execute(on: batch)
    }
    
    try await batch.commit()
    healthMonitor.recordSuccess()
}

// Usage
let ops: [BatchWriteOperation] = [
    SetBatchOperation(collection: "users", documentID: uid, data: userProfile, merge: true),
    DeleteBatchOperation(collection: "progress", documentID: oldProgressID)
]

try await service.batchWrite(ops)