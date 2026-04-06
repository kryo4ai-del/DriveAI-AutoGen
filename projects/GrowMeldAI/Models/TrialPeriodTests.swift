import XCTest
@testable import Domain

final class TrialPeriodTests: XCTestCase {
    
    // MARK: - Initialization
    
    func test_init_withValidDuration() {
        let trial = TrialPeriod(durationDays: 14)
        
        XCTAssertNotNil(trial)
        XCTAssertEqual(trial?.durationDays, 14)
        XCTAssertNil(trial?.conversionDate)
    }
    
    func test_init_rejectsZeroDuration() {
        let trial = TrialPeriod(durationDays: 0)
        XCTAssertNil(trial)
    }
    
    func test_init_rejectsNegativeDuration() {
        let trial = TrialPeriod(durationDays: -5)
        XCTAssertNil(trial)
    }
    
    // MARK: - End Date Calculation
    
    func test_endDate_calculatesCorrectly() {
        let start = MockCalendar.date(year: 2025, month: 1, day: 1)
        let trial = TrialPeriod(startDate: start, durationDays: 14)!
        
        let expected = MockCalendar.date(year: 2025, month: 1, day: 15)
        let difference = Calendar.current.dateComponents([.day], from: trial.endDate, to: expected).day ?? 999
        
        XCTAssertEqual(abs(difference), 0, "End date should be 14 days after start")
    }
    
    func test_endDate_acrossMonthBoundary() {
        let start = MockCalendar.date(year: 2025, month: 1, day: 20)
        let trial = TrialPeriod(startDate: start, durationDays: 14)!
        
        let cal = Calendar.current
        let components = cal.dateComponents([.month, .day], from: trial.endDate)
        
        XCTAssertEqual(components.month, 2, "Should cross into February")
        XCTAssertEqual(components.day, 3, "Should be Feb 3")
    }
    
    // MARK: - State Evaluation
    
    func test_currentState_activeOnFirstDay() {
        let start = MockCalendar.date(year: 2025, month: 1, day: 1)
        let now = start.addingTimeInterval(3600)  // 1 hour later, same day
        let trial = TrialPeriod(startDate: start, durationDays: 14)!
        
        let state = trial.currentState(now: now)
        
        if case .active(let days) = state {
            XCTAssertEqual(days, 14)
        } else {
            XCTFail("Expected active state on day 1, got \(state)")
        }
    }
    
    func test_currentState_activeWithDaysRemaining() {
        let start = MockCalendar.date(year: 2025, month: 1, day: 1)
        let now = MockCalendar.date(year: 2025, month: 1, day: 8)
        let trial = TrialPeriod(startDate: start, durationDays: 14)!
        
        let state = trial.currentState(now: now)
        
        if case .active(let days) = state {
            XCTAssertEqual(days, 7, "7 days remaining on day 8 of 14-day trial")
        } else {
            XCTFail("Expected active state")
        }
    }
    
    func test_currentState_expiredTodayOnLastDay() {
        let start = MockCalendar.date(year: 2025, month: 1, day: 1)
        let endDay = MockCalendar.date(year: 2025, month: 1, day: 14, hour: 12)
        let trial = TrialPeriod(startDate: start, durationDays: 14)!
        
        let state = trial.currentState(now: endDay)
        
        XCTAssertEqual(state, .expiredToday)
    }
    
    func test_currentState_fullyExpired() {
        let start = MockCalendar.date(year: 2025, month: 1, day: 1)
        let now = MockCalendar.date(year: 2025, month: 1, day: 15)
        let trial = TrialPeriod(startDate: start, durationDays: 14)!
        
        let state = trial.currentState(now: now)
        
        XCTAssertEqual(state, .expired)
    }
    
    func test_currentState_convertedToPremium() {
        let start = MockCalendar.date(year: 2025, month: 1, day: 1)
        let conversionDate = MockCalendar.date(year: 2025, month: 1, day: 7)
        var trial = TrialPeriod(startDate: start, durationDays: 14)!
        trial.markAsConverted(on: conversionDate)
        
        let now = MockCalendar.date(year: 2025, month: 1, day: 20)
        let state = trial.currentState(now: now)
        
        XCTAssertEqual(state, .converted, "Should return .converted even if trial would be expired")
    }
    
    // MARK: - Conversion
    
    func test_markAsConverted_setsDate() {
        var trial = TrialPeriod(durationDays: 14)!
        let date = MockCalendar.date(year: 2025, month: 1, day: 7)
        
        trial.markAsConverted(on: date)
        
        XCTAssertEqual(trial.conversionDate, date)
    }
    
    func test_markAsConverted_defaultsToNow() {
        var trial = TrialPeriod(durationDays: 14)!
        
        trial.markAsConverted()
        
        XCTAssertNotNil(trial.conversionDate)
        // Allow 1 second tolerance for execution time
        XCTAssertLessThan(
            abs(trial.conversionDate!.timeIntervalSinceNow),
            1.0
        )
    }
    
    // MARK: - Codable (ISO8601 Date Serialization)
    
    func test_encode_usesISO8601Format() throws {
        let start = MockCalendar.date(year: 2025, month: 1, day: 1)
        let trial = TrialPeriod(startDate: start, durationDays: 14)!
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(trial)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        let startDateStr = json["startDate"] as! String
        XCTAssertTrue(startDateStr.contains("T"), "Should use ISO8601 format with time")
        XCTAssertTrue(startDateStr.contains("Z") || startDateStr.contains("+"), "Should include timezone")
    }
    
    func test_decode_preservesAllFields() throws {
        let start = MockCalendar.date(year: 2025, month: 1, day: 1)
        let conversion = MockCalendar.date(year: 2025, month: 1, day: 7)
        let original = TrialPeriod(startDate: start, durationDays: 14, conversionDate: conversion)!
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(TrialPeriod.self, from: data)
        
        XCTAssertEqual(decoded.durationDays, original.durationDays)
        XCTAssertEqual(decoded.conversionDate, original.conversionDate)
        // Dates may differ by microseconds due to encoding precision
        XCTAssertLessThan(
            abs(decoded.startDate.timeIntervalSince(original.startDate)),
            0.001
        )
    }
    
    func test_decode_withoutConversionDate() throws {
        let json = """
        {
            "startDate": "2025-01-01T12:00:00Z",
            "durationDays": 14
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(TrialPeriod.self, from: json)
        
        XCTAssertEqual(decoded.durationDays, 14)
        XCTAssertNil(decoded.conversionDate)
    }
    
    func test_decode_invalidDate_throws() {
        let json = """
        {
            "startDate": "not-a-date",
            "durationDays": 14
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        
        XCTAssertThrowsError(
            try decoder.decode(TrialPeriod.self, from: json)
        ) { error in
            // Should contain FreemiumError or DecodingError
            XCTAssertTrue(
                error is FreemiumError || error is DecodingError,
                "Expected FreemiumError or DecodingError, got \(type(of: error))"
            )
        }
    }
}