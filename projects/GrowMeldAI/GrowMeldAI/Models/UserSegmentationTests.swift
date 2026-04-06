import XCTest
@testable import DriveAI

class UserSegmentationTests: XCTestCase {
    var sut: UserSegmentationService!
    
    override func setUp() {
        super.setUp()
        sut = UserSegmentationService()
        sut.resetHashForTesting()  // Clean state
    }
    
    override func tearDown() {
        sut.resetHashForTesting()
        super.tearDown()
    }
    
    // MARK: - Hash Generation
    
    func test_getUserIDHash_generatesHashOnFirstCall() {
        // When
        let hash = sut.getUserIDHash()
        
        // Then
        XCTAssertFalse(hash.isEmpty, "Hash should not be empty")
        XCTAssertEqual(hash.count, 64, "SHA256 hash should be 64 hex characters")
    }
    
    func test_getUserIDHash_returnsConsistentHashAcrossCalls() {
        // When
        let hash1 = sut.getUserIDHash()
        let hash2 = sut.getUserIDHash()
        let hash3 = sut.getUserIDHash()
        
        // Then
        XCTAssertEqual(hash1, hash2, "Same hash on subsequent calls")
        XCTAssertEqual(hash2, hash3, "Hash remains consistent")
    }
    
    func test_getUserIDHash_survivesServiceReinitialization() {
        // Given
        let hash1 = sut.getUserIDHash()
        
        // When (reinitialize service, hash should persist in UserDefaults)
        let newService = UserSegmentationService()
        let hash2 = newService.getUserIDHash()
        
        // Then
        XCTAssertEqual(hash1, hash2, "Hash persists across service instances")
    }
    
    func test_getUserIDHash_isThreadSafe() {
        // Given
        let expectation = XCTestExpectation(description: "Multiple threads generate same hash")
        expectation.expectedFulfillmentCount = 100
        
        var hashes: [String] = []
        let queue = DispatchQueue(label: "test.segmentation.concurrent", attributes: .concurrent)
        let lock = NSLock()
        
        // When
        for _ in 0..<100 {
            queue.async {
                let hash = self.sut.getUserIDHash()
                lock.lock()
                hashes.append(hash)
                lock.unlock()
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        let uniqueHashes = Set(hashes)
        XCTAssertEqual(uniqueHashes.count, 1, "All threads should get same hash")
    }
    
    func test_getUserIDHash_producesValidSHA256() {
        // When
        let hash = sut.getUserIDHash()
        
        // Then
        XCTAssertTrue(hash.allSatisfy { $0.isHexDigit }, "Hash should be valid hex")
    }
    
    // MARK: - Reset Functionality
    
    func test_resetHashForTesting_clearsStoredHash() {
        // Given
        let hash1 = sut.getUserIDHash()
        
        // When
        sut.resetHashForTesting()
        let hash2 = sut.getUserIDHash()
        
        // Then
        XCTAssertNotEqual(hash1, hash2, "Hash should change after reset")
    }
}