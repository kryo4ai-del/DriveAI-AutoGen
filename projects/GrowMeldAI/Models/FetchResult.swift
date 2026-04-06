enum FetchResult<T> {
    case success([T])
    case empty
    case error(MemoryError)
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