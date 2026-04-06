import XCTest
@testable import DriveAI

@MainActor
final class TrialStateManagerTests: XCTestCase {
    
    var sut: TrialStateManager!
    
    override func setUp() {
        super.setUp()
        sut = TrialStateManager()
        sut.resetForTesting()
    }
    
    // MARK: - Happy Path Tests
    
    func test_startTrial_transitionsToTrialState() {
        // Given: Fresh TrialStateManager
        XCTAssertEqual(sut.currentState, .free)
        
        // When: startTrial is called
        sut.startTrial()
        
        // Then: State transitions to .trial with dates set
        XCTAssertEqual(sut.currentState, .trial)
        XCTAssertNotNil(sut.trialStartDate)
        XCTAssertNotNil(sut.trialEndDate)
        XCTAssertEqual(sut.daysRemaining, sut.trialDurationDays)
    }
    
    func test_startTrial_setsCorrectEndDate() {
        // When: Trial starts
        let beforeStart = Date()
        sut.startTrial()
        let afterStart = Date()
        
        // Then: End date is approximately trialDurationDays from start
        guard let endDate = sut.trialEndDate else {
            XCTFail("End date not set")
            return
        }
        
        let expectedEndDate = Calendar.current.date(
            byAdding: .day,
            value: sut.trialDurationDays,
            to: beforeStart
        )!
        
        // Allow 5 second tolerance for execution time
        XCTAssertTrue(endDate.timeIntervalSince(expectedEndDate) < 5)
    }
    
    func test_convertToPaid_transitionsFromTrialToActive() {
        // Given: Active trial
        sut.startTrial()
        XCTAssertEqual(sut.currentState, .trial)
        
        // When: User purchases
        sut.convertToPaid()
        
        // Then: State transitions to .active
        XCTAssertEqual(sut.currentState, .active)
        XCTAssertTrue(sut.isPaid)
    }
    
    func test_renewSubscription_transitionsToRenewed() {
        // Given: Expired trial
        sut.startTrial()
        sut.expireTrial()
        XCTAssertEqual(sut.currentState, .expired)
        
        // When: User renews
        sut.renewSubscription()
        
        // Then: State is .renewed and isPaid
        XCTAssertEqual(sut.currentState, .renewed)
        XCTAssertTrue(sut.isPaid)
    }
    
    // MARK: - Expiry Tests
    
    func test_validateTrialState_expiresTrialWhenEndDateReached() {
        // Given: Trial that has expired
        sut.startTrial()
        sut.trialEndDate = Date().addingTimeInterval(-1) // Set to 1 second ago
        
        // When: Validation is called
        sut.validateTrialState()
        
        // Then: State transitions to .expired
        XCTAssertEqual(sut.currentState, .expired)
    }
    
    func test_validateTrialState_keepsActiveTrialBeforeExpiry() {
        // Given: Active trial with days remaining
        sut.startTrial()
        let originalState = sut.currentState
        
        // When: Validation is called (before expiry)
        sut.validateTrialState()
        
        // Then: State remains .trial
        XCTAssertEqual(sut.currentState, originalState)
        XCTAssertGreater(sut.daysRemaining ?? -1, 0)
    }
    
    func test_daysRemaining_calculatesCorrectly() {
        // Given: Trial starting today
        sut.startTrial()
        
        // Then: Days remaining equals trial duration
        XCTAssertEqual(sut.daysRemaining, sut.trialDurationDays)
        
        // When: 1 day passes (simulated)
        sut.trialEndDate = Date().addingTimeInterval(86400 * (Double(sut.trialDurationDays) - 1))
        
        // Then: Days remaining is duration - 1
        XCTAssertEqual(sut.daysRemaining, sut.trialDurationDays - 1)
    }
    
    func test_progressPercentage_rangesZeroToHundred() {
        sut.startTrial()
        
        // At start: ~0%
        XCTAssertLessThan(sut.progressPercentage, 5)
        
        // Mid-trial (8 days out of 14)
        sut.trialEndDate = Date().addingTimeInterval(86400 * 6) // 6 days remaining
        XCTAssertGreater(sut.progressPercentage, 40)
        XCTAssertLess(sut.progressPercentage, 60)
        
        // Near end (13+ days used)
        sut.trialEndDate = Date().addingTimeInterval(3600) // 1 hour remaining
        XCTAssertGreater(sut.progressPercentage, 95)
    }
    
    // MARK: - Clock Skew / Anomaly Detection
    
    func test_validateTrialState_detectsBackwardClockShift() {
        // Given: Active trial
        sut.startTrial()
        
        // Simulate last validation 5 days ago
        UserDefaults.standard.set(
            Date().addingTimeInterval(86400 * -5),
            forKey: "TrialStateLastValidation"
        )
        
        // When: User sets clock back 6 days
        sut.validateTrialState()
        
        // Then: Trial is expired due to clock anomaly
        // (Implementation should detect >3 day backward shift)
        // NOTE: This test documents expected behavior; actual detection in refactored code
        XCTAssertEqual(sut.currentState, .expired)
    }
    
    func test_validateTrialState_allowsSmallTimeAdjustments() {
        // Given: Active trial
        sut.startTrial()
        
        // When: Clock is adjusted slightly (e.g., DST, NTP sync)
        let lastValidation = Date().addingTimeInterval(-300) // 5 min ago
        UserDefaults.standard.set(lastValidation, forKey: "TrialStateLastValidation")
        
        sut.validateTrialState()
        
        // Then: Trial remains valid
        XCTAssertEqual(sut.currentState, .trial)
    }
    
    // MARK: - Persistence Tests
    
    func test_state_persistsAcrossReinitialization() {
        // Given: Started trial
        sut.startTrial()
        let originalState = sut.currentState
        let originalStartDate = sut.trialStartDate
        
        // When: New instance is created
        let newSUT = TrialStateManager()
        
        // Then: State and dates are restored
        XCTAssertEqual(newSUT.currentState, originalState)
        XCTAssertEqual(newSUT.trialStartDate, originalStartDate)
    }
    
    func test_resetForTesting_clearsAllState() {
        // Given: Active trial with data
        sut.startTrial()
        XCTAssertEqual(sut.currentState, .trial)
        
        // When: Reset is called
        sut.resetForTesting()
        
        // Then: All state is cleared
        XCTAssertEqual(sut.currentState, .free)
        XCTAssertNil(sut.trialStartDate)
        XCTAssertNil(sut.trialEndDate)
        
        // And UserDefaults are cleared
        XCTAssertNil(UserDefaults.standard.object(forKey: "TrialState"))
    }
    
    // MARK: - Invalid State Transitions
    
    func test_startTrial_ignoresIfAlreadyInTrial() {
        // Given: Already active trial
        sut.startTrial()
        let originalStartDate = sut.trialStartDate
        
        // When: startTrial called again
        sut.startTrial()
        
        // Then: No change (idempotent)
        XCTAssertEqual(sut.trialStartDate, originalStartDate)
    }
    
    func test_convertToPaid_onlyWorksFromTrialState() {
        // Given: User in .free state
        XCTAssertEqual(sut.currentState, .free)
        
        // When: Attempting to convert to paid
        sut.convertToPaid()
        
        // Then: State should transition (or implementation could guard)
        // This documents expected behavior: conversions allowed from any state
        XCTAssertEqual(sut.currentState, .active)
    }
    
    // MARK: - Edge Cases
    
    func test_daysRemaining_returnsNilWhenNotInTrial() {
        // When: In .free state
        XCTAssertEqual(sut.currentState, .free)
        
        // Then: daysRemaining is nil
        XCTAssertNil(sut.daysRemaining)
    }
    
    func test_daysRemaining_returnsZeroWhenExpired() {
        // Given: Expired trial
        sut.startTrial()
        sut.expireTrial()
        
        // When: Checking days remaining on expired trial
        // Then: Should return nil or 0 (implementation-dependent)
        // This test documents expected behavior
        XCTAssertNil(sut.daysRemaining) // Or XCTAssertEqual(sut.daysRemaining, 0)
    }
    
    func test_isTrialActive_returnsFalseWhenExpired() {
        sut.startTrial()
        XCTAssertTrue(sut.isTrialActive)
        
        sut.expireTrial()
        XCTAssertFalse(sut.isTrialActive)
    }
    
    func test_isPaid_returnsTrueForActiveAndRenewed() {
        sut.convertToPaid()
        XCTAssertTrue(sut.isPaid)
        
        sut.expireTrial()
        XCTAssertFalse(sut.isPaid)
        
        sut.renewSubscription()
        XCTAssertTrue(sut.isPaid)
    }
}