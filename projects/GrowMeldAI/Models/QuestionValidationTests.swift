// Tests/Domain/ModelValidationTests.swift
import XCTest
@testable import DriveAI

final class QuestionValidationTests: XCTestCase {
    
    func test_init_withValidData_succeeds() throws {
        let answers = try [
            Answer(text: "Option A", isCorrect: true),
            Answer(text: "Option B", isCorrect: false),
            Answer(text: "Option C", isCorrect: false)
        ]
        let question = try Question(
            categoryID: UUID(),
            text: "Test question?",
            answers: answers,
            correctAnswerID: answers[0].id
        )
        XCTAssertEqual(question.text, "Test question?")
    }
    
    func test_init_withEmptyText_throws() {
        XCTAssertThrowsError(
            try Question(
                categoryID: UUID(),
                text: "  ",  // Empty after trim
                answers: [],
                correctAnswerID: UUID()
            ),
            "Should throw ValidationError.emptyText"
        )
    }
    
    func test_init_withInsufficientAnswers_throws() {
        let answers = try [
            Answer(text: "A", isCorrect: true),
            Answer(text: "B", isCorrect: false)
        ]
        XCTAssertThrowsError(
            try Question(
                categoryID: UUID(),
                text: "Q?",
                answers: answers,
                correctAnswerID: answers[0].id
            ),
            "Should throw ValidationError.insufficientAnswers"
        )
    }
}

// Tests/Services/ProgressServiceTests.swift
final class ProgressServiceTests: XCTestCase {
    
    func test_recordAnswer_updatesProgress() async throws {
        let persistence = MockProgressPersistence()
        let service = ProgressService(persistence: persistence)
        
        let answer = try SessionAnswer(
            questionID: UUID(),
            selectedAnswerID: UUID(),
            isCorrect: true
        )
        
        try await service.recordAnswer(answer)
        
        let stats = await service.getOverallStats()
        XCTAssertEqual(stats.totalQuestionsAnswered, 1)
    }
}