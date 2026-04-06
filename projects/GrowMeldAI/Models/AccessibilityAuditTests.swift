// Tests/Accessibility/AccessibilityAuditTests.swift
import XCTest

final class AccessibilityAuditTests: XCTestCase {
    func test_primaryButton_meetsMinimumSize() throws {
        let button = PrimaryButton(title: "Test", action: {})
        let snapshot = try XCTUnwrap(button.snapshot())
        
        XCTAssertGreaterThanOrEqual(snapshot.size.height, 44, "Button must be 44pt tall")
        XCTAssertGreaterThanOrEqual(snapshot.size.width, 44, "Button must be 44pt wide")
    }
    
    func test_textContrast_meetsWCAG() throws {
        let foreground = UIColor.white
        let background = UIColor.systemBlue
        
        let ratio = contrastRatio(foreground: foreground, background: background)
        XCTAssertGreaterThanOrEqual(ratio, 4.5, "Must meet WCAG AA")
    }
    
    func test_allTextSupportsVoiceOver() throws {
        let screen = HomeScreen()
        let tree = AccessibilityElementTree(root: screen)
        
        for element in tree.allElements {
            if element.isText && !element.isDecorative {
                XCTAssertNotNil(
                    element.accessibilityLabel,
                    "Text '\(element.value)' must have a11y label"
                )
            }
        }
    }
}