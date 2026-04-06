import XCTest
@testable import DriveAI

final class LimitApproachLevelTests: XCTestCase {
    
    // MARK: - Initialization from Percentage
    
    func testSafeLevel() {
        let level = LimitApproachLevel(percentage: 0.5)
        
        XCTAssertEqual(level, .safe)
    }
    
    func testWarningLevel() {
        let level = LimitApproachLevel(percentage: 0.85)
        
        XCTAssertEqual(level, .warning)
    }
    
    func testCriticalLevel() {
        let level = LimitApproachLevel(percentage: 0.97)
        
        XCTAssertEqual(level, .critical)
    }
    
    func testExceededLevel() {
        let level = LimitApproachLevel(percentage: 1.05)
        
        XCTAssertEqual(level, .exceeded)
    }
    
    // MARK: - Boundary Cases
    
    func testAtExactBoundary80Percent() {
        let level = LimitApproachLevel(percentage: 0.80)
        
        XCTAssertEqual(level, .warning)
    }
    
    func testAtExactBoundary95Percent() {
        let level = LimitApproachLevel(percentage: 0.95)
        
        XCTAssertEqual(level, .critical)
    }
    
    func testAtExactBoundary100Percent() {
        let level = LimitApproachLevel(percentage: 1.0)
        
        XCTAssertEqual(level, .critical)
    }
    
    func testZeroPercentage() {
        let level = LimitApproachLevel(percentage: 0.0)
        
        XCTAssertEqual(level, .safe)
    }
    
    func testNegativePercentage() {
        let level = LimitApproachLevel(percentage: -0.5)
        
        XCTAssertEqual(level, .safe)
    }
    
    // MARK: - Visual Properties
    
    func testSafeColor() {
        let level: LimitApproachLevel = .safe
        
        XCTAssertEqual(level.color, .green)
    }
    
    func testWarningColor() {
        let level: LimitApproachLevel = .warning
        
        XCTAssertEqual(level.color, .yellow)
    }
    
    func testCriticalColor() {
        let level: LimitApproachLevel = .critical
        
        XCTAssertEqual(level.color, .orange)
    }
    
    func testExceededColor() {
        let level: LimitApproachLevel = .exceeded
        
        XCTAssertEqual(level.color, .red)
    }
    
    // MARK: - Haptic Feedback
    
    func testExceededTriggersError() {
        let level: LimitApproachLevel = .exceeded
        
        XCTAssertEqual(level.hapticType, .error)
    }
    
    func testCriticalTriggersError() {
        let level: LimitApproachLevel = .critical
        
        XCTAssertEqual(level.hapticType, .error)
    }
    
    func testWarningTriggersWarning() {
        let level: LimitApproachLevel = .warning
        
        XCTAssertEqual(level.hapticType, .warning)
    }
    
    func testSafeTriggersSuccess() {
        let level: LimitApproachLevel = .safe
        
        XCTAssertEqual(level.hapticType, .success)
    }
}