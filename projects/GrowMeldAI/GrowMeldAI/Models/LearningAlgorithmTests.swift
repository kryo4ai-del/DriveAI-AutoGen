// Tests/DomainTests/LearningAlgorithmTests.swift
import XCTest

final class LearningAlgorithmTests: XCTestCase {
    
    func testSpacedRepetitionRespectsBerlinMidnight() throws {
        // User in Berlin answers question at 23:55 Berlin time (21:55 UTC)
        var berlinCalendar = Calendar(identifier: .gregorian)
        berlinCalendar.timeZone = try XCTUnwrap(TimeZone(identifier: "Europe/Berlin"))
        
        let dateFormatter = ISO8601DateFormatter()
        let questionDateUTC = try XCTUnwrap(dateFormatter.date(from: "2024-01-15T21:55:00Z"))
        
        // Calculate next review (should be 7 days from Berlin midnight of Jan 15)
        let nextReview = LearningAlgorithm.calculateNextReviewDate(
            lastAttemptDate: questionDateUTC,
            correctCount: 3,
            attemptCount: 3,
            calendar: berlinCalendar
        )
        
        // Expected: 7 days from Jan 15 00:00 Berlin = Jan 22 00:00 Berlin = Jan 21 22:00 UTC
        let expectedUTC = try XCTUnwrap(
            berlinCalendar.date(byAdding: .day, value: 7, to: berlinCalendar.startOfDay(for: questionDateUTC))
        )
        
        XCTAssertEqual(
            berlinCalendar.dateComponents([.year, .month, .day], from: nextReview),
            berlinCalendar.dateComponents([.year, .month, .day], from: expectedUTC)
        )
    }
    
    func testAllDACHTimezonesHandledCorrectly() throws {
        let timeZoneIDs = ["Europe/Berlin", "Europe/Vienna", "Europe/Zurich", "Europe/Vaduz"]
        
        for tzID in timeZoneIDs {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = try XCTUnwrap(TimeZone(identifier: tzID))
            
            let baseDate = Date()
            let nextReview = LearningAlgorithm.calculateNextReviewDate(
                lastAttemptDate: baseDate,
                correctCount: 3,
                attemptCount: 3,
                calendar: calendar
            )
            
            // ✅ Should always be 7 days from local midnight, never drift
            let diff = calendar.dateComponents([.day], from: baseDate, to: nextReview).day ?? 0
            XCTAssertEqual(diff, 7, "Timezone \(tzID) produced wrong day difference")
        }
    }
}