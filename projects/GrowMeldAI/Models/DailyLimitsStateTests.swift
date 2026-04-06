import XCTest
@testable import Domain

final class DailyLimitsStateTests: XCTestCase {
    
    // MARK: - Initialization
    
    func test_init_createsStateForToday() {
        let state = DailyLimitsState()
        
        XCTAssertEqual(state.questionsAnsweredToday, 0)
        XCTAssertEqual(state.examAttemptsUsedToday, 0)
        XCTAssertTrue(state.isFromToday())
    }
    
    func test_init_withCustomDate() {
        let date = MockCalendar.date(year: 2025, month: 1, day: 15)
        let state = DailyLimitsState(date: date)
        
        XCTAssertEqual(state.date, date)
    }
    
    // MARK: - Remaining Calculations
    
    func test_remainingQuestions_whenAnsweredZero() {
        let state = DailyLimitsState()
        
        XCTAssertEqual(state.remainingQuestions, DailyLimits.defaults.questionsPerDay)
    }
    
    func test_remainingQuestions_whenAnsweredSome() {
        var state = DailyLimitsState()
        state.questionsAnsweredToday = 5
        
        XCTAssertEqual(state.remainingQuestions, DailyLimits.defaults.questionsPerDay - 5)
    }
    
    func test_remainingQuestions_whenAnsweredAll() {
        var state = DailyLimitsState()
        state.questionsAnsweredToday = DailyLimits.defaults.questionsPerDay
        
        XCTAssertEqual(state.remainingQuestions, 0)
    }
    
    func test_remainingQuestions_neverNegative() {
        var state = DailyLimitsState()
        state.questionsAnsweredToday = DailyLimits.defaults.questionsPerDay + 100
        
        XCTAssertEqual(state.remainingQuestions, 0)
        XCTAssertGreaterThanOrEqual(state.remainingQuestions, 0)
    }
    
    func test_remainingExamAttempts_neverNegative() {
        var state = DailyLimitsState()
        state.examAttemptsUsedToday = DailyLimits.defaults.examAttemptsPerDay + 10
        
        XCTAssertEqual(state.remainingExamAttempts, 0)
        XCTAssertGreaterThanOrEqual(state.remainingExamAttempts, 0)
    }
    
    // MARK: - Can Perform Actions
    
    func test_canAnswerQuestion_whenQuotaAvailable() {
        let state = DailyLimitsState()
        
        XCTAssertTrue(state.canAnswerQuestion)
    }
    
    func test_canAnswerQuestion_whenQuotaExhausted() {
        var state = DailyLimitsState()
        state.questionsAnsweredToday = DailyLimits.defaults.questionsPerDay
        
        XCTAssertFalse(state.canAnswerQuestion)
    }
    
    func test_canAttemptExam_whenQuotaAvailable() {
        let state = DailyLimitsState()
        
        XCTAssertTrue(state.canAttemptExam)
    }
    
    func test_canAttemptExam_whenQuotaExhausted() {
        var state = DailyLimitsState()
        state.examAttemptsUsedToday = DailyLimits.defaults.examAttemptsPerDay
        
        XCTAssertFalse(state.canAttemptExam)
    }
    
    // MARK: - Date Rotation
    
    func test_isFromToday_whenCreatedToday() {
        let state = DailyLimitsState()
        
        XCTAssertTrue(state.isFromToday())
    }
    
    func test_isFromToday_whenCreatedYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let state = DailyLimitsState(date: yesterday)
        
        XCTAssertFalse(state.isFromToday())
    }
    
    func test_isFromToday_withDifferentCalendars() {
        let state = DailyLimitsState()
        var gregorian = Calendar(identifier: .gregorian)
        var islamic = Calendar(identifier: .islamic)
        
        // Both should agree on "today"
        XCTAssertEqual(
            state.isFromToday(calendar: gregorian),
            state.isFromToday(calendar: islamic)
        )
    }
    
    // MARK: - Codable
    
    func test_encodeDecode_preservesState() throws {
        let original = DailyLimitsState()
        var mutated = original
        mutated.questionsAnsweredToday = 10
        mutated.examAttemptsUsedToday = 1
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(mutated)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DailyLimitsState.self, from: data)
        
        XCTAssertEqual(decoded.questionsAnsweredToday, 10)
        XCTAssertEqual(decoded.examAttemptsUsedToday, 1)
        XCTAssertEqual(decoded.date, mutated.date)
    }
}