// Models/ExplanationCache.swift
import Foundation

class ExplanationCache {
    
    struct CachedExplanation: Codable {
        let questionId: Int
        let text: String
        let tier: String
        let validatedAgainstOfficialSource: Bool
        let cachedAt: Date
        let expiresAt: Date
    }
    
    private struct CacheStore: Codable {
        var explanations: [String: CachedExplanation] = [:]
        var queryLog: [QueryLogEntry] = []
    }
    
    private struct QueryLogEntry: Codable {
        let timestamp: Date
        let hit: Bool
    }
    
    private let cacheFileURL: URL
    private var store: CacheStore
    
    init() {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheFileURL = cacheDir.appendingPathComponent("explanation_cache.json")
        self.store = CacheStore()
        self.store = Self.loadStore(from: cacheFileURL) ?? CacheStore()
    }
    
    // MARK: - Persistence
    
    private static func loadStore(from url: URL) -> CacheStore? {
        guard let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(CacheStore.self, from: data) else {
            return nil
        }
        return decoded
    }
    
    private func persistStore() {
        guard let data = try? JSONEncoder().encode(store) else { return }
        try? data.write(to: cacheFileURL, options: .atomic)
    }
    
    // MARK: - Public API
    
    /// Fetch explanation if exists and not expired
    func fetch(_ questionId: Int) -> CachedExplanation? {
        let key = "\(questionId)"
        let now = Date()
        
        guard let cached = store.explanations[key], cached.expiresAt > now else {
            store.queryLog.append(QueryLogEntry(timestamp: now, hit: false))
            persistStore()
            return nil
        }
        
        store.queryLog.append(QueryLogEntry(timestamp: now, hit: true))
        persistStore()
        return cached
    }
    
    /// Save explanation with TTL
    func save(questionId: Int, text: String, tier: String, isAuthoritative: Bool, ttl: Foundation.TimeInterval) {
        let now = Date()
        let cached = CachedExplanation(
            questionId: questionId,
            text: text,
            tier: tier,
            validatedAgainstOfficialSource: isAuthoritative,
            cachedAt: now,
            expiresAt: now.addingTimeInterval(ttl)
        )
        store.explanations["\(questionId)"] = cached
        persistStore()
    }
    
    /// Save explanation with TTL using result tuple
    func save(questionId: Int, text: String, tier: String, isAuthoritative: Bool, ttl: Double) {
        let now = Date()
        let cached = CachedExplanation(
            questionId: questionId,
            text: text,
            tier: tier,
            validatedAgainstOfficialSource: isAuthoritative,
            cachedAt: now,
            expiresAt: now.addingTimeInterval(ttl)
        )
        store.explanations["\(questionId)"] = cached
        persistStore()
    }
    
    /// Database cleanup (runs on app launch)
    func purgeExpired() {
        let now = Date()
        store.explanations = store.explanations.filter { $0.value.expiresAt >= now }
        persistStore()
    }
    
    /// Analytics
    var cacheHitRate: Double {
        let total = store.queryLog.count
        guard total > 0 else { return 0.0 }
        let hits = store.queryLog.filter { $0.hit }.count
        return hits > 0 ? Double(hits) / Double(total) : 0.0
    }
}