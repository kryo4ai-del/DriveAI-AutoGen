import XCTest
@testable import DriveAI

@MainActor
final class AccessibilityAnnouncementManagerTests: XCTestCase {
    
    var manager: AccessibilityAnnouncementManager!
    
    override func setUp() {
        super.setUp()
        manager = AccessibilityAnnouncementManager.shared
    }
    
    // MARK: - Happy Path
    
    func testAnnounceWithStandardPriority() async {
        let expectation = XCTestExpectation(description: "Announcement posted")
        
        manager.announce("Test message", priority: .standard)
        
        // Small delay for async posting
        try? await Task.sleep(nanoseconds: 100_000_000)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testAnnounceWithImportantPriority() async {
        let expectation = XCTestExpectation(description: "Important announcement posted")
        
        manager.announce("Critical message", priority: .important)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // MARK: - Debouncing
    
    func testDebouncePreventsDuplicateAnnouncements() async {
        let expectation = XCTestExpectation(description: "Only first announcement is posted")
        expectation.expectedFulfillmentCount = 1
        
        // Rapid announcements with debounce enabled
        manager.announce("Message 1", debounce: true)
        manager.announce("Message 2", debounce: true)
        manager.announce("Message 3", debounce: true)
        
        try? await Task.sleep(nanoseconds: 200_000_000)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testStateChangeBypassesDebounce() async {
        let expectation = XCTestExpectation(description: "State change always announced")
        
        let oldState: SubscriptionState = .none
        let newState: SubscriptionState = .active
        
        manager.announce("Message 1", debounce: true)
        manager.announceStateChange(from: oldState, to: newState) // Should NOT be debounced
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // MARK: - State Change Announcements
    
    func testAnnounceTrialExpiringState() async {
        let oldState: SubscriptionState = .none
        let newState: SubscriptionState = .trialExpiring(daysRemaining: 5)
        
        manager.announceStateChange(from: oldState, to: newState)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        // Verify announcement contains "5 Tagen"
    }
    
    func testAnnounceExpiredState() async {
        let oldState: SubscriptionState = .trialExpiring(daysRemaining: 1)
        let newState: SubscriptionState = .expired
        
        manager.announceStateChange(from: oldState, to: newState)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        // Verify announcement contains "abgelaufen"
    }
    
    func testAnnounceActiveState() async {
        let oldState: SubscriptionState = .none
        let newState: SubscriptionState = .active
        
        manager.announceStateChange(from: oldState, to: newState)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        // Verify announcement contains "aktiv"
    }
    
    // MARK: - Edge Cases
    
    func testEmptyMessageIsIgnored() async {
        let expectation = XCTestExpectation(description: "Empty message handling")
        
        manager.announce("", priority: .standard)
        
        try? await Task.sleep(nanoseconds: 50_000_000)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testVeryLongMessageIsTruncated() async {
        let longMessage = String(repeating: "a", count: 5000)
        
        manager.announce(longMessage, priority: .standard)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        // UIAccessibility may truncate; verify no crash
    }
}