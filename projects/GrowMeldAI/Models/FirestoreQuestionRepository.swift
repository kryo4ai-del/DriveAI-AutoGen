class FirestoreQuestionRepository: QuestionRepository {
    private let firestore: FirestoreService
    private let localCache: LocalDataService
    private let syncQueue: SyncQueue
    
    @Published private var questions: [Question] = []
    var questionsPublisher: AnyPublisher<[Question], Never> {
        $questions.eraseToAnyPublisher()
    }
    
    // MARK: - Local-first pattern
    func fetchAllQuestions() async throws -> [Question] {
        // 1. Check local cache
        if let cached = localCache.cachedQuestions, !cached.isEmpty {
            return cached
        }
        
        // 2. Fetch from Firestore
        do {
            let remote = try await firestore.fetchCollection(
                from: "questions",
                as: Question.self
            )
            localCache.saveQuestions(remote)
            return remote
        } catch {
            // 3. Fallback to stale cache if Firestore fails
            if let cached = localCache.cachedQuestions {
                return cached
            }
            throw RepositoryError.localCacheEmpty
        }
    }
    
    // MARK: - Real-time sync
    private func setupRealtimeListener() {
        firestore.listenToCollection(from: "questions", as: Question.self)
            .sink { _ in
                // Handle error silently
            } receiveValue: { [weak self] questions in
                self?.localCache.saveQuestions(questions)
                self?.questions = questions
            }
            .store(in: &cancellables)
    }
}