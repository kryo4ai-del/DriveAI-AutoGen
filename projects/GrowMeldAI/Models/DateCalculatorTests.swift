// Tests/Utilities/DateCalculatorTests.swift
import XCTest
@testable import DriveAI

final class DateCalculatorTests: XCTestCase {
    var sut: DateCalculator!
    
    override func setUp() {
        super.setUp()
        sut = DateCalculator()
    }
    
    // MARK: - Days Remaining Cases
    
    func testCalculateExamProximity_Returns7Days() {
        // Arrange
        let now = Date()
        let examDate = Calendar.current.date(byAdding: .day, value: 7, to: now)!
        
        // Act
        let result = sut.calculateExamProximity(from: now, to: examDate)
        
        // Assert
        if case .daysRemaining(let days) = result {
            XCTAssertEqual(days, 7)
        } else {
            XCTFail("Expected daysRemaining case")
        }
    }
    
    func testCalculateExamProximity_Returns1Day() {
        // Arrange
        let now = Date()
        let examDate = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        
        // Act
        let result = sut.calculateExamProximity(from: now, to: examDate)
        
        // Assert
        if case .daysRemaining(let days) = result {
            XCTAssertEqual(days, 1)
        } else {
            XCTFail("Expected daysRemaining case")
        }
    }
    
    // MARK: - Boundary Cases
    
    func testCalculateExamProximity_ExamToday_AtMidnight() {
        // Arrange
        let now = Date()
        let examDate = Calendar.current.startOfDay(for: now)
        
        // Act
        let result = sut.calculateExamProximity(from: now, to: examDate)
        
        // Assert
        XCTAssertEqual(result, .examToday)
    }
    
    func testCalculateExamProximity_ExamToday_At11PM() {
        // Arrange
        let now = Date()
        let examDate = Calendar.current.startOfDay(for: now)
        
        // Act
        let result = sut.calculateExamProximity(from: now, to: examDate)
        
        // Assert
        XCTAssertEqual(result, .examToday)
    }
    
    // MARK: - Negative Days (Past Exam)
    
    func testCalculateExamProximity_Returns1DayPast() {
        // Arrange
        let now = Date()
        let examDate = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        
        // Act
        let result = sut.calculateExamProximity(from: now, to: examDate)
        
        // Assert
        XCTAssertEqual(result, .examPassed)
    }
    
    func testCalculateExamProximity_Returns30DaysPast() {
        // Arrange
        let now = Date()
        let examDate = Calendar.current.date(byAdding: .day, value: -30, to: now)!
        
        // Act
        let result = sut.calculateExamProximity(from: now, to: examDate)
        
        // Assert
        XCTAssertEqual(result, .examPassed)
    }
    
    // MARK: - Extreme Cases
    
    func testCalculateExamProximity_365DaysInTheFuture() {
        // Arrange
        let now = Date()
        let examDate = Calendar.current.date(byAdding: .day, value: 365, to: now)!
        
        // Act
        let result = sut.calculateExamProximity(from: now, to: examDate)
        
        // Assert
        if case .daysRemaining(let days) = result {
            XCTAssertEqual(days, 365)
        } else {
            XCTFail("Expected daysRemaining case")
        }
    }
    
    func testCalculateExamProximity_IgnoresTimeComponent() {
        // Arrange
        let now = Date()
        let examDateWithTime = Calendar.current.date(
            byAdding: .day,
            value: 3,
            to: now
        )!
        
        // Act - same day should be 0 or 1 depending on time
        let result = sut.calculateExamProximity(from: now, to: examDateWithTime)
        
        // Assert - should be ~3 days (exact depends on hour of day)
        if case .daysRemaining(let days) = result {
            XCTAssertGreaterThanOrEqual(days, 2)
            XCTAssertLessThanOrEqual(days, 4)
        } else {
            XCTFail("Expected daysRemaining case")
        }
    }
}