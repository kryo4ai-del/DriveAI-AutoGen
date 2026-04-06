import XCTest
@testable import DriveAI

final class QuizResultTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testQuizResultInitialization_ValidInputs() {
        let result = QuizResult(
            categoryId: "traffic-signs",
            categoryName: "Verkehrszeichen",
            score: 7.5,
            questionCount: 10,
            correctAnswers: 8
        )
        
        XCTAssertEqual(result.categoryId, "traffic-signs")
        XCTAssertEqual(result.score, 7.5)
        XCTAssertEqual(result.correctAnswers, 8)
        XCTAssertNotNil(result.id)
        XCTAssertNotNil(result.date)
    }
    
    func testQuizResultInitialization_ScoreClamping() {
        let belowMin = QuizResult(categoryId: "test", categoryName: "Test", score: -5, questionCount: 1, correctAnswers: 0)
        let aboveMax = QuizResult(categoryId: "test", categoryName: "Test", score: 15, questionCount: 1, correctAnswers: 1)
        
        XCTAssertEqual(belowMin.score, 0)
        XCTAssertEqual(aboveMax.score, 10)
    }
    
    func testQuizResultInitialization_CorrectAnswersValidation() {
        let result = QuizResult(categoryId: "test", categoryName: "Test", score: 5, questionCount: 10, correctAnswers: 20)
        
        XCTAssertEqual(result.correctAnswers, 10) // Clamped to questionCount
    }
    
    func testQuizResultInitialization_QuestionCountMinimum() {
        let result = QuizResult(categoryId: "test", categoryName: "Test", score: 5, questionCount: 0, correctAnswers: 0)
        
        XCTAssertEqual(result.questionCount, 1) // Minimum is 1
    }
    
    // MARK: - Codable Tests
    
    func testQuizResultCodable_JSONEncoding() throws {
        let original = QuizResult(
            id: UUID(uuidString: "12345678-1234-1234-1234-123456789012")!,
            categoryId: "signs",
            categoryName: "Zeichen",
            score: 8.5,
            date: Date(timeIntervalSince1970: 0),
            questionCount: 10,
            correctAnswers: 9
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(QuizResult.self, from: data)
        
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.score, original.score)
        XCTAssertEqual(decoded.categoryId, original.categoryId)
    }
    
    // MARK: - Equatable Tests
    
    func testQuizResultEquality() {
        let id = UUID()
        let date = Date()
        
        let result1 = QuizResult(id: id, categoryId: "test", categoryName: "Test", score: 7, date: date, questionCount: 10, correctAnswers: 7)
        let result2 = QuizResult(id: id, categoryId: "test", categoryName: "Test", score: 7, date: date, questionCount: 10, correctAnswers: 7)
        let result3 = QuizResult(id: UUID(), categoryId: "test", categoryName: "Test", score: 7, date: date, questionCount: 10, correctAnswers: 7)
        
        XCTAssertEqual(result1, result2)
        XCTAssertNotEqual(result1, result3)
    }
}