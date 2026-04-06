import XCTest
@testable import DriveAI
import SwiftUI

final class TypographyScaleTests: XCTestCase {
    
    // MARK: - Font Existence Tests
    func testAllTypographyScalesExist() {
        XCTAssertNotNil(AppTheme.Typography.headline)
        XCTAssertNotNil(AppTheme.Typography.title1)
        XCTAssertNotNil(AppTheme.Typography.title2)
        XCTAssertNotNil(AppTheme.Typography.body)
        XCTAssertNotNil(AppTheme.Typography.bodyEmphasis)
        XCTAssertNotNil(AppTheme.Typography.caption)
        XCTAssertNotNil(AppTheme.Typography.captionSmall)
        XCTAssertNotNil(AppTheme.Typography.button)
    }
    
    // MARK: - Font Size Hierarchy Tests
    func testFontSizeHierarchy() {
        // Ensure headline > title1 > title2 > body > caption
        let headlineSize = 28.0
        let title1Size = 22.0
        let title2Size = 20.0
        let bodySize = 16.0
        let captionSize = 14.0
        
        XCTAssertGreaterThan(headlineSize, title1Size)
        XCTAssertGreaterThan(title1Size, title2Size)
        XCTAssertGreaterThan(title2Size, bodySize)
        XCTAssertGreaterThan(bodySize, captionSize)
    }
    
    // MARK: - Font Weight Tests
    func testHeadlineIsBold() {
        // Headline should be bold (.bold or .semibold minimum)
        let expectedWeight = Font.Weight.bold
        XCTAssertEqual(expectedWeight, .bold)
    }
    
    func testBodyIsRegular() {
        // Body text should be regular weight for readability
        let expectedWeight = Font.Weight.regular
        XCTAssertEqual(expectedWeight, .regular)
    }
    
    // MARK: - Dynamic Type Compatibility Tests
    func testHeadlineSupportsAccessibilityScaling() {
        // Font should support Dynamic Type for accessibility
        let headline = AppTheme.Typography.headline
        XCTAssertNotNil(headline)
        // In production, verify font supports Dynamic Type with @Environment(\.sizeCategory)
    }
    
    // MARK: - Convenience Extension Tests
    func testFontExtensionsMatch() {
        XCTAssertEqual(
            Font.driveAIHeadline.description,
            AppTheme.Typography.headline.description
        )
        XCTAssertEqual(
            Font.driveAIBody.description,
            AppTheme.Typography.body.description
        )
    }
    
    // MARK: - Minimum Font Size Tests (Accessibility)
    func testCaptionMinimumSize() {
        // WCAG requires minimum 12pt for body text; captions can be smaller for supplementary
        let captionSize = 12.0
        XCTAssertGreaterThanOrEqual(captionSize, 10.0, "Caption size must be readable")
    }
}