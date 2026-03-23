import XCTest
import Foundation
@testable import DriveAI

final class ReadinessAssessmentTests: XCTestCase {
    
    // MARK: - Score Calculation
    
    func test_calculateScore_withPerfectScore_returns100() {
        let score = ReadinessAssessment.calculateScore(10, 10)
        XCTAssertEqual(score, 100.0)
    }
    
    func test_calculateScore_withHalfCorrect_returns50() {
        let score = ReadinessAssessment.calculateScore(5, 10)
        XCTAssertEqual(score, 50.0)
    }
    
    func test_calculateScore_withZeroCorrect_returns0() {
        let score = ReadinessAssessment.calculateScore(0, 10)
        XCTAssertEqual(score, 0.0)
    }
    
    func test_calculateScore_withZeroQuestions_returns0() {
        let score = ReadinessAssessment.calculateScore(5, 0)
        XCTAssertEqual(score, 0.0)
    }
    
    // MARK: - Assessment Initialization
    
    func test_init_correctlyCalculatesOverallScore() {
        let categoryResults = [
            makeCategoryResult(correctAnswers: 2, questionsAsked: 3),
            makeCategoryResult(correctAnswers: 3, questionsAsked: 4)
        ]
        
        let assessment = ReadinessAssessment(
            totalQuestions: 7,
            correctAnswers: 5,
            categoryResults: categoryResults
        )
        
        XCTAssertEqual(assessment.overallScore, 71.43, accuracy: 0.01)
    }
    
    func test_init_setsReadinessLevel_notReady() {
        let assessment = ReadinessAssessment(
            totalQuestions: 10,
            correctAnswers: 4,
            categoryResults: []
        )
        
        XCTAssertEqual(assessment.readinessLevel, .notReady)
    }
    
    func test_init_setsReadinessLevel_developing() {
        let assessment = ReadinessAssessment(
            totalQuestions: 10,
            correctAnswers: 6,
            categoryResults: []
        )
        
        XCTAssertEqual(assessment.readinessLevel, .developing)
    }
    
    func test_init_setsReadinessLevel_wellPrepared() {
        let assessment = ReadinessAssessment(
            totalQuestions: 10,
            correctAnswers: 9,
            categoryResults: []
        )
        
        XCTAssertEqual(assessment.readinessLevel, .wellPrepared)
    }
    
    func test_init_sortsCategoryResultsByAccuracy() {
        let results = [
            makeCategoryResult(correctAnswers: 4, questionsAsked: 5), // 80%
            makeCategoryResult(correctAnswers: 3, questionsAsked: 5),  // 60%
            makeCategoryResult(correctAnswers: 5, questionsAsked: 5)   // 100%
        ]
        
        let assessment = ReadinessAssessment(
            totalQuestions: 15,
            correctAnswers: 12,
            categoryResults: results
        )
        
        XCTAssertEqual(assessment.categoryResults[0].accuracy, 60.0)
        XCTAssertEqual(assessment.categoryResults[1].accuracy, 80.0)
        XCTAssertEqual(assessment.categoryResults[2].accuracy, 100.0)
    }
    
    func test_passPercentage_calculatesCorrectly() {
        let assessment = ReadinessAssessment(
            totalQuestions: 10,
            correctAnswers: 7,
            categoryResults: []
        )
        
        XCTAssertEqual(assessment.passPercentage, 70.0)
    }
    
    func test_passPercentage_withZeroQuestions_returns0() {
        let assessment = ReadinessAssessment(
            totalQuestions: 0,
            correctAnswers: 0,
            categoryResults: []
        )
        
        XCTAssertEqual(assessment.passPercentage, 0.0)
    }
    
    // MARK: - Codable Conformance
    
    func test_assessment_isEncodableAndDecodable() throws {
        let assessment = ReadinessAssessment(
            totalQuestions: 10,
            correctAnswers: 7,
            categoryResults: [makeCategoryResult(correctAnswers: 7, questionsAsked: 10)]
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let encoded = try encoder.encode(assessment)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(ReadinessAssessment.self, from: encoded)
        
        XCTAssertEqual(decoded.id, assessment.id)
        XCTAssertEqual(decoded.overallScore, assessment.overallScore)
        XCTAssertEqual(decoded.readinessLevel, assessment.readinessLevel)
    }
    
    // MARK: - Helpers
    
    private func makeCategoryResult(correctAnswers: Int, questionsAsked: Int) -> CategoryResult {
        CategoryResult(
            id: UUID(),
            categoryId: "test-category",
            categoryName: "Test Category",
            questionsAsked: questionsAsked,
            correctAnswers: correctAnswers,
            difficulty: DifficultyBreakdown(
                easy: DifficultyBreakdown.QuestionStats(asked: 0, correct: 0),
                medium: DifficultyBreakdown.QuestionStats(asked: questionsAsked, correct: correctAnswers),
                hard: DifficultyBreakdown.QuestionStats(asked: 0, correct: 0)
            )
        )
    }
}