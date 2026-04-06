import XCTest
@testable import DriveAI

@MainActor
final class ExamSessionViewModelTests: XCTestCase {
    var sut: ExamSessionViewModel!
    var mockDataService: MockLocalDataService!
    
    override func setUp() {
        super.setUp()
        mockDataService = MockLocalDataService()
        sut = ExamSessionViewModel(dataService: mockDataService)
    }
    
    // MARK: - Session Initialization
    
    func testCreateSession_loads30Questions() async {
        let allQuestions = (0..<90).map { i in
            Question.stub(id: UUID(), number: i + 1)
        }
        mockDataService.stubbedAllQuestions = allQuestions
        
        await sut.createExamSession()
        
        XCTAssertEqual(sut.examSession?.questions.count, 30)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testCreateSession_shufflesQuestions() async {
        let allQuestions = (0..<90).map { i in
            Question.stub(id: UUID(), number: i + 1)
        }
        mockDataService.stubbedAllQuestions = allQuestions
        
        let session1 = await sut.createExamSession()
        let session2 = await sut.createExamSession()
        
        // Questions should be in different order (with high probability)
        let ids1 = session1.questions.map { $0.id }
        let ids2 = session2.questions.map { $0.id }
        
        XCTAssertNotEqual(ids1, ids2)
    }
    
    func testCreateSession_startsTimer() async {
        let questions = (0..<30).map { i in
            Question.stub(id: UUID(), number: i + 1)
        }
        mockDataService.stubbedAllQuestions = questions
        
        await sut.createExamSession()
        
        XCTAssertNotNil(sut.examSession?.startDate)
    }
    
    func testCreateSession_failure_setsError() async {
        mockDataService.shouldFail = true
        
        await sut.createExamSession()
        
        XCTAssertNotNil(sut.error)
        XCTAssertNil(sut.examSession)
    }
    
    // MARK: - Answer Tracking
    
    func testSubmitAnswer_recordsInSession() async {
        await setupExamSession()
        let questionId = sut.examSession!.questions[0].id
        let answerId = sut.examSession!.questions[0].answers[0].id
        
        sut.submitAnswer(answerId, forQuestion: questionId)
        
        XCTAssertTrue(sut.examSession!.answers.contains { 
            $0.questionId == questionId && $0.selectedAnswerId == answerId 
        })
    }
    
    func testSubmitAnswer_calculatesCorrectness() async {
        await setupExamSession()
        let question = sut.examSession!.questions[0]
        let correctAnswer = question.answers.first { $0.isCorrect }!
        
        sut.submitAnswer(correctAnswer.id, forQuestion: question.id)
        
        let answer = sut.examSession!.answers.first!
        XCTAssertTrue(answer.isCorrect)
    }
    
    func testSubmitAnswer_tracksTimeSpent() async {
        await setupExamSession()
        let questionId = sut.examSession!.questions[0].id
        let answerId = sut.examSession!.questions[0].answers[0].id
        
        let beforeSubmit = Date()
        usleep(100_000) // 100ms
        sut.submitAnswer(answerId, forQuestion: questionId)
        let afterSubmit = Date()
        
        let answer = sut.examSession!.answers.first!
        XCTAssertGreater(answer.timeSpentSeconds, 0)
        XCTAssertLess(answer.timeSpentSeconds, Int(afterSubmit.timeIntervalSince(beforeSubmit)) + 1)
    }
    
    func testSubmitAnswer_updatesScoreCorrectly() async {
        await setupExamSession()
        var correctCount = 0
        
        for question in sut.examSession!.questions.prefix(5) {
            let correctAnswer = question.answers.first { $0.isCorrect }!
            sut.submitAnswer(correctAnswer.id, forQuestion: question.id)
            correctCount += 1
        }
        
        XCTAssertEqual(sut.examSession!.score, correctCount)
    }
    
    // MARK: - Time Management
    
    func testTimeRemaining_calculatesCorrectly() async {
        await setupExamSession()
        let maxTime = TimeInterval(sut.examDurationSeconds)
        let timeRemaining = sut.timeRemaining
        
        // Should be close to full duration at start
        XCTAssertLess(timeRemaining, maxTime)
        XCTAssertGreater(timeRemaining, maxTime - 2) // Allow 2 second variance
    }
    
    func testTimeExpired_whenTimeRunsOut() async {
        await setupExamSession()
        
        // Fast-forward time
        let startDate = sut.examSession!.startDate
        let expiredDate = startDate.addingTimeInterval(TimeInterval(sut.examDurationSeconds) + 1)
        
        // Mock time passage
        sut.currentMockTime = expiredDate
        
        XCTAssertTrue(sut.isTimeExpired)
    }
    
    func testPauseExam_stopsTimer() async {
        await setupExamSession()
        
        sut.pauseExam()
        
        XCTAssertTrue(sut.isPaused)
    }
    
    func testResumeExam_restarts() async {
        await setupExamSession()
        sut.pauseExam()
        
        sut.resumeExam()
        
        XCTAssertFalse(sut.isPaused)
    }
    
    // MARK: - Progress & Navigation
    
    func testProgressPercentage_calculatesCorrectly() async {
        await setupExamSession()
        
        for i in 0..<10 {
            let question = sut.examSession!.questions[i]
            sut.submitAnswer(question.answers[0].id, forQuestion: question.id)
        }
        
        let expected = Double(10) / 30.0 * 100
        XCTAssertEqual(sut.progressPercentage, expected, accuracy: 1)
    }
    
    func testNavigateToQuestion_atIndex() async {
        await setupExamSession()
        
        sut.navigateToQuestion(15)
        
        XCTAssertEqual(sut.currentQuestionIndex, 15)
    }
    
    func testNavigateBackButton_disabledAtStart() async {
        await setupExamSession()
        
        XCTAssertTrue(sut.isBackButtonDisabled)
    }
    
    func testNavigateBackButton_enabledAfterProgression() async {
        await setupExamSession()
        sut.navigateToQuestion(5)
        
        XCTAssertFalse(sut.isBackButtonDisabled)
    }
    
    func testNavigateForwardButton_disabledAtEnd() async {
        await setupExamSession()
        sut.navigateToQuestion(29) // Last question
        
        XCTAssertTrue(sut.isForwardButtonDisabled)
    }
    
    // MARK: - Completion & Results
    
    func testCompleteExam_calculatesPassFail() async {
        await setupExamSession()
        
        // Answer enough questions correctly to pass (≥48%)
        let passThreshold = Int(Double(30) * 0.48) + 1 // 15+ correct = pass
        
        for i in 0..<passThreshold {
            let question = sut.examSession!.questions[i]
            let correctAnswer = question.answers.first { $0.isCorrect }!
            sut.submitAnswer(correctAnswer.id, forQuestion: question.id)
        }
        
        let result = await sut.completeExam()
        
        XCTAssertTrue(result.passed)
    }
    
    func testCompleteExam_failsWithLowScore() async {
        await setupExamSession()
        
        // Answer most questions incorrectly
        for question in sut.examSession!.questions.prefix(25) {
            let incorrectAnswer = question.answers.first { !$0.isCorrect }!
            sut.submitAnswer(incorrectAnswer.id, forQuestion: question.id)
        }
        
        let result = await sut.completeExam()
        
        XCTAssertFalse(result.passed)
    }
    
    func testCompleteExam_setsEndDate() async {
        await setupExamSession()
        let beforeComplete = Date()
        
        let result = await sut.completeExam()
        
        let afterComplete = Date()
        XCTAssertNotNil(result.endDate)
        XCTAssert(result.endDate! >= beforeComplete && result.endDate! <= afterComplete)
    }
    
    // MARK: - Edge Cases
    
    func testCompleteExam_withUnansweredQuestions() async {
        await setupExamSession()
        
        // Answer only some questions
        for i in 0..<15 {
            let question = sut.examSession!.questions[i]
            sut.submitAnswer(question.answers[0].id, forQuestion: question.id)
        }
        
        let result = await sut.completeExam()
        
        // Should calculate score from answered questions only
        XCTAssertEqual(sut.examSession!.answers.count, 15)
    }
    
    func testSwitchQuestion_withoutSubmitting_doesNotRecord() async {
        await setupExamSession()
        let question1 = sut.examSession!.questions[0]
        
        sut.navigateToQuestion(5)
        
        XCTAssertEqual(sut.examSession!.answers.count, 0)
    }
    
    func testReviewQuestion_allowsChangingAnswer() async {
        await setupExamSession()
        let question = sut.examSession!.questions[0]
        let firstAnswer = question.answers[0]
        let secondAnswer = question.answers[1]
        
        sut.submitAnswer(firstAnswer.id, forQuestion: question.id)
        var answer1 = sut.examSession!.answers.first!
        
        sut.submitAnswer(secondAnswer.id, forQuestion: question.id)
        let answer2 = sut.examSession!.answers.first!
        
        XCTAssertEqual(answer2.selectedAnswerId, secondAnswer.id)
        XCTAssertNotEqual(answer1.selectedAnswerId, answer2.selectedAnswerId)
    }
    
    // MARK: - Helpers
    
    private func setupExamSession() async {
        let questions = (0..<30).map { i in
            Question.stub(id: UUID(), number: i + 1)
        }
        mockDataService.stubbedAllQuestions = questions
        await sut.createExamSession()
    }
}