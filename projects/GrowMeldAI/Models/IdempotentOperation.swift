// Models/Domain/Idempotent.swift
protocol IdempotentOperation {
    var idempotencyKey: String { get }
}

// Models/Domain/QuestionAnswer.swift

// Services/Firestore/IdempotencyCache.swift
@MainActor
class IdempotencyCache {
    private var processedKeys: Set<String> = []
    private let maxCacheSize = 1000
    
    func isProcessed(_ key: String) -> Bool {
        processedKeys.contains(key)
    }
    
    func markProcessed(_ key: String) {
        processedKeys.insert(key)
        
        // Prevent unbounded growth
        if processedKeys.count > maxCacheSize {
            processedKeys.removeAll()
        }
    }
    
    func reset() {
        processedKeys.removeAll()
    }
}

// Services/Firestore/FirestoreService+Idempotent.swift
extension FirestoreService {
    func submitAnswerIdempotent(_ answer: QuestionAnswer) async throws {
        // 1. Check local cache first (prevents duplicate submission)
        if idempotencyCache.isProcessed(answer.idempotencyKey) {
            print("✓ Answer already processed (idempotency key: \(answer.idempotencyKey))")
            return
        }
        
        // 2. Use Firestore transaction for atomic dedup
        try await db.runTransaction { transaction, errorPointer in
            let docRef = self.answersCollection(for: self.userID)
                .document(answer.idempotencyKey)
            
            // Check if exists (Firestore-side dedup)
            let snapshot = try transaction.getDocument(docRef)
            if snapshot.exists {
                print("✓ Answer exists on server, skipping")
                return
            }
            
            // Write with idempotency key as document ID
            let data = try Firestore.Encoder().encode(answer)
            transaction.setData(data, forDocument: docRef)
            
        } as Void
        
        // 3. Mark locally cached
        idempotencyCache.markProcessed(answer.idempotencyKey)
    }
}

// Services/Firestore/OfflineQueueManager+Dedup.swift
extension OfflineQueueManager {
    func enqueueAnswerIfNew(_ answer: QuestionAnswer) throws {
        let key = answer.idempotencyKey
        
        // Check pending writes (don't queue duplicates)
        let pending = try database.query(
            "SELECT COUNT(*) as count FROM pending_writes WHERE idempotency_key = ?",
            values: [key]
        ).first
        
        guard pending?["count"] as? Int ?? 0 == 0 else {
            print("⏭️ Answer already queued: \(key)")
            return
        }
        
        // Encode and queue
        let encoded = try JSONEncoder().encode(answer)
        try database.insert(
            table: "pending_writes",
            values: [
                "idempotency_key": key,
                "operation": "submit_answer",
                "payload": encoded,
                "retry_count": 0,
                "created_at": Date()
            ]
        )
        
        pendingChangesSubject.send(getPendingCount())
    }
}