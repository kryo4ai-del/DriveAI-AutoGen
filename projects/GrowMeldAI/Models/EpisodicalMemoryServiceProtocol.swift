protocol EpisodicalMemoryServiceProtocol {  // ❌ Not Sendable
    func fetchMemories(filter: MemoryFilterMode) async throws -> [EpisodicalMemory]
}