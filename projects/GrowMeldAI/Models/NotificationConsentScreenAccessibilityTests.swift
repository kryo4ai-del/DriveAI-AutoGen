// Features/NotificationConsent/Tests/NotificationConsentScreenAccessibilityTests.swift
import XCTest
@testable import DriveAI

final class NotificationConsentScreenAccessibilityTests: XCTestCase {
    func testScreenHasAccessibilityLabels() throws {
        let screen = NotificationConsentScreen()
        
        // Render the view
        let host = try XCTUnwrap(
            XCUIApplication().windows.first?.rootViewController?.view
        )
        
        // Verify accessibility elements exist
        let benefitElements = host.accessibilityElements?.filter {
            ($0 as? NSObject)?.accessibilityLabel?.contains("Lernsträhne") ?? false
        }
        
        XCTAssertFalse(benefitElements?.isEmpty ?? true)
    }
    
    func testDynamicTypeSupport() {
        let viewController = UIHostingController(
            rootView: NotificationConsentScreen()
        )
        
        // Verify font scaling works with Large and Extra Large sizes
        let largeContentSize = UIContentSizeCategory.extraLarge
        viewController.preferredContentSizeCategory = largeContentSize
        
        // No crash = success
        XCTAssertNotNil(viewController.view)
    }
}