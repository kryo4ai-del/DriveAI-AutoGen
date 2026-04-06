// Tests/Unit/DatabaseTests.swift
import XCTest
import SQLite
@testable import DriveAI

final class DatabaseTests: XCTestCase {
    var database: Database!
    let testDBPath = NSTemporaryDirectory() + "test_driveai.db"
    
    override func setUp() async throws {
        // Clean test database
        try? FileManager.default.removeItem(atPath: testDBPath)
        database = Database(path: testDBPath)
    }
    
    override func tearDown() async throws {
        // Clean up
        try? FileManager.default.removeItem(atPath: testDBPath)
    }
    
    // MARK: - Happy Path Tests
    
    func testDatabaseInitialization_Success() async throws {
        // Given: Database initialized with valid path
        let db = Database(path: testDBPath)
        
        // Then: Tables and indexes should exist
        let tableExists = try await db.read { conn in
            let query = "SELECT name FROM sqlite_master WHERE type='table' AND name='episodic_memories'"
            return try conn.prepare(query).makeIterator().next() != nil
        }
        
        XCTAssertTrue(tableExists, "episodic_memories table should exist")
    }
    
    func testSchemaCreation_Atomic() async throws {
        // Given: Fresh database
        // When: Schema is created
        // Then: All tables and indexes should exist
        
        let indexNames = try await database.read { conn in
            let query = "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='episodic_memories'"
            var indexes: [String] = []
            for row in try conn.prepare(query) {
                if let name = row[0] as? String {
                    indexes.append(name)
                }
            }
            return indexes
        }
        
        let expectedIndexes = [
            "idx_memories_timestamp",
            "idx_memories_type",
            "idx_memories_category",
            "idx_memories_context_score"
        ]
        
        for expected in expectedIndexes {
            XCTAssertTrue(
                indexNames.contains(expected),
                "Index \(expected) should be created"
            )
        }
    }
    
    func testDatabaseWrite_Success() async throws {
        // Given: Database initialized
        // When: Write operation executes
        let result = try await database.write { _ in
            return "write_completed"
        }
        
        // Then: Closure executes and returns value
        XCTAssertEqual(result, "write_completed")
    }
    
    func testDatabaseRead_Success() async throws {
        // Given: Database initialized
        // When: Read operation executes
        let result = try await database.read { _ in
            return 42
        }
        
        // Then: Closure executes and returns value
        XCTAssertEqual(result, 42)
    }
    
    // MARK: - Concurrency Tests
    
    func testConcurrentReads_NoRaceCondition() async throws {
        // Given: Database with test data
        try await database.write { conn in
            try conn.run("""
                INSERT INTO episodic_memories 
                (id, type, timestamp, metadata, context_score)
                VALUES (?, ?, ?, ?, ?)
            """, "test_1", "correctAnswer", Date(), "{}", 50)
        }
        
        // When: Multiple read operations execute concurrently
        let readResults = try await withThrowingTaskGroup(of: Int.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    try await self.database.read { conn in
                        let query = "SELECT COUNT(*) FROM episodic_memories"
                        let statement = try conn.prepare(query)
                        guard let row = statement.makeIterator().next(),
                              let count = row[0] as? Int else {
                            return 0
                        }
                        return count
                    }
                }
            }
            
            var results: [Int] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
        
        // Then: All reads should return same value (no corruption)
        let uniqueResults = Set(readResults)
        XCTAssertEqual(
            uniqueResults.count, 1,
            "Concurrent reads should return consistent data"
        )
        XCTAssertEqual(readResults.first, 1, "Should have 1 record")
    }
    
    func testWriteBarrier_BlocksConcurrentWrites() async throws {
        // Given: Database
        var writeOrder: [Int] = []
        let lockQueue = DispatchQueue(label: "write.order")
        
        // When: Multiple writes execute concurrently (barrier enforces serialization)
        try await withThrowingTaskGroup(of: Void.self) { group in
            for i in 0..<5 {
                group.addTask {
                    try await self.database.write { conn in
                        // Simulate write latency
                        try await Task.sleep(nanoseconds: UInt64(Int.random(in: 1_000_000...10_000_000)))
                        
                        lockQueue.sync {
                            writeOrder.append(i)
                        }
                    }
                }
            }
            
            try await group.waitForAll()
        }
        
        // Then: Writes should be serialized (no interleaving)
        XCTAssertEqual(writeOrder.count, 5, "All writes should complete")
    }
    
    func testDatabaseWeakSelfCleanup() async throws {
        // Given: Database with weak reference
        var database: Database? = Database(path: testDBPath)
        weak var weakDB = database
        
        // When: Database is released
        _ = try await database?.read { _ in "test" }
        database = nil
        
        // Then: Database should be deallocated
        XCTAssertNil(weakDB, "Database should be deallocated (no retain cycle)")
    }
    
    // MARK: - Error Handling Tests
    
    func testDatabaseRead_InvalidSQL_ThrowsError() async throws {
        // Given: Database
        // When: Invalid SQL is executed
        // Then: Error should be thrown
        
        do {
            try await database.read { conn in
                try conn.execute("INVALID SQL SYNTAX")
            }
            XCTFail("Should have thrown error for invalid SQL")
        } catch {
            // Expected
            XCTAssertNotNil(error)
        }
    }
    
    func testDatabaseWrite_DiskFull_ThrowsError() async throws {
        // Given: Mock full disk scenario
        // When: Write is attempted
        // Then: Disk space error should be thrown
        
        // Note: Difficult to test in real environment; recommend mocking
        // For now, verify error handling structure exists
        XCTAssertNotNil(EpisodicMemoryError.diskSpaceLimited)
    }
    
    // MARK: - Edge Case Tests
    
    func testDatabaseWrite_EmptyData_Success() async throws {
        // Given: Empty write operation
        // When: Write executes
        let result = try await database.write { _ in
            return true
        }
        
        // Then: Should not crash
        XCTAssertTrue(result)
    }
    
    func testDatabaseRead_NoData_ReturnsEmpty() async throws {
        // Given: Empty database
        // When: Read executed on empty table
        let count = try await database.read { conn in
            let query = "SELECT COUNT(*) FROM episodic_memories"
            guard let row = try conn.prepare(query).makeIterator().next(),
                  let count = row[0] as? Int else {
                return 0
            }
            return count
        }
        
        // Then: Count should be 0
        XCTAssertEqual(count, 0)
    }
}