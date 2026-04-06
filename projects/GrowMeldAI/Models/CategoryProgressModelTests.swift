import XCTest
@testable import DriveAI

class CategoryProgressModelTests: XCTestCase {
    
    func testCategoryProgressInitialization() {
        let progress = CategoryProgress(
            categoryId: "signs",
            categoryName: "Verkehrszeichen"
        )
        
        XCTAssertEqual(progress.categoryId, "signs")
        XCTAssertEqual(progress.categoryName, "Verkehrszeichen")
        XCTAssertEqual(progress.questionsAttempted, 0)
        XCTAssertEqual(progress.correctAnswers, 0)
    }
    
    func testMasteryPercentageWhenNoQuestionsAttempted() {
        let progress = CategoryProgress(
            categoryId: "signs",
            categoryName: "Verkehrszeichen"
        )
        
        XCTAssertEqual(progress.masteryPercentage, 0)
    }
    
    func testMasteryPercentageCalculation() {
        var progress = CategoryProgress(
            categoryId: "signs",
            categoryName: "Verkehrszeichen"
        )
        progress.questionsAttempted = 10
        progress.correctAnswers = 7
        
        XCTAssertEqual(progress.masteryPercentage, 70.0)
    }
    
    func testMasteryPercentageRounding() {
        var progress = CategoryProgress(
            categoryId: "signs",
            categoryName: "Verkehrszeichen"
        )
        progress.questionsAttempted = 3
        progress.correctAnswers = 1  // 33.333...%
        
        XCTAssertEqual(progress.masteryPercentage, 33.333333333, accuracy: 0.001)
    }
    
    func testCorrectAnswersCannotExceedAttempts() {
        var progress = CategoryProgress(
            categoryId: "signs",
            categoryName: "Verkehrszeichen"
        )
        progress.questionsAttempted = 5
        progress.correctAnswers = 10  // Invalid: more correct than attempted
        
        // Validation should cap it
        XCTAssertLessThanOrEqual(progress.correctAnswers, progress.questionsAttempted)
    }
    
    func testLastAttemptDateTracking() {
        var progress = CategoryProgress(
            categoryId: "signs",
            categoryName: "Verkehrszeichen"
        )
        let testDate = Date()
        
        progress.lastAttemptDate = testDate
        
        XCTAssertEqual(progress.lastAttemptDate, testDate)
    }
    
    func testProgressEquality() {
        let progress1 = CategoryProgress(categoryId: "signs", categoryName: "Verkehrszeichen")
        let progress2 = CategoryProgress(categoryId: "signs", categoryName: "Verkehrszeichen")
        
        XCTAssertEqual(progress1, progress2)
    }
}