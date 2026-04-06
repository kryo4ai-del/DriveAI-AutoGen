// Tests/AccessibilityTests/ColorContrastTests.swift
import XCTest

class ColorContrastTests: XCTestCase {
    func testPrimaryActionContrast() {
        let primaryColor = Color.wcagCompliant.primaryAction
        let backgroundColor = Color.white
        
        let contrastRatio = calculateContrastRatio(primaryColor, backgroundColor)
        XCTAssertGreaterThanOrEqual(contrastRatio, 7.0, "Primary action must meet WCAG AAA")
    }
}