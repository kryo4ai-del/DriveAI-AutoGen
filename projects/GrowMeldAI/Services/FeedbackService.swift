class FeedbackService {
    private var deletedFeedbackIDs: Set<UUID> = []  // Track deletions
    
    func deleteFeedback(id: UUID) async throws {
        deletedFeedbackIDs.insert(id)  // Mark as deleted
        try await persistenceManager.deleteFeedback(id: id)
    }
    
    func syncPendingFeedback() async throws {
        let pending = try await persistenceManager.getPendingFeedback()
            .filter { !deletedFeedbackIDs.contains($0.id) }  // Filter out deleted
        
        for item in pending {
            try await syncItem(item)
        }
    }
}