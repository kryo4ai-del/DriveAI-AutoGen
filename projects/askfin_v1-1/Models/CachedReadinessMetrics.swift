import Foundation
// Services/Cache/CachedReadinessMetrics.swift

@MainActor
final class CachedReadinessMetrics: Sendable {
    private struct CacheEntry {
        let metrics: ReadinessMetrics
        let timestamp: Date
        let ttl: TimeInterval
        
        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > ttl
        }
    }
    
    private var entry: CacheEntry?
    
    init(ttl: TimeInterval = 3600) {
        self.ttl = ttl
    }
    
    private var ttl: TimeInterval
    
    func get() -> ReadinessMetrics? {
        guard let entry = entry, !entry.isExpired else {
            self.entry = nil
            return nil
        }
        return entry.metrics
    }
    
    func set(_ metrics: ReadinessMetrics) {
        entry = CacheEntry(metrics: metrics, timestamp: Date(), ttl: ttl)
    }
    
    func clear() {
        entry = nil
    }
}