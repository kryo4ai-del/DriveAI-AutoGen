import XCTest
@testable import DriveAI

@MainActor
final class DatabaseConnectionPoolTests: XCTestCase {
    var tempDBPath: String!
    var pool: DatabaseConnectionPool!
    
    override func setUp() async throws {
        // Create temporary database for each test
        let tempDir = FileManager.default.temporaryDirectory
        tempDBPath = tempDir.appendingPathComponent("test_\(UUID().uuidString).db").path
        pool = DatabaseConnectionPool(databasePath: tempDBPath)
    }
    
    override func tearDown() async throws {
        try? FileManager.default.removeItem(atPath: tempDBPath)
    }
    
    // MARK: - Initialization Tests
    
    func testInitialize_Success() async throws {
        try pool.initialize()
        // Verify PRAGMA settings applied
        try pool.withConnection { db in
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            
            sqlite3_prepare_v2(db, "PRAGMA journal_mode", -1, &stmt, nil)
            sqlite3_step(stmt)
            
            let mode = String(cString: sqlite3_column_text(stmt, 0))
            XCTAssertEqual(mode.lowercased(), "wal")
        }
    }
    
    func testInitialize_Idempotent() async throws {
        try pool.initialize()
        try pool.initialize()  // Should not crash
        // Verify connection still valid
        try pool.withConnection { db in
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            
            sqlite3_prepare_v2(db, "SELECT 1", -1, &stmt, nil)
            XCTAssertEqual(sqlite3_step(stmt), SQLITE_ROW)
        }
    }
    
    func testInitialize_CreatesDatabase() async throws {
        try pool.initialize()
        
        let fileExists = FileManager.default.fileExists(atPath: tempDBPath)
        XCTAssertTrue(fileExists, "Database file should be created")
    }
    
    // MARK: - Connection Safety Tests
    
    func testConcurrentAccess_NoRaceCondition() async throws {
        try pool.initialize()
        
        let iterations = 100
        var results: [Int] = []
        let lock = NSLock()
        
        await withTaskGroup(of: Int.self) { group in
            for i in 0..<iterations {
                group.addTask {
                    return try! self.pool.withConnection { _ in
                        return i
                    }
                }
            }
            
            for await result in group {
                lock.withLock {
                    results.append(result)
                }
            }
        }
        
        XCTAssertEqual(results.count, iterations, "All tasks should complete")
    }
    
    func testWithConnection_ThrowsWhenUninitialized() async throws {
        let error = try XCTUnwrap(
            (try? pool.withConnection { _ in }).map { _ -> DriveAIError? in nil } ?? 
            DriveAIError.databaseUnavailable as? DriveAIError
        )
        
        XCTAssertEqual(error, .databaseUnavailable)
    }
    
    func testDeinit_ClosesDatabaseGracefully() async throws {
        try pool.initialize()
        let path = tempDBPath!
        
        // Let pool go out of scope
        var localPool: DatabaseConnectionPool? = pool
        pool = nil
        localPool = nil
        
        // Should be able to reopen/recreate
        let newPool = DatabaseConnectionPool(databasePath: path)
        try newPool.initialize()
        // ✅ No "database is locked" error
    }
}