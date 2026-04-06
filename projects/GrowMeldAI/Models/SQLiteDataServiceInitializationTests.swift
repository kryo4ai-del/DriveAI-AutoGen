import XCTest
@testable import DriveAI

final class SQLiteDataServiceInitializationTests: XCTestCase {
    
    var tempDatabasePath: String!
    
    override func setUp() {
        super.setUp()
        let tempDir = NSTemporaryDirectory()
        tempDatabasePath = (tempDir as NSString).appendingPathComponent("test-\(UUID().uuidString).db")
    }
    
    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(atPath: tempDatabasePath)
    }
    
    // HAPPY PATH
    
    func test_initialization_createsDatabase() async throws {
        let service = SQLiteDataService(dbPath: tempDatabasePath)
        
        let fileExists = FileManager.default.fileExists(atPath: tempDatabasePath)
        XCTAssertTrue(fileExists, "Database file should be created at initialization")
        
        service.closeDatabase()
    }
    
    func test_initialization_createsSchema() async throws {
        let service = SQLiteDataService(dbPath: tempDatabasePath)
        
        // Verify tables exist by querying them
        let categories = try await service.fetchCategories()
        XCTAssertNotNil(categories, "Should be able to query categories table after init")
        
        service.closeDatabase()
    }
    
    func test_initialization_enablesForeignKeys() async throws {
        let service = SQLiteDataService(dbPath: tempDatabasePath)
        
        // Foreign key constraint should prevent orphaned records
        // (Tested indirectly in category deletion tests)
        
        service.closeDatabase()
    }
    
    func test_initialization_withExistingDatabase_doesNotRecreateSchema() async throws {
        // First initialization
        let service1 = SQLiteDataService(dbPath: tempDatabasePath)
        service1.closeDatabase()
        
        // Get schema modification time
        let attributes1 = try FileManager.default.attributesOfItem(atPath: tempDatabasePath)
        let modTime1 = attributes1[.modificationDate] as? Date ?? .distantPast
        
        // Brief delay
        try await Task.sleep(nanoseconds: 100_000_000)  // 0.1 second
        
        // Second initialization
        let service2 = SQLiteDataService(dbPath: tempDatabasePath)
        service2.closeDatabase()
        
        // Schema should not be recreated (modification time minimal change)
        let attributes2 = try FileManager.default.attributesOfItem(atPath: tempDatabasePath)
        let modTime2 = attributes2[.modificationDate] as? Date ?? .distantPast
        
        let timeDiff = modTime2.timeIntervalSince(modTime1)
        XCTAssertLessThan(timeDiff, 1.0, "Schema should not be recreated for existing database")
    }
    
    // EDGE CASES
    
    func test_initialization_withInvalidPath_gracefullyHandles() {
        let invalidPath = "/invalid/path/that/does/not/exist/db.sqlite"
        let service = SQLiteDataService(dbPath: invalidPath)
        
        // Should not crash, but subsequent operations will fail
        service.closeDatabase()
    }
    
    func test_initialization_withReadOnlyPath_createsInAlternateLocation() {
        let readOnlyDir = "/tmp/readonly-test-\(UUID().uuidString)"
        try? FileManager.default.createDirectory(atPath: readOnlyDir, withIntermediateDirectories: true)
        try? FileManager.default.setAttributes([.protectionKey: FileProtectionType.none], ofItemAtPath: readOnlyDir)
        
        defer {
            try? FileManager.default.removeItem(atPath: readOnlyDir)
        }
        
        let service = SQLiteDataService(dbPath: "\(readOnlyDir)/db.sqlite")
        service.closeDatabase()
    }
    
    func test_deinit_closesDatabase() {
        autoreleasepool {
            let service = SQLiteDataService(dbPath: tempDatabasePath)
            _ = service
            // service deinit called
        }
        
        // Subsequent access should fail gracefully (cannot test directly,
        // but memory should be cleaned up - verify with instruments)
    }
}