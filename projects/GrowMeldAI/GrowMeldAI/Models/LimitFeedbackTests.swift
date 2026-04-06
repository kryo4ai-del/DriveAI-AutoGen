import XCTest
@testable import Domain

final class LimitFeedbackTests: XCTestCase {
    
    // MARK: - Initialization & Validation
    
    func test_init_clampsNegativeRemaining() {
        let feedback = LimitFeedback(allowed: true, remaining: -5)
        
        XCTAssertEqual(feedback.remaining, 0)
        XCTAssertGreaterThanOrEqual(feedback.remaining, 0)
    }
    
    func test_init_preservesPositiveRemaining() {
        let feedback = LimitFeedback(allowed: true, remaining: 10)
        
        XCTAssertEqual(feedback.remaining, 10)
    }
    
    // MARK: - Approach Level Determination
    
    func test_approachLevel_comfortable_whenManyRemaining() {
        let feedback = LimitFeedback(allowed: true, remaining: 10)
        
        XCTAssertEqual(feedback.approachLevel, .comfortable)
    }
    
    func test_approachLevel_comfortable_exactly4Remaining() {
        let feedback = LimitFeedback(allowed: true, remaining: 4)
        
        XCTAssertEqual(feedback.approachLevel, .comfortable)
    }
    
    func test_approachLevel_warning_3Remaining() {
        let feedback = LimitFeedback(allowed: true, remaining: 3)
        
        XCTAssertEqual(feedback.approachLevel, .warning)
    }
    
    func test_approachLevel_warning_2Remaining() {
        let feedback = LimitFeedback(allowed: true, remaining: 2)
        
        XCTAssertEqual(feedback.approachLevel, .warning)
    }
    
    func test_approachLevel_critical_1Remaining() {
        let feedback = LimitFeedback(allowed: true, remaining: 1)
        
        XCTAssertEqual(feedback.approachLevel, .critical)
    }
    
    func test_approachLevel_exceeded_whenNotAllowed() {
        let feedback = LimitFeedback(allowed: false, remaining: 0)
        
        XCTAssertEqual(feedback.approachLevel, .exceeded)
    }
    
    func test_approachLevel_exceeded_ignoresRemaining() {
        let feedback = LimitFeedback(allowed: false, remaining: 100)
        
        XCTAssertEqual(feedback.approachLevel, .exceeded)
    }
    
    // MARK: - Haptic Feedback Levels
    
    func test_hapticStyle_comfortable() {
        let level = LimitApproachLevel.comfortable
        
        XCTAssertNil(level.hapticStyle)
    }
    
    func test_hapticStyle_warning() {
        let level = LimitApproachLevel.warning
        
        XCTAssertEqual(level.hapticStyle, .light)
    }
    
    func test_hapticStyle_critical() {
        let level = LimitApproachLevel.critical
        
        XCTAssertEqual(level.hapticStyle, .medium)
    }
    
    func test_hapticStyle_exceeded() {
        let level = LimitApproachLevel.exceeded
        
        XCTAssertEqual(level.hapticStyle, .heavy)
    }
    
    // MARK: - Haptic Triggering
    
    func test_triggerHapticIfNeeded_doesNotCrashOnComfortable() {
        let feedback = LimitFeedback(allowed: true, remaining: 10)
        
        // Should not crash; no haptic triggered
        feedback.triggerHapticIfNeeded()
    }
    
    func test_triggerHapticIfNeeded_respectsShouldTriggerFlag() {
        let feedback = LimitFeedback(
            allowed: true,
            remaining: 1,
            shouldTriggerHaptic: false
        )
        
        // Should not crash; respects flag
        feedback.triggerHapticIfNeeded()
    }
}