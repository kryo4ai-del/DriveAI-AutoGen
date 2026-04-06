// Tests/UtilitiesTests/HapticManagerTests.swift
import XCTest
@testable import DriveAI

final class HapticManagerTests: XCTestCase {
    func testTapHaptic() {
        let haptic = HapticManager()
        haptic.isEnabled = true
        haptic.tap() // Should not crash
    }
    
    func testDisabledHapticDoesNotFire() {
        let haptic = HapticManager()
        haptic.isEnabled = false
        haptic.tap() // Should no-op silently
    }
}