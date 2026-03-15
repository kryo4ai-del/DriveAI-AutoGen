@MainActor
final class ReadinessDataService: ReadinessDataServiceProtocol {
    private let localDataService: LocalDataServiceProtocol
    private var l2Cache: CachedReadinessMetrics
    
    init(localDataService: LocalDataServiceProtocol) {
        self.localDataService = localDataService
        self.l2Cache = CachedReadinessMetrics(ttl: 3600)
    }
    
    func fetchLatestReadiness() async throws -> ReadinessMetrics? {
        // Check L2 cache first
        if let cached = l2Cache.get() {
            return cached
        }
        
        // Fetch from persistent store
        guard let data = try await localDataService.fetchLatestReadiness() else {
            return nil
        }
        
        let metrics = try JSONDecoder().decode(ReadinessMetrics.self, from: data)
        l2Cache.set(metrics)
        return metrics
    }
    
    func saveReadiness(_ metrics: ReadinessMetrics) async throws {
        let encoded = try JSONEncoder().encode(metrics)
        try await localDataService.saveReadiness(encoded)
        l2Cache.set(metrics)
    }
    
    func getReadinessHistory() async throws -> [ReadinessMetrics] {
        guard let data = try await localDataService.fetchReadinessHistory() else {
            return []
        }
        return try JSONDecoder().decode([ReadinessMetrics].self, from: data)
    }
    
    func clearReadinessData() async throws {
        try await localDataService.clearReadinessData()
        l2Cache.clear()
    }
}