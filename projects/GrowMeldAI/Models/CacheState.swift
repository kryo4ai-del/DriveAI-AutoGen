import Foundation

actor PerformanceStore {
    private enum CacheState {
        case unloaded
        case loading(Task<Void, Error>)
        case loaded
    }

    private var cacheState: CacheState = .unloaded

    func ensureCacheLoaded() async throws {
        switch cacheState {
        case .loaded:
            return
        case .loading(let task):
            try await task.value
        case .unloaded:
            try await performLoad()
        }
    }

    private func performLoad() async throws {
        let task = Task<Void, Error> {
            try await self.loadAllData()
        }
        cacheState = .loading(task)
        do {
            try await task.value
            cacheState = .loaded
        } catch {
            cacheState = .unloaded
            throw error
        }
    }

    private func loadAllData() async throws {
        // Default no-op implementation
    }
}