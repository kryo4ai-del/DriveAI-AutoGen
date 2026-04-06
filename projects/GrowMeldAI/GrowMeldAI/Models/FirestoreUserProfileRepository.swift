class FirestoreUserProfileRepository: UserProfileRepository {
    private let firestore: FirestoreService
    private let localCache: LocalDataService
    private let syncQueue: SyncQueue
    private let conflictResolver: ExamDateConflictResolver
    
    @Published private var user: User?
    var userPublisher: AnyPublisher<User?, Never> {
        $user.eraseToAnyPublisher()
    }
    
    func fetchCurrentUser() async throws -> User {
        let currentUserID = try Auth.auth().currentUser?.uid ?? { 
            throw RepositoryError.firestoreAuthFailed 
        }()
        
        do {
            let remote = try await firestore.fetchDocument(
                from: "users",
                documentID: currentUserID,
                as: User.self
            )
            localCache.saveUser(remote)
            return remote
        } catch {
            if let cached = localCache.cachedUser {
                return cached
            }
            throw error
        }
    }
    
    func updateExamDate(_ date: Date) async throws {
        let userID = try getCurrentUserID()
        
        // 1. Update locally immediately (optimistic)
        var updated = user ?? User.mock(id: userID)
        updated.examDate = date
        localCache.saveUser(updated)
        self.user = updated
        
        // 2. Queue sync operation
        let operation = SyncOperation(
            id: UUID().uuidString,
            collection: "users",
            documentID: userID,
            operationType: .update,
            data: ["exam_date": AnyCodable.object(["seconds": AnyCodable.int(Int(date.timeIntervalSince1970))])],
            timestamp: Date()
        )
        try syncQueue.enqueue(operation)
        
        // 3. Attempt immediate sync
        try await syncQueue.flush(firestore: firestore)
    }
}