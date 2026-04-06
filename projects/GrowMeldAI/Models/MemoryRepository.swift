protocol MemoryRepository {
    func insert(_ memory: EpisodicMemory) async throws
    func fetch(categoryID: String) async throws -> [EpisodicMemory]
    func deleteOlderThan(_ date: Date) async throws
}

@MainActor
class MemoryService {
    private let repository: MemoryRepository
    
    init(repository: MemoryRepository = SQLiteMemoryRepository()) {
        self.repository = repository
    }
    
    func recordMemory(_ memory: EpisodicMemory) async throws {
        // Validation, deduplication, enrichment
        try await repository.insert(memory)
    }
}