import XCTest
@testable import DriveAI

class CategoryReadinessTests: XCTestCase {
    
    // MARK: - Initialization & Percentage Calculation
    
    func test_init_calculatesPercentageCorrectly() {
        let readiness = CategoryReadiness(
            categoryId: "signs",
            categoryName: "Traffic Signs",
            correctAnswers: 7,
            totalQuestions: 10
        )
        
        XCTAssertEqual(readiness.percentage, 70)
        XCTAssertEqual(readiness.level, .intermediate)
    }
    
    func test_init_handlesZeroQuestions() {
        let readiness = CategoryReadiness(
            categoryId: "signs",
            categoryName: "Traffic Signs",
            correctAnswers: 0,
            totalQuestions: 0
        )
        
        XCTAssertEqual(readiness.percentage, 0)
        XCTAssertEqual(readiness.level, .beginner)
    }
    
    func test_init_handlesAllCorrect() {
        let readiness = CategoryReadiness(
            categoryId: "signs",
            categoryName: "Traffic Signs",
            correctAnswers: 50,
            totalQuestions: 50
        )
        
        XCTAssertEqual(readiness.percentage, 100)
        XCTAssertEqual(readiness.level, .expert)
    }
    
    // MARK: - Computed Properties
    
    func test_displayPercentage_formattsCorrectly() {
        let readiness = CategoryReadiness(
            categoryId: "test",
            categoryName: "Test",
            correctAnswers: 3,
            totalQuestions: 4
        )
        
        XCTAssertEqual(readiness.displayPercentage, "75%")
    }
    
    func test_estimatedWeakness_calculatesCorrectly() {
        let readiness = CategoryReadiness(
            categoryId: "test",
            categoryName: "Test",
            correctAnswers: 6,
            totalQuestions: 10  // 60% → 0.4 weakness
        )
        
        XCTAssertEqual(readiness.estimatedWeakness, 0.4, accuracy: 0.01)
    }
    
    // MARK: - Edge Cases
    
    func test_init_roundsPercentageDown() {
        let readiness = CategoryReadiness(
            categoryId: "test",
            categoryName: "Test",
            correctAnswers: 1,
            totalQuestions: 3  // 33.333...%
        )
        
        XCTAssertEqual(readiness.percentage, 33)  // Rounded down (integer division)
    }
    
    // MARK: - Identifiable
    
    func test_id_equalsCategoyId() {
        let readiness = CategoryReadiness(
            categoryId: "unique_id",
            categoryName: "Test",
            correctAnswers: 5,
            totalQuestions: 10
        )
        
        XCTAssertEqual(readiness.id, "unique_id")
    }
}