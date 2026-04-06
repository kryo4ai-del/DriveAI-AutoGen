import Foundation
import os.log
import SwiftUI

private let logger = Logger(subsystem: "com.driveai.fallback", category: "cache")

/// Thread-safe LRU cache with persistent storage
@MainActor
final class AIResponseCache: Sendable {
    private struct CacheEntry: Codable, Sendable {
        let value: String
        var timestamp: Date
        let sizeBytes: Int
    }
    
    private var cache: [String: CacheEntry] = [:]
    private let maxSizeBytes: Int
    private var totalBytes = 0
    private var hits = 0
    private var misses = 0
    
    init(maxSizeMB: Int) {
        self.maxSizeBytes = maxSizeMB * 1024 * 1024
        logger.info("AIResponseCache initialized: \(maxSizeMB)MB")
    }
    
    // MARK: - Core API
    
    func get(key: String) -> String? {
        defer {
            if cache[key] == nil {
                misses += 1
            } else {
                hits += 1
                // Update timestamp for LRU
                cache[key]?.timestamp = Date()
            }
        }
        return cache[key]?.value
    }
    
    func store(_ value: String, for key: String) {
        let sizeBytes = value.utf8.count
        
        // Remove existing entry
        if let existing = cache[key] {
            totalBytes -= existing.sizeBytes
        }
        
        // Evict LRU entries if needed
        while totalBytes + sizeBytes > maxSizeBytes && !cache.isEmpty {
            let oldest = cache.min { $0.value.timestamp < $1.value.timestamp }!
            totalBytes -= oldest.value.sizeBytes
            cache.removeValue(forKey: oldest.key)
            logger.debug("Evicted: \(oldest.key)")
        }
        
        cache[key] = CacheEntry(
            value: value,
            timestamp: Date(),
            sizeBytes: sizeBytes
        )
        totalBytes += sizeBytes
    }
    
    func clear() {
        cache.removeAll()
        totalBytes = 0
        hits = 0
        misses = 0
        logger.info("Cache cleared")
    }
    
    // MARK: - Statistics
    
    func getStatistics() -> CacheStatistics {
        let total = hits + misses
        let hitRate = total > 0 ? Double(hits) / Double(total) : 0
        
        return CacheStatistics(
            hitRate: hitRate,
            itemCount: cache.count,
            sizeBytes: totalBytes,
            totalRequests: total
        )
    }
    
    // MARK: - Persistence (Non-blocking)
    
    func saveToDiskAsync(path: URL) async throws {
        let dataToSave = cache
        
        try await Task.detached(priority: .background) { [dataToSave] in
            let encoder = JSONEncoder()
            let data = try encoder.encode(dataToSave)
            try data.write(to: path, options: .atomic)
            logger.info("Cache persisted: \(path.lastPathComponent)")
        }.value
    }
    
    func loadFromDiskAsync(path: URL) async throws {
        let data = try Data(contentsOf: path)
        let decoder = JSONDecoder()
        let loaded = try decoder.decode([String: CacheEntry].self, from: data)
        
        cache = loaded
        totalBytes = loaded.values.reduce(0) { $0 + $1.sizeBytes }
        logger.info("Loaded \(loaded.count) cached items")
    }
}

// MARK: - Cache Statistics

struct CacheStatistics: Sendable {
    let hitRate: Double
    let itemCount: Int
    let sizeBytes: Int
    let totalRequests: Int
    
    var isHealthy: Bool {
        hitRate >= 0.5  // 50%+ hit rate is good
    }
    
    var sizeFormattedString: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(sizeBytes))
    }
}