// MARK: - MaintenanceStatusTests.swift
import XCTest
@testable import DriveAI

final class MaintenanceStatusTests: XCTestCase {
    
    func testStatusColorValues() {
        XCTAssertEqual(MaintenanceStatus.completed.color, "green")
        XCTAssertEqual(MaintenanceStatus.dueSoon.color, "yellow")
        XCTAssertEqual(MaintenanceStatus.overdue.color, "red")
    }
    
    func testStatusEmojiValues() {
        XCTAssertEqual(MaintenanceStatus.completed.emoji, "✅")
        XCTAssertEqual(MaintenanceStatus.dueSoon.emoji, "⚠️")
        XCTAssertEqual(MaintenanceStatus.overdue.emoji, "🔴")
    }
    
    func testStatusEquatable() {
        XCTAssertEqual(MaintenanceStatus.completed, MaintenanceStatus.completed)
        XCTAssertNotEqual(MaintenanceStatus.completed, MaintenanceStatus.overdue)
    }
}