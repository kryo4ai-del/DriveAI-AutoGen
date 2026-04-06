// Tests/Models/ConsentStateTests.swift
import XCTest
@testable import DriveAI

final class NotificationPreferenceTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testDefaultPreferenceState() {
        let preference = NotificationPreference()
        
        XCTAssertEqual(preference.consentState, .notAsked)
        XCTAssertNil(preference.acceptedAt)
        XCTAssertNil(preference.declinedAt)
        XCTAssertEqual(preference.deferralCount, 0)
        XCTAssertEqual(preference.dailyReminderTime.hour, 8)
        XCTAssertEqual(preference.dailyReminderTime.minute, 0)
    }
    
    // MARK: - shouldPromptAgain Logic
    
    func testShouldPromptAgain_WhenNotAsked() {
        var preference = NotificationPreference()
        preference.consentState = .notAsked
        
        XCTAssertTrue(preference.shouldPromptAgain)
    }
    
    func testShouldPromptAgain_WhenAccepted() {
        var preference = NotificationPreference()
        preference.consentState = .accepted
        
        XCTAssertFalse(preference.shouldPromptAgain)
    }
    
    func testShouldPromptAgain_WhenDeclined() {
        var preference = NotificationPreference()
        preference.consentState = .declined
        
        XCTAssertFalse(preference.shouldPromptAgain)
    }
    
    func testShouldPromptAgain_WhenDeferredAndDatePassed() {
        var preference = NotificationPreference()
        preference.consentState = .deferred
        preference.deferredUntil = Date().addingTimeInterval(-3600)  // 1 hour ago
        
        XCTAssertTrue(preference.shouldPromptAgain)
    }
    
    func testShouldPromptAgain_WhenDeferredAndDateNotPassed() {
        var preference = NotificationPreference()
        preference.consentState = .deferred
        preference.deferredUntil = Date().addingTimeInterval(86400)  // 1 day from now
        
        XCTAssertFalse(preference.shouldPromptAgain)
    }
    
    func testShouldPromptAgain_WhenDeferredWithoutDate() {
        var preference = NotificationPreference()
        preference.consentState = .deferred
        preference.deferredUntil = nil
        
        XCTAssertTrue(preference.shouldPromptAgain)
    }
    
    func testShouldPromptAgain_AcceptedButSystemDenied() {
        var preference = NotificationPreference()
        preference.consentState = .acceptedButSystemDenied
        
        XCTAssertFalse(preference.shouldPromptAgain)
    }
    
    // MARK: - Deferral Logic
    
    func testCanDeferAgain_UnderLimit() {
        var preference = NotificationPreference()
        preference.deferralCount = 0
        XCTAssertTrue(preference.canDeferAgain)
        
        preference.deferralCount = 2
        XCTAssertTrue(preference.canDeferAgain)
    }
    
    func testCanDeferAgain_AtLimit() {
        var preference = NotificationPreference()
        preference.deferralCount = 3
        
        XCTAssertFalse(preference.canDeferAgain)
    }
    
    func testCanDeferAgain_ExceedsLimit() {
        var preference = NotificationPreference()
        preference.deferralCount = 5
        
        XCTAssertFalse(preference.canDeferAgain)
    }
    
    // MARK: - Encoding/Decoding
    
    func testEncodingAndDecoding() throws {
        var original = NotificationPreference()
        original.consentState = .accepted
        original.acceptedAt = Date()
        original.deferralCount = 2
        original.dailyReminderTime.hour = 19
        original.dailyReminderTime.minute = 30
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(NotificationPreference.self, from: encoded)
        
        XCTAssertEqual(decoded.consentState, .accepted)
        XCTAssertEqual(decoded.deferralCount, 2)
        XCTAssertEqual(decoded.dailyReminderTime.hour, 19)
        XCTAssertEqual(decoded.dailyReminderTime.minute, 30)
    }
    
    func testEncodingEmptyPreference() throws {
        let preference = NotificationPreference()
        
        let encoded = try JSONEncoder().encode(preference)
        let decoded = try JSONDecoder().decode(NotificationPreference.self, from: encoded)
        
        XCTAssertEqual(decoded, preference)
    }
}

// Tests/Models/ConsentErrorTests.swift
final class ConsentErrorTests: XCTestCase {
    
    func testSystemAuthorizationDeniedError() {
        let error = ConsentError.systemAuthorizationDenied
        
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Systemebene") ?? false)
    }
    
    func testNotificationSchedulingFailedError() {
        let underlyingError = NSError(domain: "Test", code: -1)
        let error = ConsentError.notificationSchedulingFailed(underlyingError)
        
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Benachrichtigungen") ?? false)
    }
    
    func testStorageFailureError() {
        let error = ConsentError.storageFailure
        
        XCTAssertNotNil(error.errorDescription)
    }
}