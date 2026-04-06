// Tests/Unit/Utilities/DateHelperTests.swift
import XCTest
@testable import DriveAI

final class DateHelperTests: XCTestCase {
    
    // MARK: - Days From Now Calculation
    
    func testDaysFromNowToday() {
        let today = Date()
        let days = DateHelper.daysFromNow(to: today)
        
        XCTAssertEqual(days, 0)
    }
    
    func testDaysFromNowTomorrow() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let days = DateHelper.daysFromNow(to: tomorrow)
        
        XCTAssertEqual(days, 1)
    }
    
    func testDaysFromNowOneWeek() {
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        let days = DateHelper.daysFromNow(to: nextWeek)
        
        XCTAssertEqual(days, 7)
    }
    
    func testDaysFromNowPast() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let days = DateHelper.daysFromNow(to: yesterday)
        
        XCTAssertEqual(days, -1)
    }
    
    // MARK: - Review Timing Labels
    
    func testReviewTimingLabelToday() {
        let label = DateHelper.reviewTimingLabel(for: Date())
        XCTAssertEqual(label, "Heute üben")
    }
    
    func testReviewTimingLabelTomorrow() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let label = DateHelper.reviewTimingLabel(for: tomorrow)
        XCTAssertEqual(label, "Morgen üben")
    }
    
    func testReviewTimingLabelDayAfterTomorrow() {
        let dayAfterTomorrow = Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()
        let label = DateHelper.reviewTimingLabel(for: dayAfterTomorrow)
        XCTAssertEqual(label, "Übermorgen")
    }
    
    func testReviewTimingLabelMultipleDays() {
        let nextWeek = Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date()
        let label = DateHelper.reviewTimingLabel(for: nextWeek)
        XCTAssertEqual(label, "In 5 Tagen")
    }
    
    func testReviewTimingLabelOverdue() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let label = DateHelper.reviewTimingLabel(for: yesterday)
        XCTAssertEqual(label, "Überfällig")
    }
    
    // MARK: - Accessibility Labels
    
    func testAccessibilityReviewLabelToday() {
        let label = DateHelper.accessibilityReviewLabel(for: Date())
        XCTAssertEqual(label, "Nächste Wiederholung: heute")
    }
    
    func testAccessibilityReviewLabelTomorrow() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let label = DateHelper.accessibilityReviewLabel(for: tomorrow)
        XCTAssertEqual(label, "Nächste Wiederholung: morgen")
    }
    
    func testAccessibilityReviewLabelMultipleDays() {
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        let label = DateHelper.accessibilityReviewLabel(for: nextWeek)
        XCTAssertEqual(label, "Nächste Wiederholung: in 7 Tagen")
    }
    
    // MARK: - Edge Cases
    
    func testConsistencyBetweenDaysAndLabel() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        
        let days = DateHelper.daysFromNow(to: tomorrow)
        let label = DateHelper.reviewTimingLabel(for: tomorrow)
        
        // If days == 1, label should be "Morgen üben"
        XCTAssertEqual(days, 1)
        XCTAssertEqual(label, "Morgen üben")
    }
}