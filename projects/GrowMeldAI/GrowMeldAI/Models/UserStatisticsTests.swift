import XCTest
@testable import DriveAI

final class UserStatisticsTests: XCTestCase {
    
    // MARK: - Computed Properties
    
    func testAverageScore_CalculatesCorrectly() {
        let stats = UserStatistics(
            totalQuestionsAnswered: 100,
            totalCorrectAnswers: 85,
            totalIncorrectAnswers: 15,
            currentStreak: 5,
            longestStreak: 12,
            totalExams: 2,
            passedExams: 1
        )
        
        XCTAssertEqual(stats.averageScore, 0.85, accuracy: 0.001)
    }
    
    func testAverageScore_ZeroWhenNoAnswers() {
        let stats = UserStatistics()
        XCTAssertEqual(stats.averageScore, 0.0)
    }
    
    func testExamPassRate_CalculatesCorrectly() {
        let stats = UserStatistics(
            totalQuestionsAnswered: 0,
            totalCorrectAnswers: 0,
            totalIncorrectAnswers: 0,
            currentStreak: 0,
            longestStreak: 0,
            totalExams: 5,
            passedExams: 3
        )
        
        XCTAssertEqual(stats.examPassRate, 0.6, accuracy: 0.001)
    }
    
    func testExamPassRate_ZeroWhenNoExams() {
        let stats = UserStatistics()
        XCTAssertEqual(stats.examPassRate, 0.0)
    }
}