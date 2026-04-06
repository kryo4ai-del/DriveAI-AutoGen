// MARK: - Tests/Analytics/AnalyticsDataSanitizerTests.swift

class AnalyticsDataSanitizerTests: XCTestCase {
    
    // MARK: - User ID Hashing
    
    func test_hashUserId_returnsConsistentHash() {
        let userId = "user_12345_abc"
        
        let hash1 = AnalyticsDataSanitizer.hashUserId(userId)
        let hash2 = AnalyticsDataSanitizer.hashUserId(userId)
        
        XCTAssertEqual(hash1, hash2, "Same user ID should produce same hash")
    }
    
    func test_hashUserId_returnsDifferentHashesForDifferentIds() {
        let hash1 = AnalyticsDataSanitizer.hashUserId("user_123")
        let hash2 = AnalyticsDataSanitizer.hashUserId("user_456")
        
        XCTAssertNotEqual(hash1, hash2, "Different user IDs should produce different hashes")
    }
    
    func test_hashUserId_producesFixedLengthHash() {
        let userIds = ["a", "short_id", "this_is_a_very_long_user_identifier_string_123"]
        
        for userId in userIds {
            let hash = AnalyticsDataSanitizer.hashUserId(userId)
            XCTAssertEqual(hash.count, 24, "Hash should always be 24 chars (privacy truncation)")
        }
    }
    
    func test_hashUserId_withSpecialCharacters() {
        let userId = "user+123@example.com/path?query=1"
        let hash = AnalyticsDataSanitizer.hashUserId(userId)
        
        XCTAssertEqual(hash.count, 24)
        XCTAssertTrue(hash.allSatisfy { $0.isHexDigit || $0 == "x" }, "Hash should contain only hex + x")
    }
    
    // MARK: - Score Bucketing (Privacy)
    
    func test_bucketScore_groupsIntoRanges() {
        let cases: [(Int, String)] = [
            (0, "0-10"),
            (5, "0-10"),
            (10, "10-20"),
            (15, "10-20"),
            (99, "90-100"),
        ]
        
        for (score, expected) in cases {
            let result = AnalyticsDataSanitizer.bucketScore(score)
            XCTAssertEqual(result, expected)
        }
    }
    
    func test_bucketScore_clampsNegativeAndOverflow() {
        let negResult = AnalyticsDataSanitizer.bucketScore(-5)
        XCTAssertEqual(negResult, "0-10", "Negative scores should clamp to 0")
        
        let overResult = AnalyticsDataSanitizer.bucketScore(150)
        XCTAssertEqual(overResult, "140-150", "Over 100 should still bucket")
    }
    
    func test_bucketScore_preventsExactScoreLeakage() {
        let event73 = AnalyticsEvent.examCompleted(score: 73, passed: true, durationSeconds: 0)
        let event74 = AnalyticsEvent.examCompleted(score: 74, passed: true, durationSeconds: 0)
        
        XCTAssertEqual(
            event73.parameters["score_bucket"] as? String,
            event74.parameters["score_bucket"] as? String
        )
        // Both should bucket to "70-80", preventing fingerprinting attacks
    }
    
    // MARK: - Date Bucketing (Privacy)
    
    func test_dateToWeekBucket_extractsWeekNumber() {
        let calendar = Calendar.current
        let date = Date(timeIntervalSince1970: 1000000000)  // Fixed date for testing
        
        let week = AnalyticsDataSanitizer.dateToWeekBucket(date)
        
        let expectedWeek = calendar.component(.weekOfYear, from: date)
        XCTAssertEqual(week, expectedWeek)
    }
    
    func test_dateToWeekBucket_sameWeekProduce​sSameValue() {
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        let week1 = AnalyticsDataSanitizer.dateToWeekBucket(today)
        let week2 = AnalyticsDataSanitizer.dateToWeekBucket(tomorrow)
        
        if calendar.component(.weekOfYear, from: today) == calendar.component(.weekOfYear, from: tomorrow) {
            XCTAssertEqual(week1, week2, "Same calendar week should produce same week number")
        }
    }
    
    // MARK: - Duration Bucketing
    
    func test_bucketDuration_groupsTimeRanges() {
        let cases: [(Int, String)] = [
            (0, "0-60"),
            (30, "0-60"),
            (60, "60-120"),
            (119, "60-120"),
            (1800, "1800-1860"),
        ]
        
        for (seconds, expected) in cases {
            let result = AnalyticsDataSanitizer.bucketDuration(seconds, bucketSeconds: 60)
            XCTAssertEqual(result, expected)
        }
    }
}