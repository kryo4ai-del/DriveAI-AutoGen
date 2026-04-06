// Tests/Models/CategoryProgressTests.swift

final class CategoryProgressTests: XCTestCase {
    
    // HAPPY PATH
    func testBeginnerMastery() {
        let progress = CategoryProgress(
            id: "signs",
            categoryName: "Verkehrszeichen",
            totalQuestionsAnswered: 10,
            correctCount: 4  // 40%
        )
        
        XCTAssertEqual(progress.accuracy, 0.4)
        XCTAssertEqual(progress.masteryLevel, .beginner)
    }
    
    func testIntermediateMastery() {
        let progress = CategoryProgress(
            id: "signs",
            categoryName: "Verkehrszeichen",
            totalQuestionsAnswered: 20,
            correctCount: 14  // 70%
        )
        
        XCTAssertEqual(progress.accuracy, 0.7)
        XCTAssertEqual(progress.masteryLevel, .intermediate)
    }
    
    func testAdvancedMastery() {
        let progress = CategoryProgress(
            id: "signs",
            categoryName: "Verkehrszeichen",
            totalQuestionsAnswered: 20,
            correctCount: 18  // 90%
        )
        
        XCTAssertEqual(progress.accuracy, 0.9)
        XCTAssertEqual(progress.masteryLevel, .advanced)
    }
    
    func testExpertMastery() {
        let progress = CategoryProgress(
            id: "signs",
            categoryName: "Verkehrszeichen",
            totalQuestionsAnswered: 50,
            correctCount: 50  // 100%
        )
        
        XCTAssertEqual(progress.accuracy, 1.0)
        XCTAssertEqual(progress.masteryLevel, .expert)
    }
    
    // EDGE CASES
    func testZeroQuestionsAnswered() {
        let progress = CategoryProgress(
            id: "signs",
            categoryName: "Verkehrszeichen",
            totalQuestionsAnswered: 0,
            correctCount: 0
        )
        
        XCTAssertEqual(progress.accuracy, 0.0)
        XCTAssertEqual(progress.masteryLevel, .beginner)
    }
    
    func testSingleQuestionCorrect() {
        let progress = CategoryProgress(
            id: "signs",
            categoryName: "Verkehrszeichen",
            totalQuestionsAnswered: 1,
            correctCount: 1  // 100%
        )
        
        XCTAssertEqual(progress.accuracy, 1.0)
        XCTAssertEqual(progress.masteryLevel, .expert)
    }
    
    func testSingleQuestionIncorrect() {
        let progress = CategoryProgress(
            id: "signs",
            categoryName: "Verkehrszeichen",
            totalQuestionsAnswered: 1,
            correctCount: 0  // 0%
        )
        
        XCTAssertEqual(progress.accuracy, 0.0)
        XCTAssertEqual(progress.masteryLevel, .beginner)
    }
    
    // INVALID INPUTS
    func testMoreCorrectThanTotal() {
        XCTAssertThrowsError(
            try {
                let _ = CategoryProgress(
                    id: "signs",
                    categoryName: "Verkehrszeichen",
                    totalQuestionsAnswered: 5,
                    correctCount: 10  // Invalid: more correct than total
                )
            }()
        )
    }
    
    func testNegativeTotal() {
        XCTAssertThrowsError(
            try {
                let _ = CategoryProgress(
                    id: "signs",
                    categoryName: "Verkehrszeichen",
                    totalQuestionsAnswered: -5,
                    correctCount: 0
                )
            }()
        )
    }
    
    func testEmptyCategoryID() {
        XCTAssertThrowsError(
            try {
                let _ = CategoryProgress(
                    id: "",
                    categoryName: "Verkehrszeichen",
                    totalQuestionsAnswered: 10,
                    correctCount: 5
                )
            }()
        )
    }
    
    // BUILDER METHOD
    func testUpdateProgress() {
        var progress = CategoryProgress(
            id: "signs",
            categoryName: "Verkehrszeichen",
            totalQuestionsAnswered: 10,
            correctCount: 5
        )
        
        let originalTimestamp = progress.lastUpdated
        
        // Simulate a small delay to ensure timestamp changes
        Thread.sleep(forTimeInterval: 0.01)
        
        progress = progress.withUpdated(totalAnswered: 11, correctCount: 6)
        
        XCTAssertEqual(progress.totalQuestionsAnswered, 11)
        XCTAssertEqual(progress.correctCount, 6)
        XCTAssertGreaterThan(progress.lastUpdated, originalTimestamp)
    }
}