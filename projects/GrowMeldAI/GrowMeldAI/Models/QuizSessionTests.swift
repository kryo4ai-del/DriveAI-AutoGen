// Tests/Unit/Models/QuizSessionTests.swift
import XCTest
@testable import DriveAI

final class QuizSessionTests: XCTestCase {
    var session: QuizSession!
    var questions: [Question]!
    
    override func setUp() {
        super.setUp()
        questions = [
            Question.fixture(id: "q1", correctAnswerIndex: 0),
            Question.fixture(id: "q2", correctAnswerIndex: 1),
            Question.fixture(id: "q3", correctAnswerIndex: 2),
        ]
        session = QuizSession(questions: questions)
    }
    
    // MARK: - Current Question
    func test_currentQuestion_atStart() {
        XCTAssertEqual(session.currentQuestion?.id, "q1")
    }
    
    func test_currentQuestion_afterNavigation() {
        session.currentQuestionIndex = 1
        XCTAssertEqual(session.currentQuestion?.id, "q2")
    }
    
    func test_currentQuestion_outOfBounds() {
        session.currentQuestionIndex = 100
        XCTAssertNil(session.currentQuestion)
    }
    
    // MARK: - Answer Selection
    func test_selectAnswer_firstQuestion() {
        session.selectAnswer(0)  // Correct answer
        XCTAssertEqual(session.selectedAnswers[0], 0)
        XCTAssertEqual(session.correctCount, 1)
    }
    
    func test_selectAnswer_wrongAnswer() {
        session.selectAnswer(3)  // Incorrect (correct is 0)
        XCTAssertEqual(session.selectedAnswers[0], 3)
        XCTAssertEqual(session.correctCount, 0)
    }
    
    func test_selectAnswer_multipleQuestions() {
        session.selectAnswer(0)  // Q1 correct
        session.nextQuestion()
        session.selectAnswer(1)  // Q2 correct
        
        XCTAssertEqual(session.correctCount, 2)
        XCTAssertEqual(session.selectedAnswers.count, 2)
    }
    
    func test_selectAnswer_overwritesPrevious() {
        session.selectAnswer(3)  // Wrong
        session.selectAnswer(0)  // Correct
        
        XCTAssertEqual(session.selectedAnswers[0], 0)
        XCTAssertEqual(session.correctCount, 1)
    }
    
    // MARK: - Progress
    func test_progress_atStart() {
        XCTAssertEqual(session.progress, 1.0 / 3.0, accuracy: 0.01)
    }
    
    func test_progress_midway() {
        session.currentQuestionIndex = 1
        XCTAssertEqual(session.progress, 2.0 / 3.0, accuracy: 0.01)
    }
    
    func test_progress_atEnd() {
        session.currentQuestionIndex = 2
        XCTAssertEqual(session.progress, 1.0, accuracy: 0.01)
    }
    
    // MARK: - Navigation
    func test_nextQuestion_advances() {
        session.nextQuestion()
        XCTAssertEqual(session.currentQuestionIndex, 1)
        XCTAssertFalse(session.isCompleted)
    }
    
    func test_nextQuestion_atLastQuestion_completesSession() {
        session.currentQuestionIndex = 2
        session.nextQuestion()
        
        XCTAssertTrue(session.isCompleted)
        XCTAssertNotNil(session.endTime)
    }
    
    func test_nextQuestion_beyondLastQuestion_noOp() {
        session.currentQuestionIndex = 3
        session.nextQuestion()
        
        XCTAssertEqual(session.currentQuestionIndex, 3)
    }
    
    // MARK: - Edge Cases
    func test_emptySession() {
        let empty = QuizSession(questions: [])
        XCTAssertNil(empty.currentQuestion)
        XCTAssertEqual(empty.progress, 0)
    }
    
    func test_singleQuestion() {
        let single = QuizSession(questions: [Question.fixture()])
        XCTAssertEqual(single.progress, 1.0)
        
        single.nextQuestion()
        XCTAssertTrue(single.isCompleted)
    }
}