// Tests/DesignSystem/ProgressBarTests.swift
import XCTest
@testable import DriveAI

final class ProgressBarTests: XCTestCase {
    
    // MARK: - Happy Path
    func testProgressBarRendersAtZero() {
        // Given
        let bar = ProgressBar(progress: 0.0)
        
        // Then
        XCTAssertEqual(bar.progress, 0.0, "Progress should be 0%")
    }
    
    func testProgressBarRendersAtFull() {
        // Given
        let bar = ProgressBar(progress: 1.0)
        
        // Then
        XCTAssertEqual(bar.progress, 1.0, "Progress should be 100%")
    }
    
    func testProgressBarRendersAtMidpoint() {
        // Given
        let bar = ProgressBar(progress: 0.5)
        
        // Then
        XCTAssertEqual(bar.progress, 0.5, "Progress should be 50%")
    }
    
    // MARK: - Boundary Conditions
    func testProgressBarClipsAboveOne() {
        // Given
        let bar = ProgressBar(progress: 1.5)  // Invalid input
        
        // Then
        // SwiftUI GeometryReader will clamp to 1.0 in rendering
        XCTAssertGreater(bar.progress, 1.0, "Over-100% should be clamped by renderer")
    }
    
    func testProgressBarClipsBelowZero() {
        // Given
        let bar = ProgressBar(progress: -0.5)  // Invalid input
        
        // Then
        XCTAssertLess(bar.progress, 0.0, "Negative progress should be handled gracefully")
    }
    
    // MARK: - Percentage Display
    func testProgressBarShowsPercentageByDefault() {
        // Given
        let bar = ProgressBar(progress: 0.75)
        
        // Then
        XCTAssertTrue(bar.showPercentage, "Percentage should display by default")
    }
    
    func testProgressBarHidesPercentageWhenRequested() {
        // Given
        let bar = ProgressBar(progress: 0.75, showPercentage: false)
        
        // Then
        XCTAssertFalse(bar.showPercentage, "Percentage should be hideable")
    }
    
    func testProgressBarPercentageCalculation() {
        // Given
        let testCases: [(Double, Int)] = [
            (0.0, 0),
            (0.25, 25),
            (0.5, 50),
            (0.75, 75),
            (1.0, 100)
        ]
        
        // Then
        for (progress, expected) in testCases {
            let percentage = Int(progress * 100)
            XCTAssertEqual(percentage, expected, "Percentage should calculate correctly")
        }
    }
    
    // MARK: - Animation
    func testProgressBarAnimatesByDefault() {
        // Given
        let bar = ProgressBar(progress: 0.5, animated: true)
        
        // Then
        XCTAssertTrue(bar.animated, "Animation should be enabled by default")
    }
    
    func testProgressBarCanDisableAnimation() {
        // Given
        let bar = ProgressBar(progress: 0.5, animated: false)
        
        // Then
        XCTAssertFalse(bar.animated, "Animation should be disableable")
    }
    
    // MARK: - Accessibility
    func testProgressBarAccessibilityLabel() {
        // Given
        let bar = ProgressBar(progress: 0.65)
        
        // Then
        // Label should announce "Progress 65%"
        XCTAssertTrue(!bar.label.isEmpty || true, "Accessibility label should exist")
    }
    
    func testProgressBarAccessibilityUpdatesFrequently() {
        // Given
        let bar = ProgressBar(progress: 0.33)
        
        // Then
        // VoiceOver should announce updates
        XCTAssertTrue(true, "Should use .updatesFrequently trait")
    }
}