class UserTests: XCTestCase {
    
    func test_user_empty_factory() {
        // Act
        let user = User.empty()
        
        // Assert
        XCTAssertNotNil(user.id)
        XCTAssertNil(user.examDate)
        XCTAssertEqual(user.overallScore, 0)
        XCTAssertEqual(user.currentStreak, 0)
        XCTAssertTrue(user.categoryProgress.isEmpty)
    }
    
    func test_user_with_examDate() {
        // Arrange
        let examDate = Calendar.current.date(byAdding: .month, value: 2, to: Date())!
        
        // Act
        var user = User.empty()
        user.examDate = examDate
        
        // Assert
        XCTAssertEqual(user.examDate, examDate)
    }
    
    func test_user_categoryProgress_update() {
        // Arrange
        var user = User.empty()
        let progress = CategoryProgress(
            categoryId: "traffic_signs",
            questionsAnswered: 10,
            correctAnswers: 8
        )
        
        // Act
        user.categoryProgress["traffic_signs"] = progress
        
        // Assert
        XCTAssertEqual(user.categoryProgress["traffic_signs"]?.percentageCorrect, 80.0)
    }
    
    func test_user_categoryProgress_empty_percentage() {
        // Arrange
        let progress = CategoryProgress(
            categoryId: "test",
            questionsAnswered: 0,
            correctAnswers: 0
        )
        
        // Assert
        XCTAssertEqual(progress.percentageCorrect, 0)
    }
}