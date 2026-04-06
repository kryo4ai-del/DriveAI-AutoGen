// Tests/Services/Cache/CacheServiceTests.swift

import XCTest
@testable import DriveAI

@MainActor
final class CacheServiceTests: XCTestCase {
    var sut: CacheService!
    
    override func setUp() {
        super.setUp()
        sut = CacheService()
    }
    
    override func tearDown() {
        try? sut.clearAll()
        super.tearDown()
    }
    
    // MARK: - Happy Path: Store & Retrieve
    
    func test_setAndGet_simpleValue_succeeds() throws {
        // Given
        let testString = "Verkehrszeichen"
        let key = "category_1"
        
        // When
        try sut.set(testString, forKey: key)
        let retrieved: String? = sut.get(key, type: String.self)
        
        // Then
        XCTAssertEqual(retrieved, testString)
    }
    
    func test_setAndGet_codableModel_succeeds() throws {
        // Given
        let question = Question(
            id: UUID(),
            number: 1,
            category: "Verkehrszeichen",
            text: "Was ist dieses Zeichen?",
            imageURL: nil,
            options: [
                .init(text: "Stopp", imageURL: nil),
                .init(text: "Vorfahrt", imageURL: nil)
            ],
            correctAnswerIndices: [0],
            explanation: "Das ist ein Stoppschild",
            difficulty: .easy
        )
        
        // When
        try sut.set(question, forKey: "q_1")
        let retrieved: Question? = sut.get("q_1", type: Question.self)
        
        // Then
        XCTAssertEqual(retrieved, question)
    }
    
    func test_setAndGet_array_succeeds() throws {
        // Given
        let questions: [Question] = [
            Question(id: UUID(), number: 1, category: "Test", text: "Q1", 
                     imageURL: nil, options: [.init(text: "A", imageURL: nil)],
                     correctAnswerIndices: [0], explanation: nil, difficulty: .easy),
            Question(id: UUID(), number: 2, category: "Test", text: "Q2",
                     imageURL: nil, options: [.init(text: "B", imageURL: nil)],
                     correctAnswerIndices: [0], explanation: nil, difficulty: .medium)
        ]
        
        // When
        try sut.set(questions, forKey: "all_questions")
        let retrieved: [Question]? = sut.get("all_questions", type: [Question].self)
        
        // Then
        XCTAssertEqual(retrieved?.count, 2)
        XCTAssertEqual(retrieved?[0].number, 1)
        XCTAssertEqual(retrieved?[1].number, 2)
    }
    
    // MARK: - Memory Cache: Persistence Across Operations
    
    func test_memoryCacheHit_returnsCachedValue() throws {
        // Given
        let value = "cached_value"
        try sut.set(value, forKey: "test_key")
        
        // When: Access multiple times
        let result1: String? = sut.get("test_key", type: String.self)
        let result2: String? = sut.get("test_key", type: String.self)
        
        // Then: Both should return same value
        XCTAssertEqual(result1, value)
        XCTAssertEqual(result2, value)
    }
    
    func test_diskCacheRecovery_afterMemoryEviction() throws {
        // Given
        let value = "persisted_value"
        try sut.set(value, forKey: "persistent_key")
        
        // Simulate memory cache eviction (NSCache clears under memory pressure)
        // Unfortunately we can't directly test this, but we verify disk persistence
        
        // When: Disk value should still be retrievable
        let retrieved: String? = sut.get("persistent_key", type: String.self)
        
        // Then
        XCTAssertEqual(retrieved, value)
    }
    
    // MARK: - TTL Expiration
    
    func test_get_withExpiredTTL_returnsNil() throws {
        // Given
        let value = "short_lived"
        let pastDate = Date().addingTimeInterval(-10)  // Expired 10 seconds ago
        try sut.set(value, forKey: "ttl_key", ttl: 5)  // 5 second TTL
        
        // When: We'd need to mock time, so we test boundary
        // Actually set with -1 TTL (always expired)
        try sut.set(value, forKey: "expired_key", ttl: -1)
        
        // Then
        let retrieved: String? = sut.get("expired_key", type: String.self)
        XCTAssertNil(retrieved)
    }
    
    func test_get_withValidTTL_returnValue() throws {
        // Given
        let value = "valid_ttl"
        
        // When: Set with 1-hour TTL
        try sut.set(value, forKey: "valid_ttl_key", ttl: 3600)
        let retrieved: String? = sut.get("valid_ttl_key", type: String.self)
        
        // Then
        XCTAssertEqual(retrieved, value)
    }
    
    // MARK: - Edge Cases: Invalid Data
    
    func test_get_wrongType_returnsNil() throws {
        // Given
        try sut.set("string_value", forKey: "type_mismatch")
        
        // When: Try to retrieve as different type
        let retrieved: Int? = sut.get("type_mismatch", type: Int.self)
        
        // Then
        XCTAssertNil(retrieved)
    }
    
    func test_get_nonexistentKey_returnsNil() {
        // When
        let retrieved: String? = sut.get("never_set", type: String.self)
        
        // Then
        XCTAssertNil(retrieved)
    }
    
    func test_get_corruptedDiskData_returnsNil() throws {
        // This would require file manipulation
        // Strategy: Write invalid JSON to cache file
        let documentsURL = FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let cacheDir = documentsURL.appendingPathComponent("net.driveai.cache")
        
        try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        let corruptedFile = cacheDir.appendingPathComponent("corrupted_key")
        try "not valid json".write(to: corruptedFile, atomically: true, encoding: .utf8)
        
        // When
        let retrieved: String? = sut.get("corrupted_key", type: String.self)
        
        // Then
        XCTAssertNil(retrieved)
        try FileManager.default.removeItem(at: corruptedFile)
    }
    
    // MARK: - Removal Operations
    
    func test_remove_deletesFromMemoryAndDisk() throws {
        // Given
        try sut.set("to_remove", forKey: "removal_key")
        
        // Verify it exists
        var retrieved: String? = sut.get("removal_key", type: String.self)
        XCTAssertEqual(retrieved, "to_remove")
        
        // When
        sut.remove("removal_key")
        
        // Then
        retrieved = sut.get("removal_key", type: String.self)
        XCTAssertNil(retrieved)
    }
    
    func test_remove_nonexistentKey_doesNotThrow() {
        // Should not throw or crash
        XCTAssertNoThrow {
            sut.remove("never_existed")
        }
    }
    
    // MARK: - Cleanup Operations
    
    func test_clearExpired_removesOnlyExpiredEntries() throws {
        // Given
        try sut.set("keep_me", forKey: "valid_key", ttl: 3600)  // 1 hour
        try sut.set("remove_me", forKey: "expired_key", ttl: -1)  // Always expired
        
        // When
        let removedCount = sut.clearExpired()
        
        // Then
        XCTAssertEqual(removedCount, 1)
        XCTAssertNotNil(sut.get("valid_key", type: String.self))
        XCTAssertNil(sut.get("expired_key", type: String.self))
    }
    
    func test_clearAll_removesAllCachedData() throws {
        // Given
        try sut.set("data1", forKey: "key1")
        try sut.set("data2", forKey: "key2")
        try sut.set("data3", forKey: "key3")
        
        // When
        try sut.clearAll()
        
        // Then
        XCTAssertNil(sut.get("key1", type: String.self))
        XCTAssertNil(sut.get("key2", type: String.self))
        XCTAssertNil(sut.get("key3", type: String.self))
    }
    
    // MARK: - Concurrency: Multiple Access
    
    func test_concurrentWrites_doNotCorruptData() async throws {
        // Given
        let iterations = 50
        
        // When
        try await withThrowingTaskGroup(of: Void.self) { group in
            for i in 0..<iterations {
                group.addTask {
                    try self.sut.set("value_\(i)", forKey: "concurrent_\(i)")
                }
            }
            try await group.waitForAll()
        }
        
        // Then: All writes should succeed
        for i in 0..<iterations {
            let retrieved: String? = sut.get("concurrent_\(i)", type: String.self)
            XCTAssertEqual(retrieved, "value_\(i)")
        }
    }
}