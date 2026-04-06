import XCTest
@testable import DriveAI

final class SpacingScaleTests: XCTestCase {
    
    // MARK: - Spacing Value Tests
    func testSpacingValuesExist() {
        XCTAssertEqual(AppTheme.Spacing.xs, 4)
        XCTAssertEqual(AppTheme.Spacing.sm, 8)
        XCTAssertEqual(AppTheme.Spacing.md, 16)
        XCTAssertEqual(AppTheme.Spacing.lg, 24)
        XCTAssertEqual(AppTheme.Spacing.xl, 32)
        XCTAssertEqual(AppTheme.Spacing.xxl, 48)
    }
    
    // MARK: - Spacing Hierarchy Tests
    func testSpacingProgression() {
        // Spacing should follow a consistent progression (roughly 2x or Fibonacci)
        let xs = AppTheme.Spacing.xs
        let sm = AppTheme.Spacing.sm
        let md = AppTheme.Spacing.md
        let lg = AppTheme.Spacing.lg
        
        XCTAssertLessThan(xs, sm)
        XCTAssertLessThan(sm, md)
        XCTAssertLessThan(md, lg)
    }
    
    // MARK: - Touch Target Accessibility Tests
    func testButtonHeightMeetsA11yStandard() {
        // Apple HIG: minimum 44pt touch target
        XCTAssertGreaterThanOrEqual(AppTheme.Spacing.buttonHeight, 44, "Button height must meet accessibility standard")
    }
    
    func testScreenPaddingReasonable() {
        // Screen padding should be at least 8pt, max 32pt for normal phones
        XCTAssertGreaterThanOrEqual(AppTheme.Spacing.screenPadding, 8)
        XCTAssertLessThanOrEqual(AppTheme.Spacing.screenPadding, 32)
    }
    
    // MARK: - Convenience Extension Tests
    func testCGFloatExtensionsMatch() {
        XCTAssertEqual(CGFloat.md, AppTheme.Spacing.md)
        XCTAssertEqual(CGFloat.lg, AppTheme.Spacing.lg)
        XCTAssertEqual(CGFloat.buttonHeight, AppTheme.Spacing.buttonHeight)
    }
    
    // MARK: - Spacing Consistency Tests
    func testCommonPatternsConsistent() {
        // Screen padding and card padding should be consistent
        XCTAssertEqual(
            AppTheme.Spacing.screenPadding,
            AppTheme.Spacing.cardPadding,
            "Screen and card padding should match for visual consistency"
        )
    }
}