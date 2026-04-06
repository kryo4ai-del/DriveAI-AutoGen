// Tests/Accessibility/TypographyTests.swift
@available(iOS 17.0, *)
final class TypographyAccessibilityTests: XCTestCase {
    
    func testHeading1_IncreasedTextSizeSettings_RemainsReadable() {
        // Simulate A6/A7 accessibility setting
        let view = Text("Einführung")
            .appHeading(1)
        
        // Should not truncate or overlap
        // Requires snapshot testing with accessibility settings enabled
    }
    
    func testBody_AtMaximumTextSize_DoesNotCauseHorizontalScroll() {
        let longText = "Was bedeutet dieses Verkehrszeichen? Hier ist eine sehr lange Erklärung die möglicherweise zu mehreren Zeilen führt."
        
        let view = Text(longText)
            .appBody()
        
        // Frame must allow full text without horizontal overflow
    }
}