import XCTest
@testable import DriveAI

@MainActor
final class TrialExpiringViewModelTests: XCTestCase {
    
    var viewModel: TrialExpiringViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = TrialExpiringViewModel(daysRemaining: 5)
    }
    
    // MARK: - Initialization
    
    func testInitializationWithDaysRemaining() {
        XCTAssertEqual(viewModel.daysRemaining, 5)
        XCTAssertFalse(viewModel.hasAnnouncedOnce)
    }
    
    func testInitializationWithZeroDays() {
        viewModel = TrialExpiringViewModel(daysRemaining: 0)
        XCTAssertEqual(viewModel.daysRemaining, 0)
    }
    
    func testInitializationWithNegativeDays() {
        viewModel = TrialExpiringViewModel(daysRemaining: -1)
        XCTAssertEqual(viewModel.daysRemaining, -1)
    }
    
    // MARK: - Announcement Logic
    
    func testAnnounceTrialStatusOnFirstCall() async {
        XCTAssertFalse(viewModel.hasAnnouncedOnce)
        
        viewModel.announceTrialStatus()
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(viewModel.hasAnnouncedOnce)
    }
    
    func testAnnounceTrialStatusNotCalledTwice() async {
        viewModel.announceTrialStatus()
        XCTAssertTrue(viewModel.hasAnnouncedOnce)
        
        // Second call should be ignored
        viewModel.announceTrialStatus()
        
        try? await Task.sleep(nanoseconds: 50_000_000)
        // hasAnnouncedOnce should still be true
        XCTAssertTrue(viewModel.hasAnnouncedOnce)
    }
    
    // MARK: - Urgency Levels
    
    func testCriticalUrgencyAt3Days() async {
        viewModel = TrialExpiringViewModel(daysRemaining: 3)
        
        viewModel.announceTrialStatus()
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(viewModel.hasAnnouncedOnce)
        // Announcement should be "urgent"
    }
    
    func testCriticalUrgencyAt1Day() async {
        viewModel = TrialExpiringViewModel(daysRemaining: 1)
        
        viewModel.announceTrialStatus()
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(viewModel.hasAnnouncedOnce)
    }
    
    func testNormalUrgencyAt5Days() async {
        viewModel = TrialExpiringViewModel(daysRemaining: 5)
        
        viewModel.announceTrialStatus()
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(viewModel.hasAnnouncedOnce)
        // Announcement should be normal priority
    }
    
    // MARK: - Edge Cases
    
    func testAnnounceWith30DaysRemaining() async {
        viewModel = TrialExpiringViewModel(daysRemaining: 30)
        
        viewModel.announceTrialStatus()
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(viewModel.hasAnnouncedOnce)
    }
}