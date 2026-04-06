final class UserProgressMetricsTests: XCTestCase {
    
    // MARK: - Completion Percentage
    func testCompletionPercentageCalculation() {
        let metrics = UserProgressMetrics(
            totalQuestionsAnswered: 250,
            totalQuestions: 500,
            masteryCategoryStats: [:],
            examDate: .now,
            currentDate: .now
        )
        
        XCTAssertEqual(metrics.completionPercentage, 50)
    }
    
    func testCompletionPercentageZeroWhenNoQuestionsAnswered() {
        let metrics = UserProgressMetrics(
            totalQuestionsAnswered: 0,
            totalQuestions: 500,
            masteryCategoryStats: [:],
            examDate: .now,
            currentDate: .now
        )
        
        XCTAssertEqual(metrics.completionPercentage, 0)
    }
    
    func testCompletionPercentageZeroWhenTotalIsZero() {
        let metrics = UserProgressMetrics(
            totalQuestionsAnswered: 0,
            totalQuestions: 0,
            masteryCategoryStats: [:],
            examDate: .now,
            currentDate: .now
        )
        
        XCTAssertEqual(metrics.completionPercentage, 0)
    }
    
    func testCompletionPercentageHundredWhenComplete() {
        let metrics = UserProgressMetrics(
            totalQuestionsAnswered: 600,
            totalQuestions: 600,
            masteryCategoryStats: [:],
            examDate: .now,
            currentDate: .now
        )
        
        XCTAssertEqual(metrics.completionPercentage, 100)
    }
    
    // MARK: - Days Until Exam
    func testDaysUntilExamCalculation() {
        let today = Date()
        let examDate = Calendar.current.date(byAdding: .day, value: 45, to: today)!
        
        let metrics = UserProgressMetrics(
            totalQuestionsAnswered: 100,
            totalQuestions: 500,
            masteryCategoryStats: [:],
            examDate: examDate,
            currentDate: today
        )
        
        XCTAssertEqual(metrics.daysUntilExam, 45)
    }
    
    func testDaysUntilExamNeverNegative() {
        let today = Date()
        let examDate = Calendar.current.date(byAdding: .day, value: -10, to: today)!
        
        let metrics = UserProgressMetrics(
            totalQuestionsAnswered: 100,
            totalQuestions: 500,
            masteryCategoryStats: [:],
            examDate: examDate,
            currentDate: today
        )
        
        XCTAssertGreaterThanOrEqual(metrics.daysUntilExam, 0)
    }
    
    func testExamInDangerWhen7DaysOrLess() {
        let today = Date()
        let examDate = Calendar.current.date(byAdding: .day, value: 5, to: today)!
        
        let metrics = UserProgressMetrics(
            totalQuestionsAnswered: 100,
            totalQuestions: 500,
            masteryCategoryStats: [:],
            examDate: examDate,
            currentDate: today
        )
        
        XCTAssertTrue(metrics.examsInDanger)
    }
    
    func testExamNotInDangerWhen8DaysOrMore() {
        let today = Date()
        let examDate = Calendar.current.date(byAdding: .day, value: 15, to: today)!
        
        let metrics = UserProgressMetrics(
            totalQuestionsAnswered: 100,
            totalQuestions: 500,
            masteryCategoryStats: [:],
            examDate: examDate,
            currentDate: today
        )
        
        XCTAssertFalse(metrics.examsInDanger)
    }
    
    // MARK: - Motivation Message
    func testMotivationMessageIncludesPercentages() {
        let today = Date()
        let examDate = Calendar.current.date(byAdding: .day, value: 30, to: today)!
        
        let metrics = UserProgressMetrics(
            totalQuestionsAnswered: 300,
            totalQuestions: 600,
            masteryCategoryStats: [:],
            examDate: examDate,
            currentDate: today
        )
        
        let message = metrics.motivationMessage
        
        XCTAssertTrue(message.contains("50%"))  // Completed
        XCTAssertTrue(message.contains("50%"))  // Remaining
    }
    
    func testMotivationMessageIncludesExamDate() {
        let today = Date()
        let examDate = Calendar.current.date(byAdding: .day, value: 30, to: today)!
        
        let metrics = UserProgressMetrics(
            totalQuestionsAnswered: 100,
            totalQuestions: 500,
            masteryCategoryStats: [:],
            examDate: examDate,
            currentDate: today
        )
        
        let message = metrics.motivationMessage
        
        XCTAssertTrue(message.contains("Prüfungstermin"))
    }
    
    func testMotivationMessageGermanLanguage() {
        let today = Date()
        let examDate = Calendar.current.date(byAdding: .day, value: 30, to: today)!
        
        let metrics = UserProgressMetrics(
            totalQuestionsAnswered: 100,
            totalQuestions: 500,
            masteryCategoryStats: [:],
            examDate: examDate,
            currentDate: today
        )
        
        let message = metrics.motivationMessage
        
        XCTAssertTrue(message.contains("gemeistert"))
        XCTAssertTrue(message.contains("Premium"))
    }
    
    // MARK: - Remaining Percentage
    func testRemainingPercentageComplementCompletion() {
        let metrics = UserProgressMetrics(
            totalQuestionsAnswered: 250,
            totalQuestions: 500,
            masteryCategoryStats: [:],
            examDate: .now,
            currentDate: .now
        )
        
        XCTAssertEqual(
            metrics.completionPercentage + metrics.remainingPercentage,
            100
        )
    }
}