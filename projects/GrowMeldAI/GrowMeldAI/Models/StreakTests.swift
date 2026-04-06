import XCTest
@testable import DriveAI

final class StreakTests: XCTestCase {
    
    // MARK: - Happy Path
    
    func testStreakInitialization() {
        let streak = Streak()
        
        XCTAssertEqual(streak.current, 0)
        XCTAssertEqual(streak.longest, 0)
        XCTAssertNil(streak.lastAnswerDate)
    }
    
    func testStreakIncrement() {
        var streak = Streak()
        
        streak.increment()
        XCTAssertEqual(streak.current, 1)
        XCTAssertEqual(streak.longest, 1)
        XCTAssertNotNil(streak.lastAnswerDate)
    }
    
    func testStreakIncrementMultipleTimes() {
        var streak = Streak()
        
        for i in 1...10 {
            streak.increment()
            XCTAssertEqual(streak.current, i)
            XCTAssertEqual(streak.longest, i)
        }
    }
    
    func testStreakReset() {
        var streak = Streak()
        streak.increment()
        streak.increment()
        streak.increment()
        
        XCTAssertEqual(streak.current, 3)
        
        streak.reset()
        
        XCTAssertEqual(streak.current, 0)
        XCTAssertEqual(streak.longest, 3)  // Longest is preserved
        XCTAssertNil(streak.lastAnswerDate)
    }
    
    func testStreakLongestIsPreserved() {
        var streak = Streak()
        
        // Build streak to 5
        (1...5).forEach { _ in streak.increment() }
        XCTAssertEqual(streak.longest, 5)
        
        // Reset and build to 3
        streak.reset()
        (1...3).forEach { _ in streak.increment() }
        
        XCTAssertEqual(streak.current, 3)
        XCTAssertEqual(streak.longest, 5)  // Longest unchanged
    }
    
    func testStreakCoding() {
        var streak = Streak()
        (1...7).forEach { _ in streak.increment() }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let encoded = try encoder.encode(streak)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Streak.self, from: encoded)
        
        XCTAssertEqual(decoded.current, 7)
        XCTAssertEqual(decoded.longest, 7)
        XCTAssertNotNil(decoded.lastAnswerDate)
    }
    
    // MARK: - Edge Cases
    
    func testStreakLongestWithMultipleResets() {
        var streak = Streak()
        
        // First streak: 5
        (1...5).forEach { _ in streak.increment() }
        streak.reset()
        
        // Second streak: 8
        (1...8).forEach { _ in streak.increment() }
        
        XCTAssertEqual(streak.current, 8)
        XCTAssertEqual(streak.longest, 8)
    }
    
    func testStreakIsActiveDayAfterLastAnswer() {
        var streak = Streak()
        streak.increment()
        
        // Simulate answer yesterday
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        streak.lastAnswerDate = yesterday
        streak.current = 5
        
        let streakData = StreakData(
            current: streak.current,
            longest: streak.longest,
            lastAnswerDate: streak.lastAnswerDate
        )
        
        XCTAssertTrue(streakData.isActive)
    }
    
    func testStreakIsInactiveMoreThanDayOld() {
        var streak = Streak()
        
        // Simulate answer 2 days ago
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        streak.lastAnswerDate = twoDaysAgo
        streak.current = 5
        
        let streakData = StreakData(
            current: streak.current,
            longest: streak.longest,
            lastAnswerDate: streak.lastAnswerDate
        )
        
        XCTAssertFalse(streakData.isActive)
    }
}