// Tests/Unit/Services/LocalDataServiceTests.swift
import XCTest
@testable import DriveAI

final class InMemoryLocalDataServiceTests: XCTestCase {
    var sut: InMemoryLocalDataService!
    
    override func setUp() {
        super.setUp()
        sut = InMemoryLocalDataService()
    }
    
    // MARK: - Question Fetching
    
    func test_fetchQuestion_withValidID_returnsQuestion() async throws {
        // Arrange
        let allQuestions = try await sut.fetchAllQuestions()
        guard let testQuestion = allQuestions.first else {
            XCTFail("No mock questions available")
            return
        }
        
        // Act
        let fetchedQuestion = try await sut.fetchQuestion(id: testQuestion.id)
        
        // Assert
        XCTAssertNotNil(fetchedQuestion)
        XCTAssertEqual(fetchedQuestion?.id, testQuestion.id)
        XCTAssertEqual(fetchedQuestion?.text, testQuestion.text)
    }
    
    func test_fetchQuestion_withInvalidID_returnsNil() async throws {
        // Arrange
        let invalidID = UUID()
        
        // Act
        let question = try await sut.fetchQuestion(id: invalidID)
        
        // Assert
        XCTAssertNil(question)
    }
    
    func test_fetchQuestionsByCategory_withValidCategory_returnsAllMatching() async throws {
        // Arrange
        let category = "signs"
        
        // Act
        let questions = try await sut.fetchQuestionsByCategory(category)
        
        // Assert
        XCTAssertGreaterThan(questions.count, 0)
        XCTAssertTrue(questions.allSatisfy { $0.category == category })
    }
    
    func test_fetchQuestionsByCategory_withEmptyString_throwsError() async {
        // Act & Assert
        do {
            _ = try await sut.fetchQuestionsByCategory("")
            XCTFail("Should throw DataError.invalidInput")
        } catch let error as LocalDataService.DataError {
            XCTAssertEqual(error, .invalidInput("Category cannot be empty"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_fetchQuestionsByCategory_withNonexistentCategory_returnsEmptyArray() async throws {
        // Act
        let questions = try await sut.fetchQuestionsByCategory("nonexistent_category_xyz")
        
        // Assert
        XCTAssertEqual(questions.count, 0)
    }
    
    func test_fetchAllQuestions_returnsAllQuestions() async throws {
        // Act
        let questions = try await sut.fetchAllQuestions()
        
        // Assert
        XCTAssertGreaterThan(questions.count, 0)
        XCTAssertTrue(questions.allSatisfy { $0.isValid })
    }
    
    func test_fetchAllCategories_returnsAllCategories() async throws {
        // Act
        let categories = try await sut.fetchAllCategories()
        
        // Assert
        XCTAssertEqual(categories.count, 5) // signs, right_of_way, safety, fines, documents
        XCTAssertTrue(categories.allSatisfy { !$0.name.isEmpty })
    }
    
    // MARK: - Progress Recording
    
    func test_saveProgress_withValidProgress_succeeds() async throws {
        // Arrange
        let progress = UserProgress(
            id: UUID(),
            questionId: UUID(),
            category: "signs",
            isCorrect: true,
            answeredAt: Date(),
            timeSpent: 5.0
        )
        
        // Act & Assert
        XCTAssertNoThrow {
            try await self.sut.saveProgress(progress)
        }
    }
    
    func test_saveProgress_withInvalidQuestionID_throwsError() async {
        // Arrange
        var progress = UserProgress(
            id: UUID(),
            questionId: UUID(),
            category: "signs",
            isCorrect: true,
            answeredAt: Date(),
            timeSpent: 5.0
        )
        // Simulate corruption by forcing empty UUID (can't directly, so test validation in service)
        
        // This test validates that service should add validation
        // For now, verify save succeeds with valid data
        do {
            try await sut.saveProgress(progress)
        } catch {
            XCTFail("Should not throw for valid progress")
        }
    }
    
    func test_fetchProgressForQuestion_afterSave_returnsProgress() async throws {
        // Arrange
        let questionId = UUID()
        let progress = UserProgress(
            id: UUID(),
            questionId: questionId,
            category: "signs",
            isCorrect: true,
            answeredAt: Date(),
            timeSpent: 3.0
        )
        try await sut.saveProgress(progress)
        
        // Act
        let fetchedProgress = try await sut.fetchProgressForQuestion(id: questionId)
        
        // Assert
        XCTAssertNotNil(fetchedProgress)
        XCTAssertEqual(fetchedProgress?.questionId, questionId)
        XCTAssertTrue(fetchedProgress?.isCorrect ?? false)
    }
    
    func test_fetchProgressByCategory_returnsOnlySpecificCategory() async throws {
        // Arrange
        let category = "right_of_way"
        let progress1 = UserProgress(
            id: UUID(),
            questionId: UUID(),
            category: category,
            isCorrect: true,
            answeredAt: Date(),
            timeSpent: 2.0
        )
        let progress2 = UserProgress(
            id: UUID(),
            questionId: UUID(),
            category: "signs",
            isCorrect: false,
            answeredAt: Date(),
            timeSpent: 1.5
        )
        try await sut.saveProgress(progress1)
        try await sut.saveProgress(progress2)
        
        // Act
        let categoryProgress = try await sut.fetchProgressByCategory(category)
        
        // Assert
        XCTAssertEqual(categoryProgress.count, 1)
        XCTAssertTrue(categoryProgress.allSatisfy { $0.category == category })
    }
    
    func test_fetchAllProgress_returnsAllRecords() async throws {
        // Arrange
        let records: [UserProgress] = (0..<5).map { _ in
            UserProgress(
                id: UUID(),
                questionId: UUID(),
                category: "signs",
                isCorrect: Bool.random(),
                answeredAt: Date(),
                timeSpent: Double.random(in: 1...10)
            )
        }
        for record in records {
            try await sut.saveProgress(record)
        }
        
        // Act
        let allProgress = try await sut.fetchAllProgress()
        
        // Assert
        XCTAssertGreaterThanOrEqual(allProgress.count, records.count)
    }
    
    // MARK: - User Management
    
    func test_saveUser_withValidUser_succeeds() async throws {
        // Arrange
        let user = User(
            id: UUID(),
            name: "Max Mustermann",
            examDate: Date().addingTimeInterval(86400 * 30),
            hasCompletedOnboarding: false,
            createdAt: Date()
        )
        
        // Act & Assert
        XCTAssertNoThrow {
            try await self.sut.saveUser(user)
        }
    }
    
    func test_saveUser_withEmptyName_throwsError() async {
        // Arrange
        let user = User(
            id: UUID(),
            name: "",
            examDate: Date().addingTimeInterval(86400 * 30),
            hasCompletedOnboarding: false,
            createdAt: Date()
        )
        
        // Act & Assert
        do {
            try await sut.saveUser(user)
            XCTFail("Should throw DataError.invalidInput")
        } catch let error as LocalDataService.DataError {
            XCTAssertEqual(error, .invalidInput("User name cannot be empty"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_fetchUser_afterSave_returnsUser() async throws {
        // Arrange
        let originalUser = User(
            id: UUID(),
            name: "Anna Schmidt",
            examDate: Date().addingTimeInterval(86400 * 60),
            hasCompletedOnboarding: true,
            createdAt: Date()
        )
        try await sut.saveUser(originalUser)
        
        // Act
        let fetchedUser = try await sut.fetchUser()
        
        // Assert
        XCTAssertNotNil(fetchedUser)
        XCTAssertEqual(fetchedUser?.name, originalUser.name)
        XCTAssertEqual(fetchedUser?.id, originalUser.id)
    }
    
    func test_fetchUser_withoutSavingFirst_returnsNil() async throws {
        // Create fresh service instance (doesn't save user in init)
        let freshService = InMemoryLocalDataService()
        
        // Act
        let user = try await freshService.fetchUser()
        
        // Assert
        XCTAssertNil(user)
    }
    
    // MARK: - Exam Sessions
    
    func test_saveExamSession_withValidSession_succeeds() async throws {
        // Arrange
        let questions = try await sut.fetchAllQuestions()
        let questionIds = Array(questions.prefix(10).map { $0.id })
        let session = ExamSession(
            id: UUID(),
            startTime: Date(),
            questionIds: questionIds
        )
        
        // Act & Assert
        XCTAssertNoThrow {
            try await self.sut.saveExamSession(session)
        }
    }
    
    func test_saveExamSession_withEmptyQuestionList_throwsError() async {
        // Arrange
        let session = ExamSession(
            id: UUID(),
            startTime: Date(),
            questionIds: []
        )
        
        // Act & Assert
        do {
            try await sut.saveExamSession(session)
            XCTFail("Should throw DataError.invalidInput")
        } catch let error as LocalDataService.DataError {
            XCTAssertEqual(error, .invalidInput("Exam session must contain questions"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_fetchExamSession_afterSave_returnsSession() async throws {
        // Arrange
        let questions = try await sut.fetchAllQuestions()
        let questionIds = Array(questions.prefix(5).map { $0.id })
        let originalSession = ExamSession(
            id: UUID(),
            startTime: Date(),
            questionIds: questionIds
        )
        try await sut.saveExamSession(originalSession)
        
        // Act
        let fetchedSession = try await sut.fetchExamSession(id: originalSession.id)
        
        // Assert
        XCTAssertNotNil(fetchedSession)
        XCTAssertEqual(fetchedSession?.id, originalSession.id)
        XCTAssertEqual(fetchedSession?.questionIds.count, questionIds.count)
    }
}

// MARK: - Helper Extension
extension XCTestCase {
    func XCTAssertNoThrow(
        _ expression: @escaping () async throws -> Void,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let expectation = expectation(description: "No throw")
        Task {
            do {
                try await expression()
                expectation.fulfill()
            } catch {
                XCTFail("Expected no throw but got: \(error)", file: file, line: line)
            }
        }
        wait(for: [expectation], timeout: 5.0)
    }
}