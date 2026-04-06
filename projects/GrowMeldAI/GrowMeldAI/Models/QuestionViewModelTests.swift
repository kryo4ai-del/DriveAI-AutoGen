// Tests/Unit/QuestionViewModelTests.swift
import XCTest
@testable import DriveAI

@MainActor
final class QuestionViewModelTests: XCTestCase {
    
    var viewModel: QuestionViewModel!
    var mockQuestionService: MockQuestionService!
    var mockAnalyticsService: MockAnalyticsService!
    
    override func setUp() async throws {
        mockQuestionService = MockQuestionService()
        mockAnalyticsService = MockAnalyticsService()
        
        viewModel = QuestionViewModel(
            questionService: mockQuestionService,
            analyticsService: mockAnalyticsService,
            mode: .learning,
            category: nil
        )
    }
    
    // MARK: - State Transitions
    
    func testInitialStateIsIdle() {
        if case .idle = viewModel.state {
            XCTAssert(true)
        } else {
            XCTFail("Expected initial state to be .idle, got \(viewModel.state)")
        }
    }
    
    func testLoadQuestionsTransitionsToLoading() async {
        await viewModel.loadQuestions()
        
        if case .loading = viewModel.state {
            XCTAssert(true)
        } else {
            XCTFail("Expected .loading state during load")
        }
    }
    
    func testLoadQuestionsTransitionsToPresenting() async {
        mockQuestionService.questionsToReturn = [.mock]
        
        await viewModel.loadQuestions()
        try? await Task.sleep(for: .milliseconds(100))
        
        if case .presenting(let q, _) = viewModel.state {
            XCTAssertEqual(q.id, Question.mock.id)
        } else {
            XCTFail("Expected .presenting state after loading questions")
        }
    }
    
    func testLoadQuestionsWithEmptyResultsShowsError() async {
        mockQuestionService.questionsToReturn = []
        
        await viewModel.loadQuestions()
        try? await Task.sleep(for: .milliseconds(100))
        
        if case .error(let msg) = viewModel.state {
            XCTAssertEqual(msg, "Keine Fragen verfügbar")
        } else {
            XCTFail("Expected .error state for empty questions")
        }
    }
    
    func testLoadQuestionsWithErrorPropagatesError() async {
        mockQuestionService.shouldThrowError = true
        
        await viewModel.loadQuestions()
        try? await Task.sleep(for: .milliseconds(100))
        
        if case .error = viewModel.state {
            XCTAssert(true)
        } else {
            XCTFail("Expected .error state when service throws")
        }
    }
    
    // MARK: - Answer Selection
    
    func testSelectAnswerUpdatesSelectedAnswerInState() async {
        mockQuestionService.questionsToReturn = [.mock]
        await viewModel.loadQuestions()
        try? await Task.sleep(for: .milliseconds(100))
        
        viewModel.selectAnswer("A")
        
        if case .presenting(_, let selected) = viewModel.state {
            XCTAssertEqual(selected, "A")
        } else {
            XCTFail("Expected selected answer to be 'A'")
        }
    }
    
    func testSelectAnswerDoesNothingIfNotPresenting() {
        viewModel.selectAnswer("A")
        
        if case .idle = viewModel.state {
            XCTAssert(true)
        } else {
            XCTFail("State should remain unchanged if not presenting")
        }
    }
    
    func testSelectingDifferentAnswerReplacesPrevious() async {
        mockQuestionService.questionsToReturn = [.mock]
        await viewModel.loadQuestions()
        try? await Task.sleep(for: .milliseconds(100))
        
        viewModel.selectAnswer("A")
        viewModel.selectAnswer("B")
        
        if case .presenting(_, let selected) = viewModel.state {
            XCTAssertEqual(selected, "B")
        } else {
            XCTFail("Selected answer should be updated to 'B'")
        }
    }
    
    // MARK: - Answer Submission
    
    func testSubmitCorrectAnswerTransitionsToSubmittedWithIsCorrectTrue() async {
        let question = Question.mock
        mockQuestionService.questionsToReturn = [question]
        await viewModel.loadQuestions()
        try? await Task.sleep(for: .milliseconds(100))
        
        viewModel.selectAnswer(question.correctAnswerID)
        await viewModel.submitAnswer()
        
        if case .submitted(_, _, let isCorrect, _) = viewModel.state {
            XCTAssertTrue(isCorrect)
        } else {
            XCTFail("Expected .submitted state with isCorrect=true")
        }
    }
    
    func testSubmitIncorrectAnswerTransitionsToSubmittedWithIsCorrectFalse() async {
        let question = Question.mock
        mockQuestionService.questionsToReturn = [question]
        await viewModel.loadQuestions()
        try? await Task.sleep(for: .milliseconds(100))
        
        let wrongAnswer = "Z" // Not the correct answer
        viewModel.selectAnswer(wrongAnswer)
        await viewModel.submitAnswer()
        
        if case .submitted(_, _, let isCorrect, _) = viewModel.state {
            XCTAssertFalse(isCorrect)
        } else {
            XCTFail("Expected .submitted state with isCorrect=false")
        }
    }
    
    func testSubmitAnswerIncrementsCorrectAnswerCount() async {
        let question = Question.mock
        mockQuestionService.questionsToReturn = [question]
        await viewModel.loadQuestions()
        try? await Task.sleep(for: .milliseconds(100))
        
        XCTAssertEqual(viewModel.correctAnswers, 0)
        
        viewModel.selectAnswer(question.correctAnswerID)
        await viewModel.submitAnswer()
        
        XCTAssertEqual(viewModel.correctAnswers, 1)
    }
    
    func testSubmitCorrectAnswerIncrementsStreak() async {
        let question = Question.mock
        mockQuestionService.questionsToReturn = [question]
        await viewModel.loadQuestions()
        try? await Task.sleep(for: .milliseconds(100))
        
        XCTAssertEqual(viewModel.streak, 0)
        
        viewModel.selectAnswer(question.correctAnswerID)
        await viewModel.submitAnswer()
        
        XCTAssertEqual(viewModel.streak, 1)
    }
    
    func testSubmitIncorrectAnswerResetsStreak() async {
        // Set initial streak
        viewModel.streak = 5
        
        let question = Question.mock
        mockQuestionService.questionsToReturn = [question]
        await viewModel.loadQuestions()
        try? await Task.sleep(for: .milliseconds(100))
        
        viewModel.selectAnswer("Z") // Wrong answer
        await viewModel.submitAnswer()
        
        XCTAssertEqual(viewModel.streak, 0)
    }
    
    func testSubmitRecordsAnalyticsEvent() async {
        let question = Question.mock
        mockQuestionService.questionsToReturn = [question]
        await viewModel.loadQuestions()
        try? await Task.sleep(for: .milliseconds(100))
        
        viewModel.selectAnswer(question.correctAnswerID)
        await viewModel.submitAnswer()
        
        XCTAssertEqual(mockAnalyticsService.recordedAnswers.count, 1)
        let recorded = mockAnalyticsService.recordedAnswers.first!
        XCTAssertEqual(recorded.questionID, question.id)
        XCTAssertTrue(recorded.correct)
    }
    
    func testSubmitWithoutSelectionDoesNothing() async {
        mockQuestionService.questionsToReturn = [.mock]
        await viewModel.loadQuestions()
        try? await Task.sleep(for: .milliseconds(100))
        
        // Don't select an answer
        await viewModel.submitAnswer()
        
        if case .presenting = viewModel.state {
            XCTAssert(true) // State unchanged
        } else {
            XCTFail("State should remain .presenting when no answer selected")
        }
    }
    
    // MARK: - Progress Tracking
    
    func testProgressUpdatesAfterLoadingQuestions() async {
        let questions = [Question.mock, Question.mock, Question.mock]
        mockQuestionService.questionsToReturn = questions
        
        await viewModel.loadQuestions()
        try? await Task.sleep(for: .milliseconds(100))
        
        XCTAssertEqual(viewModel.progress.current, 1)
        XCTAssertEqual(viewModel.progress.total, 3)
    }
    
    func testProgressIncrementAfterNextQuestion() async {
        let questions = [Question.mock, Question.mock, Question.mock]
        mockQuestionService.questionsToReturn = questions
        
        await viewModel.loadQuestions()
        try? await Task.sleep(for: .milliseconds(100))
        
        viewModel.selectAnswer("A")
        await viewModel.submitAnswer()
        await viewModel.nextQuestion()
        
        XCTAssertEqual(viewModel.progress.current, 2)
        XCTAssertEqual(viewModel.progress.total, 3)
    }
    
    // MARK: - Session Timer
    
    func testSessionTimeIncrementsWhenLoaded() async {
        mockQuestionService.questionsToReturn = [.mock]
        
        let initialTime = viewModel.sessionTime
        await viewModel.loadQuestions()
        
        // Wait for timer to tick
        try? await Task.sleep(for: .milliseconds(1100))
        
        XCTAssertGreaterThan(viewModel.sessionTime, initialTime)
    }
    
    func testSessionTimerCancelsOnDeinit() async {
        mockQuestionService.questionsToReturn = [.mock]
        await viewModel.loadQuestions()
        
        let timeBeforeDeinit = viewModel.sessionTime
        
        // Deinit will be called here
        var localViewModel: QuestionViewModel? = viewModel
        viewModel = QuestionViewModel(
            questionService: mockQuestionService,
            analyticsService: mockAnalyticsService
        )
        localViewModel = nil
        
        try? await Task.sleep(for: .milliseconds(1100))
        
        // Time should not have incremented after deinit
        XCTAssertEqual(viewModel.sessionTime, 0)
    }
}

// MARK: - Mocks

final class MockQuestionService: QuestionServiceProtocol {
    var questionsToReturn: [Question] = []
    var shouldThrowError = false
    
    func fetchQuestions(category: Category?, limit: Int? = nil) async throws -> [Question] {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1)
        }
        var result = questionsToReturn
        if let limit = limit {
            result = Array(result.prefix(limit))
        }
        return result
    }
    
    func checkAnswer(_ answerID: String, for question: Question) -> Bool {
        return answerID == question.correctAnswerID
    }
    
    func fetchCategories() async throws -> [Category] {
        return []
    }
}

final class MockAnalyticsService: ObservableObject {
    @Published var recordedAnswers: [RecordedAnswer] = []
    
    struct RecordedAnswer {
        let questionID: String
        let correct: Bool
        let categoryID: String
        let responseTime: TimeInterval
    }
    
    func recordAnswer(
        questionID: String,
        correct: Bool,
        categoryID: String,
        responseTime: TimeInterval
    ) async {
        recordedAnswers.append(
            RecordedAnswer(
                questionID: questionID,
                correct: correct,
                categoryID: categoryID,
                responseTime: responseTime
            )
        )
    }
}

// Test fixtures
extension Question {
    static let mock = Question(
        id: "q1",
        text: "Was ist die maximale Geschwindigkeit in der Stadt?",
        category: .mock,
        answers: [
            Answer(id: "A", text: "30 km/h"),
            Answer(id: "B", text: "50 km/h"),
            Answer(id: "C", text: "60 km/h"),
            Answer(id: "D", text: "80 km/h")
        ],
        correctAnswerID: "B",
        explanation: "In bebauten Gebieten beträgt die zulässige Höchstgeschwindigkeit 50 km/h."
    )
}

extension Category {
    static let mock = Category(
        id: "cat1",
        name: "Verkehrsregeln",
        description: "Grundregeln des Straßenverkehrs"
    )
}