enum MemoryError {
    case persistenceError(String)
}

enum MemoryFilterMode {
    case all
}

struct EpisodicalMemory {
}

class LocalDataService {
    func fetchEpisodicalMemories() async throws -> [EpisodicalMemory] {
        return []
    }
}

enum FetchResult<T> {
    case success([T])
    case empty
    case error(MemoryError)
}

let localDataService = LocalDataService()

func filterMemories(_ memories: [EpisodicalMemory], by filter: MemoryFilterMode) -> [EpisodicalMemory] {
    return memories
}

func fetchMemories(filter: MemoryFilterMode) async -> FetchResult<EpisodicalMemory> {
    do {
        let all = try await localDataService.fetchEpisodicalMemories()
        guard !all.isEmpty else { return .empty }
        
        let filtered = filterMemories(all, by: filter)
        return .success(filtered)
    } catch {
        return .error(.persistenceError(error.localizedDescription))
    }
}