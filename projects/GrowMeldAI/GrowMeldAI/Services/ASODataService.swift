// ✅ ATOMIC FETCH-OR-CREATE

@MainActor
final class ASODataService: ASODataServiceProtocol {
    private var inflightRequests: [String: Task<[KeywordMetric], Error>] = [:]
    
    func getKeywordMetrics() async throws -> [KeywordMetric] {
        let key = "keywords"
        
        // Reuse inflight request
        if let task = inflightRequests[key] {
            return try await task.value
        }
        
        // Create single fetch task
        let task = Task {
            if localDatabase.isCacheValid(for: key, ttl: 86400) {
                return try await localDatabase.getKeywords()
            }
            
            let metrics = try await keywordService.fetchLatestMetrics()
            try await localDatabase.saveKeywords(metrics)
            return metrics
        }
        
        inflightRequests[key] = task
        defer { inflightRequests.removeValue(forKey: key) }
        
        return try await task.value
    }
}