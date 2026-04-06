final class FeedbackCacheTests: XCTestCase {
    var sut: FeedbackCache!
    
    override func setUp() {
        super.setUp()
        sut = FeedbackCache(ttl: 1)  // 1 second expiration
    }
    
    // HAPPY PATH
    func test_set_storesFeedback() {
        let feedback = UserFeedback(questionID: UUID(), category: .tooFast)
        
        sut.set(feedback)
        
        XCTAssertEqual(sut.get(feedback.questionID)?.id, feedback.id)
    }
    
    func test_get_returnsNilWhenNotSet() {
        let nonexistentID = UUID()
        
        let result = sut.get(nonexistentID)
        
        XCTAssertNil(result)
    }
    
    // EDGE CASES
    func test_cache_expiresAfterTTL() async throws {
        let feedback = UserFeedback(questionID: UUID(), category: .tooFast)
        sut.set(feedback)
        
        XCTAssertNotNil(sut.get(feedback.questionID))
        
        try await Task.sleep(nanoseconds: 1_100_000_000)  // Wait 1.1 seconds
        
        XCTAssertNil(sut.get(feedback.questionID), "Should expire after TTL")
    }
    
    func test_remove_deletesEntry() {
        let feedback = UserFeedback(questionID: UUID(), category: .tooFast)
        sut.set(feedback)
        
        sut.remove(feedback.questionID)
        
        XCTAssertNil(sut.get(feedback.questionID))
    }
    
    func test_removeAll_clearsCache() {
        let f1 = UserFeedback(questionID: UUID(), category: .tooFast)
        let f2 = UserFeedback(questionID: UUID(), category: .ruleUnknown)
        
        sut.set(f1)
        sut.set(f2)
        sut.removeAll()
        
        XCTAssertNil(sut.get(f1.questionID))
        XCTAssertNil(sut.get(f2.questionID))
    }
    
    func test_purgeExpired_removesOnlyExpiredEntries() async throws {
        let f1 = UserFeedback(questionID: UUID(), category: .tooFast)
        sut.set(f1)
        
        try await Task.sleep(nanoseconds: 500_000_000)  // 0.5 seconds
        
        let f2 = UserFeedback(questionID: UUID(), category: .ruleUnknown)
        sut.set(f2)
        
        try await Task.sleep(nanoseconds: 600_000_000)  // 0.6 more seconds
        
        sut.purgeExpired()
        
        XCTAssertNil(sut.get(f1.questionID), "f1 should be expired")
        XCTAssertNotNil(sut.get(f2.questionID), "f2 should still be valid")
    }
}