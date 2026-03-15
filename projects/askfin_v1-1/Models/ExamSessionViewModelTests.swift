// Tests/Features/ExamReadiness/ViewModels/ExamSessionViewModelTests.swift
import XCTest
import Combine
import Foundation
// [FK-019 sanitized] @testable import DriveAI

@MainActor
final class ExamSessionViewModelTests: XCTestCase {
    var sut: ExamSessionViewModel!
    var mockExamService: MockExamSessionService!
    var mockRepository: MockQuestionRepository!
    var mockPersistence: MockPersistenceService!
    var mockTimer: MockExamTimerService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
        mockRepository = MockQuestionRepository()
        mockPersistence = MockPersistenceService()
        mockExamService = MockExamSessionService()
        mockTimer = MockExamTimerService()
        
        let session = ExamSession(
            id: "test-session",
            startTime: Date(),
            endTime: nil,
            answers: [:],
            score: nil,
            passed: nil,
            questionIds: ["q1", "q2", "q3"]
        )
        
        sut = ExamSessionViewModel(
            session: session,
            examSessionService: mockExamService,
            persistenceService: mockPersistence,
            questionRepository: mockRepository,
            timerService: mockTimer
        )
    }
    
    override func tearDown() {
        cancellables.removeAll()
        sut = nil
        mockRepository = nil
        mockPersistence = nil
        mockExamService = nil
        mockTimer = nil
        super.tearDown()
    }
    
    // MARK: - Happy Path Tests
    
    func test_loadQuestions_success() async {
        // Given
        let mockQuestions = [
            Question.fixture(id: "q1", correctAnswer: 0),
            Question.fixture(id: "q2", correctAnswer: 1),
            Question.fixture(id: "q3", correctAnswer: 2)
        ]
        mockRepository.questionsToReturn = mockQuestions
        
        // When
        await sut.loadQuestions()
        
        // Then
        XCTAssertEqual(sut.examQuestions.count, 3)
        XCTAssertEqual(sut.currentQuestion?.id, "q1")
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_selectAnswer_updatesState() async {
        // Given
        await sut.loadQuestions()
        
        // When
        try? await sut.selectAnswer(2)
        
        // Then
        XCTAssertEqual(sut.selectedAnswer, 2)
        XCTAssertTrue(sut.hasAnsweredCurrent)
        XCTAssertTrue(mockPersistence.saveExamSessionCalled)
    }
    
    func test_selectAnswer_storesInSession() async {
        // Given
        await sut.loadQuestions()
        let questionId = sut.currentQuestion!.id
        
        // When
        try? await sut.selectAnswer(1)
        
        // Then
        XCTAssertEqual(sut.session.answers[questionId], 1)
    }
    
    func test_showFeedback_onAnswerSelection() async {
        // Given
        await sut.loadQuestions()
        
        // When
        sut.toggleFeedback()
        
        // Then
        XCTAssertTrue(sut.showFeedback)
    }
    
    func test_nextQuestion_advancesIndex() async {
        // Given
        await sut.loadQuestions()
        XCTAssertEqual(sut.currentQuestionIndex, 0)
        
        // When
        sut.nextQuestion()
        
        // Then
        XCTAssertEqual(sut.currentQuestionIndex, 1)
        XCTAssertEqual(sut.currentQuestion?.id, "q2")
        XCTAssertNil(sut.selectedAnswer) // Reset on advance
        XCTAssertFalse(sut.showFeedback)
    }
    
    // MARK: - Edge Cases
    
    func test_nextQuestion_atLastQuestion_doesNotAdvance() async {
        // Given
        await sut.loadQuestions()
        sut.currentQuestionIndex = 2 // Last question
        
        // When
        sut.nextQuestion()
        
        // Then
        XCTAssertEqual(sut.currentQuestionIndex, 2) // No change
    }
    
    func test_selectAnswer_beforeLoadingQuestions_fails() async {
        // When
        await self.expectError {
            try await self.sut.selectAnswer(0)
        }
        
        // Then
        XCTAssertNil(sut.currentQuestion)
    }
    
    func test_selectAnswer_withInvalidIndex_fails() async {
        // Given
        await sut.loadQuestions()
        
        // When
        await self.expectError {
            try await self.sut.selectAnswer(99) // Invalid: only 0-3 valid
        }
        
        // Then
        XCTAssertNil(sut.selectedAnswer)
    }
    
    func test_submitExam_calculatesCorrectScore() async {
        // Given
        await sut.loadQuestions()
        mockExamService.scoreToReturn = 24
        
        // When
        try? await sut.submitExam()
        
        // Then
        XCTAssertEqual(sut.session.score, 24)
        XCTAssertTrue(sut.session.passed ?? false)
        XCTAssertNotNil(sut.session.endTime)
    }
    
    func test_submitExam_failingScore() async {
        // Given
        await sut.loadQuestions()
        mockExamService.scoreToReturn = 20 // < 24 (80%)
        
        // When
        try? await sut.submitExam()
        
        // Then
        XCTAssertEqual(sut.session.score, 20)
        XCTAssertFalse(sut.session.passed ?? true)
    }
    
    // MARK: - Error Handling
    
    func test_loadQuestions_fileNotFound() async {
        // Given
        mockRepository.errorToThrow = LocalDataError.fileNotFound
        
        // When
        await sut.loadQuestions()
        
        // Then
        XCTAssertTrue(sut.showError)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.examQuestions.isEmpty)
    }
    
    func test_selectAnswer_persistenceFails_showsError() async {
        // Given
        await sut.loadQuestions()
        mockPersistence.errorToThrow = PersistenceError.writeFailure(reason: "Disk full")
        
        // When
        try? await sut.selectAnswer(1)
        
        // Then
        XCTAssertTrue(sut.showError)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssert(sut.errorMessage?.contains("Speichern") ?? false)
    }
    
    // MARK: - Timer Integration
    
    func test_startExam_startsTimer() async {
        // When
        sut.startExam()
        
        // Then
        XCTAssertTrue(mockTimer.startCalled)
    }
    
    func test_pauseExam_pausesTimer() {
        // When
        sut.pauseExam()
        
        // Then
        XCTAssertTrue(mockTimer.pauseCalled)
    }
    
    // MARK: - Helper Methods
    
    private func expectError<T>(
        _ operation: @escaping () async throws -> T
    ) async {
        do {
            _ = try await operation()
            XCTFail("Expected error but operation succeeded")
        } catch {
            // Expected
        }
    }
}

// MARK: - Fixtures

extension Question {
    static func fixture(
        id: String = UUID().uuidString,
        category: QuestionCategory = .trafficSigns,
        text: String = "Testfrage?",
        answers: [String] = ["A", "B", "C", "D"],
        correctAnswer: Int = 0,
        explanation: String = "Erklärung",
        imageURL: URL? = nil,
        difficultyLevel: Int = 2
    ) -> Question {
        Question(
            id: id,
            category: category,
            text: text,
            answers: answers,
            correctAnswer: correctAnswer,
            explanation: explanation,
            imageURL: imageURL,
            difficultyLevel: difficultyLevel
        )
    }
}

extension ExamSession {
    static func fixture(
        id: String = UUID().uuidString,
        startTime: Date = Date(),
        endTime: Date? = nil,
        answers: [String: Int] = [:],
        score: Int? = nil,
        passed: Bool? = nil,
        questionIds: [String] = []
    ) -> ExamSession {
        ExamSession(
            id: id,
            startTime: startTime,
            endTime: endTime,
            answers: answers,
            score: score,
            passed: passed,
            questionIds: questionIds
        )
    }
}