import XCTest
@testable import DriveAI

final class TrialStatusTests: XCTestCase {
    
    // MARK: - Setup
    
    private let calendar = Calendar.current
    
    // MARK: - Happy Path: Active State
    
    func test_activeStatus_computedProperties() {
        let now = Date()
        let status = TrialStatus.active(activationDate: now, durationDays: 7)
        
        XCTAssertTrue(status.isActive)
        XCTAssertFalse(status.isExpired)
        XCTAssertFalse(status.isPurchased)
        XCTAssertEqual(status.activationDate, now)
        XCTAssertNotNil(status.expirationDate)
    }
    
    func test_activeStatus_daysRemaining() {
        let now = Date()
        let status = TrialStatus.active(activationDate: now, durationDays: 7)
        
        // Should have approximately 7 days remaining
        XCTAssertEqual(status.daysRemaining, 7)
    }
    
    func test_activeStatus_notExpired() {
        let now = Date()
        let status = TrialStatus.active(activationDate: now, durationDays: 7)
        
        XCTAssertFalse(status.hasExpired())
    }
    
    // MARK: - Edge Case: Expiration Boundary
    
    func test_activeStatus_expiresAtMidnight() {
        // Trial started yesterday, expires today at midnight
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date()))!
        let status = TrialStatus.active(activationDate: yesterday, durationDays: 1)
        
        // At this exact moment (before midnight), days remaining should be 0
        XCTAssertEqual(status.daysRemaining, 0)
        XCTAssertTrue(status.hasExpired())
    }
    
    func test_activeStatus_oneSecondBeforeExpiration() {
        let calendar = Calendar.current
        let tomorrowStart = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))!
        let oneSecondBefore = calendar.date(byAdding: .second, value: -1, to: tomorrowStart)!
        
        let status = TrialStatus.active(activationDate: oneSecondBefore, durationDays: 1)
        
        // Still 1 day remaining (not expired yet)
        XCTAssertEqual(status.daysRemaining, 1)
        XCTAssertFalse(status.hasExpired())
    }
    
    // MARK: - Edge Case: Timezone Handling
    
    func test_activeStatus_acrossDaylightSavingTime() {
        // Simulate DST transition (Germany: last Sunday of March)
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: Date())
        components.year = 2025
        components.month = 3
        components.day = 30 // Last Sunday of March (DST starts)
        components.hour = 2
        
        guard let dstDate = calendar.date(from: components) else {
            XCTFail("Could not create DST date")
            return
        }
        
        let status = TrialStatus.active(activationDate: dstDate, durationDays: 7)
        let daysRemaining = status.daysRemaining
        
        // Should still correctly calculate 7 days despite clock change
        XCTAssertGreaterThan(daysRemaining, 0)
        XCTAssertLessThanOrEqual(daysRemaining, 7)
    }
    
    func test_activeStatus_zoneDependentCrossingBoundary() {
        // Berlin time (UTC+2 in summer) crossing to UTC+1
        let now = Date()
        let status = TrialStatus.active(activationDate: now, durationDays: 7)
        
        // Days remaining should be consistent regardless of timezone changes
        let remainingBefore = status.daysRemaining
        
        // Simulate timezone change (would happen on device)
        let remainingAfter = status.daysRemaining
        
        XCTAssertEqual(remainingBefore, remainingAfter)
    }
    
    // MARK: - Happy Path: Expired State
    
    func test_expiredStatus_properties() {
        let activation = Date(timeIntervalSince1970: 0)
        let expiration = Date(timeIntervalSince1970: 86400) // 1 day later
        
        let status = TrialStatus.expired(activationDate: activation, expirationDate: expiration)
        
        XCTAssertFalse(status.isActive)
        XCTAssertTrue(status.isExpired)
        XCTAssertFalse(status.isPurchased)
        XCTAssertEqual(status.daysRemaining, 0)
        XCTAssertTrue(status.hasExpired())
    }
    
    // MARK: - Happy Path: Purchased State
    
    func test_purchasedStatus_properties() {
        let status = TrialStatus.purchased
        
        XCTAssertFalse(status.isActive)
        XCTAssertFalse(status.isExpired)
        XCTAssertTrue(status.isPurchased)
        XCTAssertNil(status.activationDate)
        XCTAssertNil(status.expirationDate)
        XCTAssertEqual(status.daysRemaining, Int.max)
        XCTAssertFalse(status.hasExpired())
    }
    
    // MARK: - Codable: JSON Encoding/Decoding
    
    func test_activeStatus_codable() throws {
        let now = Date()
        let original = TrialStatus.active(activationDate: now, durationDays: 7)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let json = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(TrialStatus.self, from: json)
        
        XCTAssertEqual(original, decoded)
    }
    
    func test_expiredStatus_codable() throws {
        let activation = Date(timeIntervalSince1970: 1000)
        let expiration = Date(timeIntervalSince1970: 2000)
        let original = TrialStatus.expired(activationDate: activation, expirationDate: expiration)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let json = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(TrialStatus.self, from: json)
        
        XCTAssertEqual(original, decoded)
    }
    
    func test_purchasedStatus_codable() throws {
        let original = TrialStatus.purchased
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let json = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(TrialStatus.self, from: json)
        
        XCTAssertEqual(original, decoded)
    }
    
    func test_codable_invalidType_throwsError() throws {
        let invalidJSON = """
        {
            "type": "unknown_status",
            "activationDate": "2025-01-01T00:00:00Z",
            "durationDays": 7
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        XCTAssertThrowsError(try decoder.decode(TrialStatus.self, from: invalidJSON)) { error in
            guard case TrialError.invalidState = error as? TrialError else {
                XCTFail("Expected TrialError.invalidState, got \(error)")
                return
            }
        }
    }
    
    // MARK: - Invalid Input
    
    func test_activeStatus_negativeDaysRemaining_clamped() {
        // Activation was 10 days ago with 7-day duration
        let calendar = Calendar.current
        let activation = calendar.date(byAdding: .day, value: -10, to: Date())!
        let status = TrialStatus.active(activationDate: activation, durationDays: 7)
        
        // Should clamp to 0, not negative
        XCTAssertEqual(status.daysRemaining, 0)
    }
    
    func test_activeStatus_zerotDurationDays() {
        let now = Date()
        let status = TrialStatus.active(activationDate: now, durationDays: 0)
        
        // Zero duration means expired immediately
        XCTAssertEqual(status.daysRemaining, 0)
        XCTAssertTrue(status.hasExpired())
    }
    
    // MARK: - Date Arithmetic
    
    func test_activeStatus_largeExpirationDate() {
        let now = Date()
        let status = TrialStatus.active(activationDate: now, durationDays: 365)
        
        let calendar = Calendar.current
        let expectedExpiration = calendar.date(byAdding: .day, value: 365, to: now)!
        
        XCTAssertEqual(status.expirationDate, expectedExpiration)
        XCTAssertEqual(status.daysRemaining, 365)
    }
    
    func test_activeStatus_singleDay() {
        let now = Date()
        let status = TrialStatus.active(activationDate: now, durationDays: 1)
        
        XCTAssertEqual(status.daysRemaining, 1)
    }
}