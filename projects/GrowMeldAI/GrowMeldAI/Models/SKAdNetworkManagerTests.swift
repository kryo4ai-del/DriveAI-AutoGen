import XCTest
@testable import DriveAI

class SKAdNetworkManagerTests: XCTestCase {
    var sut: SKAdNetworkManager!
    var mockUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        mockUserDefaults = UserDefaults(suiteName: "test-skadn-\(UUID().uuidString)")
        sut = SKAdNetworkManager(userDefaults: mockUserDefaults)
    }
    
    override func tearDown() {
        if let suiteName = mockUserDefaults.suiteName {
            mockUserDefaults.removePersistentDomain(forName: suiteName)
        }
        super.tearDown()
    }
    
    // MARK: - Happy Path Tests
    
    func testConversionValueIncrementsCorrectly() {
        sut.updateConversionValue(30)
        XCTAssertEqual(sut.currentConversionValue, 30)
    }
    
    func testConversionValuePersistedToUserDefaults() {
        sut.updateConversionValue(50)
        
        let newInstance = SKAdNetworkManager(userDefaults: mockUserDefaults)
        XCTAssertEqual(newInstance.currentConversionValue, 50)
    }
    
    func testConversionValueSurvivesAppCrash() {
        sut.updateConversionValue(60)
        
        // Simulate app termination
        sut = nil
        
        // New instance should restore from disk
        sut = SKAdNetworkManager(userDefaults: mockUserDefaults)
        XCTAssertEqual(sut.currentConversionValue, 60)
    }
    
    func testMultipleIncrementalUpdates() {
        sut.updateConversionValue(20)
        sut.updateConversionValue(40)
        sut.updateConversionValue(60)
        sut.updateConversionValue(80)
        
        XCTAssertEqual(sut.currentConversionValue, 80)
        
        let stored = mockUserDefaults.dictionary(forKey: "asa_current_conversion_value")
        XCTAssertEqual(stored?["value"] as? Int, 80)
    }
    
    // MARK: - Edge Cases
    
    func testConversionValueClampsToMax100() {
        sut.updateConversionValue(150)
        XCTAssertEqual(sut.currentConversionValue, 100)
    }
    
    func testConversionValueClampsToMin0() {
        sut.updateConversionValue(-50)
        XCTAssertEqual(sut.currentConversionValue, 0)
    }
    
    func testZeroConversionValueIsValid() {
        sut.updateConversionValue(0)
        XCTAssertEqual(sut.currentConversionValue, 0)
    }
    
    func testConversionValue100IsValid() {
        sut.updateConversionValue(100)
        XCTAssertEqual(sut.currentConversionValue, 100)
    }
    
    // MARK: - Rejection Cases (Only Increments Allowed)
    
    func testConversionValueRejectsDecrement() {
        sut.updateConversionValue(50)
        sut.updateConversionValue(30)  // Lower than current
        
        XCTAssertEqual(sut.currentConversionValue, 50, "Should reject decrement")
    }
    
    func testConversionValueRejectsSameValue() {
        sut.updateConversionValue(50)
        sut.updateConversionValue(50)  // Same as current
        
        XCTAssertEqual(sut.currentConversionValue, 50)
    }
    
    func testConversionValueRejectsLargeDecrement() {
        sut.updateConversionValue(80)
        sut.updateConversionValue(20)
        
        XCTAssertEqual(sut.currentConversionValue, 80, "Should reject large decrement")
    }
    
    // MARK: - Persistence Edge Cases
    
    func testEmptyUserDefaultsInitializes ToZero() {
        mockUserDefaults.removeObject(forKey: "asa_current_conversion_value")
        
        sut = SKAdNetworkManager(userDefaults: mockUserDefaults)
        XCTAssertEqual(sut.currentConversionValue, 0)
    }
    
    func testCorruptedUserDefaultsHandledGracefully() {
        mockUserDefaults.set("invalid_string", forKey: "asa_current_conversion_value")
        
        sut = SKAdNetworkManager(userDefaults: mockUserDefaults)
        XCTAssertEqual(sut.currentConversionValue, 0)  // Graceful fallback
    }
    
    func testTimestampRecordedOnUpdate() {
        let beforeUpdate = Date().timeIntervalSince1970
        sut.updateConversionValue(45)
        let afterUpdate = Date().timeIntervalSince1970
        
        let stored = mockUserDefaults.dictionary(forKey: "asa_current_conversion_value")
        guard let timestamp = stored?["timestamp"] as? TimeInterval else {
            XCTFail("Timestamp not recorded")
            return
        }
        
        XCTAssertGreaterThanOrEqual(timestamp, beforeUpdate)
        XCTAssertLessThanOrEqual(timestamp, afterUpdate)
    }
    
    // MARK: - Reset Behavior
    
    func testResetForNewSessionClearsValue() {
        sut.updateConversionValue(60)
        sut.resetForNewSession()
        
        XCTAssertEqual(sut.currentConversionValue, 0)
    }
    
    func testResetForNewSessionRemovesFromUserDefaults() {
        sut.updateConversionValue(60)
        sut.resetForNewSession()
        
        let stored = mockUserDefaults.dictionary(forKey: "asa_current_conversion_value")
        XCTAssertNil(stored)
    }
    
    // MARK: - Thread Safety
    
    func testConcurrentUpdatesThreadSafe() {
        let iterations = 100
        let queue = DispatchQueue.global(qos: .default)
        let group = DispatchGroup()
        
        for i in 1...iterations {
            group.enter()
            queue.async { [weak self] in
                self?.sut.updateConversionValue(i)
                group.leave()
            }
        }
        
        group.wait()
        
        // Final value should be the max value attempted
        XCTAssertEqual(sut.currentConversionValue, iterations, "Should handle concurrent updates safely")
    }
    
    func testConcurrentReadsAndWritesThreadSafe() {
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .default)
        var readValues: [Int] = []
        let lock = NSLock()
        
        for i in 0..<50 {
            group.enter()
            queue.async { [weak self] in
                if i % 2 == 0 {
                    self?.sut.updateConversionValue(i)
                } else {
                    let value = self?.sut.currentConversionValue ?? 0
                    lock.lock()
                    readValues.append(value)
                    lock.unlock()
                }
                group.leave()
            }
        }
        
        group.wait()
        
        // All read operations should complete without crashes
        XCTAssertTrue(readValues.count > 0, "Should have concurrent reads")
    }
}