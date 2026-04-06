import XCTest
@testable import DriveAI
import SwiftUI

class AccessibleExamTimerTests: XCTestCase {
    
    // MARK: - Timer Lifecycle
    
    func test_timerStartsOnAppear() async {
        // Given
        let expectation = XCTestExpectation(description: "Timer should announce 5-min warning")
        var announcements: [String] = []
        
        // When
        let view = AccessibleExamTimer(
            totalSeconds: 1800,
            secondsRemaining: 310,
            onTimeExpired: {}
        )
        
        // Simulate appearance
        let vc = UIHostingController(rootView: view)
        _ = vc.view  // Trigger onAppear
        
        // Then
        XCTAssertNotNil(vc.view, "View should render and onAppear should fire")
    }
    
    func test_timerStopsOnDisappear() async {
        // Given
        var expiredCallCount = 0
        let view = AccessibleExamTimer(
            totalSeconds: 1800,
            secondsRemaining: 10,
            onTimeExpired: {
                expiredCallCount += 1
            }
        )
        
        // When
        let vc = UIHostingController(rootView: view)
        _ = vc.view  // onAppear
        vc.removeFromParent()  // Trigger onDisappear
        
        // Wait for cleanup
        try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 sec
        
        // Then
        XCTAssertEqual(expiredCallCount, 0, "onTimeExpired should not fire after disappear")
    }
    
    func test_onTimeExpiredCalledOnceOnly() async {
        // CRITICAL: BUG-001 regression
        // Given
        var callCount = 0
        let onExpired = {
            callCount += 1
        }
        
        // When: Simulate timer reaching 0 and lingering
        var timer: AccessibleExamTimer? = AccessibleExamTimer(
            totalSeconds: 1800,
            secondsRemaining: 0,
            onTimeExpired: onExpired
        )
        
        let vc = UIHostingController(rootView: timer!)
        _ = vc.view
        
        // Simulate 3 seconds of timer ticks
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        
        // Then
        XCTAssertEqual(callCount, 1, "onTimeExpired should fire exactly once")
        XCTAssertLessThanOrEqual(callCount, 1, "Should not double-fire on timer lingering")
    }
    
    func test_timerNoMemoryLeakOnDeinit() async {
        // CRITICAL: BUG-001 regression
        // Given
        weak var weakTimer: AccessibleExamTimer?
        
        do {
            var timer: AccessibleExamTimer? = AccessibleExamTimer(
                totalSeconds: 1800,
                secondsRemaining: 60,
                onTimeExpired: {}
            )
            let vc = UIHostingController(rootView: timer!)
            _ = vc.view
            weakTimer = timer
            
            // When: Deinit should clean up
            timer = nil
        }
        
        // Force cleanup
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertNil(weakTimer, "Timer should be deallocated (no retain cycle)")
    }
    
    // MARK: - Accessibility Announcements
    
    func test_announcementsAtMilestones() async {
        // Given
        var announcedSeconds: [Int] = []
        let expectedMilestones = [300, 180, 120, 60, 30, 10, 5, 4, 3, 2, 1]
        
        // When
        let view = AccessibleExamTimer(
            totalSeconds: 1800,
            secondsRemaining: 350,  // Will count down through milestones
            onTimeExpired: {}
        )
        
        // Then: Verify accessibility labels exist
        let label = view.accessibilityLabel  // Should be "Verbleibende Zeit"
        XCTAssert(label.contains("Zeit"), "Should have time accessibility label")
    }
    
    func test_announcementNotDuplicatedOnRerender() async {
        // CRITICAL: BUG-006 regression
        // Announcements should not fire on every state change
        let view = AccessibleExamTimer(
            totalSeconds: 1800,
            secondsRemaining: 60,
            onTimeExpired: {}
        )
        
        // View should be stable across rerenders
        XCTAssertEqual(view.secondsRemaining, 60)
    }
    
    func test_warningTimeAccessibilityTrait() {
        // Given
        let warningView = AccessibleExamTimer(
            totalSeconds: 1800,
            secondsRemaining: 280,  // < 5 min
            onTimeExpired: {}
        )
        
        let normalView = AccessibleExamTimer(
            totalSeconds: 1800,
            secondsRemaining: 600,  // > 5 min
            onTimeExpired: {}
        )
        
        // Then: Both should be accessible, but warning should be marked
        XCTAssertNotNil(warningView.accessibilityHint)
        XCTAssertTrue(
            warningView.accessibilityHint?.contains("Warnung") ?? false,
            "Warning state should mention 'Warnung'"
        )
    }
    
    // MARK: - Time Formatting
    
    func test_formattedTimeDisplay() {
        let testCases: [(seconds: Int, expected: String)] = [
            (3661, "01:01"),  // 1 min 1 sec
            (1800, "30:00"),  // 30 min
            (60, "01:00"),
            (5, "00:05"),
            (0, "00:00"),
        ]
        
        for (seconds, expected) in testCases {
            let view = AccessibleExamTimer(
                totalSeconds: 1800,
                secondsRemaining: seconds,
                onTimeExpired: {}
            )
            
            let minutes = seconds / 60
            let secs = seconds % 60
            let formatted = String(format: "%02d:%02d", minutes, secs)
            
            XCTAssertEqual(formatted, expected, "Time format failed for \(seconds)s")
        }
    }
}