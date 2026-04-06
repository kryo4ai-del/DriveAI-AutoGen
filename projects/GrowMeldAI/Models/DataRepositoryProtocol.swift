// Services/Data/BaseDataService.swift
protocol DataRepositoryProtocol: Sendable {
    // Backend-specific implementation
    func fetchRemote<T: Decodable>(_ path: String) async throws -> T
    func writeRemote<T: Encodable>(_ path: String, data: T) async throws
}

actor BaseDataService: DataServiceProtocol {
    private let repository: DataRepositoryProtocol
    private let cache: CacheServiceProtocol
    private let logger: Logger
    
    init(
        repository: DataRepositoryProtocol,
        cache: CacheServiceProtocol,
        logger: Logger = .shared
    ) {
        self.repository = repository
        self.cache = cache
        self.logger = logger
    }
    
    // Shared pattern: Cache-then-network
    func fetchQuestions(for categoryId: String) async throws -> [Question] {
        // 1. Check cache first
        if let cached = try? cache.get(key: "questions_\(categoryId)", as: [Question].self) {
            return cached
        }
        
        // 2. Fetch from backend
        let questions: [Question] = try await repository.fetchRemote(
            "categories/\(categoryId)/questions"
        )
        
        // 3. Cache result
        try? cache.set(questions, forKey: "questions_\(categoryId)")
        return questions
    }
    
    func fetchCategoryProgress(userId: String) async throws -> [CategoryProgress] {
        // Same pattern: cache → fetch → cache
        let key = "progress_\(userId)"
        if let cached = try? cache.get(key: key, as: [CategoryProgress].self) {
            return cached
        }
        
        let progress: [CategoryProgress] = try await repository.fetchRemote(
            "users/\(userId)/progress"
        )
        
        try? cache.set(progress, forKey: key)
        return progress
    }
    
    // Unified write: local first, remote async
    func updateCategoryProgress(
        _ progress: CategoryProgress,
        userId: String
    ) async throws {
        // Write locally (always succeeds)
        try await cache.set(progress, forKey: "progress_\(userId)_\(progress.categoryId)")
        
        // Async remote (fire-and-forget with error handling)
        Task { [weak self] in
            do {
                try await self?.repository.writeRemote(
                    "users/\(userId)/progress/\(progress.categoryId)",
                    data: progress
                )
            } catch {
                self?.logger.warn("Remote sync failed: \(error)")
                // Queue for retry (via SyncQueue)
            }
        }
    }
}

// LocalDataRepository (Phase 1)
actor LocalDataRepository: DataRepositoryProtocol {
    private let db: Database
    
    func fetchRemote<T: Decodable>(_ path: String) async throws -> T {
        // Parse path: "categories/traffic_signs/questions"
        let components = path.split(separator: "/")
        // Query local SQLite
        ...
    }
    
    func writeRemote<T: Encodable>(_ path: String, data: T) async throws {
        // Write to local SQLite (Phase 1: no actual remote write)
        ...
    }
}

// FirebaseDataRepository (Phase 2c)
actor FirebaseDataRepository: DataRepositoryProtocol {
    private let db: Firestore
    
    func fetchRemote<T: Decodable>(_ path: String) async throws -> T {
        let document = try await db.document(path).getDocument()
        return try document.data(as: T.self)
    }
    
    func writeRemote<T: Encodable>(_ path: String, data: T) async throws {
        try db.document(path).setData(from: data, merge: true)
    }
}