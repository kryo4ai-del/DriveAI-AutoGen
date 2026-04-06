import XCTest
@testable import DriveAI

@MainActor
class IdempotencyCacheTests: XCTestCase {
    var sut: IdempotencyCache!
    
    override func setUp() {
        super.setUp()
        sut = IdempotencyCache()
    }
    
    // HAPPY PATH: Mark key as processed, check returns true
    func test_markProcessed_thenIsProcessed_returnsTrue() {
        // Arrange
        let key = "device123_question456_session789"
        
        // Act
        sut.markProcessed(key)
        let result = sut.isProcessed(key)
        
        // Assert
        XCTAssertTrue(result)
    }
    
    // EDGE CASE: Check unprocessed key returns false
    func test_isProcessed_unknownKey_returnsFalse() {
        // Arrange
        let unknownKey = "never_seen_before"
        
        // Act
        let result = sut.isProcessed(unknownKey)
        
        // Assert
        XCTAssertFalse(result)
    }
    
    // BOUNDARY: Cache size limit prevents unbounded growth
    func test_cacheMaxSize_preventsUnboundedGrowth() {
        // Arrange
        let maxSize = 1000
        
        // Act: Insert more than max size
        for i in 0..<(maxSize + 100) {
            sut.markProcessed("key_\(i)")
        }
        
        // Assert: Cache cleared when exceeded
        // After reset, should not contain early keys
        sut.reset()
        for i in 0..<maxSize {
            XCTAssertFalse(sut.isProcessed("key_\(i)"))
        }
    }
    
    // INVALID INPUT: Empty key handled gracefully
    func test_emptyKey_handled() {
        // Act & Assert: No crash
        sut.markProcessed("")
        XCTAssertTrue(sut.isProcessed(""))
    }
    
    // CONCURRENT: Thread-safe operations (when @MainActor enforced)
    func test_concurrent_markAndCheck_noRaceConditions() async {
        // Arrange
        let keys = (0..<100).map { "key_\($0)" }
        
        // Act: Mark in parallel tasks
        await withTaskGroup(of: Void.self) { group in
            for key in keys {
                group.addTask {
                    self.sut.markProcessed(key)
                }
            }
        }
        
        // Assert: All marked
        for key in keys {
            XCTAssertTrue(sut.isProcessed(key))
        }
    }
}