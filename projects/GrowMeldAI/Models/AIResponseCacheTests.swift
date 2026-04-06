import XCTest
@testable import DriveAI

@MainActor
final class AIResponseCacheTests: XCTestCase {
    var cache: AIResponseCache!
    
    override func setUp() {
        super.setUp()
        cache = AIResponseCache(maxSizeMB: 1)  // 1MB for testing
    }
    
    override func tearDown() {
        cache.clear()
        cache = nil
        super.tearDown()
    }
    
    // MARK: - Happy Path
    
    func test_store_and_retrieve_value() {
        // Arrange
        let key = "test_key"
        let value = "Test explanation"
        
        // Act
        cache.store(value, for: key)
        let retrieved = cache.get(key: key)
        
        // Assert
        XCTAssertEqual(retrieved, value)
    }
    
    func test_cache_hit_increments_hitRate() {
        // Arrange
        cache.store("value", for: "key1")
        var stats = cache.getStatistics()
        XCTAssertEqual(stats.hitRate, 0)
        
        // Act
        _ = cache.get(key: "key1")  // Hit
        stats = cache.getStatistics()
        
        // Assert
        XCTAssertEqual(stats.hitRate, 1.0)  // 100% hit rate (1 hit, 0 misses)
    }
    
    func test_cache_miss_decrements_hitRate() {
        // Arrange
        cache.store("value", for: "key1")
        
        // Act
        _ = cache.get(key: "nonexistent")  // Miss
        let stats = cache.getStatistics()
        
        // Assert
        XCTAssertEqual(stats.hitRate, 0.0)  // 0% hit rate (0 hits, 1 miss)
    }
    
    func test_mixed_hits_and_misses_calculate_correct_rate() {
        // Arrange
        cache.store("value1", for: "key1")
        cache.store("value2", for: "key2")
        
        // Act
        _ = cache.get(key: "key1")     // Hit
        _ = cache.get(key: "key1")     // Hit
        _ = cache.get(key: "missing1") // Miss
        _ = cache.get(key: "missing2") // Miss
        let stats = cache.getStatistics()
        
        // Assert
        XCTAssertEqual(stats.hitRate, 0.5)  // 2 hits / 4 total = 50%
        XCTAssertEqual(stats.totalRequests, 4)
    }
    
    // MARK: - Edge Cases: Size Management
    
    func test_lru_eviction_removes_oldest_entry() {
        // Arrange: 1MB cache, each entry ~500KB
        let largeValue = String(repeating: "A", count: 500_000)
        
        // Act
        cache.store(largeValue, for: "key1")
        let stats1 = cache.getStatistics()
        
        cache.store(largeValue, for: "key2")
        let stats2 = cache.getStatistics()
        
        // Assert: key1 should be evicted when key2 is added
        XCTAssertEqual(stats1.itemCount, 1)
        XCTAssertEqual(stats2.itemCount, 1)  // LRU eviction occurred
        XCTAssertNil(cache.get(key: "key1"))
        XCTAssertNotNil(cache.get(key: "key2"))
    }
    
    func test_updating_existing_key_does_not_increase_size() {
        // Arrange
        cache.store("value1", for: "key1")
        let stats1 = cache.getStatistics()
        
        // Act
        cache.store("updated_value", for: "key1")
        let stats2 = cache.getStatistics()
        
        // Assert
        XCTAssertEqual(stats1.itemCount, 1)
        XCTAssertEqual(stats2.itemCount, 1)  // Still 1 item
    }
    
    func test_cache_respects_max_size_limit() {
        // Arrange: Fill cache to near capacity
        let entrySize = 100_000  // 100KB
        let value = String(repeating: "X", count: entrySize)
        
        // Act: Add 11 entries (1.1MB total, but max is 1MB)
        for i in 0..<11 {
            cache.store(value, for: "key\(i)")
        }
        let stats = cache.getStatistics()
        
        // Assert: Should not exceed max size
        XCTAssertLessThanOrEqual(stats.sizeBytes, 1 * 1024 * 1024)
    }
    
    // MARK: - Edge Cases: Empty/Missing Data
    
    func test_get_nonexistent_key_returns_nil() {
        let result = cache.get(key: "never_stored")
        XCTAssertNil(result)
    }
    
    func test_clear_removes_all_entries() {
        // Arrange
        cache.store("value1", for: "key1")
        cache.store("value2", for: "key2")
        
        // Act
        cache.clear()
        let stats = cache.getStatistics()
        
        // Assert
        XCTAssertEqual(stats.itemCount, 0)
        XCTAssertEqual(stats.sizeBytes, 0)
        XCTAssertNil(cache.get(key: "key1"))
        XCTAssertNil(cache.get(key: "key2"))
    }
    
    func test_store_empty_string() {
        cache.store("", for: "empty_key")
        let retrieved = cache.get(key: "empty_key")
        XCTAssertEqual(retrieved, "")
    }
    
    // MARK: - Persistence
    
    func test_save_to_disk_async() async throws {
        // Arrange
        cache.store("value1", for: "key1")
        cache.store("value2", for: "key2")
        
        let tempPath = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_cache.json")
        
        // Act
        try await cache.saveToDiskAsync(path: tempPath)
        
        // Assert
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempPath.path))
        
        // Cleanup
        try? FileManager.default.removeItem(at: tempPath)
    }
    
    func test_load_from_disk_async_restores_data() async throws {
        // Arrange
        cache.store("value1", for: "key1")
        
        let tempPath = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_cache.json")
        
        try await cache.saveToDiskAsync(path: tempPath)
        
        // Create new cache and load
        let newCache = AIResponseCache(maxSizeMB: 1)
        
        // Act
        try await newCache.loadFromDiskAsync(path: tempPath)
        
        // Assert
        XCTAssertEqual(newCache.get(key: "key1"), "value1")
        
        // Cleanup
        try? FileManager.default.removeItem(at: tempPath)
    }
    
    func test_load_from_corrupted_file_throws_error() async {
        // Arrange
        let tempPath = FileManager.default.temporaryDirectory
            .appendingPathComponent("corrupted.json")
        
        try? "invalid json {[".write(toFile: tempPath.path, atomically: true, encoding: .utf8)
        
        // Act & Assert
        do {
            try await cache.loadFromDiskAsync(path: tempPath)
            XCTFail("Should have thrown decoding error")
        } catch {
            XCTAssertNotNil(error)
        }
        
        // Cleanup
        try? FileManager.default.removeItem(at: tempPath)
    }
}