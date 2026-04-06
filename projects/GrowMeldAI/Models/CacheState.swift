actor PerformanceStore {
    private enum CacheState {
        case unloaded
        case loading(Task<Void, Error>)
        case loaded
    }
    
    private var cacheState: CacheState = .unloaded
    
    nonisolated private func ensureCacheLoaded() async throws {
        switch await getCacheState() {
        case .loaded:
            return
        case .loading(let task):
            // Wait for in-progress load
            try await task.value
        case .unloaded:
            try await performLoad()
        }
    }
    
    private func performLoad() async throws {
        let task = Task {
            cacheState = .loading(Task { })  // Placeholder
            defer { cacheState = .loaded }
            try await loadAllData()
        }
        cacheState = .loading(task)
        try await task.value
    }
    
    private func getCacheState() -> CacheState {
        cacheState
    }
}