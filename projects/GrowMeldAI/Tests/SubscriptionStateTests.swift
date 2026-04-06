import XCTest
@testable import DriveAI

final class SubscriptionStateTests: XCTestCase {
    
    // MARK: - State Active Checks
    
    func testIsActive_WithFutureTrialExpiry_ReturnsTrue() {
        // Arrange
        let futureDate = Date().addingTimeInterval(86400 * 10)  // 10 days
        let futureTimestamp = futureDate.timeIntervalSince1970 * 1000
        let state = SubscriptionState.trial(expiresAtTimestamp: futureTimestamp)
        
        // Act
        let isActive = state.isActive
        
        // Assert
        XCTAssertTrue(isActive, "Trial with future expiry should be active")
    }
    
    func testIsActive_WithPastTrialExpiry_ReturnsFalse() {
        // Arrange
        let pastDate = Date().addingTimeInterval(-86400)  // 1 day ago
        let pastTimestamp = pastDate.timeIntervalSince1970 * 1000
        let state = SubscriptionState.trial(expiresAtTimestamp: pastTimestamp)
        
        // Act
        let isActive = state.isActive
        
        // Assert
        XCTAssertFalse(isActive, "Trial with past expiry should not be active")
    }
    
    func testIsActive_WithNotSubscribed_ReturnsFalse() {
        // Arrange
        let state = SubscriptionState.notSubscribed
        
        // Act
        let isActive = state.isActive
        
        // Assert
        XCTAssertFalse(isActive)
    }
    
    func testIsActive_WithCancelled_ReturnsFalse() {
        // Arrange
        let cancelDate = Date()
        let cancelTimestamp = cancelDate.timeIntervalSince1970 * 1000
        let state = SubscriptionState.cancelled(cancelledAtTimestamp: cancelTimestamp)
        
        // Act
        let isActive = state.isActive
        
        // Assert
        XCTAssertFalse(isActive)
    }
    
    // MARK: - Days Remaining Calculations
    
    func testDaysRemaining_WithExactlyOneDayLeft_ReturnsOne() {
        // Arrange
        let tomorrowMidnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        let timestamp = tomorrowMidnight.timeIntervalSince1970 * 1000
        let state = SubscriptionState.active(expiresAtTimestamp: timestamp)
        
        // Act
        let daysRemaining = state.daysRemaining(referenceDate: Date())
        
        // Assert
        XCTAssertEqual(daysRemaining, 1, "One day until expiry should return 1")
    }
    
    func testDaysRemaining_WithExpiredDate_ReturnsZero() {
        // Arrange
        let pastDate = Date().addingTimeInterval(-3600)  // 1 hour ago
        let pastTimestamp = pastDate.timeIntervalSince1970 * 1000
        let state = SubscriptionState.active(expiresAtTimestamp: pastTimestamp)
        
        // Act
        let daysRemaining = state.daysRemaining(referenceDate: Date())
        
        // Assert
        XCTAssertEqual(daysRemaining, 0, "Expired date should return 0 days")
    }
    
    func testDaysRemaining_With30DaysRemaining_Returns30() {
        // Arrange
        let futureDate = Date().addingTimeInterval(86400 * 30)
        let timestamp = futureDate.timeIntervalSince1970 * 1000
        let state = SubscriptionState.trial(expiresAtTimestamp: timestamp)
        
        // Act
        let daysRemaining = state.daysRemaining(referenceDate: Date())
        
        // Assert
        XCTAssertEqual(daysRemaining, 30, "30 days away should return 30")
    }
    
    func testDaysRemaining_WithNegativeValue_CannotBeNegative() {
        // Arrange
        let veryPastDate = Date().addingTimeInterval(-86400 * 365)
        let veryPastTimestamp = veryPastDate.timeIntervalSince1970 * 1000
        let state = SubscriptionState.expired(lastExpiryDateTimestamp: veryPastTimestamp)
        
        // Act
        let daysRemaining = state.daysRemaining(referenceDate: Date())
        
        // Assert
        XCTAssertGreaterThanOrEqual(daysRemaining, 0, "Days remaining should never be negative")
    }
    
    // MARK: - State Transitions
    
    func testCanTransition_FromNotSubscribed_ToAnyState_ReturnsTrue() {
        // Arrange
        let states: [SubscriptionState] = [
            .notSubscribed,
            .trial(expiresAtTimestamp: Date().timeIntervalSince1970 * 1000),
            .active(expiresAtTimestamp: Date().timeIntervalSince1970 * 1000),
            .expired(lastExpiryDateTimestamp: Date().timeIntervalSince1970 * 1000),
            .cancelled(cancelledAtTimestamp: Date().timeIntervalSince1970 * 1000)
        ]
        let fromState = SubscriptionState.notSubscribed
        
        // Act & Assert
        for toState in states {
            XCTAssertTrue(fromState.canTransition(to: toState),
                         "Should transition from notSubscribed to \(toState)")
        }
    }
    
    func testCanTransition_FromTrialToActive_ReturnsTrue() {
        // Arrange
        let trialState = SubscriptionState.trial(expiresAtTimestamp: 1700000000)
        let activeState = SubscriptionState.active(expiresAtTimestamp: 1700000000)
        
        // Act
        let canTransition = trialState.canTransition(to: activeState)
        
        // Assert
        XCTAssertTrue(canTransition)
    }
    
    func testCanTransition_FromTrialToNotSubscribed_ReturnsFalse() {
        // Arrange
        let trialState = SubscriptionState.trial(expiresAtTimestamp: 1700000000)
        let notSubscribedState = SubscriptionState.notSubscribed
        
        // Act
        let canTransition = trialState.canTransition(to: notSubscribedState)
        
        // Assert
        XCTAssertFalse(canTransition, "Trial cannot go directly to notSubscribed")
    }
    
    func testCanTransition_FromActiveToExpiredAndRenew_BothValid() {
        // Arrange
        let activeState = SubscriptionState.active(expiresAtTimestamp: 1700000000)
        let expiredState = SubscriptionState.expired(lastExpiryDateTimestamp: 1700000000)
        let renewedState = SubscriptionState.active(expiresAtTimestamp: 1700000000 + 365*86400*1000)
        
        // Act & Assert
        XCTAssertTrue(activeState.canTransition(to: expiredState),
                     "Active can transition to Expired")
        XCTAssertTrue(expiredState.canTransition(to: renewedState),
                     "Expired can transition to Active (renewal)")
    }
    
    func testCanTransition_FromCancelledBack_OnlyToNotSubscribed() {
        // Arrange
        let cancelledState = SubscriptionState.cancelled(cancelledAtTimestamp: 1700000000)
        let notSubscribedState = SubscriptionState.notSubscribed
        let activeState = SubscriptionState.active(expiresAtTimestamp: 1700000000)
        
        // Act & Assert
        XCTAssertTrue(cancelledState.canTransition(to: notSubscribedState),
                     "Cancelled can go back to notSubscribed")
        XCTAssertFalse(cancelledState.canTransition(to: activeState),
                      "Cancelled cannot go directly to active without notSubscribed")
    }
    
    // MARK: - Expiry Checks
    
    func testIsExpired_WithPastDate_ReturnsTrue() {
        // Arrange
        let pastDate = Date().addingTimeInterval(-3600)
        let pastTimestamp = pastDate.timeIntervalSince1970 * 1000
        let state = SubscriptionState.active(expiresAtTimestamp: pastTimestamp)
        
        // Act
        let isExpired = state.isExpired(at: Date())
        
        // Assert
        XCTAssertTrue(isExpired)
    }
    
    func testIsExpired_WithFutureDate_ReturnsFalse() {
        // Arrange
        let futureDate = Date().addingTimeInterval(86400)
        let futureTimestamp = futureDate.timeIntervalSince1970 * 1000
        let state = SubscriptionState.active(expiresAtTimestamp: futureTimestamp)
        
        // Act
        let isExpired = state.isExpired(at: Date())
        
        // Assert
        XCTAssertFalse(isExpired)
    }
    
    func testIsExpired_AtExactExpirtTime_ReturnsTrue() {
        // Arrange
        let referenceDate = Date()
        let refTimestamp = referenceDate.timeIntervalSince1970 * 1000
        let state = SubscriptionState.active(expiresAtTimestamp: refTimestamp)
        
        // Act
        let isExpired = state.isExpired(at: referenceDate)
        
        // Assert
        XCTAssertTrue(isExpired, "At exact expiry time should be expired")
    }
    
    // MARK: - Codable Roundtrip (Precision Test)
    
    func testCodable_RoundTripPreservesTimestampPrecision() throws {
        // Arrange
        let originalTimestamp: TimeInterval = 1700000000123  // 123 ms precision
        let originalState = SubscriptionState.trial(expiresAtTimestamp: originalTimestamp)
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // Act: Encode and decode
        let encoded = try encoder.encode(originalState)
        let decoded = try decoder.decode(SubscriptionState.self, from: encoded)
        
        // Assert: Timestamps must match exactly
        if case .trial(let decodedTimestamp) = decoded {
            XCTAssertEqual(decodedTimestamp, originalTimestamp,
                          "Timestamp precision lost in roundtrip encoding")
        } else {
            XCTFail("Decoded state is not .trial")
        }
    }
    
    func testCodable_MultipleRoundtrips_MaintainsPrecision() throws {
        // Arrange
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        var currentState = SubscriptionState.trial(expiresAtTimestamp: 1700000000123)
        
        // Act: Encode/decode 10 times
        for _ in 0..<10 {
            let encoded = try encoder.encode(currentState)
            currentState = try decoder.decode(SubscriptionState.self, from: encoded)
        }
        
        // Assert: Original timestamp must match final
        if case .trial(let finalTimestamp) = currentState {
            XCTAssertEqual(finalTimestamp, 1700000000123,
                          "Precision degraded after multiple roundtrips")
        } else {
            XCTFail("State changed unexpectedly")
        }
    }
    
    // MARK: - Display Text
    
    func testDisplayText_NotSubscribed_ReturnsGermanText() {
        // Arrange
        let state = SubscriptionState.notSubscribed
        
        // Act
        let text = state.displayText
        
        // Assert
        XCTAssertEqual(text, "Kein Abo")
    }
    
    func testDisplayText_TrialWith5Days_IncludesDayCount() {
        // Arrange
        let futureDate = Date().addingTimeInterval(86400 * 5)
        let timestamp = futureDate.timeIntervalSince1970 * 1000
        let state = SubscriptionState.trial(expiresAtTimestamp: timestamp)
        
        // Act
        let text = state.displayText
        
        // Assert
        XCTAssertTrue(text.contains("5 Tage"), "Should include day count in German")
    }
    
    func testDisplayText_ActiveSubscription_IncludesExpiryDate() {
        // Arrange
        let futureDate = Date().addingTimeInterval(86400 * 365)
        let timestamp = futureDate.timeIntervalSince1970 * 1000
        let state = SubscriptionState.active(expiresAtTimestamp: timestamp)
        
        // Act
        let text = state.displayText
        
        // Assert
        XCTAssertTrue(text.contains("Aktiv bis"), "Should indicate active status")
    }
}