// Tests/Unit/Services/UserProgressServiceTests.swift
import XCTest
@testable import DriveAI

class UserProgressServiceTests: XCTestCase {
    var sut: UserProgressService!
    
    override func setUp() {
        super.setUp()
        // Clear UserDefaults before each test
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier ?? "")
        UserDefaults.standard.synchronize()
        
        sut = UserProgressService()
    }
    
    override func tearDown() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier ?? "")
        UserDefaults.standard.synchronize()
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func test_init_createsNewUserIdIfNotExists() {
        // Act
        let userId = sut.userProgress.userId
        
        // Assert
        XCTAssertFalse(userId.isEmpty)
    }
    
    func test_init_loadsExistingProgressFromUserDefaults() {
        // Arrange
        let firstService = UserProgressService()
        firstService.updateExamDate(Date().addingTimeInterval(86400 * 30))
        let userId = firstService.userProgress.userId
        
        // Act
        let secondService = UserProgressService()
        
        // Assert
        XCTAssertEqual(secondService.userProgress.userId, userId)
        XCTAssertNotNil(secondService.userProgress.examDate)
    }
    
    // MARK: - recordAnswer() Tests
    
    func test_recordAnswer_withCorrectAnswer_incrementsCorrectCount() {
        // Arrange
        let categoryId = "test_category"
        let initialCorrect = sut.userProgress.categoryProgress[categoryId]?.correctAnswers ?? 0
        
        // Act
        sut.recordAnswer(categoryId: categoryId, isCorrect: true)
        
        // Assert
        let updatedCorrect = sut.userProgress.categoryProgress[categoryId]?.correctAnswers ?? 0
        XCTAssertEqual(updatedCorrect, initialCorrect + 1)
    }
    
    func test_recordAnswer_withIncorrectAnswer_incrementsOnlyAnsweredCount() {
        // Arrange
        let categoryId = "test_category"
        let initialAnswered = sut.userProgress.categoryProgress[categoryId]?.questionsAnswered ?? 0
        let initialCorrect = sut.userProgress.categoryProgress[categoryId]?.correctAnswers ?? 0
        
        // Act
        sut.recordAnswer(categoryId: categoryId, isCorrect: false)
        
        // Assert
        let updatedAnswered = sut.userProgress.categoryProgress[categoryId]?.questionsAnswered ?? 0
        let updatedCorrect = sut.userProgress.categoryProgress[categoryId]?.correctAnswers ?? 0
        XCTAssertEqual(updatedAnswered, initialAnswered + 1)
        XCTAssertEqual(updatedCorrect, initialCorrect)
    }
    
    func test_recordAnswer_updatesLastAnsweredDate() {
        // Arrange
        let categoryId = "test_category"
        let beforeDate = Date()
        
        // Act
        sut.recordAnswer(categoryId: categoryId, isCorrect: true)
        
        // Assert
        let afterDate = Date()
        if let lastAnsweredDate = sut.userProgress.categoryProgress[categoryId]?.lastAnsweredDate {
            XCTAssertGreaterThanOrEqual(lastAnsweredDate, beforeDate)
            XCTAssertLessThanOrEqual(lastAnsweredDate, afterDate)
        } else {
            XCTFail("lastAnsweredDate not set")
        }
    }
    
    func test_recordAnswer_persistsToUserDefaults() {
        // Arrange
        let categoryId = "test_category"
        
        // Act
        sut.recordAnswer(categoryId: categoryId, isCorrect: true)
        let newService = UserProgressService()
        
        // Assert
        let savedProgress = newService.userProgress.categoryProgress[categoryId]
        XCTAssertNotNil(savedProgress)
        XCTAssertEqual(savedProgress?.questionsAnswered, 1)
        XCTAssertEqual(savedProgress?.correctAnswers, 1)
    }
    
    // MARK: - updateExamDate() Tests
    
    func test_updateExamDate_setsExamDate() {
        // Arrange
        let targetDate = Date().addingTimeInterval(86400 * 45)
        
        // Act
        sut.updateExamDate(targetDate)
        
        // Assert
        XCTAssertNotNil(sut.userProgress.examDate)
        let calendar = Calendar.current
        XCTAssertTrue(
            calendar.isDate(sut.userProgress.examDate!, inSameDayAs: targetDate),
            "Exam date should be set to target date"
        )
    }
    
    func test_updateExamDate_persistsToUserDefaults() {
        // Arrange
        let targetDate = Date().addingTimeInterval(86400 * 30)
        
        // Act
        sut.updateExamDate(targetDate)
        let newService = UserProgressService()
        
        // Assert
        XCTAssertNotNil(newService.userProgress.examDate)
    }
    
    // MARK: - resetProgress() Tests
    
    func test_resetProgress_clearsAllAnswers() {
        // Arrange
        sut.recordAnswer(categoryId: "cat1", isCorrect: true)
        sut.recordAnswer(categoryId: "cat2", isCorrect: false)
        
        // Act
        sut.resetProgress()
        
        // Assert
        XCTAssertEqual(sut.userProgress.categoryProgress.count, 0)
        XCTAssertEqual(sut.userProgress.totalQuestionsAnswered, 0)
    }
    
    func test_resetProgress_preservesUserId() {
        // Arrange
        let originalUserId = sut.userProgress.userId
        sut.recordAnswer(categoryId: "cat1", isCorrect: true)
        
        // Act
        sut.resetProgress()
        
        // Assert
        XCTAssertEqual(sut.userProgress.userId, originalUserId)
    }
    
    // MARK: - Computed Properties Tests
    
    func test_userProgress_totalQuestionsAnswered_calculatesCorrectly() {
        // Arrange
        sut.recordAnswer(categoryId: "cat1", isCorrect: true)
        sut.recordAnswer(categoryId: "cat1", isCorrect: false)
        sut.recordAnswer(categoryId: "cat2", isCorrect: true)
        
        // Act & Assert
        XCTAssertEqual(sut.userProgress.totalQuestionsAnswered, 3)
    }
    
    func test_userProgress_totalCorrectAnswers_calculatesCorrectly() {
        // Arrange
        sut.recordAnswer(categoryId: "cat1", isCorrect: true)
        sut.recordAnswer(categoryId: "cat1", isCorrect: false)
        sut.recordAnswer(categoryId: "cat2", isCorrect: true)
        
        // Act & Assert
        XCTAssertEqual(sut.userProgress.totalCorrectAnswers, 2)
    }
    
    func test_userProgress_overallPercentage_calculatesCorrectly() {
        // Arrange
        sut.recordAnswer(categoryId: "cat1", isCorrect: true)
        sut.recordAnswer(categoryId: "cat1", isCorrect: true)
        sut.recordAnswer(categoryId: "cat1", isCorrect: false)
        sut.recordAnswer(categoryId: "cat1", isCorrect: false)
        
        // Act
        let percentage = sut.userProgress.overallPercentage
        
        // Assert
        XCTAssertEqual(percentage, 50.0)
    }
    
    func test_userProgress_daysUntilExam_calculatesCorrectly() {
        // Arrange
        let examDate = Date().addingTimeInterval(86400 * 7)  // 7 days from now
        
        // Act
        sut.updateExamDate(examDate)
        let daysUntil = sut.userProgress.daysUntilExam
        
        // Assert
        XCTAssertEqual(daysUntil, 7)
    }
}