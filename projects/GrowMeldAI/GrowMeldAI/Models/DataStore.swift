@MainActor
final class DataStore: NSObject {
    static let shared = DataStore()
    private let container: NSPersistentContainer
    
    override init() {
        container = NSPersistentContainer(name: "DriveAI")
        container.loadPersistentStores { _, error in
            if let error { fatalError("Core Data failed: \(error)") }
        }
        super.init()
    }
    
    // MARK: - DSGVO Article 17: Complete Erasure
    nonisolated func deleteAllUserData(userId: UUID) async throws {
        let backgroundContext = container.newBackgroundContext()
        
        try await backgroundContext.perform {
            // Delete all related records (cascade)
            let progressFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "QuizProgress")
            progressFetch.predicate = NSPredicate(format: "userId == %@", userId as CVarArg)
            try backgroundContext.execute(NSBatchDeleteRequest(fetchRequest: progressFetch))
            
            let profileFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "UserProfile")
            profileFetch.predicate = NSPredicate(format: "id == %@", userId as CVarArg)
            try backgroundContext.execute(NSBatchDeleteRequest(fetchRequest: profileFetch))
            
            try backgroundContext.save()
        }
        
        // Refresh main context
        await MainActor.run {
            self.container.viewContext.refreshAllObjects()
        }
    }
}