// Tests/Notifications/NotificationPermissionTrackerTests.swift
import XCTest
@testable import DriveAI

final class NotificationPermissionTrackerTests: XCTestCase {
    
    private var tracker: NotificationPermissionTracker!
    private var mockUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        // Use in-memory UserDefaults for testing
        mockUserDefaults = UserDefaults(suiteName: "test_\(UUID().uuidString)")
        tracker = NotificationPermissionTracker(userDefaults: mockUserDefaults)
    }
    
    override func tearDown() {
        super.tearDown()
        mockUserDefaults.removePersistentDomain(forName: mockUserDefaults.suiteName ?? "")
    }
    
    // MARK: - Happy Path Tests
    
    func testCanRequest_WhenStateIsNever_ReturnsTrue() {
        let trigger = NotificationTrigger.examCompletion
        
        let canRequest = tracker.canRequest(for: trigger)
        
        XCTAssertTrue(canRequest, "Should allow request when permission state is .never")
    }
    
    func testRecordAcceptance_SetsStateToAccepted() {
        let trigger = NotificationTrigger.examCompletion
        
        tracker.recordAcceptance(trigger: trigger)
        let state = tracker.getState(for: trigger)
        
        switch state {
        case .accepted:
            XCTAssertTrue(true, "State should be .accepted")
        default:
            XCTFail("Expected .accepted state, got \(state)")
        }
    }
    
    func testCanRequest_AfterAcceptance_ReturnsFalse() {
        let trigger = NotificationTrigger.examCompletion
        
        tracker.recordAcceptance(trigger: trigger)
        let canRequest = tracker.canRequest(for: trigger)
        
        XCTAssertFalse(canRequest, "Should not request again after acceptance")
    }
    
    // MARK: - Dismissal & Backoff Logic
    
    func testRecordDismissal_SetsStateToDenieWithRetryDate() {
        let trigger = NotificationTrigger.streakMilestone
        let retryDays = 7
        
        tracker.recordDismissal(trigger: trigger, retryAfterDays: retryDays)
        let state = tracker.getState(for: trigger)
        
        switch state {
        case .denied(_, let nextRetryDate):
            XCTAssertNotNil(nextRetryDate, "Retry date should be set")
            let expectedDate = Calendar.current.date(
                byAdding: .day,
                value: retryDays,
                to: Date()
            )
            let diff = abs(nextRetryDate!.timeIntervalSince(expectedDate ?? Date()))
            XCTAssertLessThan(diff, 1.0, "Retry date should be within 1 second of expected")
        default:
            XCTFail("Expected .denied state, got \(state)")
        }
    }
    
    func testCanRequest_AfterDismissal_ReturnsFalse() {
        let trigger = NotificationTrigger.categoryMilestone
        
        tracker.recordDismissal(trigger: trigger, retryAfterDays: 7)
        let canRequest = tracker.canRequest(for: trigger)
        
        XCTAssertFalse(canRequest, "Should not request before retry period expires")
    }
    
    func testCanRequest_AfterRetryDateExpires_ReturnsTrue() {
        let trigger = NotificationTrigger.dailyReminder
        
        // Record dismissal with past retry date
        tracker.recordDismissal(trigger: trigger, retryAfterDays: -1)  // Expired
        let canRequest = tracker.canRequest(for: trigger)
        
        XCTAssertTrue(canRequest, "Should allow request after retry period expires")
    }
    
    // MARK: - State Persistence
    
    func testState_PersistsToUserDefaults() {
        let trigger = NotificationTrigger.examCompletion
        
        tracker.recordAcceptance(trigger: trigger)
        
        // Create new tracker with same UserDefaults
        let newTracker = NotificationPermissionTracker(userDefaults: mockUserDefaults)
        let state = newTracker.getState(for: trigger)
        
        switch state {
        case .accepted:
            XCTAssertTrue(true, "State should persist across tracker instances")
        default:
            XCTFail("Expected persisted .accepted state, got \(state)")
        }
    }
    
    func testState_CorrectlyDecodesCorruptedData_DefaultsToNever() {
        let trigger = NotificationTrigger.examCompletion
        let key = "notification_permission_\(trigger.rawValue)"
        
        // Corrupt the saved data
        mockUserDefaults.set("invalid_json_data".data(using: .utf8), forKey: key)
        
        let state = tracker.getState(for: trigger)
        
        switch state {
        case .never:
            XCTAssertTrue(true, "Should default to .never on corrupted data")
        default:
            XCTFail("Expected .never state, got \(state)")
        }
    }
    
    // MARK: - Trigger Independence
    
    func testDifferentTriggers_MaintainSeparateStates() {
        let trigger1 = NotificationTrigger.examCompletion
        let trigger2 = NotificationTrigger.streakMilestone
        
        tracker.recordAcceptance(trigger: trigger1)
        tracker.recordDismissal(trigger: trigger2, retryAfterDays: 7)
        
        let state1 = tracker.getState(for: trigger1)
        let state2 = tracker.getState(for: trigger2)
        
        switch (state1, state2) {
        case (.accepted, .denied):
            XCTAssertTrue(true, "Triggers should maintain separate states")
        default:
            XCTFail("States should be independent: got \(state1) and \(state2)")
        }
    }
    
    // MARK: - Edge Cases
    
    func testRecordDismissal_WithZeroRetryDays_AllowsImmediateRetry() {
        let trigger = NotificationTrigger.examCompletion
        
        tracker.recordDismissal(trigger: trigger, retryAfterDays: 0)
        let canRequest = tracker.canRequest(for: trigger)
        
        XCTAssertTrue(canRequest, "Zero retry days should allow immediate retry")
    }
    
    func testRecordDismissal_WithNegativeRetryDays_AllowsImmediateRetry() {
        let trigger = NotificationTrigger.streakMilestone
        
        tracker.recordDismissal(trigger: trigger, retryAfterDays: -1)
        let canRequest = tracker.canRequest(for: trigger)
        
        XCTAssertTrue(canRequest, "Negative retry days should allow immediate retry")
    }
    
    // MARK: - Concurrent Access Tests
    
    func testConcurrentRecordAcceptance_DoesNotCauseCrash() {
        let trigger = NotificationTrigger.examCompletion
        let dispatchGroup = DispatchGroup()
        
        // Simulate concurrent calls from multiple threads
        for i in 0..<10 {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                self.tracker.recordAcceptance(trigger: trigger)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.wait(timeout: .now() + 5)
        
        // Final state should still be accepted
        let state = tracker.getState(for: trigger)
        switch state {
        case .accepted:
            XCTAssertTrue(true, "Concurrent calls should not corrupt state")
        default:
            XCTFail("State corrupted after concurrent access: \(state)")
        }
    }
    
    func testConcurrentCanRequest_ReturnsConsistentResults() {
        let trigger = NotificationTrigger.categoryMilestone
        tracker.recordAcceptance(trigger: trigger)
        
        let dispatchGroup = DispatchGroup()
        var results: [Bool] = []
        let lock = NSLock()
        
        for _ in 0..<20 {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                let canRequest = self.tracker.canRequest(for: trigger)
                lock.lock()
                results.append(canRequest)
                lock.unlock()
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.wait(timeout: .now() + 5)
        
        let allFalse = results.allSatisfy { $0 == false }
        XCTAssertTrue(allFalse, "All concurrent reads should return consistent false")
    }
    
    // MARK: - State Transitions
    
    func testStateTransition_NeverToAcceptedToNever_Invalid() {
        let trigger = NotificationTrigger.dailyReminder
        
        tracker.recordAcceptance(trigger: trigger)
        // Attempted transition back to .never should not happen (no API for it)
        // This test documents that transitions are one-directional
        
        let state = tracker.getState(for: trigger)
        switch state {
        case .accepted:
            XCTAssertTrue(true, "Cannot transition back to .never")
        default:
            XCTFail("Unexpected state: \(state)")
        }
    }
    
    func testStateTransition_AcceptedToDenied_NotAllowed() {
        let trigger = NotificationTrigger.examCompletion
        
        tracker.recordAcceptance(trigger: trigger)
        // No API to transition from .accepted to .denied
        // Documenting intended behavior
        
        let canRequest = tracker.canRequest(for: trigger)
        XCTAssertFalse(canRequest, "Accepted state should persist")
    }
}